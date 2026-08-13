/// The type scale from `docs/ux/tokens.md`, in the instrument direction.
///
/// One bundled variable family, differentiated by weight and size. Two things
/// make the screen read like a measuring device rather than a form:
///
/// * **Size contrast of three.** The value is 40, its label 13. The nurse
///   reads the value at arm's length; the label only when she needs it.
/// * **Tabular figures everywhere a number appears**, so measurements line up
///   under each other in the list and later in the progress column.
///
/// Weights come from [FontVariation] rather than [FontWeight] alone: with a
/// variable font registered under a single family, Flutter would otherwise
/// synthesise the bold instead of using the real axis.
library;

import 'package:flutter/material.dart';

/// The bundled font family.
///
/// An enum rather than a bare string so a future second family cannot be
/// introduced by typing a name somewhere in feature code. See `DECISIONS.md`
/// for why this one.
enum AppFontFamily {
  /// Tight, technical grotesque; close to instrument lettering.
  geist('Geist');

  const AppFontFamily(this.family);

  final String family;
}

const _tabular = [FontFeature.tabularFigures()];

TextStyle _style({
  required String family,
  required double size,
  required double height,
  required double weight,
  double letterSpacing = 0,
  bool tabular = false,
}) => TextStyle(
  fontFamily: family,
  fontSize: size,
  height: height,
  fontWeight: FontWeight.values.firstWhere(
    (w) => w.value >= weight,
    orElse: () => FontWeight.w900,
  ),
  fontVariations: [FontVariation('wght', weight)],
  letterSpacing: letterSpacing,
  fontFeatures: tabular ? _tabular : null,
);

/// Builds the text theme for [family].
///
/// Slot mapping, because Material has no "label in small caps" slot:
///
/// | Token | Slot | Use |
/// |---|---|---|
/// Four sizes carry a screen — 40 / 30 / 20 / 16 / 13 exist, but no single
/// surface uses more than four of them (`22-design-tokens.md`). The ratio
/// between screen title and running text is 30 : 16 = 1,875, above the 1,75
/// the rules ask for: with a muted palette the size contrast has to do the
/// work colour is not doing here.
///
/// | Token | Slot | Use |
/// |---|---|---|
/// | display 40/700 | displayMedium | a figure that has to be read across the room |
/// | headline 30/700 | headlineMedium | screen title |
/// | figure 34/600 | headlineLarge | the one figure that has to win a row |
/// | section 22/600 | headlineSmall, titleLarge | section heading |
/// | title 20/600 | titleMedium | card heading |
/// | body 16/400 | bodyMedium | running text, transcript |
/// | bodyStrong 16/600 | bodyLarge | value in a compact row |
/// | label 13/600 caps | labelMedium | field name above a value |
/// | labelPlain 13/600 | labelSmall, bodySmall | secondary annotations |
///
/// Two weights carry a surface: 400 for running text, 600 for everything
/// else. The small annotations are 600 rather than the 400–500 the numbers
/// suggest, because at 13 px a light weight fails `textContrastGuideline`:
/// antialiasing eats the effective contrast, and the check measures rendered
/// pixels rather than the nominal colour pair. Readability and the
/// two-weight rule pull the same way here.
///
/// 700 exists only for the recording timer, a screen with three roles on it.
TextTheme buildTextTheme(AppFontFamily font) {
  final family = font.family;
  return TextTheme(
    displayMedium: _style(
      family: family,
      size: 40,
      height: 1.05,
      weight: 700,
      letterSpacing: -0.8,
      tabular: true,
    ),
    headlineMedium: _style(
      family: family,
      size: 30,
      height: 1.15,
      weight: 600,
      letterSpacing: -0.5,
    ),
    // Roles Material widgets and screens reach for that the scale did not
    // fill. An unfilled role falls back to the framework default in another
    // family — invisible on a device with a system font, obvious in a golden.
    headlineLarge: _style(
      family: family,
      size: 34,
      height: 1.10,
      weight: 600,
      letterSpacing: -0.5,
      tabular: true,
    ),
    headlineSmall: _style(
      family: family,
      size: 22,
      height: 1.25,
      weight: 600,
      letterSpacing: -0.2,
    ),
    titleLarge: _style(family: family, size: 22, height: 1.25, weight: 600),
    labelLarge: _style(family: family, size: 16, height: 1.25, weight: 600),
    titleMedium: _style(family: family, size: 20, height: 1.30, weight: 600),
    bodySmall: _style(family: family, size: 13, height: 1.40, weight: 600),
    bodyMedium: _style(family: family, size: 16, height: 1.50, weight: 400),
    bodyLarge: _style(
      family: family,
      size: 16,
      height: 1.50,
      weight: 600,
      tabular: true,
    ),
    // Field names are set in caps with open tracking: at 13 px that reads as
    // an instrument legend rather than as small body text, and it keeps the
    // label from competing with the value above it in weight.
    labelMedium: _style(
      family: family,
      size: 13,
      height: 1.20,
      weight: 600,
      letterSpacing: 1.0,
    ),
    labelSmall: _style(family: family, size: 13, height: 1.30, weight: 600),
  );
}
