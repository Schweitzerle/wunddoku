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
    required this.quote,
    required this.onShowProvenance,
    required this.onAccept,
    required this.onDiscard,
    this.onEnter,
    super.key,
  });

  final ConfirmationEntry entry;

  /// The words this value was heard in, or null when there are none.
  ///
  /// Under the value rather than behind a sheet: with gloves on, every grab
  /// costs, and the wording is what settles the decision this card is asking
  /// for.
  final String? quote;

  /// Called when the nurse wants to see where the value came from.
  final VoidCallback onShowProvenance;

  final VoidCallback onAccept;
  final VoidCallback onDiscard;

  /// Sets the value by hand instead of deciding about the proposal.
  ///
  /// The repair for a value the recogniser did not understand: confirming a
  /// number the screen deliberately does not show is not a decision, it is a
  /// coin flip. Null where there is no card for this field.
  final VoidCallback? onEnter;

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
          // r12 like every other card in the app: one radius per level,
          // project-wide (`22-design-tokens.md`).
          borderRadius: BorderRadius.circular(spacing.r12),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final legend = theme.textTheme.labelMedium?.copyWith(
                    color: state.accent,
                  );
                  // The tier as a word beside the field name while both fit.
                  // At twice the text size they were squeezed into each
                  // other and both broke mid-word; the tier still reaches
                  // the eye through the icon and the border, and the screen
                  // reader through the row's label.
                  final needed =
                      _width(context, label.toUpperCase(), legend) +
                      _width(context, state.stateWord.toUpperCase(), legend) +
                      spacing.s16;
                  final both = needed + 20 + spacing.s8 <= constraints.maxWidth;

                  return Row(
                    children: [
                      ExcludeSemantics(
                        child: Icon(state.icon, color: state.accent, size: 20),
                      ),
                      SizedBox(width: spacing.s8),
                      Expanded(
                        child: ExcludeSemantics(
                          child: Text(label.toUpperCase(), style: legend),
                        ),
                      ),
                      if (both)
                        ExcludeSemantics(
                          child: Text(
                            state.stateWord.toUpperCase(),
                            style: legend,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s20,
                spacing.s4,
                spacing.s20,
                0,
              ),
              child: ExcludeSemantics(
                child: Text(
                  state.valueText,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: state.valueColour(theme.colorScheme),
                  ),
                ),
              ),
            ),
            if (quote != null)
              Semantics(
                label: l10n.actionShowProvenance,
                button: true,
                excludeSemantics: true,
                child: InkWell(
                  onTap: onShowProvenance,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.s20,
                      spacing.s4,
                      spacing.s20,
                      0,
                    ),
                    child: Text(
                      l10n.confirmationQuote(quote!),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(spacing.s16),
              child: _RowActions(
                // Two decisions per tier, and they differ. A value that was
                // understood can be right ("Stimmt") or wrong ("Ändern"). A
                // value that was not understood is neither — it is discarded
                // or entered by hand.
                primaryLabel: state.isBlocking
                    ? (onEnter == null
                          ? l10n.actionAcceptAnyway
                          : l10n.actionEnterValue)
                    : l10n.actionConfirmShort,
                onPrimary: state.isBlocking
                    ? (onEnter ?? onAccept)
                    : onAccept,
                secondaryLabel: state.isBlocking || onEnter == null
                    ? l10n.actionDiscardShort
                    : l10n.actionChangeValue,
                onSecondary: state.isBlocking || onEnter == null
                    ? onDiscard
                    : onEnter!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The decision, as two areas a glove can hit.
///
/// The pair used to be two 24 dp icon buttons in the corner of the card. A
/// decision that changes what reaches the record may not sit on the smallest
/// target on the screen, and a tick without a word is a guess about what it
/// does.
class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final discard = OutlinedButton(
      onPressed: onSecondary,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(spacing.comfortTouch),
      ),
      child: Text(secondaryLabel),
    );
    final accept = FilledButton(
      onPressed: onPrimary,
      style: FilledButton.styleFrom(
        minimumSize: Size.fromHeight(spacing.comfortTouch),
      ),
      child: Text(primaryLabel),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // Side by side while both words fit; stacked when they do not.
        // "Trotzdem übernehmen" at twice the text size is wider than half a
        // narrow phone, and a decision may not be read as a stump.
        final side = (constraints.maxWidth - spacing.s8) / 2;
        final fits = [secondaryLabel, primaryLabel].every(
          (label) => _width(context, label, theme.textTheme.labelLarge) +
                  2 * spacing.s16 <=
              side,
        );

        if (!fits) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // Discard on top, keeping the reading order of the row it
            // replaces; the affirmative sits nearer the thumb.
            children: [discard, SizedBox(height: spacing.s8), accept],
          );
        }

        return Row(
          children: [
            Expanded(child: discard),
            SizedBox(width: spacing.s8),
            Expanded(child: accept),
          ],
        );
      },
    );
  }

}

/// Width of [text] as it will be laid out here.
///
/// Measured rather than derived from the text scale: the answer depends on
/// the width as much as on the size.
double _width(BuildContext context, String text, TextStyle? style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final width = painter.width;
  painter.dispose();
  return width;
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
