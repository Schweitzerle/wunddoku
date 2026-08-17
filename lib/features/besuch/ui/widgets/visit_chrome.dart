import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';

/// The steps of a visit, in the order they are worked through.
///
/// The same four steps the corridor runs (`main.dart`): the finding is spoken
/// at the open dressing, the proposals are settled, the wound is photographed
/// and marked, and the visit is closed. The band exists so the answer to
/// "where am I" is carried by the screen's structure rather than by its title.
enum VisitStep {
  speak,
  check,
  photo,
  closing;

  /// This step's position, counted from one.
  int get position => index + 1;

  String label(AppLocalizations l10n) => switch (this) {
    VisitStep.speak => l10n.visitStepSpeak,
    VisitStep.check => l10n.visitStepCheck,
    VisitStep.photo => l10n.visitStepPhoto,
    VisitStep.closing => l10n.visitStepClosing,
  };
}

/// Thickness of the line under a step.
///
/// Not a spacing token: this is the weight of a drawn line, and it has no
/// business changing when the spacing scale does.
const _segmentHeight = 3.0;

/// Thickness of the line under the step the nurse is on.
const _currentSegmentHeight = 6.0;

/// Where the nurse is in the visit, as four segments over the content.
///
/// Progress is carried by *how many* segments are filled, not by which one is
/// coloured — colour alone would leave the state invisible to anyone who
/// cannot tell teal from grey (`23-a11y.md`). The whole band is one semantics
/// node so a screen reader says "Schritt 2 von 4: Prüfen" instead of reading
/// four disconnected words.
class VisitBand extends StatelessWidget {
  const VisitBand({required this.current, this.onSelect, super.key});

  final VisitStep current;

  /// Goes to a step. Null where the band only reports.
  ///
  /// Four segments with the current one picked out look like something you
  /// press, and on a device that is what people try — the draft's read-only
  /// band left the ways to the other steps scattered over a tile, a header
  /// button and one that happens by itself.
  final void Function(VisitStep step)? onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final labelStyle = theme.textTheme.labelMedium!;
    final steps = VisitStep.values;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.s16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // At twice the text size four labels cannot share one line without
          // breaking mid-word. The segments still carry the position; then
          // only the step the nurse is on says its name.
          final labelled = _fits(
            context: context,
            style: labelStyle,
            labels: [for (final step in steps) step.label(l10n)],
            gap: spacing.s8,
            available: constraints.maxWidth,
          );

          return Row(
            // Top, not stretch: the band lives in a column of unbounded
            // height, and stretch would ask its children for an infinite
            // one. The segments line up on the top edge either way.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final step in steps) ...[
                if (step.index > 0) SizedBox(width: spacing.s8),
                Expanded(
                  child: _BandStep(
                    step: step,
                    current: current,
                    label: labelled || step == current
                        ? step.label(l10n)
                        : null,
                    onSelect: onSelect,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Whether [labels] fit side by side in [available] with [gap] between them.
  ///
  /// Measured rather than guessed from the text scale: the four words are
  /// short, so four layout passes cost far less than the frame budget, and a
  /// threshold picked from arithmetic would be wrong on the first screen with
  /// a different width or a translated label.
  static bool _fits({
    required BuildContext context,
    required TextStyle style,
    required List<String> labels,
    required double gap,
    required double available,
  }) {
    final scaler = MediaQuery.textScalerOf(context);
    var needed = gap * (labels.length - 1);
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: Directionality.of(context),
        textScaler: scaler,
      )..layout();
      needed += painter.width;
      painter.dispose();
    }
    return needed <= available;
  }
}

/// One step of the band: its share of the bar, and its name under it.
class _BandStep extends StatelessWidget {
  const _BandStep({
    required this.step,
    required this.current,
    required this.label,
    required this.onSelect,
  });

  final VisitStep step;
  final VisitStep current;

  /// Null where this step gives up its name to keep the line unbroken.
  final String? label;

  final void Function(VisitStep step)? onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final done = step.index <= current.index;
    final text = label;

    final here = step == current;
    final content = ConstrainedBox(
      // A step whose label gave way at large text would otherwise be a bare
      // line — below the floor for a target.
      constraints: BoxConstraints(minHeight: spacing.minTouch),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (text != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.s12),
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                // Without tracking: with it "Abschluss" broke across two
                // lines in the width a quarter of a phone gives it, and a
                // word broken in half reads as decoration, not as a place
                // to go.
                style: theme.textTheme.labelSmall?.copyWith(
                  color: here
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            SizedBox(height: spacing.s48),
          // Under the word, not over it: an underline is what a row of
          // words uses to say which one you are on. Its weight doubles on
          // the current step, so the state survives without colour.
          Container(
            height: here ? _currentSegmentHeight : _segmentHeight,
            decoration: BoxDecoration(
              color: done
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(_segmentHeight / 2),
            ),
          ),
        ],
      ),
    );

    final semanticsLabel = l10n.visitStepPosition(
      step.position,
      VisitStep.values.length,
      step.label(l10n),
    );

    if (onSelect == null) {
      return Semantics(
        label: semanticsLabel,
        selected: step == current,
        excludeSemantics: true,
        child: content,
      );
    }

    return Semantics(
      label: semanticsLabel,
      button: true,
      selected: step == current,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onSelect!(step),
        borderRadius: BorderRadius.circular(spacing.r8),
        child: content,
      ),
    );
  }
}

/// The top row of every screen inside a visit.
///
/// Not an [AppBar]: that bar is 56 dp tall whatever the text size, and the
/// closing action carries a word rather than an icon — "Besuch abschließen" as
/// a bare tick is a guess, and this is the one action that ends the record. In
/// the body the row grows with the text instead of clipping it.
class VisitHeader extends StatelessWidget {
  const VisitHeader({
    required this.step,
    this.visitDate,
    this.onBack,
    this.onFinish,
    this.onShowHistory,
    this.onSelectStep,
    super.key,
  });

  /// Where in the visit this screen sits.
  final VisitStep step;

  /// When the open visit was started.
  ///
  /// Tells a resumed draft from today's visit; omitted while the record is
  /// still being read.
  final DateTime? visitDate;

  /// Leaves the visit. Omitted when there is nowhere to go back to.
  final VoidCallback? onBack;

  /// Ends the visit. Reachable from every step (`23-a11y.md`, 3.2.6).
  final VoidCallback? onFinish;

  /// Opens the course of this wound.
  ///
  /// In the header rather than among the actions of the visit: what the
  /// wound looked like a week ago is background for the whole visit, not a
  /// step in it.
  final VoidCallback? onShowHistory;

  /// Goes to another step of the visit; see [VisitBand.onSelect].
  final void Function(VisitStep step)? onSelectStep;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;
    final date = visitDate;

    // With nothing in it the row was 48 dp of empty screen above the band.
    final hasRow =
        onBack != null ||
        onFinish != null ||
        onShowHistory != null ||
        date != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasRow)
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: spacing.minTouch),
            child: Padding(
              // At 200 % the outlined action grows past the top edge of the
              // screen and loses the arc of its stadium shape.
              padding: EdgeInsets.only(top: spacing.s8),
              child: Row(
                children: [
                  if (onBack != null)
                    BackButton(onPressed: onBack)
                  else
                    SizedBox(width: spacing.s16),
                  Expanded(
                    child: date == null
                        ? const SizedBox.shrink()
                        : _WhichVisit(date: date),
                  ),
                  if (onShowHistory != null)
                    IconButton(
                      onPressed: onShowHistory,
                      icon: const Icon(Icons.show_chart),
                      tooltip: l10n.captureShowHistory,
                    ),
                  if (onFinish != null)
                    Padding(
                      padding: EdgeInsets.only(right: spacing.s16),
                      child: OutlinedButton(
                        onPressed: onFinish,
                        child: Text(l10n.captureFinishShort),
                      ),
                    )
                  else
                    SizedBox(width: spacing.s16),
                ],
              ),
            ),
          ),
        SizedBox(height: spacing.s8),
        VisitBand(current: step, onSelect: onSelectStep),
      ],
    );
  }
}

/// Which visit is open, or nothing when the room is not there.
///
/// Whole or absent: a date shown as "Besu…" is a value that looks cut off,
/// and the action beside it has the better claim to the width. Nothing is
/// lost — the record itself says which visit this is.
class _WhichVisit extends StatelessWidget {
  const _WhichVisit({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final text = l10n.visitHeaderDate(date);

    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final fits = painter.width <= constraints.maxWidth;
        painter.dispose();

        return fits
            ? Center(child: Text(text, style: style, maxLines: 1))
            : const SizedBox.shrink();
      },
    );
  }
}
