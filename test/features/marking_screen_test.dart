import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/model/image_marking.dart';
import 'package:wunddoku/features/besuch/ui/marking_screen.dart';
import 'package:wunddoku/features/besuch/ui/widgets/marking_editor.dart';

import '../support/test_app.dart';

/// A synthetic stand-in for a wound photo.
///
/// Never a real one: a wound photo is health data in its own right and does
/// not belong in a repository, a test or a screenshot (`datenschutz-art9.md`).
Future<Uint8List> _syntheticPhoto() async {
  final recorder = ui.PictureRecorder();
  const size = Size(120, 90);
  Canvas(recorder, Offset.zero & size)
    ..drawRect(Offset.zero & size, Paint()..color = const Color(0xFFB08068))
    ..drawOval(
      const Rect.fromLTWH(35, 25, 50, 40),
      Paint()..color = const Color(0xFF9C3B2E),
    );

  final image = await recorder.endRecording().toImage(120, 90);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

void main() {
  late Uint8List photoBytes;

  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    await binding.runAsync(() async {
      photoBytes = await _syntheticPhoto();
    });
  });

  ImageProvider photo() => MemoryImage(photoBytes);

  group('the screen', () {
    testWidgets('promises the original stays untouched', (tester) async {
      await tester.pumpWidget(TestApp(child: MarkingScreen(photo: photo())));

      expect(
        find.text('Umrande die Wunde. Das Original bleibt unverändert.'),
        findsOneWidget,
      );
    });

    testWidgets('offers an alternative to dragging', (tester) async {
      await tester.pumpWidget(TestApp(child: MarkingScreen(photo: photo())));

      // WCAG 2.2 SC 2.5.7: every drag gesture needs a single-contact way.
      expect(find.text('Punkte'), findsOneWidget);
      expect(find.text('Ellipse'), findsOneWidget);
      expect(find.text('Freehand'), findsNothing);
      expect(find.text('Freihand'), findsOneWidget);
    });

    testWidgets('cannot be finished without an outline', (tester) async {
      await tester.pumpWidget(TestApp(child: MarkingScreen(photo: photo())));

      expect(find.text('Noch nichts markiert.'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Markierung übernehmen'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('tapping with the point tool builds an outline', (
      tester,
    ) async {
      ImageMarking? handed;
      await tester.pumpWidget(
        TestApp(
          child: MarkingScreen(photo: photo(), onDone: (m) => handed = m),
        ),
      );

      await tester.tap(find.text('Punkte'));
      await tester.pump();

      final editor = find.byType(MarkingEditor);
      await tester.tapAt(tester.getCenter(editor) - const Offset(40, 30));
      await tester.pump();
      await tester.tapAt(tester.getCenter(editor) + const Offset(40, -30));
      await tester.pump();
      await tester.tapAt(tester.getCenter(editor) + const Offset(0, 30));
      await tester.pump();

      await tester.tap(find.text('Markierung übernehmen'));
      expect(handed, isNotNull);
      expect(handed!.tool, MarkingTool.points);
      expect(handed!.outline, hasLength(3));

      // Everything stored is normalised, so it survives any later resizing.
      for (final point in handed!.outline) {
        expect(point.dx, inInclusiveRange(0.0, 1.0));
        expect(point.dy, inInclusiveRange(0.0, 1.0));
      }
    });

    testWidgets('undo takes back one point, clear takes back all', (
      tester,
    ) async {
      ImageMarking? handed;
      await tester.pumpWidget(
        TestApp(
          child: MarkingScreen(photo: photo(), onDone: (m) => handed = m),
        ),
      );

      await tester.tap(find.text('Punkte'));
      await tester.pump();

      final editor = find.byType(MarkingEditor);
      for (final offset in const [
        Offset(-40, -30),
        Offset(40, -30),
        Offset(0, 30),
        Offset(-20, 20),
      ]) {
        await tester.tapAt(tester.getCenter(editor) + offset);
        await tester.pump();
      }

      await tester.tap(find.byTooltip('Letzten Punkt zurück'));
      await tester.pump();
      await tester.tap(find.text('Markierung übernehmen'));
      expect(handed!.outline, hasLength(3));

      await tester.tap(find.byTooltip('Markierung löschen'));
      await tester.pump();
      expect(find.text('Noch nichts markiert.'), findsOneWidget);
    });

    testWidgets('an earlier outline is announced when it is shown', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: MarkingScreen(
            photo: photo(),
            previous: ImageMarking(
              outline: const [
                Offset(0.3, 0.3),
                Offset(0.7, 0.3),
                Offset(0.5, 0.7),
              ],
              tool: MarkingTool.points,
              createdAt: DateTime(2026, 7, 28),
            ),
          ),
        ),
      );

      // Comparing across weeks only works if the nurse knows the faint
      // outline is last week's, not part of the photo.
      expect(find.text('Voriger Besuch ist mit eingeblendet'), findsOneWidget);
    });
  });

  group('zoom', () {
    final surface = find.descendant(
      of: find.byType(MarkingEditor),
      matching: find.byType(Stack),
    );

    /// Pumps a bare editor with [scale] already applied.
    ///
    /// The zoom is set on the controller rather than pinched: a synthetic
    /// pinch loses part of its movement to the touch slop, so the resulting
    /// scale is close to but not exactly the one the test wants to check
    /// against.
    Future<TransformationController> pumpZoomed(
      WidgetTester tester,
      double scale,
      ValueChanged<ImageMarking> onChanged,
    ) async {
      final controller = TransformationController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: MarkingEditor(
              photo: photo(),
              marking: null,
              tool: MarkingTool.points,
              transformationController: controller,
              onChanged: onChanged,
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await precacheImage(photo(), tester.element(find.byType(Stack).first));
      });
      await tester.pumpAndSettle();

      if (scale != 1) {
        // Zoom around the middle of the photo, the way a pinch does. Scaling
        // around the origin instead would push that middle off screen, and
        // the test would only prove that a tap into nothing does nothing.
        final centre =
            tester.getCenter(surface) -
            tester.getTopLeft(find.byType(MarkingEditor));
        controller.value = Matrix4.identity()
          ..translateByDouble(
            centre.dx * (1 - scale),
            centre.dy * (1 - scale),
            0,
            1,
          )
          ..scaleByDouble(scale, scale, 1, 1);
        await tester.pumpAndSettle();
      }
      return controller;
    }

    testWidgets('the drawing surface carries the photo ratio', (tester) async {
      await pumpZoomed(tester, 1, (_) {});

      // 120x90 in the fixture. If the surface were the whole widget box, the
      // outline would be normalised against the letterbox bars as well and
      // land somewhere else in the burnt copy.
      final size = tester.getSize(surface);
      expect(size.width / size.height, closeTo(120 / 90, 0.001));
    });

    testWidgets('a mark placed while zoomed in lands under the finger', (
      tester,
    ) async {
      ImageMarking? drawn;
      await pumpZoomed(tester, 2, (m) => drawn = m);

      final size = tester.getSize(surface);
      // Transform-aware, so this is where the middle of the photo really is
      // on screen at this zoom.
      final centre = tester.getCenter(surface);

      await tester.tapAt(centre);
      await tester.pump();
      expect(drawn!.outline.single.dx, closeTo(0.5, 0.005));
      expect(drawn!.outline.single.dy, closeTo(0.5, 0.005));

      // At twice the size, 40 logical pixels right of the middle are 20 image
      // pixels. The classic defect is a mark that ignores the zoom and lands
      // at 40 — visibly beside the spot the nurse touched.
      await tester.tapAt(centre + const Offset(40, 0));
      await tester.pump();
      expect(drawn!.outline.last.dx, closeTo(0.5 + 20 / size.width, 0.005));
      expect(drawn!.outline.last.dy, closeTo(0.5, 0.005));
    });
  });

  group('accessibility', () {
    testWidgets('meets the four guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(TestApp(child: MarkingScreen(photo: photo())));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('survives 200 percent text scaling', (tester) async {
      await tester.pumpWidget(
        TestApp(textScale: 2, child: MarkingScreen(photo: photo())),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('goldens', () {
    final marking = ImageMarking(
      outline: const [
        Offset(0.28, 0.35),
        Offset(0.72, 0.32),
        Offset(0.78, 0.62),
        Offset(0.35, 0.68),
      ],
      tool: MarkingTool.points,
      createdAt: DateTime(2026, 8, 11),
    );

    /// Pumps the screen with the photo decoded.
    ///
    /// Decoding an image is real asynchronous work, so without [runAsync] the
    /// picture never arrives and the golden shows an empty frame.
    Future<void> pumpMarked(
      WidgetTester tester, {
      Brightness brightness = Brightness.light,
      double textScale = 1,
    }) async {
      final widget = TestApp(
        brightness: brightness,
        textScale: textScale,
        child: MarkingScreen(photo: photo(), initial: marking),
      );
      await tester.pumpWidget(widget);
      await tester.runAsync(() async {
        final context = tester.element(find.byType(MarkingScreen));
        await precacheImage(photo(), context);
      });
      await tester.pumpAndSettle();
    }

    testWidgets('light theme', (tester) async {
      await pumpMarked(tester);
      await expectLater(
        find.byType(MarkingScreen),
        matchesGoldenFile('goldens/marking_light.png'),
      );
    });

    testWidgets('dark theme', (tester) async {
      await pumpMarked(tester, brightness: Brightness.dark);
      await expectLater(
        find.byType(MarkingScreen),
        matchesGoldenFile('goldens/marking_dark.png'),
      );
    });

    testWidgets('200 percent text scaling', (tester) async {
      await pumpMarked(tester, textScale: 2);
      await expectLater(
        find.byType(MarkingScreen),
        matchesGoldenFile('goldens/marking_text200.png'),
      );
    });
  });
}
