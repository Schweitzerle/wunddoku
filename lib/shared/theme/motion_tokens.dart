import 'package:flutter/material.dart';

/// Motion tokens from `docs/ux/tokens.md`.
///
/// Spring-based movement is deliberate self-build: Flutter 3.41.5 ships no
/// M3-Expressive spring tokens (`motion.dart` only has `Durations` and
/// `Easing`), so the springs below are project values, to be tuned on the
/// device — desktop motion is deceptive.
@immutable
class AppMotion extends ThemeExtension<AppMotion> {
  const AppMotion();

  /// Movement of elements; screen changes along the visit corridor.
  SpringDescription get spatialDefault =>
      const SpringDescription(mass: 1, stiffness: 380, damping: 30);

  /// Small position changes, e.g. rows re-sorting after a decision.
  SpringDescription get spatialFast =>
      const SpringDescription(mass: 1, stiffness: 700, damping: 34);

  /// Colour and opacity state changes: fading in and out.
  Duration get effectsDefault => const Duration(milliseconds: 250);
  Curve get effectsCurve => Easing.standard;

  /// Tap acknowledgement and other control feedback.
  Duration get kurz => const Duration(milliseconds: 150);
  Curve get kurzCurve => Easing.standardAccelerate;

  /// A change of screen.
  Duration get uebergang => const Duration(milliseconds: 400);
  Curve get uebergangCurve => Easing.emphasizedDecelerate;

  @override
  AppMotion copyWith() => this;

  @override
  AppMotion lerp(AppMotion? other, double t) => this;
}
