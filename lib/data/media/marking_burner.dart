import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../domain/model/image_marking.dart';

/// Draws a marking into a copy of the photo.
///
/// The briefing asks for both: the original *and* a second file with the pen
/// mark burnt in. The original is never opened for writing — this reads it,
/// paints on a fresh canvas and returns new bytes.
///
/// No image package is involved. The marking is geometry, so burning it in is
/// a drawing operation on a second canvas, not image processing.
abstract final class MarkingBurner {
  /// The outline colour.
  ///
  /// Cyan occurs in no wound: tissue reads as black (necrosis), yellow
  /// (fibrin), red (granulation) or pink (epithelialisation). A mark in cyan
  /// is unmistakably a mark and never mistaken for tissue.
  static const markingColour = Color(0xFF00E5FF);

  /// A dark halo under the line so it stays visible on pale skin as well.
  static const haloColour = Color(0x99000000);

  /// Renders [photo] with [marking] burnt in and returns PNG bytes.
  ///
  /// The result keeps the source resolution: a report printed from it should
  /// not be softer than the photo it came from.
  static Future<Uint8List> burn(
    ui.Image photo,
    ImageMarking marking, {
    double strokeWidth = 6,
  }) async {
    final recorder = ui.PictureRecorder();
    final size = Size(photo.width.toDouble(), photo.height.toDouble());
    final canvas = Canvas(recorder, Offset.zero & size);

    canvas.drawImage(photo, Offset.zero, Paint());
    _paintOutline(canvas, marking, size, strokeWidth);

    final picture = recorder.endRecording();
    try {
      final image = await picture.toImage(photo.width, photo.height);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        if (data == null) {
          throw StateError('the marked copy could not be encoded');
        }
        return data.buffer.asUint8List();
      } finally {
        image.dispose();
      }
    } finally {
      picture.dispose();
    }
  }

  /// Paints [marking] onto [canvas] at [size].
  ///
  /// Shared with the on-screen painter so what the nurse drew and what ends
  /// up in the report cannot drift apart.
  static void paint(
    Canvas canvas,
    ImageMarking marking,
    Size size, {
    double strokeWidth = 3,
  }) => _paintOutline(canvas, marking, size, strokeWidth);

  static void _paintOutline(
    Canvas canvas,
    ImageMarking marking,
    Size size,
    double strokeWidth,
  ) {
    final points = marking.toPixels(size);
    if (points.length < 2) {
      // A single tap is a started marking, not a mistake: show it as a dot so
      // the nurse can see the tool responded.
      if (points.length == 1) {
        canvas
          ..drawCircle(
            points.first,
            strokeWidth * 1.6,
            Paint()..color = haloColour,
          )
          ..drawCircle(
            points.first,
            strokeWidth,
            Paint()..color = markingColour,
          );
      }
      return;
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    if (marking.isClosed) path.close();

    canvas
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = haloColour,
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = markingColour,
      );
  }
}
