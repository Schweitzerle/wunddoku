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

/// Thickness of one segment of the band.
///
/// Not a spacing token: this is the weight of a drawn line, and it has no
/// business changing when the spacing scale does.
const _segmentHeight = 6.0;

/// Where the nurse is in the visit, as four segments over the content.
///
/// Progress is carried by *how many* segments are filled, not by which one is
/// coloured — colour alone would leave the state invisible to anyone who
/// cannot tell teal from grey (`23-a11y.md`). The whole band is one semantics
/// node so a screen reader says "Schritt 2 von 4: Prüfen" instead of reading
/// four disconnected words.
class VisitBand extends StatelessWidget {
  const VisitBand({required this.current, super.key});

  final VisitStep current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final labelStyle = theme.textTheme.labelMedium!;
    final steps = VisitStep.values;

    return Semantics(
      label: l10n.visitStepPosition(
        current.position,
        steps.length,
        current.label(l10n),
      ),
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                for (final step in steps) ...[
                  if (step.index > 0) SizedBox(width: spacing.s8),
                  Expanded(
                    child: Container(
                      height: _segmentHeight,
                      decoration: BoxDecoration(
                        color: step.index <= current.index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(
                          _segmentHeight / 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: spacing.s8),
            LayoutBuilder(
              builder: (context, constraints) => _fits(
                context: context,
                style: labelStyle,
                labels: [for (final step in steps) step.label(l10n)],
                gap: spacing.s8,
                available: constraints.maxWidth,
              )
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final step in steps)
                          Text(
                            step.label(l10n),
                            style: labelStyle.copyWith(
                              color: step == current
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    )
                  // At large text sizes four labels cannot share one line
                  // without truncating to stumps. The segments still carry
                  // the position; the word only has to name where that is.
                  : Text(
                      current.label(l10n),
                      style: labelStyle.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
            ),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;
    final date = visitDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: spacing.minTouch),
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
        SizedBox(height: spacing.s8),
        VisitBand(current: step),
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
