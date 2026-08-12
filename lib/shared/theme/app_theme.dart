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
  ///
  /// Everything around it is warm and near-neutral. A wound assessment
  /// distinguishes four colour impressions — black, yellow, red, pink — and a
  /// cool grey interface makes reddened skin read colder than it is. The
  /// screen is also held next to the patient, whose own wound is on it: it
  /// should look like care, not like a diagnostic instrument.
  static const seed = Color(0xFF0F5F66);

  /// The family both themes are built with.
  static const font = AppFontFamily.geist;

  /// The normal case: daylight, a stranger's flat, often a window.
  static ThemeData light() => _build(
    brightness: Brightness.light,
    surface: const Color(0xFFFCFAF7),
    surfaceContainer: const Color(0xFFF4F0EA),
    surfaceContainerHighest: const Color(0xFFEAE4DC),
    onSurface: const Color(0xFF1C1A17),
    onSurfaceVariant: const Color(0xFF57514A),
    outline: const Color(0xFF8E877F),
    primary: const Color(0xFF0F5F66),
    onPrimary: const Color(0xFFFFFFFF),
    error: const Color(0xFFA32017),
    status: StatusColors.light,
  );

  /// For the night shift, and for a bedroom with the blinds down.
  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    surface: const Color(0xFF16140F),
    surfaceContainer: const Color(0xFF201D18),
    surfaceContainerHighest: const Color(0xFF2B2721),
    onSurface: const Color(0xFFEDE7DF),
    onSurfaceVariant: const Color(0xFFB7AFA4),
    outline: const Color(0xFF8A837A),
    primary: const Color(0xFF6FC5C9),
    onPrimary: const Color(0xFF08302F),
    error: const Color(0xFFF0B4AC),
    status: StatusColors.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color surface,
    required Color surfaceContainer,
    required Color surfaceContainerHighest,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color primary,
    required Color onPrimary,
    required Color error,
    required StatusColors status,
  }) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness)
        .copyWith(
          surface: surface,
          surfaceContainer: surfaceContainer,
          surfaceContainerHighest: surfaceContainerHighest,
          primary: primary,
          onPrimary: onPrimary,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          outline: outline,
          error: error,
        );

    return ThemeData(
      colorScheme: scheme,
      textTheme: buildTextTheme(font),
      scaffoldBackgroundColor: scheme.surface,
      // Flat by decision: separation comes from surface tones and spacing.
      // Shadows are invisible in sunlight and cost saveLayer.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      // The one accent, used the same way everywhere: a filled action is
      // teal, whatever widget it happens to be.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
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
