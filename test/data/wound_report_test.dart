import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:wunddoku/data/report/wound_report_document.dart';
import 'package:wunddoku/domain/model/ids.dart';
import 'package:wunddoku/domain/model/visit_draft.dart';
import 'package:wunddoku/domain/model/wound_history.dart';
import 'package:wunddoku/domain/report/report_content.dart';
import 'package:wunddoku/l10n/app_localizations.dart';
import 'package:wunddoku/shared/text/field_presentation.dart';

HistoryEntry _entry({
  required String id,
  required DateTime at,
  double? length,
  double? width,
  double? depth,
  String? markedPhotoRef,
  bool closedWithGaps = false,
}) => HistoryEntry(
  visit: VisitId(id),
  recordedAt: at,
  draft: VisitDraft(
    values: {
      if (length != null) 'measurement.lengthCm': CentimetreValue(length),
      if (width != null) 'measurement.widthCm': CentimetreValue(width),
      if (depth != null) 'measurement.depthCm': CentimetreValue(depth),
    },
  ),
  closedWithGaps: closedWithGaps,
  isOpen: false,
  markedPhotoRef: markedPhotoRef,
);

ReportContent _content({
  List<HistoryEntry>? entries,
  DateTime? from,
  DateTime? to,
}) => ReportContent.fromHistory(
  history: WoundHistory(
    entries ??
        [
          _entry(
            id: 'v1',
            at: DateTime(2026, 7, 14),
            length: 4,
            width: 3,
            depth: 0.8,
            markedPhotoRef: 'markedphoto_1.bin',
          ),
          _entry(
            id: 'v2',
            at: DateTime(2026, 7, 21),
            length: 3.5,
            width: 2.5,
            markedPhotoRef: 'markedphoto_2.bin',
            closedWithGaps: true,
          ),
        ],
  ),
  expectedSlots: FieldPresentation.woundBedSlots,
  patientName: 'Erika Mustermann',
  birthDate: DateTime(1948, 3, 14),
  woundLocation: 'linker Unterschenkel, distal',
  icd10Code: 'I83.0',
  createdAt: DateTime(2026, 8, 11),
  from: from,
  to: to,
);

void main() {
  group('the content', () {
    test('gaps are counted, not smoothed over', () {
      final content = _content();

      // A report that hides what is missing is more dangerous than one that
      // shows it (docs/ux/nachprozess.md).
      expect(content.hasGaps, isTrue);
      expect(content.visits.first.gapSlots, contains('pain.score'));
      expect(content.visits.last.gapSlots, contains('measurement.depthCm'));
    });

    test('the first photo carries the comparability note', () {
      final content = _content();

      // Nothing to line the first photo up against, so its distance is
      // whatever it happened to be — better said than assumed.
      expect(
        content.visits.first.comparability,
        ComparabilityNote.noFramingAid,
      );
      expect(content.visits.last.comparability, ComparabilityNote.none);
    });

    test('a visit without a photo says so rather than leaving a frame', () {
      final content = _content(
        entries: [_entry(id: 'v1', at: DateTime(2026, 7, 14))],
      );

      expect(
        content.visits.single.comparability,
        ComparabilityNote.missingPhoto,
      );
      expect(content.visits.single.photoRef, isNull);
    });

    test('the period selects the visits and names itself', () {
      final content = _content(from: DateTime(2026, 7, 20));

      expect(content.visits, hasLength(1));
      expect(content.period?.$1, DateTime(2026, 7, 21));
    });

    test('an empty period is empty, not a report about nothing', () {
      final content = _content(from: DateTime(2026, 8, 1));

      expect(content.isEmpty, isTrue);
      expect(content.period, isNull);
      expect(content.hasGaps, isFalse);
    });
  });

  group('the document', () {
    late AppLocalizations l10n;

    late pw.Font font;

    setUpAll(() async {
      // In the app the global Material delegates do this; the report is built
      // from a context that has them. Here only AppLocalizations is loaded.
      await initializeDateFormatting('de');
      l10n = await AppLocalizations.delegate.load(const Locale('de'));
      font = pw.Font.ttf(
        await File('assets/fonts/Geist.ttf').readAsBytes().then(
          (bytes) => ByteData.view(Uint8List.fromList(bytes).buffer),
        ),
      );
    });

    testWidgets('is a PDF with the wound photos in it', (tester) async {
      // Rendering is real work with real futures; inside the fake async zone
      // those never complete.
      await tester.runAsync(() async {
        final photo = Uint8List.fromList(await _pngBytes());
        final bytes = await WoundReportDocument.build(
          content: _content(),
          l10n: l10n,
          photos: {'markedphoto_1.bin': photo, 'markedphoto_2.bin': photo},
          font: font,
        );

        expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
        expect(bytes.length, greaterThan(2000));

        // The font travels inside the file. Without it the PDF viewer falls
        // back to Helvetica, which has no German quotation marks and no em
        // dash — the customer's own wording would print with holes in it.
        expect(String.fromCharCodes(bytes), contains('FontFile2'));
      });
    });

    testWidgets('builds without any photo at all', (tester) async {
      await tester.runAsync(() async {
        final bytes = await WoundReportDocument.build(
          content: _content(),
          l10n: l10n,
          font: font,
        );

        // A picture that cannot be read is a fact about the record, not a
        // reason for the report to fail.
        expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
      });
    });

    testWidgets('builds for a period without visits', (tester) async {
      await tester.runAsync(() async {
        final bytes = await WoundReportDocument.build(
          content: _content(from: DateTime(2026, 8, 1)),
          l10n: l10n,
          font: font,
        );

        expect(String.fromCharCodes(bytes.sublist(0, 5)), '%PDF-');
      });
    });
  });
}

/// A tiny valid PNG, so the renderer gets something real to embed.
Future<List<int>> _pngBytes() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder, const Rect.fromLTWH(0, 0, 12, 9)).drawRect(
    const Rect.fromLTWH(0, 0, 12, 9),
    Paint()..color = const Color(0xFF9C3B2E),
  );
  final image = await recorder.endRecording().toImage(12, 9);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}
