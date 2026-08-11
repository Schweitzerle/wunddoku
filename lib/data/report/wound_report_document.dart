import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/report/report_content.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/text/field_presentation.dart';

/// Renders a [ReportContent] as a PDF.
///
/// Every word comes from the localisation and every figure from the record —
/// the report is assembled, never written a second time. That is the whole
/// point: today the same finding is formulated twice, once at the bed and
/// once in the office (`docs/ux/nachprozess.md`).
abstract final class WoundReportDocument {
  /// Builds the report and returns the PDF bytes.
  ///
  /// [photos] maps a media handle to the decoded image bytes. A handle
  /// missing from the map prints as a note rather than an empty frame: a
  /// picture that cannot be read is a fact about the record, not a layout
  /// problem.
  static Future<Uint8List> build({
    required ReportContent content,
    required AppLocalizations l10n,
    Map<String, Uint8List> photos = const {},
    pw.Font? font,
  }) async {
    // The built-in Helvetica of the PDF format covers no typographic
    // quotation marks and no em dash, so the customer's own wording would
    // print with holes in it. The bundled font is the same one the app uses.
    final base = font ?? await _bundledFont();

    final document = pw.Document(
      title: l10n.reportTitle,
      // No author, no creator: those fields travel with the file, and a wound
      // report leaves the device.
      producer: '',
      theme: pw.ThemeData.withFont(base: base, bold: base),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (context) => _footer(context, content, l10n),
        build: (context) => [
          _header(content, l10n),
          if (content.hasGaps) ...[pw.SizedBox(height: 12), _gapNotice(l10n)],
          pw.SizedBox(height: 20),
          if (content.isEmpty)
            pw.Text(l10n.reportNoVisits)
          else ...[
            _courseTable(content, l10n),
            pw.SizedBox(height: 20),
            for (final visit in content.visits.reversed) ...[
              _visitSection(visit, l10n, photos),
              pw.SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );

    return document.save();
  }

  /// Loads the bundled font once and keeps it.
  ///
  /// Parsing a 169 kB font for every report would be paid on the phone that
  /// produces it, at the end of a tour.
  static Future<pw.Font> _bundledFont() async =>
      _font ??= pw.Font.ttf(await rootBundle.load('assets/fonts/Geist.ttf'));

  static pw.Font? _font;

  static pw.Widget _header(ReportContent content, AppLocalizations l10n) {
    final period = content.period;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.reportTitle,
          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 10),
        _field(l10n.reportPatient, content.patientName),
        _field('', l10n.reportBirthDate(content.birthDate)),
        _field(l10n.reportWound, content.woundLocation),
        if (content.icd10Code != null)
          _field(l10n.reportDiagnosis, content.icd10Code!),
        if (period != null) _field('', l10n.reportPeriod(period.$1, period.$2)),
      ],
    );
  }

  static pw.Widget _field(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 130,
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
        ),
      ],
    ),
  );

  static pw.Widget _gapNotice(AppLocalizations l10n) => pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(width: 0.8),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Text(
      l10n.reportGapNotice,
      style: const pw.TextStyle(fontSize: 10),
    ),
  );

  static pw.Widget _courseTable(
    ReportContent content,
    AppLocalizations l10n,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        l10n.reportCourseHeading,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 6),
      pw.TableHelper.fromTextArray(
        headers: [
          l10n.reportColumnDate,
          l10n.reportColumnArea,
          l10n.reportColumnDepth,
          l10n.reportColumnStatus,
        ],
        cellStyle: const pw.TextStyle(fontSize: 10),
        headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        cellAlignment: pw.Alignment.centerLeft,
        data: [
          for (final visit in content.visits)
            [
              l10n.historyDate(visit.recordedAt),
              // A missing measurement prints as the gap marker, never as
              // a zero and never as the neighbouring value.
              visit.areaCm2 == null
                  ? l10n.confidenceMissing
                  : l10n.historyArea(_rounded(visit.areaCm2!)),
              visit.depthCm == null
                  ? l10n.confidenceMissing
                  : l10n.historyDepth(_rounded(visit.depthCm!)),
              visit.gapSlots.isEmpty
                  ? l10n.reportStatusComplete
                  : l10n.reportStatusGaps(visit.gapSlots.length),
            ],
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Text(l10n.historyAreaApprox, style: const pw.TextStyle(fontSize: 9)),
    ],
  );

  static pw.Widget _visitSection(
    ReportVisit visit,
    AppLocalizations l10n,
    Map<String, Uint8List> photos,
  ) {
    final ref = visit.photoRef;
    final bytes = ref == null ? null : photos[ref];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l10n.reportVisitHeading(visit.recordedAt),
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(
              width: 160,
              child: bytes == null
                  ? pw.Text(
                      l10n.reportPhotoMissing,
                      style: const pw.TextStyle(fontSize: 9),
                    )
                  : pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Image(pw.MemoryImage(bytes), height: 120),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          l10n.reportPhotoCaption(visit.recordedAt),
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                        if (visit.comparability ==
                            ComparabilityNote.noFramingAid)
                          pw.Text(
                            l10n.reportPhotoFirst,
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                      ],
                    ),
            ),
            pw.SizedBox(width: 16),
            pw.Expanded(child: _findings(visit, l10n)),
          ],
        ),
      ],
    );
  }

  /// The finding as the customer's own catalogue words it.
  static pw.Widget _findings(ReportVisit visit, AppLocalizations l10n) {
    final rows = <pw.Widget>[];

    for (final slot in FieldPresentation.woundBedSlots) {
      final value = visit.draft[slot];
      rows.add(
        _field(
          FieldPresentation.label(l10n, slot),
          value == null
              ? l10n.confidenceMissing
              : FieldPresentation.storedValue(l10n, value),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows,
    );
  }

  static pw.Widget _footer(
    pw.Context context,
    ReportContent content,
    AppLocalizations l10n,
  ) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        l10n.reportCreatedAt(content.createdAt),
        style: const pw.TextStyle(fontSize: 8),
      ),
      pw.Text(
        l10n.reportPage(context.pageNumber, context.pagesCount),
        style: const pw.TextStyle(fontSize: 8),
      ),
    ],
  );

  static num _rounded(double value) => (value * 10).round() / 10;
}
