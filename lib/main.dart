import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/bootstrap.dart';
import 'data/capture/audio_recorder.dart';
import 'data/capture/speech_recognizer.dart';
import 'data/visit_repository.dart';
import 'domain/model/ids.dart';
import 'domain/model/visit_draft.dart';
import 'features/besuch/ui/capture_screen.dart';
import 'features/besuch/ui/capture_view_model.dart';
import 'features/besuch/ui/card_entry_screen.dart';
import 'features/besuch/ui/card_entry_view_model.dart';
import 'features/besuch/ui/confirmation_screen.dart';
import 'features/besuch/ui/confirmation_view_model.dart';
import 'features/besuch/ui/field_presentation.dart';
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
              Icon(Icons.lock_outline, size: 48, color: theme.colorScheme.error),
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

/// The phases of a visit, in the order the nurse works through them.
///
/// Phase A is the recording at the open dressing; phase B is the check once
/// the hands are free; the card mode is the equal path without speech. A
/// fixed sequence rather than free navigation, and the entry point comes from
/// the record: an unfinished visit is resumed, not started over.
class VisitCorridor extends StatefulWidget {
  const VisitCorridor({required this.dependencies, super.key});

  final AppDependencies dependencies;

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
    final visit = await _visits.openDraft(wound) ?? await _visits.startVisit(wound);
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

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConfirmationScreen(
          viewModel: ConfirmationViewModel(
            expectedSlots: FieldPresentation.woundBedSlots,
            result: state.result,
          ),
          onAccept: () {
            unawaited(_acceptProposals(visit, state));
            Navigator.of(context).pop();
          },
        ),
      ),
    );

    if (mounted) _capture.reset();
  }

  Future<void> _acceptProposals(VisitId visit, CaptureDone state) async {
    var draft = _draft;
    for (final proposal in state.result.proposals) {
      final value = VisitValue.fromProposal(proposal);
      draft = draft.withValue(proposal.slotId, value);
      await _visits.saveValue(visit, proposal.slotId, value);
    }
    if (mounted) setState(() => _draft = draft);
  }

  @override
  Widget build(BuildContext context) => CaptureScreen(
    viewModel: _capture,
    onInterpreted: _openConfirmation,
    onUseCards: _visit == null ? null : _openCards,
  );
}
