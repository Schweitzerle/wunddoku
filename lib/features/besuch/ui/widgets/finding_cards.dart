import 'package:flutter/material.dart';

import '../../../../domain/catalog/exudation.dart';
import '../../../../domain/catalog/tissue_distribution.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../card_entry_view_model.dart';
import '../field_presentation.dart';
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
        borderRadius: BorderRadius.circular(spacing.r20),
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
