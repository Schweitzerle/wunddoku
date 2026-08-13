import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

/// Input level of the open microphone as a row of bars.
///
/// Large enough to register from arm's length with a glance, because that is
/// all the attention it will get. It is decoration for a screen reader — the
/// recording state itself is announced by the surrounding live region — so it
/// is excluded from semantics rather than read out as a number.
class LevelMeter extends StatelessWidget {
  const LevelMeter({required this.level, this.barCount = 24, super.key});

  /// Input level between 0 and 1.
  final double level;

  final int barCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    // Grows from the middle outwards, not from the left. Filled left to
    // right beside a clock reading 00:00, it looked like a recording of
    // fixed length running down — the one thing this meter must not say.
    final centre = (barCount - 1) / 2;
    final reach = level.clamp(0.0, 1.0) * (centre + 1);

    return ExcludeSemantics(
      child: SizedBox(
        height: spacing.s48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < barCount; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.5),
                  child: AnimatedContainer(
                    duration: context.motion.kurz,
                    curve: context.motion.kurzCurve,
                    // Tallest in the middle and tapering out, so the
                    // silhouette reads as a level rather than as a bar
                    // that fills.
                    height: (i - centre).abs() < reach
                        ? spacing.s8 +
                              (spacing.s48 - spacing.s8) *
                                  (1 - (i - centre).abs() / (centre + 1))
                        : spacing.s8,
                    decoration: BoxDecoration(
                      // The accent, not the "decide" red: a running
                      // recording is the normal case, and the palette
                      // reserves red for a value that blocks saving. A red
                      // bar across the screen while the patient watches
                      // reads as an alarm that is not happening.
                      color: (i - centre).abs() < reach
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(spacing.r4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
