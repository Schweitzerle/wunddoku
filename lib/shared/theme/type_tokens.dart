import 'package:flutter/material.dart';

/// The type scale from `docs/ux/tokens.md`: one family, differentiated by
/// weight and size, ratio ~1.25.
///
/// The concrete font family is still an open `/eps:technikwahl` decision
/// (licence, variable weight, `tnum`, file size); until then the platform
/// default carries the scale. Measured values sit in tabular figures so
/// columns of measurements align.
///
/// Slot mapping, because Material has no "bodyStrong" slot:
///
/// | Token | TextTheme slot |
/// |---|---|
/// | display 40/700 | displayMedium |
/// | headline 28/600 | headlineMedium |
/// | title 20/600 | titleMedium |
/// | body 17/400 | bodyMedium |
/// | bodyStrong 17/600 | bodyLarge |
/// | label 13/500 | labelMedium |
TextTheme buildTextTheme() => const TextTheme(
  displayMedium: TextStyle(
    fontSize: 40,
    height: 1.10,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  ),
  headlineMedium: TextStyle(
    fontSize: 28,
    height: 1.20,
    fontWeight: FontWeight.w600,
  ),
  titleMedium: TextStyle(
    fontSize: 20,
    height: 1.30,
    fontWeight: FontWeight.w600,
  ),
  bodyMedium: TextStyle(
    fontSize: 17,
    height: 1.45,
    fontWeight: FontWeight.w400,
  ),
  bodyLarge: TextStyle(fontSize: 17, height: 1.45, fontWeight: FontWeight.w600),
  labelMedium: TextStyle(
    fontSize: 13,
    height: 1.30,
    fontWeight: FontWeight.w500,
  ),
);
