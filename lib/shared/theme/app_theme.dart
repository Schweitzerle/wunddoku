import 'package:flutter/material.dart';

import 'color_tokens.dart';
import 'motion_tokens.dart';
import 'space_tokens.dart';
import 'type_tokens.dart';

/// Builds the two themes from the token specification in
/// `docs/ux/tokens.md`. Feature code never names a colour or size — it reads
/// everything through `Theme.of(context)`.
abstract final class AppTheme {
  /// Seed: muted blue-green, far from every tissue colour so the chrome
  /// never tints the perception of a wound photo.
  static const seed = Color(0xFF0B5F6B);

  static ThemeData light() => _build(
    brightness: Brightness.light,
    surface: const Color(0xFFFCFCFD),
    surfaceContainer: const Color(0xFFF1F2F4),
    onSurface: const Color(0xFF16181A),
    onSurfaceVariant: const Color(0xFF4A4E52),
    outline: const Color(0xFF7A7E82),
    error: const Color(0xFFB3261E),
    status: StatusColors.light,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    surface: const Color(0xFF121315),
    surfaceContainer: const Color(0xFF1D1F21),
    onSurface: const Color(0xFFE6E8EA),
    onSurfaceVariant: const Color(0xFFB4B8BC),
    outline: const Color(0xFF8A8E92),
    error: const Color(0xFFF2B8B5),
    status: StatusColors.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color surface,
    required Color surfaceContainer,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color error,
    required StatusColors status,
  }) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness)
        .copyWith(
          surface: surface,
          surfaceContainer: surfaceContainer,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          outline: outline,
          error: error,
        );

    return ThemeData(
      colorScheme: scheme,
      textTheme: buildTextTheme(),
      scaffoldBackgroundColor: scheme.surface,
      // Flat by decision: separation comes from surface tones and spacing.
      // Shadows are invisible in sunlight and cost saveLayer.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppSpacing(),
        AppMotion(),
      ].followedBy([status]).toList(),
    );
  }
}

/// Shorthand accessors so feature code stays terse without bypassing the
/// theme.
extension ThemeTokens on BuildContext {
  StatusColors get statusColors => Theme.of(this).extension<StatusColors>()!;
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;
  AppMotion get motion => Theme.of(this).extension<AppMotion>()!;
}
