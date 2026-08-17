import 'package:flutter/material.dart';

import '../../../../domain/catalog/exudation.dart';
import '../../../../domain/catalog/tissue_distribution.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../card_entry_view_model.dart';
import '../../../../shared/text/field_presentation.dart';
import 'stepper_row.dart';

/// A finding card: heading, optional status line, content.
///
/// The briefing asks for one card per finding area, and explicitly *not* for
/// the wound photo — that stays its own block. See `docs/fachkataloge.md`.
class FindingCard extends StatelessWidget {
  const FindingCard({
    required this.heading,
    required this.children,
    this.status,
    super.key,
  });

  final String heading;

  /// A line under the heading that reports the state of the whole card.
  final Widget? status;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      padding: EdgeInsets.all(spacing.s20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(spacing.r12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: theme.textTheme.titleMedium),
          if (status != null) ...[SizedBox(height: spacing.s4), status!],
          SizedBox(height: spacing.s12),
          ...children,
        ],
      ),
    );
  }
}

/// The wound bed: four tissue shares that have to add up to 100 percent.
///
/// The invariant is shown as a remainder rather than enforced as an error.
/// The nurse is distributing a whole; "20 % nicht vergeben" tells her what to
/// do next, while "Summe muss 100 ergeben" only tells her she was wrong.
class WoundBedCard extends StatelessWidget {
  const WoundBedCard({required this.viewModel, super.key});

  final CardEntryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final status = context.statusColors;
    final remainder = viewModel.tissueRemainder;

    final (text, colour) = switch (remainder) {
      0 => (l10n.cardsTissueComplete, theme.colorScheme.onSurfaceVariant),
      < 0 => (l10n.cardsTissueOver(-remainder), status.entscheiden),
      _ => (l10n.cardsTissueRemainder(remainder), status.pruefen),
    };

    return FindingCard(
      heading: l10n.cardsWoundBed,
      status: Semantics(
        liveRegion: true,
        child: Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(color: colour),
        ),
      ),
      children: [
        // The whole, drawn. The rule is that four shares make 100 %, and a
        // sentence saying so is a rule while a bar is the thing itself: what
        // is left over is the empty part of it.
        _DistributionBar(viewModel: viewModel),
        SizedBox(height: context.spacing.s16),
        for (final type in TissueType.values)
          if (type != TissueType.other)
            StepperRow(
              key: ValueKey(type),
              label: FieldPresentation.label(l10n, 'tissue.${type.name}'),
              value: l10n.valuePercent(viewModel.tissueShare(type)),
              dimmed: viewModel.tissueShare(type) == 0,
              onDecrease: viewModel.tissueShare(type) == 0
                  ? null
                  : () => viewModel.adjustTissue(type, -5),
              onIncrease: () => viewModel.adjustTissue(type, 5),
            ),
      ],
    );
  }
}

/// The four shares as one bar, in one accent at four strengths.
///
/// Not four colours: these are parts of one whole, not four categories that
/// need identities of their own, and this palette has one accent (see
/// `22-design-tokens.md`). The numbers stand under it either way, so nothing
/// here rests on colour alone.
class _DistributionBar extends StatelessWidget {
  const _DistributionBar({required this.viewModel});

  final CardEntryViewModel viewModel;

  /// Height of the bar. A drawn line, not a spacing value.
  static const _height = 14.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final types = [
      for (final type in TissueType.values)
        if (type != TissueType.other) type,
    ];
    final shares = [for (final type in types) viewModel.tissueShare(type)];
    final given = shares.fold(0, (sum, share) => sum + share);
    // Over-allocation is allowed while redistributing, so the bar shows the
    // shares against whatever the larger of 100 and the sum is — otherwise a
    // 110 % bar would silently drop the last share off its end.
    final total = given > 100 ? given : 100;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_height / 2),
      child: SizedBox(
        // Explicit width: the card's column aligns its children to the start,
        // so a box with only a height collapses to nothing.
        width: double.infinity,
        height: _height,
        child: Row(
          // A [ColoredBox] with no child takes the smallest size it is
          // allowed, and a row hands its children loose cross-axis
          // constraints — so without this the segments lay out at full width
          // and paint nothing at all.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (index, share) in shares.indexed)
              if (share > 0)
                Expanded(
                  flex: share,
                  child: ColoredBox(
                    // Every second share a step lighter, so two neighbours
                    // never run into each other.
                    color: index.isEven
                        ? theme.colorScheme.primary
                        : Color.lerp(
                            theme.colorScheme.primary,
                            theme.colorScheme.surfaceContainer,
                            0.45,
                          )!,
                  ),
                ),
            if (total > given)
              Expanded(
                flex: total - given,
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Length, width and depth in centimetres.
///
/// Measured with the ruler as before; the app records the number rather than
/// deriving it from the photo (`docs/fachkataloge.md`, section 5).
class MeasurementCard extends StatelessWidget {
  const MeasurementCard({required this.viewModel, super.key});

  final CardEntryViewModel viewModel;

  static const _slots = [
    'measurement.lengthCm',
    'measurement.widthCm',
    'measurement.depthCm',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FindingCard(
      heading: l10n.cardsMeasurements,
      children: [
        for (final slot in _slots)
          Builder(
            builder: (context) {
              final value = viewModel.measurement(slot);
              return StepperRow(
                key: ValueKey(slot),
                label: FieldPresentation.label(l10n, slot),
                value: value == null
                    ? l10n.cardsNotEnteredShort
                    : FieldPresentation.centimetres(l10n, value),
                dimmed: value == null,
                onDecrease: value == null
                    ? null
                    : () => viewModel.adjustMeasurement(slot, -0.5),
                onIncrease: () => viewModel.adjustMeasurement(slot, 0.5),
              );
            },
          ),
      ],
    );
  }
}

/// The pain rating, on the scale the catalogue defines.
///
/// Stepped like the other values and never typed. Zero is a finding here —
/// "keine Schmerzen" is an answer, not a missing one — so it does not fall
/// back into a gap the way a measurement of zero does; clearing it is its
/// own action.
class PainCard extends StatelessWidget {
  const PainCard({required this.viewModel, super.key});

  final CardEntryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final score = viewModel.painScore;

    return FindingCard(
      heading: l10n.cardsPain,
      status: Text(
        l10n.cardsPainScale,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      children: [
        StepperRow(
          // The card is already called "Schmerz"; the row underneath saying
          // it again is a label on a label.
          label: l10n.valuePainScoreLabel,
          value: score == null
              ? l10n.cardsNotEnteredShort
              : l10n.valuePainScore(score),
          dimmed: score == null,
          onDecrease: score == null || score == 0
              ? null
              : () => viewModel.adjustPain(-1),
          onIncrease: score == 10 ? null : () => viewModel.adjustPain(1),
        ),
        if (score != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: spacing.s8),
              child: TextButton(
                onPressed: viewModel.clearPain,
                child: Text(l10n.cardsPainClear),
              ),
            ),
          ),
      ],
    );
  }
}

/// Amount and kinds of exudate, both chosen from the catalogue.
class ExudationCard extends StatelessWidget {
  const ExudationCard({required this.viewModel, super.key});

  final CardEntryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;
    final noExudate = viewModel.exudateAmount == ExudateAmount.none;

    return FindingCard(
      heading: l10n.cardsExudation,
      children: [
        _ChoiceRow(
          label: FieldPresentation.label(l10n, 'exudate.amount'),
          children: [
            for (final amount in ExudateAmount.values)
              _Choice(
                label: FieldPresentation.exudateAmount(l10n, amount),
                selected: viewModel.exudateAmount == amount,
                onTap: () => viewModel.toggleExudateAmount(amount),
              ),
          ],
        ),
        SizedBox(height: spacing.s16),
        _ChoiceRow(
          label: FieldPresentation.label(l10n, 'exudate.kind.serous'),
          // No exudate cannot have a kind; the catalogue rejects the pair, so
          // the choices go quiet rather than accepting a contradiction.
          enabled: !noExudate,
          children: [
            for (final kind in ExudateKind.values)
              _Choice(
                label: FieldPresentation.exudateKind(l10n, kind),
                selected: viewModel.hasExudateKind(kind),
                onTap: noExudate
                    ? null
                    : () => viewModel.toggleExudateKind(kind),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.children,
    this.enabled = true,
  });

  final String label;
  final List<Widget> children;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: enabled
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.outline,
          ),
        ),
        SizedBox(height: spacing.s8),
        Wrap(spacing: spacing.s8, runSpacing: spacing.s8, children: children),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final disabled = onTap == null;

    return Semantics(
      selected: selected,
      button: true,
      enabled: !disabled,
      child: Material(
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(spacing.r12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(spacing.r12),
          child: Container(
            constraints: BoxConstraints(minHeight: spacing.minTouch),
            padding: EdgeInsets.symmetric(horizontal: spacing.s16),
            alignment: Alignment.center,
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: disabled
                    ? theme.colorScheme.outline
                    : selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
