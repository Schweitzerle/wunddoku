import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:printing/printing.dart';

import 'app/bootstrap.dart';
import 'data/capture/audio_recorder.dart';
import 'data/capture/speech_recognizer.dart';
import 'data/media/marking_burner.dart';
import 'data/media/media_store.dart';
import 'data/report/wound_report_document.dart';
import 'data/visit_repository.dart';
import 'domain/model/ids.dart';
import 'domain/model/image_marking.dart';
import 'domain/model/visit_draft.dart';
import 'domain/model/wound_history.dart';
import 'domain/report/report_content.dart';
import 'features/besuch/ui/capture_screen.dart';
import 'features/besuch/ui/capture_view_model.dart';
import 'features/besuch/ui/card_entry_screen.dart';
import 'features/besuch/ui/card_entry_view_model.dart';
import 'features/besuch/ui/closing_screen.dart';
import 'features/besuch/ui/closing_view_model.dart';
import 'features/besuch/ui/confirmation_screen.dart';
import 'features/besuch/ui/confirmation_view_model.dart';
import 'shared/text/field_presentation.dart';
import 'features/besuch/ui/marking_screen.dart';
import 'features/besuch/ui/photo_screen.dart';
import 'features/verlauf/ui/history_screen.dart';
import 'l10n/app_localizations.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(WunddokuApp(dependencies: bootstrap()));
}

/// The example file the development recorder hands back.
const _exampleAudio = 'befund_01.m4a';

/// A dictation from the example set.
///
/// Synthetic on purpose: no real patient data reaches development, tests or
/// screenshots (`datenschutz-art9.md`).
const _exampleTranscript =
    'Länge drei Komma fünf, Breite zwei, Tiefe fünfzig. '
    'Granulationsgewebe sechzig Prozent. Exsudat gering, serös.';

/// The application shell.
class WunddokuApp extends StatelessWidget {
  const WunddokuApp({required this.dependencies, super.key});

  /// Resolves once the encrypted database is open.
  final Future<AppDependencies> dependencies;

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    debugShowCheckedModeBanner: false,
    home: FutureBuilder<AppDependencies>(
      future: dependencies,
      builder: (context, snapshot) => switch (snapshot) {
        AsyncSnapshot(hasError: true, :final error?) => _StartupFailed(
          error: error,
        ),
        AsyncSnapshot(:final data?) => VisitCorridor(dependencies: data),
        _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
      },
    ),
  );
}

/// Shown when the database could not be opened.
///
/// Deliberately a dead end: the encryption self-test refusing is the one
/// failure that must not be worked around, because carrying on would mean
/// storing health data unprotected.
class _StartupFailed extends StatelessWidget {
  const _StartupFailed({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Die Wunddokumentation lässt sich nicht öffnen.',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Wende dich an die IT. Bis dahin bitte auf Papier '
                'dokumentieren.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws [marking] into a copy of [photo] and returns the encoded bytes.
Future<Uint8List> burnWithPainter(Uint8List photo, ImageMarking marking) async {
  final decoded = await decodeImageFromList(photo);
  try {
    return await MarkingBurner.burn(decoded, marking);
  } finally {
    decoded.dispose();
  }
}

/// What the closing screen sent back.
class _ClosingResult {
  const _ClosingResult.finished({required this.withGaps}) : fillGap = false;
  const _ClosingResult.fillGap() : fillGap = true, withGaps = false;

  /// Whether the nurse went back to fill a named gap instead of closing.
  final bool fillGap;

  /// Whether the visit was closed with gaps left in it on purpose.
  final bool withGaps;
}

/// The phases of a visit, in the order the nurse works through them.
///
/// Phase A is the recording at the open dressing; phase B is the check once
/// the hands are free; the card mode is the equal path without speech. A
/// fixed sequence rather than free navigation, and the entry point comes from
/// the record: an unfinished visit is resumed, not started over.
class VisitCorridor extends StatefulWidget {
  const VisitCorridor({
    required this.dependencies,
    this.burn = burnWithPainter,
    super.key,
  });

  final AppDependencies dependencies;

  /// Turns a photo and an outline into the marked copy.
  ///
  /// A seam rather than a direct call: decoding and re-encoding a picture is
  /// real asynchronous work, which never completes inside a widget test's
  /// fake async zone. The drawing itself is covered against real images in
  /// `test/domain/image_marking_test.dart`.
  final Future<Uint8List> Function(Uint8List photo, ImageMarking marking) burn;

  @override
  State<VisitCorridor> createState() => _VisitCorridorState();
}

class _VisitCorridorState extends State<VisitCorridor> {
  late final CaptureViewModel _capture;

  VisitRepository get _visits => widget.dependencies.visits;

  VisitId? _visit;
  VisitDraft _draft = const VisitDraft();

  @override
  void initState() {
    super.initState();
    _capture = CaptureViewModel(
      recorder: FakeAudioRecorder(
        exampleFile: File('${Directory.systemTemp.path}/$_exampleAudio'),
      ),
      recognizer: const CannedSpeechRecognizer({
        _exampleAudio: _exampleTranscript,
      }),
    );
    unawaited(_resumeOrStart());
  }

  @override
  void dispose() {
    _capture.dispose();
    super.dispose();
  }

  /// Picks up the unfinished visit, or starts a new one.
  ///
  /// This is what makes an interruption survivable: the re-entry point is the
  /// record, not the navigation stack.
  Future<void> _resumeOrStart() async {
    final wound = widget.dependencies.demoWound;
    final visit =
        await _visits.openDraft(wound) ?? await _visits.startVisit(wound);
    final draft = await _visits.loadDraft(visit);
    if (!mounted) return;
    setState(() {
      _visit = visit;
      _draft = draft;
    });
  }

  Future<void> _openCards() async {
    final visit = _visit;
    if (visit == null) return;

    final entry = CardEntryViewModel(
      draft: _draft,
      repository: _visits,
      visit: visit,
    );
    final result = await Navigator.of(context).push<VisitDraft>(
      MaterialPageRoute<VisitDraft>(
        builder: (_) => CardEntryScreen(
          viewModel: entry,
          onDone: (draft) => Navigator.of(context).pop(draft),
        ),
      ),
    );
    entry.dispose();

    if (result != null && mounted) {
      setState(() => _draft = result);
      _capture.reset();
    }
  }

  Future<void> _openConfirmation() async {
    final state = _capture.state;
    final visit = _visit;
    if (state is! CaptureDone || visit == null) return;

    // The verbatim transcript belongs to the visit whether or not a single
    // value is accepted: it is the evidence the words were the nurse's own.
    unawaited(_visits.saveTranscript(visit, state.result.transcript));

    final review = ConfirmationViewModel(
      expectedSlots: FieldPresentation.woundBedSlots,
      result: state.result,
    );

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConfirmationScreen(
          viewModel: review,
          onAccept: () {
            unawaited(_acceptSettled(visit, review.settledEntries));
            Navigator.of(context).pop();
          },
        ),
      ),
    );
    review.dispose();

    if (mounted) _capture.reset();
  }

  /// Shows the visits recorded for this wound.
  ///
  /// Read before the dressing comes off: the course is what says whether the
  /// treatment works, and a single finding cannot.
  Future<void> _showHistory() async {
    final history = await _visits.historyOf(widget.dependencies.demoWound);
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HistoryScreen(
          history: history,
          loadPhoto: (ref) => _readQuietly(MediaRef(ref)),
          onCreateReport: () => _createReport(history),
        ),
      ),
    );
  }

  /// Produces the wound report and hands it to the system.
  ///
  /// Everything in it comes from the record. The report must not be a second
  /// formulation of the finding — that duplicated evening in the office is
  /// what the app exists to remove (`docs/ux/nachprozess.md`).
  Future<void> _createReport(WoundHistory history) async {
    final l10n = AppLocalizations.of(context)!;
    final wound = await widget.dependencies.patients.contextOfWound(
      widget.dependencies.demoWound,
    );
    if (wound == null || !mounted) return;

    final photos = <String, Uint8List>{};
    for (final entry in history.entries) {
      final ref = entry.markedPhotoRef ?? entry.photoRef;
      if (ref == null) continue;
      final bytes = await _readQuietly(MediaRef(ref));
      if (bytes != null) photos[ref] = bytes;
    }

    final content = ReportContent.fromHistory(
      history: history,
      expectedSlots: FieldPresentation.woundBedSlots,
      patientName: '${wound.patient.givenName} ${wound.patient.familyName}',
      birthDate: wound.patient.birthDate,
      woundLocation: wound.location,
      icd10Code: wound.icd10Code,
      createdAt: DateTime.now(),
    );

    final bytes = await WoundReportDocument.build(
      content: content,
      l10n: l10n,
      photos: photos,
    );
    if (!mounted) return;

    // Handing the file to the system is where the health data leaves the app.
    // The nurse decides who receives it; nothing is sent automatically.
    await Printing.sharePdf(bytes: bytes, filename: 'wundbericht.pdf');
  }

  /// Closes the visit, after showing what travels with it.
  ///
  /// The gaps are named here and never block: a nurse who cannot close leaves
  /// the flat with an open record, which is the evening in the office this app
  /// exists to remove. What the visit is *recorded* as does differ, and that
  /// distinction reaches the office.
  Future<void> _finishVisit() async {
    final visit = _visit;
    if (visit == null) return;

    final photos = await _visits.photosOf(visit);
    if (!mounted) return;

    final navigator = Navigator.of(context);
    final result = await navigator.push<_ClosingResult>(
      MaterialPageRoute<_ClosingResult>(
        builder: (_) => ClosingScreen(
          summary: ClosingSummary(
            draft: _draft,
            expectedSlots: FieldPresentation.woundBedSlots,
            photoCount: photos.length,
            markedPhotoCount: photos
                .where((photo) => photo.markedRef != null)
                .length,
          ),
          onFinish: (withGaps) =>
              navigator.pop(_ClosingResult.finished(withGaps: withGaps)),
          onFillGap: (_) => navigator.pop(const _ClosingResult.fillGap()),
          onBack: navigator.pop,
        ),
      ),
    );

    if (result == null || !mounted) return;
    if (result.fillGap) {
      await _openCards();
      return;
    }

    await _visits.completeVisit(visit, withGaps: result.withGaps);
    if (!mounted) return;

    // The next patient is the next visit: the corridor starts a fresh one
    // rather than leaving a closed record open on screen.
    setState(() => _draft = const VisitDraft());
    _capture.reset();
    await _resumeOrStart();
  }

  /// Photograph, mark, keep — the picture half of phase A.
  ///
  /// One corridor rather than three screens the nurse navigates between: at
  /// the open dressing there is no time to decide where to go next, and the
  /// photo is worthless once the new bandage is on.
  Future<void> _takePhoto() async {
    final visit = _visit;
    if (visit == null) return;

    final previous = await _visits.lastPhotoOfWound(
      widget.dependencies.demoWound,
      before: visit,
    );
    final previousBytes = previous == null
        ? null
        : await _readQuietly(previous.originalRef);
    if (!mounted) return;

    final navigator = Navigator.of(context);
    final taken = await navigator.push<Uint8List>(
      MaterialPageRoute<Uint8List>(
        builder: (_) => PhotoScreen(
          camera: widget.dependencies.camera(),
          previousPhoto: previousBytes == null
              ? null
              : MemoryImage(previousBytes),
          onTaken: navigator.pop,
          onSkipped: navigator.pop,
        ),
      ),
    );
    if (taken == null || !mounted) return;

    final marking = await navigator.push<ImageMarking>(
      MaterialPageRoute<ImageMarking>(
        builder: (_) => MarkingScreen(
          photo: MemoryImage(taken),
          previous: previous?.marking,
          onDone: navigator.pop,
        ),
      ),
    );

    await _keepPhoto(visit, taken, marking);
  }

  /// Writes the photo and, when one was drawn, the burnt-in copy.
  Future<void> _keepPhoto(
    VisitId visit,
    Uint8List original,
    ImageMarking? marking,
  ) async {
    final marked = marking == null
        ? null
        : await widget.burn(original, marking);

    await _visits.savePhoto(visit, original, marking: marking, marked: marked);
  }

  /// The bytes behind [ref], or null when the file no longer reads.
  ///
  /// A framing aid that cannot be loaded is a missing convenience, not a
  /// reason to refuse the photo the nurse is standing there to take.
  Future<Uint8List?> _readQuietly(MediaRef ref) async {
    try {
      return await _visits.photoBytes(ref);
    } on Exception {
      return null;
    }
  }

  /// Writes the values the nurse settled on, and only those.
  ///
  /// A discarded proposal is a gap, not a value: the example recording says
  /// "Tiefe fünfzig", and half a metre of wound depth reaching the office as a
  /// finding nobody made is the one failure this app must not have.
  Future<void> _acceptSettled(
    VisitId visit,
    List<ConfirmationEntry> settled,
  ) async {
    var draft = _draft;
    for (final entry in settled) {
      final value = VisitValue.fromProposal(entry.proposal!);
      draft = draft.withValue(entry.slotId, value);
      await _visits.saveValue(visit, entry.slotId, value);
    }
    if (mounted) setState(() => _draft = draft);
  }

  @override
  Widget build(BuildContext context) => CaptureScreen(
    viewModel: _capture,
    onInterpreted: _openConfirmation,
    onUseCards: _visit == null ? null : _openCards,
    onTakePhoto: _visit == null ? null : _takePhoto,
    onFinishVisit: _visit == null ? null : _finishVisit,
    onShowHistory: _visit == null ? null : _showHistory,
  );
}
