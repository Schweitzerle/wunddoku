import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';

/// One value with a large decrease/increase pair on either side.
///
/// The pattern every card in this mode is built from. Chosen over a text
/// field for the reason the field-app rules give: typing is the last resort,
/// and with gloves on it is no resort at all. Two 64 dp targets and a value
/// between them can be worked without looking closely.
class StepperRow extends StatelessWidget {
  const StepperRow({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
    this.accent,
    this.dimmed = false,
    super.key,
  });

  /// Field name, set as an instrument legend.
  final String label;

  /// The value as the nurse reads it, units included.
  final String value;

  /// Null disables the step — used at the ends of a scale.
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  /// Colour for label and value; defaults to the ordinary text colours.
  final Color? accent;

  /// Whether the row shows an unentered field, which is drawn back.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Semantics(
      // Read as one node: name and value belong together, and the two
      // buttons keep their own nodes so a screen reader can reach them.
      container: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.s4),
        child: Row(
          children: [
            Expanded(
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: accent ?? theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: spacing.s4),
                    Text(
                      value,
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: dimmed
                            ? theme.colorScheme.onSurfaceVariant
                            : (accent ?? theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _StepButton(
              icon: Icons.remove,
              tooltip: l10n.cardsDecrease(label),
              onPressed: onDecrease,
            ),
            SizedBox(width: spacing.s8),
            _StepButton(
              icon: Icons.add,
              tooltip: l10n.cardsIncrease(label),
              onPressed: onIncrease,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: spacing.s64,
        height: spacing.s64,
        child: Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(spacing.r12),
          child: InkWell(
            onTap: onPressed == null
                ? null
                : () {
                    // Each step is felt, so a series of taps can be counted
                    // without watching the number.
                    HapticFeedback.selectionClick().catchError((_) {});
                    onPressed!();
                  },
            borderRadius: BorderRadius.circular(spacing.r12),
            child: Icon(
              icon,
              size: 28,
              color: onPressed == null
                  ? theme.colorScheme.outline
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
