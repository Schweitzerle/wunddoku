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

/// The bundled families currently on trial.
///
/// Both ship while the direction is being decided; the loser is removed before
/// the handover. See `DECISIONS.md`.
enum AppFontFamily {
  /// Neutral UI grotesque with an optical-size axis.
  inter('Inter'),

  /// Tighter, more technical; closer to instrument lettering.
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
/// | display 40/700 | displayMedium | the measured value in a row |
/// | headline 28/600 | headlineMedium | screen title |
/// | title 20/600 | titleMedium | card heading |
/// | body 17/400 | bodyMedium | running text, transcript |
/// | bodyStrong 17/600 | bodyLarge | value in a compact row |
/// | label 13/600 caps | labelMedium | field name above a value |
/// | labelPlain 13/500 | labelSmall | secondary annotations |
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
      size: 28,
      height: 1.15,
      weight: 600,
      letterSpacing: -0.4,
    ),
    titleMedium: _style(family: family, size: 20, height: 1.30, weight: 600),
    bodyMedium: _style(family: family, size: 17, height: 1.45, weight: 400),
    bodyLarge: _style(
      family: family,
      size: 17,
      height: 1.45,
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
    labelSmall: _style(family: family, size: 13, height: 1.30, weight: 500),
  );
}
