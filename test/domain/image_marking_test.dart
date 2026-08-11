import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/media/marking_burner.dart';
import 'package:wunddoku/domain/model/image_marking.dart';

/// A small solid image to burn markings into.
Future<ui.Image> _photo({int width = 40, int height = 30}) {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..color = const Color(0xFF884422),
  );
  return recorder.endRecording().toImage(width, height);
}

void main() {
  final at = DateTime(2026, 8, 11);

  group('scaling', () {
    final marking = ImageMarking(
      outline: const [Offset(0.25, 0.5), Offset(0.75, 0.5), Offset(0.5, 0.9)],
      tool: MarkingTool.points,
      createdAt: at,
    );

    test('the same outline lands correctly at any image size', () {
      expect(marking.toPixels(const Size(100, 100)), const [
        Offset(25, 50),
        Offset(75, 50),
        Offset(50, 90),
      ]);

      // The point of normalised storage: a bigger export needs no conversion
      // table, only a different multiplication.
      expect(marking.toPixels(const Size(4000, 3000)), const [
        Offset(1000, 1500),
        Offset(3000, 1500),
        Offset(2000, 2700),
      ]);
    });

    test('the bounding box is normalised too', () {
      expect(marking.bounds, const Rect.fromLTRB(0.25, 0.5, 0.75, 0.9));
    });

    test('an empty outline has no bounds and encloses nothing', () {
      final empty = ImageMarking(
        outline: const [],
        tool: MarkingTool.freehand,
        createdAt: at,
      );
      expect(empty.bounds, Rect.zero);
      expect(empty.isClosed, isFalse);
    });
  });

  group('drawing', () {
    test('a point outside the photo is clamped to its edge', () {
      final marking = ImageMarking(
        outline: const [],
        tool: MarkingTool.freehand,
        createdAt: at,
      ).withPoint(const Offset(1.4, -0.3));

      // A finger leaving the picture ends the stroke at the edge rather than
      // recording a point that is not on the photo.
      expect(marking.outline.single, const Offset(1.0, 0.0));
    });

    test('undo removes the last point only', () {
      final marking = ImageMarking(
        outline: const [Offset(0.1, 0.1), Offset(0.2, 0.2)],
        tool: MarkingTool.points,
        createdAt: at,
      ).withoutLastPoint();

      expect(marking.outline, const [Offset(0.1, 0.1)]);
    });

    test('undo on an empty outline does nothing', () {
      final empty = ImageMarking(
        outline: const [],
        tool: MarkingTool.points,
        createdAt: at,
      );
      expect(empty.withoutLastPoint().outline, isEmpty);
    });

    test('an ellipse becomes an outline like every other tool', () {
      final ellipse = ImageMarking.ellipse(
        const Offset(0.2, 0.2),
        const Offset(0.8, 0.6),
        createdAt: at,
        segments: 8,
      );

      expect(ellipse.tool, MarkingTool.ellipse);
      expect(ellipse.outline, hasLength(8));
      expect(ellipse.isClosed, isTrue);
      // Inscribed in the rectangle the two corners span.
      expect(ellipse.bounds.left, closeTo(0.2, 0.001));
      expect(ellipse.bounds.right, closeTo(0.8, 0.001));
    });

    test('an ellipse pulled past the edge stays on the photo', () {
      final ellipse = ImageMarking.ellipse(
        const Offset(0.5, 0.5),
        const Offset(1.6, 1.6),
        createdAt: at,
        segments: 12,
      );
      for (final point in ellipse.outline) {
        expect(point.dx, inInclusiveRange(0.0, 1.0));
        expect(point.dy, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  group('burning in', () {
    // Encoding a picture is real asynchronous work; inside the fake async
    // zone those futures never complete, so every case here runs in real
    // time via runAsync.
    testWidgets('produces a PNG at the source resolution', (tester) async {
      await tester.runAsync(() async {
        final photo = await _photo(width: 40, height: 30);
        addTearDown(photo.dispose);

        final bytes = await MarkingBurner.burn(
          photo,
          ImageMarking(
            outline: const [
              Offset(0.2, 0.2),
              Offset(0.8, 0.2),
              Offset(0.5, 0.8),
            ],
            tool: MarkingTool.points,
            createdAt: at,
          ),
        );

        // PNG magic number, so the second file really is a picture.
        expect(bytes.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);

        final decoded = await decodeImageFromList(Uint8List.fromList(bytes));
        addTearDown(decoded.dispose);
        expect(decoded.width, 40);
        expect(decoded.height, 30);
      });
    });

    testWidgets('leaves the original image untouched', (tester) async {
      await tester.runAsync(() async {
        final photo = await _photo();
        addTearDown(photo.dispose);

        final before = await photo.toByteData(format: ui.ImageByteFormat.png);
        await MarkingBurner.burn(
          photo,
          ImageMarking(
            outline: const [Offset(0.1, 0.1), Offset(0.9, 0.9)],
            tool: MarkingTool.freehand,
            createdAt: at,
          ),
        );
        final after = await photo.toByteData(format: ui.ImageByteFormat.png);

        // The briefing asks for the original to stay as it is; the marked copy
        // is a second file, never a rewrite.
        expect(after!.buffer.asUint8List(), before!.buffer.asUint8List());
      });
    });

    testWidgets('marks the photo visibly', (tester) async {
      await tester.runAsync(() async {
        final photo = await _photo(width: 40, height: 30);
        addTearDown(photo.dispose);

        final marking = ImageMarking(
          outline: const [Offset(0.0, 0.5), Offset(1.0, 0.5)],
          tool: MarkingTool.freehand,
          createdAt: at,
        );
        final bytes = await MarkingBurner.burn(photo, marking, strokeWidth: 4);

        final decoded = await decodeImageFromList(Uint8List.fromList(bytes));
        addTearDown(decoded.dispose);
        final pixels = await decoded.toByteData();

        // The centre pixel sits on the line, so it must no longer be the
        // photo's own colour.
        final centre = ((15 * 40) + 20) * 4;
        final red = pixels!.getUint8(centre);
        final green = pixels.getUint8(centre + 1);
        final blue = pixels.getUint8(centre + 2);
        expect(
          [red, green, blue],
          isNot([0x88, 0x44, 0x22]),
          reason: 'the marking has to be on the copy',
        );
      });
    });
  });
}
