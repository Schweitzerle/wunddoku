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
  /// The palette is the checked one for "Ruhiges Fachwerkzeug"
  /// (`/eps:ui-gestaltung`, `zahlen-und-paletten.md`): muted, cool, calm, for
  /// a context where the user is under pressure and the screen is held next
  /// to the patient whose wound is on it.
  ///
  /// The warmth a tissue colour needs is not the interface's job — wound
  /// photos sit on `mediaGround`, which is its own token and follows neither
  /// theme.
  static const seed = Color(0xFF0F6E7E);

  /// The family both themes are built with.
  static const font = AppFontFamily.geist;

  /// The normal case: daylight, a stranger's flat, often a window.
  static ThemeData light() => _build(
    brightness: Brightness.light,
    surface: const Color(0xFFF7FAFA),
    surfaceContainer: const Color(0xFFEDF2F3),
    surfaceContainerHighest: const Color(0xFFE2EAEB),
    onSurface: const Color(0xFF0F3B45),
    onSurfaceVariant: const Color(0xFF3E5C63),
    outline: const Color(0xFF728E95),
    primary: const Color(0xFF0F6E7E),
    onPrimary: const Color(0xFFFFFFFF),
    error: const Color(0xFFB3261E),
    status: StatusColors.light,
  );

  /// For the night shift, and for a bedroom with the blinds down.
  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    surface: const Color(0xFF101617),
    surfaceContainer: const Color(0xFF1A2224),
    surfaceContainerHighest: const Color(0xFF202A2C),
    onSurface: const Color(0xFFE3EDEF),
    onSurfaceVariant: const Color(0xFFA9BFC4),
    outline: const Color(0xFF778F95),
    primary: const Color(0xFF7FD1DE),
    onPrimary: const Color(0xFF04262D),
    error: const Color(0xFFF2B8B5),
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
        ).copyWith(
          // Material's 10 % overlay is invisible on this teal, and the
          // 96 dp target is pressed with gloves on while the eyes are on
          // the wound. Touch confirms it too, but a device without a
          // vibrator has to show it.
          //
          // The tint moves the fill *away* from the label colour rather
          // than towards it: lightening a teal button that carries white
          // text makes the press visible and the label unreadable at the
          // same moment.
          overlayColor: WidgetStateProperty.resolveWith((states) {
            final tint = brightness == Brightness.light
                ? Colors.black
                : Colors.white;
            if (states.contains(WidgetState.pressed)) {
              return tint.withValues(alpha: 0.16);
            }
            if (states.contains(WidgetState.focused)) {
              return tint.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return tint.withValues(alpha: 0.06);
            }
            return null;
          }),
        ),
      ),
      // The quiet counterpart, and the one place a width is *not* forced:
      // it sits beside other things in the visit header. 48 rather than
      // Material's 40, because the platform floor is the measure here
      // (`23-a11y.md`), and 1.5 so the outline survives sunlight.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outline, width: 1.5),
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
