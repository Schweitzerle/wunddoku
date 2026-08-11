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
    this.transformationController,
    super.key,
  });

  /// Zoom and pan, if the caller wants to drive or observe them.
  ///
  /// Left out, the editor keeps its own. A caller that passes one owns it and
  /// disposes it.
  final TransformationController? transformationController;

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
  TransformationController? _ownTransformation;

  TransformationController get _transformation =>
      widget.transformationController ??
      (_ownTransformation ??= TransformationController());

  /// Where an ellipse drag started, in normalised coordinates.
  Offset? _ellipseAnchor;

  ImageStream? _stream;
  ImageStreamListener? _listener;

  /// The photo's aspect ratio, once it is known.
  ///
  /// The drawing surface is laid out to exactly this ratio. Without it the
  /// outline would be normalised against the widget box while [MarkingBurner]
  /// normalises against the image, so a mark drawn next to a letterbox bar
  /// would sit somewhere else in the burnt copy.
  double? _aspectRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolvePhoto();
  }

  @override
  void didUpdateWidget(MarkingEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photo != widget.photo) _resolvePhoto();
  }

  void _resolvePhoto() {
    _detach();
    final stream = widget.photo.resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener((info, _) {
      final ratio = info.image.width / info.image.height;
      info.image.dispose();
      if (mounted) setState(() => _aspectRatio = ratio);
    });
    _stream = stream..addListener(listener);
    _listener = listener;
  }

  void _detach() {
    final listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _detach();
    _ownTransformation?.dispose();
    super.dispose();
  }

  /// Turns a pointer position into normalised image coordinates.
  ///
  /// The gesture detector sits *inside* the transformed subtree, so Flutter
  /// has already mapped the pointer back through the zoom by the time it
  /// arrives here — a second correction would move the mark twice. Dividing by
  /// the painted size, which equals the photo's own rectangle, is all that is
  /// left to do.
  Offset _normalise(Offset local, Size size) =>
      Offset(local.dx / size.width, local.dy / size.height);

  bool get _drawing => widget.tool != MarkingTool.points;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final status = context.statusColors;
    final ratio = _aspectRatio;

    return ClipRRect(
      borderRadius: BorderRadius.circular(spacing.r12),
      child: ColoredBox(
        // The ground behind a wound photo stays neutral in both themes so the
        // surround never tints the tissue colours.
        color: status.mediaGround,
        child: InteractiveViewer(
          transformationController: _transformation,
          maxScale: 6,
          // Panning is off while a drawing tool is active, otherwise every
          // attempt to move the picture leaves a line.
          panEnabled: !_drawing,
          scaleEnabled: !_drawing,
          child: Center(
            child: AspectRatio(
              // Until the photo's size is known there is nothing to mark; a
              // neutral square keeps the layout from jumping.
              aspectRatio: ratio ?? 1,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest;

                  return GestureDetector(
                    onTapUp: widget.tool == MarkingTool.points
                        ? (details) => _addPoint(details.localPosition, size)
                        : null,
                    onPanStart: _drawing
                        ? (details) => _startStroke(details.localPosition, size)
                        : null,
                    onPanUpdate: _drawing
                        ? (details) =>
                              _extendStroke(details.localPosition, size)
                        : null,
                    onPanEnd: _drawing ? (_) => _ellipseAnchor = null : null,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // BoxFit.fill is right here precisely because the box
                        // already carries the photo's ratio: the picture is
                        // undistorted and fills the drawing surface exactly.
                        if (ratio != null)
                          Image(image: widget.photo, fit: BoxFit.fill),
                        CustomPaint(
                          painter: MarkingPainter(
                            marking: widget.marking,
                            previous: widget.previous,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
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
