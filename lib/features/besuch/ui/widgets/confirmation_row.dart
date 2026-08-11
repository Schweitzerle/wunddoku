import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/theme/color_tokens.dart';
import '../confirmation_view_model.dart';
import '../field_presentation.dart';

/// One field of the record in the confirmation view.
///
/// Shows the label, the proposed value and how sure the interpreter was.
/// Colour is never the only carrier of that state: every tier also has an
/// icon, a word, and a semantics label, so it survives sunlight, colour
/// blindness and a screen reader.
class ConfirmationRow extends StatelessWidget {
  const ConfirmationRow({
    required this.entry,
    required this.onShowProvenance,
    required this.onAccept,
    required this.onDiscard,
    super.key,
  });

  final ConfirmationEntry entry;

  /// Called when the nurse wants to see where the value came from.
  final VoidCallback onShowProvenance;

  final VoidCallback onAccept;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final label = FieldPresentation.label(l10n, entry.slotId);
    final state = _RowState.of(
      entry,
      l10n,
      context.statusColors,
      theme.colorScheme,
    );

    return Container(
      constraints: BoxConstraints(minHeight: spacing.confirmationRow),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(spacing.r12),
        border: Border.all(color: state.accent, width: state.borderWidth),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              // The confidence has to reach a screen reader as words, not as
              // a colour: acting on a misread value is the actual risk here.
              // Child semantics are excluded so the tier is announced once,
              // while the buttons beside stay reachable as their own nodes.
              label: '$label, ${state.valueText}, ${state.stateWord}',
              button: true,
              container: true,
              excludeSemantics: true,
              child: InkWell(
                onTap: onShowProvenance,
                borderRadius: BorderRadius.circular(spacing.r12),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.s16,
                    vertical: spacing.s12,
                  ),
                  child: Row(
                    children: [
                      Icon(state.icon, color: state.accent, size: 24),
                      SizedBox(width: spacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: spacing.s4),
                            Text(
                              state.valueText,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: state.isGap
                                    ? theme.colorScheme.onSurfaceVariant
                                    : theme.colorScheme.onSurface,
                                fontStyle: state.isGap
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (entry.needsAttention)
            Padding(
              padding: EdgeInsets.only(right: spacing.s8),
              child: _RowActions(onAccept: onAccept, onDiscard: onDiscard),
            ),
        ],
      ),
    );
  }
}

/// The accept/discard pair shown on rows that still need a decision.
class _RowActions extends StatelessWidget {
  const _RowActions({required this.onAccept, required this.onDiscard});

  final VoidCallback onAccept;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onDiscard,
          icon: const Icon(Icons.close),
          tooltip: l10n.actionDiscardValue,
        ),
        IconButton(
          onPressed: onAccept,
          icon: const Icon(Icons.check),
          tooltip: l10n.actionAcceptValue,
        ),
      ],
    );
  }
}

/// Everything the row needs to draw itself, derived once per build.
class _RowState {
  const _RowState({
    required this.valueText,
    required this.stateWord,
    required this.icon,
    required this.accent,
    required this.borderWidth,
    required this.isGap,
  });

  factory _RowState.of(
    ConfirmationEntry entry,
    AppLocalizations l10n,
    StatusColors status,
    ColorScheme scheme,
  ) {
    if (entry.isGap) {
      return _RowState(
        valueText: l10n.confidenceMissing,
        stateWord: l10n.confidenceMissing,
        icon: Icons.remove,
        accent: status.luecke,
        borderWidth: 1.5,
        isGap: true,
      );
    }

    final proposal = entry.proposal!;
    final valueText = FieldPresentation.value(l10n, proposal);

    if (entry.blocksSaving) {
      // A low-confidence value is shown as the word "decide" rather than as
      // the number itself: printing it would make a guess look like a finding.
      return _RowState(
        valueText: l10n.confidenceLow,
        stateWord: l10n.confidenceLow,
        icon: Icons.priority_high,
        accent: status.entscheiden,
        borderWidth: 2,
        isGap: false,
      );
    }

    if (entry.needsAttention) {
      return _RowState(
        valueText: valueText,
        stateWord: l10n.confidenceMedium,
        icon: Icons.visibility_outlined,
        accent: status.pruefen,
        borderWidth: 1.5,
        isGap: false,
      );
    }

    return _RowState(
      valueText: valueText,
      stateWord: l10n.confidenceHigh,
      icon: Icons.check,
      accent: scheme.outlineVariant,
      borderWidth: 1,
      isGap: false,
    );
  }

  final String valueText;
  final String stateWord;
  final IconData icon;
  final Color accent;
  final double borderWidth;
  final bool isGap;
}
