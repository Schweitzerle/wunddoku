import 'package:flutter/material.dart';

import '../../../../data/media/marking_burner.dart';
import '../../../../domain/model/image_marking.dart';
import '../../../../shared/theme/app_theme.dart';

/// Draws the outline over the photo.
///
/// Shares its painting with [MarkingBurner] so what the nurse sees and what
/// the report shows cannot drift apart.
class MarkingPainter extends CustomPainter {
  const MarkingPainter({required this.marking, this.previous});

  final ImageMarking? marking;

  /// The previous visit's outline, drawn behind in a second colour.
  ///
  /// Magenta, like cyan, occurs in no wound, so both marks stay readable as
  /// marks. Seeing last week's outline while drawing is what makes the two
  /// comparable later.
  final ImageMarking? previous;

  @override
  void paint(Canvas canvas, Size size) {
    final earlier = previous;
    if (earlier != null) {
      final points = earlier.toPixels(size);
      if (points.length >= 2) {
        final path = Path()..moveTo(points.first.dx, points.first.dy);
        for (final point in points.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
        if (earlier.isClosed) path.close();
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = const Color(0x99FF00E5),
        );
      }
    }

    final current = marking;
    if (current != null) MarkingBurner.paint(canvas, current, size);
  }

  @override
  bool shouldRepaint(MarkingPainter oldDelegate) =>
      oldDelegate.marking != marking || oldDelegate.previous != previous;
}

/// The photo with the outline on top, zoomable and drawable.
///
/// Two things make this work rather than merely look right:
///
/// * **Drawing and panning are separate modes.** With one mode, every attempt
///   to move the picture leaves a line.
/// * **Pointer positions are converted through the transformation**, so a
///   mark placed at 4× zoom lands where the finger was. Without that step the
///   outline slides as soon as the nurse has zoomed in — the classic defect
///   of this widget.
class MarkingEditor extends StatefulWidget {
  const MarkingEditor({
    required this.photo,
    required this.marking,
    required this.tool,
    required this.onChanged,
    this.previous,
    super.key,
  });

  /// The photo to mark; any [ImageProvider] so tests can pass a memory image.
  final ImageProvider photo;

  final ImageMarking? marking;
  final ImageMarking? previous;

  /// Which tool the toolbar has selected.
  final MarkingTool tool;

  final ValueChanged<ImageMarking> onChanged;

  @override
  State<MarkingEditor> createState() => _MarkingEditorState();
}

class _MarkingEditorState extends State<MarkingEditor> {
  final _transformation = TransformationController();

  /// Where an ellipse drag started, in normalised coordinates.
  Offset? _ellipseAnchor;

  @override
  void dispose() {
    _transformation.dispose();
    super.dispose();
  }

  /// Turns a pointer position into normalised image coordinates.
  ///
  /// [TransformationController.toScene] undoes the current zoom and pan; the
  /// division by the painted size makes the result independent of the device.
  Offset _normalise(Offset local, Size size) {
    final scene = _transformation.toScene(local);
    return Offset(scene.dx / size.width, scene.dy / size.height);
  }

  bool get _drawing => widget.tool != MarkingTool.points;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final status = context.statusColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return ClipRRect(
          borderRadius: BorderRadius.circular(spacing.r12),
          child: ColoredBox(
            // The ground behind a wound photo stays neutral in both themes so
            // the surround never tints the tissue colours.
            color: status.mediaGround,
            child: InteractiveViewer(
              transformationController: _transformation,
              maxScale: 6,
              // Panning is off while a drawing tool is active, otherwise every
              // attempt to move the picture leaves a line.
              panEnabled: !_drawing,
              scaleEnabled: !_drawing,
              child: GestureDetector(
                onTapUp: widget.tool == MarkingTool.points
                    ? (details) => _addPoint(details.localPosition, size)
                    : null,
                onPanStart: _drawing
                    ? (details) => _startStroke(details.localPosition, size)
                    : null,
                onPanUpdate: _drawing
                    ? (details) => _extendStroke(details.localPosition, size)
                    : null,
                onPanEnd: _drawing ? (_) => _ellipseAnchor = null : null,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(image: widget.photo, fit: BoxFit.contain),
                    CustomPaint(
                      painter: MarkingPainter(
                        marking: widget.marking,
                        previous: widget.previous,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _addPoint(Offset local, Size size) {
    final point = _normalise(local, size);
    final current = widget.marking;
    widget.onChanged(
      current == null || current.tool != MarkingTool.points
          ? ImageMarking(
              outline: [point],
              tool: MarkingTool.points,
              createdAt: DateTime.now(),
            )
          : current.withPoint(point),
    );
  }

  void _startStroke(Offset local, Size size) {
    final point = _normalise(local, size);
    if (widget.tool == MarkingTool.ellipse) {
      _ellipseAnchor = point;
      return;
    }
    widget.onChanged(
      ImageMarking.freehandStroke([point], createdAt: DateTime.now()),
    );
  }

  void _extendStroke(Offset local, Size size) {
    final point = _normalise(local, size);
    final current = widget.marking;

    if (widget.tool == MarkingTool.ellipse) {
      final anchor = _ellipseAnchor;
      if (anchor == null) return;
      // Redrawn from the anchor on every update, so the ellipse follows the
      // finger instead of accumulating points.
      widget.onChanged(
        ImageMarking.ellipse(anchor, point, createdAt: DateTime.now()),
      );
      return;
    }

    widget.onChanged(
      current == null
          ? ImageMarking.freehandStroke([point], createdAt: DateTime.now())
          : current.withPoint(point),
    );
  }
}
