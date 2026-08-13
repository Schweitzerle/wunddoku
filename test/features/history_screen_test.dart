import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/model/ids.dart';
import 'package:wunddoku/domain/model/visit_draft.dart';
import 'package:wunddoku/domain/model/wound_history.dart';
import 'package:wunddoku/features/verlauf/ui/history_screen.dart';
import 'package:wunddoku/features/verlauf/ui/widgets/area_chart.dart';

import '../support/phone.dart';
import '../support/test_app.dart';

/// A synthetic wound photo — never a real one (`datenschutz-art9.md`).
Future<Uint8List> _syntheticPhoto() async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder, const Rect.fromLTWH(0, 0, 60, 45))
    ..drawRect(
      const Rect.fromLTWH(0, 0, 60, 45),
      Paint()..color = const Color(0xFFB08068),
    )
    ..drawOval(
      const Rect.fromLTWH(18, 12, 24, 20),
      Paint()..color = const Color(0xFF9C3B2E),
    );

  final image = await recorder.endRecording().toImage(60, 45);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

HistoryEntry _entry({
  required String id,
  required DateTime at,
  double? length,
  double? width,
  double? depth,
  String? photoRef,
  String? markedPhotoRef,
  bool isOpen = false,
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
  isOpen: isOpen,
  photoRef: photoRef,
  markedPhotoRef: markedPhotoRef,
);

void main() {
  late Uint8List photoBytes;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.runAsync(() async {
      photoBytes = await _syntheticPhoto();
    });
  });

  Future<Uint8List?> loadPhoto(String ref) async =>
      ref == 'missing' ? null : photoBytes;

  WoundHistory shrinking() => WoundHistory([
    _entry(
      id: 'v1',
      at: DateTime(2026, 7, 14),
      length: 4,
      width: 3,
      depth: 0.8,
      markedPhotoRef: 'photo_1',
    ),
    _entry(id: 'v2', at: DateTime(2026, 7, 21)),
    _entry(
      id: 'v3',
      at: DateTime(2026, 7, 28),
      length: 3,
      width: 2,
      depth: 0.4,
      markedPhotoRef: 'photo_3',
      closedWithGaps: true,
    ),
  ]);

  group('the course', () {
    test('a visit without measurements stays a gap in the series', () {
      expect(shrinking().areaSeries, [12, null, 6]);
    });

    test('the change is measured against the neighbour, not reached past', () {
      final history = shrinking();

      // From 12 to nothing to 6: saying "six less than three weeks ago" is a
      // different statement from "less than last week", so it is not made.
      expect(history.areaChangeBefore(history.entries.last), isNull);
    });

    test('two visits with measurements do give a change', () {
      final history = WoundHistory([
        _entry(id: 'v1', at: DateTime(2026, 7, 14), length: 4, width: 3),
        _entry(id: 'v2', at: DateTime(2026, 7, 21), length: 3, width: 2),
      ]);

      expect(history.areaChangeBefore(history.entries.last), -6);
    });
  });

  group('the screen', () {
    testWidgets('says what a course is for when there is none', (tester) async {
      var started = false;
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(
            history: const WoundHistory([]),
            loadPhoto: loadPhoto,
            onStartVisit: () => started = true,
          ),
        ),
      );

      expect(find.text('Noch kein Besuch dokumentiert.'), findsOneWidget);
      expect(find.byType(AreaChart), findsNothing);

      await tester.tap(find.text('Befund sprechen'));
      expect(started, isTrue);
    });

    testWidgets('draws no chart out of a single visit', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(
            history: WoundHistory([
              _entry(id: 'v1', at: DateTime(2026, 7, 14), length: 4, width: 3),
            ]),
            loadPhoto: loadPhoto,
          ),
        ),
      );

      expect(find.byType(AreaChart), findsNothing);
      expect(
        find.text('Der Vergleich entsteht ab dem zweiten Besuch.'),
        findsOneWidget,
      );
      expect(find.text('12 cm²'), findsOneWidget);
    });

    testWidgets('shows the newest visit first', (tester) async {
      // Tall enough for every row: a ListView builds only what is visible,
      // and the assertion is about order, not about what fits.
      await useScreen(tester, size: const Size(390, 1600));
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(history: shrinking(), loadPhoto: loadPhoto),
        ),
      );

      final dates = tester
          .widgetList<Text>(find.byType(Text))
          .map((text) => text.data)
          .whereType<String>()
          // Only the visit rows: the period under the chart is a date too,
          // and it is written in the short form.
          .where((text) => text.contains('Juli 2026'))
          .toList();
      expect(dates.first, contains('28'));
      expect(dates.last, contains('14'));
    });

    testWidgets('a growing wound says so, not just a number', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(
            history: WoundHistory([
              _entry(id: 'v1', at: DateTime(2026, 7, 14), length: 3, width: 2),
              _entry(id: 'v2', at: DateTime(2026, 7, 21), length: 4, width: 3),
            ]),
            loadPhoto: loadPhoto,
          ),
        ),
      );

      // Growth is the alarm signal in wound care. A bare "6 cm²" reads as
      // neutral next to the "-6 cm²" a shrinking wound gets.
      expect(find.text('6 cm² größer als beim vorigen Besuch'), findsOneWidget);
    });

    testWidgets('a shrinking wound is named in the same words', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(
            history: WoundHistory([
              _entry(id: 'v1', at: DateTime(2026, 7, 14), length: 4, width: 3),
              _entry(id: 'v2', at: DateTime(2026, 7, 21), length: 3, width: 2),
            ]),
            loadPhoto: loadPhoto,
          ),
        ),
      );

      expect(
        find.text('6 cm² kleiner als beim vorigen Besuch'),
        findsOneWidget,
      );
    });

    testWidgets('an unchanged wound is called unchanged', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(
            history: WoundHistory([
              _entry(id: 'v1', at: DateTime(2026, 7, 14), length: 3, width: 2),
              _entry(id: 'v2', at: DateTime(2026, 7, 21), length: 3, width: 2),
            ]),
            loadPhoto: loadPhoto,
          ),
        ),
      );

      // "0 cm² kleiner" is a strange way to say nothing moved, and a wound
      // that stands still for a week is a statement of its own.
      expect(find.text('unverändert zum vorigen Besuch'), findsOneWidget);
      expect(find.textContaining('0 cm²'), findsNothing);
    });

    testWidgets('names the area as an approximation', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(history: shrinking(), loadPhoto: loadPhoto),
        ),
      );

      // It is length times width, not a measured area — and that has to be
      // readable, otherwise the number claims more than it is.
      expect(find.text('Fläche als Näherung: Länge × Breite.'), findsOneWidget);
    });

    testWidgets('a visit without measurements says so instead of guessing', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(history: shrinking(), loadPhoto: loadPhoto),
        ),
      );

      expect(find.text('Keine Maße erfasst'), findsOneWidget);
      expect(find.text('Mit Lücken abgeschlossen'), findsOneWidget);
    });

    testWidgets('an unreadable photo costs its thumbnail and nothing else', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(
            history: WoundHistory([
              _entry(
                id: 'v1',
                at: DateTime(2026, 7, 14),
                length: 4,
                width: 3,
                photoRef: 'missing',
              ),
            ]),
            loadPhoto: loadPhoto,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The mark in the box is an icon; the sentence lives in its semantics
      // label, where a screen reader gets it whole.
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      expect(find.text('12 cm²'), findsOneWidget);
    });

    testWidgets('the open visit is marked as open', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(
            history: WoundHistory([
              _entry(id: 'v1', at: DateTime(2026, 7, 14), length: 4, width: 3),
              _entry(id: 'v2', at: DateTime(2026, 7, 21), isOpen: true),
            ]),
            loadPhoto: loadPhoto,
          ),
        ),
      );

      expect(find.text('Besuch offen'), findsOneWidget);
    });
  });

  group('accessibility', () {
    testWidgets('meets the four guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(history: shrinking(), loadPhoto: loadPhoto),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('survives 200 percent text scaling', (tester) async {
      await tester.pumpWidget(
        TestApp(
          textScale: 2,
          child: HistoryScreen(history: shrinking(), loadPhoto: loadPhoto),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  /// Waits until every thumbnail has actually decoded.
  ///
  /// [WidgetTester.pumpAndSettle] returns once the frames are quiet, and
  /// decoding a photo is not a frame — so without this the golden sometimes
  /// captured empty thumbnails and sometimes did not.
  Future<void> settleThumbnails(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pump();
      for (final element in find.byType(Image).evaluate()) {
        await precacheImage((element.widget as Image).image, element);
      }
    });
    await tester.pumpAndSettle();
  }

  testWidgets('the report says it is working, and cannot be started twice', (
    tester,
  ) async {
    await useScreen(tester);
    var started = 0;
    await tester.pumpWidget(
      TestApp(
        child: HistoryScreen(
          history: shrinking(),
          loadPhoto: loadPhoto,
          onCreateReport: () => started++,
          creatingReport: true,
        ),
      ),
    );
    // Fixed pumps, not pumpAndSettle: the progress indicator never stops
    // turning, and settling waits for it forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Every photo of the course is decrypted for the document; on a wound
    // with a few visits that is seconds of nothing happening.
    expect(find.text('Bericht wird erzeugt …'), findsOneWidget);
    await tester.tap(find.text('Bericht wird erzeugt …'));
    expect(started, 0);
  });

  group('goldens', () {
    testWidgets('a shrinking wound, light theme', (tester) async {
      await useScreen(tester);
      await tester.pumpWidget(
        TestApp(
          child: HistoryScreen(
            history: shrinking(),
            loadPhoto: loadPhoto,
            woundLocation: 'linker Unterschenkel, distal',
            onCreateReport: () {},
          ),
        ),
      );
      await settleThumbnails(tester);

      await expectLater(
        find.byType(HistoryScreen),
        matchesGoldenFile('goldens/history_light.png'),
      );
    });

    testWidgets('a shrinking wound, dark theme', (tester) async {
      await useScreen(tester);
      await tester.pumpWidget(
        TestApp(
          brightness: Brightness.dark,
          child: HistoryScreen(
            history: shrinking(),
            loadPhoto: loadPhoto,
            woundLocation: 'linker Unterschenkel, distal',
            onCreateReport: () {},
          ),
        ),
      );
      await settleThumbnails(tester);

      await expectLater(
        find.byType(HistoryScreen),
        matchesGoldenFile('goldens/history_dark.png'),
      );
    });
  });
}
