import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

/// The area of the wound over the visits.
///
/// Drawn rather than pulled in as a package: this is one series with at most a
/// few dozen points, and the one rule it has to follow — **gaps are not
/// interpolated** — is exactly what a general-purpose chart library would do
/// by default. A line straight through a visit where nobody measured looks
/// like a measurement, and the record only works if it can be trusted.
class AreaChart extends StatelessWidget {
  const AreaChart({required this.series, required this.label, super.key});

  /// One entry per visit, oldest first; null where nothing was measured.
  final List<double?> series;

  /// Read out instead of the drawing itself.
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Semantics(
      label: label,
      // The curve is decoration for a screen reader; the numbers stand in the
      // list below it, where they are readable one by one.
      excludeSemantics: true,
      child: SizedBox(
        height: 96,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.s8),
          child: CustomPaint(
            size: Size.infinite,
            painter: _AreaChartPainter(
              series: series,
              line: theme.colorScheme.primary,
              dot: theme.colorScheme.primary,
              baseline: theme.colorScheme.outlineVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  const _AreaChartPainter({
    required this.series,
    required this.line,
    required this.dot,
    required this.baseline,
  });

  final List<double?> series;
  final Color line;
  final Color dot;
  final Color baseline;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()
        ..color = baseline
        ..strokeWidth = 1,
    );

    final measured = [for (final value in series) ?value];
    if (measured.isEmpty) return;

    // The scale starts at zero: a chart that starts at the smallest value
    // turns a millimetre into a cliff, and this one is read while deciding
    // whether a treatment is working.
    final highest = measured.reduce((a, b) => a > b ? a : b);
    final top = highest <= 0 ? 1.0 : highest;
    final step = series.length == 1 ? 0.0 : size.width / (series.length - 1);

    Offset positionOf(int index, double value) => Offset(
      series.length == 1 ? size.width / 2 : index * step,
      size.height - (value / top) * size.height,
    );

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = line;

    // Segments, not one path: the line breaks wherever a visit has no
    // measurement, so a gap stays visible as a gap.
    for (var i = 1; i < series.length; i++) {
      final previous = series[i - 1];
      final current = series[i];
      if (previous == null || current == null) continue;
      canvas.drawLine(
        positionOf(i - 1, previous),
        positionOf(i, current),
        stroke,
      );
    }

    for (var i = 0; i < series.length; i++) {
      final value = series[i];
      if (value == null) continue;
      canvas.drawCircle(positionOf(i, value), 5, Paint()..color = dot);
    }
  }

  @override
  bool shouldRepaint(_AreaChartPainter oldDelegate) =>
      oldDelegate.series != series ||
      oldDelegate.line != line ||
      oldDelegate.baseline != baseline;
}
