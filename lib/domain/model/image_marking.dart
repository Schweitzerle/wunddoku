import 'dart:math' as math;
import 'dart:ui';

/// How a marking was drawn.
///
/// Three tools, because dragging needs an alternative that works with a
/// single pointer contact (WCAG 2.2 SC 2.5.7) — and because with gloves on,
/// an ellipse is usually faster than tracing an outline anyway.
enum MarkingTool {
  /// Traced with a finger.
  freehand,

  /// Built by tapping one corner after another.
  points,

  /// An ellipse pulled up from two opposite corners.
  ellipse,
}

/// An outline drawn on a wound photo.
///
/// Stored as **geometry, never as pixels**, and normalised to the source
/// image (0..1 on both axes). That is the decision everything else rests on:
/// the outline survives scaling, rotation, a device change and re-export, it
/// stays editable, and it can be compared across visits. Absolute pixel
/// coordinates would survive none of that.
///
/// The original photo is never touched. The burnt-in copy is a second file
/// derived from this geometry — see `/eps:bild-erfassung`.
class ImageMarking {
  const ImageMarking({
    required this.outline,
    required this.tool,
    required this.createdAt,
  });

  /// The outline in normalised image coordinates, 0..1 on both axes.
  final List<Offset> outline;

  final MarkingTool tool;
  final DateTime createdAt;

  /// Whether the outline has enough points to enclose an area.
  bool get isClosed => outline.length >= 3;

  /// The normalised bounding box of the outline.
  ///
  /// Returns [Rect.zero] for an empty outline. Used to place labels and to
  /// frame the marking in the progress view.
  Rect get bounds {
    if (outline.isEmpty) return Rect.zero;
    var left = outline.first.dx;
    var top = outline.first.dy;
    var right = left;
    var bottom = top;
    for (final point in outline) {
      if (point.dx < left) left = point.dx;
      if (point.dx > right) right = point.dx;
      if (point.dy < top) top = point.dy;
      if (point.dy > bottom) bottom = point.dy;
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }

  /// The outline scaled onto an image of [size].
  ///
  /// The one place normalised coordinates turn back into pixels, so a mistake
  /// here cannot spread.
  List<Offset> toPixels(Size size) => [
    for (final point in outline)
      Offset(point.dx * size.width, point.dy * size.height),
  ];

  /// Returns a copy with [point] appended, clamped into the image.
  ///
  /// A finger that leaves the photo while tracing should end the stroke at
  /// the edge rather than record a point outside the picture.
  ImageMarking withPoint(Offset point) => ImageMarking(
    outline: [
      ...outline,
      Offset(point.dx.clamp(0.0, 1.0), point.dy.clamp(0.0, 1.0)),
    ],
    tool: tool,
    createdAt: createdAt,
  );

  /// Returns a copy without the last point.
  ///
  /// Undo works per point for the tapping tool and per stroke for freehand;
  /// see [ImageMarking.freehandStroke].
  ImageMarking withoutLastPoint() => outline.isEmpty
      ? this
      : ImageMarking(
          outline: outline.sublist(0, outline.length - 1),
          tool: tool,
          createdAt: createdAt,
        );

  /// An ellipse inscribed in the rectangle spanned by [a] and [b].
  ///
  /// Approximated with [segments] points so the rest of the pipeline only
  /// ever deals with one shape — an outline — instead of special-casing
  /// ellipses in painting, burning in and measuring.
  factory ImageMarking.ellipse(
    Offset a,
    Offset b, {
    required DateTime createdAt,
    int segments = 48,
  }) {
    final rect = Rect.fromPoints(a, b);
    final centre = rect.center;
    final radiusX = rect.width / 2;
    final radiusY = rect.height / 2;

    return ImageMarking(
      outline: [
        for (var i = 0; i < segments; i++)
          () {
            final angle = 2 * math.pi * i / segments;
            return Offset(
              (centre.dx + radiusX * math.cos(angle)).clamp(0.0, 1.0),
              (centre.dy + radiusY * math.sin(angle)).clamp(0.0, 1.0),
            );
          }(),
      ],
      tool: MarkingTool.ellipse,
      createdAt: createdAt,
    );
  }

  /// A freehand stroke from already normalised [points].
  factory ImageMarking.freehandStroke(
    List<Offset> points, {
    required DateTime createdAt,
  }) => ImageMarking(
    outline: [
      for (final point in points)
        Offset(point.dx.clamp(0.0, 1.0), point.dy.clamp(0.0, 1.0)),
    ],
    tool: MarkingTool.freehand,
    createdAt: createdAt,
  );

}
