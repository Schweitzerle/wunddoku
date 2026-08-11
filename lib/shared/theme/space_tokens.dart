import 'package:flutter/material.dart';

/// Spacing, radii and touch-target sizes from `docs/ux/tokens.md`.
///
/// The values are constant across themes, but they live in a
/// [ThemeExtension] so feature code reads every visual value through
/// `Theme.of(context)` — one source, one review rule.
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing();

  /// Spacing scale, base 4.
  double get s4 => 4;
  double get s8 => 8;
  double get s12 => 12;
  double get s16 => 16;
  double get s20 => 20;
  double get s24 => 24;
  double get s32 => 32;

  /// The wide gap in front of the primary action — part of glove
  /// operability, it keeps mis-taps away from the main button.
  double get s48 => 48;
  double get s64 => 64;

  /// Height of the one target that must be hit without looking.
  double get s96 => 96;

  /// Radii: xs / sm / md (cards) / lg. The primary action uses a stadium
  /// shape instead of a radius token.
  double get r4 => 4;
  double get r8 => 8;
  double get r12 => 12;
  double get r20 => 20;

  /// Minimum touch target; platform guidance, stricter than WCAG 2.5.8.
  double get minTouch => 48;

  /// Row height in the confirmation view — glove-sized.
  double get confirmationRow => 64;

  @override
  AppSpacing copyWith() => this;

  @override
  AppSpacing lerp(AppSpacing? other, double t) => this;
}
