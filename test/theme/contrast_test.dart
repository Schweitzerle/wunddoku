import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/shared/theme/app_theme.dart';
import 'package:wunddoku/shared/theme/color_tokens.dart';

/// WCAG 2.x contrast ratio between two colours.
///
/// Formula from WCAG: relative luminance with the sRGB transfer curve,
/// ratio (L1 + 0.05) / (L2 + 0.05). This test is the "checked with a
/// script, not by eye" promised in docs/ux/tokens.md.
double contrast(Color a, Color b) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color color) =>
      0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);

  final la = luminance(a);
  final lb = luminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  void checkPairs(String themeName, ThemeData theme, StatusColors status) {
    final scheme = theme.colorScheme;

    // (label, foreground, background, minimum ratio)
    final pairs = <(String, Color, Color, double)>[
      ('text on surface', scheme.onSurface, scheme.surface, 4.5),
      ('text on card', scheme.onSurface, scheme.surfaceContainer, 4.5),
      ('field labels on surface', scheme.onSurfaceVariant, scheme.surface, 4.5),
      (
        'field labels on card',
        scheme.onSurfaceVariant,
        scheme.surfaceContainer,
        4.5,
      ),
      (
        'status entscheiden on card',
        status.entscheiden,
        scheme.surfaceContainer,
        4.5,
      ),
      ('status pruefen on card', status.pruefen, scheme.surfaceContainer, 4.5),
      ('status offline on surface', status.offline, scheme.surface, 4.5),
      ('primary action text', scheme.onPrimary, scheme.primary, 4.5),
      ('error text on surface', scheme.error, scheme.surface, 4.5),
      // Non-text elements (borders, gap outlines): 3:1 per WCAG 1.4.11.
      ('outline on surface', scheme.outline, scheme.surface, 3.0),
      ('gap outline on card', status.luecke, scheme.surfaceContainer, 3.0),
      // The gap colour is not only an outline: it labels the gaps on the
      // capture, closing and course screens, and a nurse spends most of a
      // visit looking at those lines.
      ('gap text on surface', status.luecke, scheme.surface, 4.5),
      ('gap text on card', status.luecke, scheme.surfaceContainer, 4.5),
      // The ground behind photos does not follow the theme, so the text on it
      // must not either — in the light theme a theme-derived label turns dark
      // grey on dark grey.
      ('label on the media ground', status.onMediaGround, status.mediaGround, 4.5),
    ];

    for (final (label, fg, bg, minimum) in pairs) {
      final ratio = contrast(fg, bg);
      expect(
        ratio,
        greaterThanOrEqualTo(minimum),
        reason:
            '$themeName: $label has ${ratio.toStringAsFixed(2)}:1, '
            'needs $minimum:1',
      );
    }
  }

  test('light theme meets WCAG contrast on every token pair', () {
    checkPairs('light', AppTheme.light(), StatusColors.light);
  });

  test('dark theme meets WCAG contrast on every token pair', () {
    checkPairs('dark', AppTheme.dark(), StatusColors.dark);
  });

  test('the media ground is identical in both themes', () {
    expect(StatusColors.light.mediaGround, StatusColors.dark.mediaGround);
    expect(StatusColors.light.onMediaGround, StatusColors.dark.onMediaGround);
  });
}
