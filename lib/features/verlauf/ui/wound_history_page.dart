import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../app/bootstrap.dart';
import '../../../data/media/media_store.dart';
import '../../../data/report/wound_report_document.dart';
import '../../../domain/model/ids.dart';
import '../../../domain/model/wound_history.dart';
import '../../../domain/report/report_content.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/text/field_presentation.dart';
import 'history_screen.dart';
import 'visit_detail_screen.dart';

/// The course of one wound, loaded from the record.
///
/// Reachable from the wound itself as well as from inside a visit: what the
/// wound looked like a week ago is the comparison the nurse makes while the
/// dressing is off, and it is also the answer to a question asked from the
/// office with nobody standing at a bed.
class WoundHistoryPage extends StatefulWidget {
  const WoundHistoryPage({
    required this.dependencies,
    required this.wound,
    super.key,
  });

  final AppDependencies dependencies;
  final WoundId wound;

  @override
  State<WoundHistoryPage> createState() => _WoundHistoryPageState();
}

class _WoundHistoryPageState extends State<WoundHistoryPage> {
  WoundHistory? _history;
  String? _location;
  bool _creatingReport = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await widget.dependencies.visits.historyOf(widget.wound);
    final owner = await widget.dependencies.patients.contextOfWound(
      widget.wound,
    );
    if (!mounted) return;
    setState(() {
      _history = history;
      _location = owner?.location;
    });
  }

  /// Opens the full record of one visit, with the words it was spoken in.
  Future<void> _openVisit(HistoryEntry entry) async {
    final history = _history;
    if (history == null) return;
    final transcript = await widget.dependencies.visits.transcriptOf(
      entry.visit,
    );
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VisitDetailScreen(
          entry: entry,
          areaChange: history.areaChangeBefore(entry),
          expectedSlots: FieldPresentation.woundBedSlots,
          loadPhoto: (ref) => _readQuietly(MediaRef(ref)),
          transcript: transcript,
        ),
      ),
    );
  }

  /// The bytes behind [ref], or null when the file no longer reads.
  ///
  /// A thumbnail that cannot be loaded costs its picture and nothing else.
  Future<Uint8List?> _readQuietly(MediaRef ref) async {
    try {
      return await widget.dependencies.visits.photoBytes(ref);
    } on Exception {
      return null;
    }
  }

  /// Produces the wound report and hands it to the system.
  ///
  /// Everything in it comes from the record. The report must not be a second
  /// formulation of the finding — that duplicated evening in the office is
  /// what the app exists to remove (`docs/ux/nachprozess.md`).
  Future<void> _createReport(WoundHistory history) async {
    if (_creatingReport) return;
    setState(() => _creatingReport = true);
    try {
      await _buildAndShare(history);
    } on Exception {
      // What went wrong belongs in the log, not on the screen
      // (`30-sicherheit.md`). What the nurse needs is that it did not
      // happen and that trying again is allowed.
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reportFailed)));
    } finally {
      if (mounted) setState(() => _creatingReport = false);
    }
  }

  Future<void> _buildAndShare(WoundHistory history) async {
    final l10n = AppLocalizations.of(context)!;
    final wound = await widget.dependencies.patients.contextOfWound(
      widget.wound,
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

  @override
  Widget build(BuildContext context) {
    final history = _history;
    if (history == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return HistoryScreen(
      history: history,
      woundLocation: _location,
      loadPhoto: (ref) => _readQuietly(MediaRef(ref)),
      onCreateReport: () => _createReport(history),
      creatingReport: _creatingReport,
      onOpenVisit: _openVisit,
    );
  }
}
