import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/theme/color_tokens.dart';
import '../confirmation_view_model.dart';
import '../../../../shared/text/field_presentation.dart';

/// A field that still wants a decision, drawn at full size.
///
/// Reads like an instrument, not like a form row: the value dominates
/// (40 px against a 13 px legend), and the only saturated colour on screen
/// marks what the nurse has to act on. Colour is never the sole carrier —
/// every tier also has an icon, a word and a semantics label, so it survives
/// sunlight, colour blindness and a screen reader.
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
    final state = _RowState.of(entry, l10n, context.statusColors);

    return Semantics(
      // The confidence has to reach a screen reader as words, not as a
      // colour: acting on a misread value is the actual risk here.
      label: '$label, ${state.valueText}, ${state.stateWord}',
      container: true,
      explicitChildNodes: true,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(spacing.r20),
          border: Border.all(color: state.accent, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s20,
                spacing.s16,
                spacing.s12,
                0,
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(state.icon, color: state.accent, size: 20),
                  ),
                  SizedBox(width: spacing.s8),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Text(
                        label.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: state.accent,
                        ),
                      ),
                    ),
                  ),
                  _RowActions(onAccept: onAccept, onDiscard: onDiscard),
                ],
              ),
            ),
            InkWell(
              onTap: onShowProvenance,
              borderRadius: BorderRadius.circular(spacing.r20),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.s20,
                  spacing.s4,
                  spacing.s20,
                  spacing.s16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ExcludeSemantics(
                        child: Text(
                          state.valueText,
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: state.valueColour(theme.colorScheme),
                          ),
                        ),
                      ),
                    ),
                    Semantics(
                      label: l10n.actionShowProvenance,
                      button: true,
                      child: Icon(
                        Icons.subject,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
    required this.isBlocking,
  });

  factory _RowState.of(
    ConfirmationEntry entry,
    AppLocalizations l10n,
    StatusColors status,
  ) {
    final proposal = entry.proposal!;

    if (entry.blocksSaving) {
      // A low-confidence value is shown as the word "decide" rather than as
      // the number itself: printing it would make a guess look like a finding.
      return _RowState(
        valueText: l10n.confidenceLow,
        stateWord: l10n.confidenceLow,
        icon: Icons.priority_high,
        accent: status.entscheiden,
        isBlocking: true,
      );
    }

    return _RowState(
      valueText: FieldPresentation.value(l10n, proposal),
      stateWord: l10n.confidenceMedium,
      icon: Icons.visibility_outlined,
      accent: status.pruefen,
      isBlocking: false,
    );
  }

  final String valueText;
  final String stateWord;
  final IconData icon;
  final Color accent;
  final bool isBlocking;

  /// A blocking row shows a word, not a value, so it takes the accent; a row
  /// that only wants a look shows a real value and keeps the text colour.
  Color valueColour(ColorScheme scheme) =>
      isBlocking ? accent : scheme.onSurface;
}
