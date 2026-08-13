import 'package:flutter/material.dart';

import '../../../domain/model/wound_history.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/photo_thumbnail.dart';
import 'widgets/area_chart.dart';

/// The visits of one wound in their order.
///
/// The screen that carries the clinical value: a single finding says little,
/// the course says whether the treatment works. Everything here is built so
/// the answer survives doubt — the area is labelled as an approximation, a
/// visit without measurements shows as a gap instead of a guess, and an
/// unreadable photo costs its thumbnail and nothing else.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.history,
    required this.loadPhoto,
    this.woundLocation,
    this.onStartVisit,
    this.onCreateReport,
    super.key,
  });

  final WoundHistory history;
  final PhotoLoader loadPhoto;

  /// Which wound this course belongs to, for the line under the title.
  ///
  /// A course without its wound is a chart about nothing — a patient with a
  /// heel and a lower leg has two of them.
  final String? woundLocation;

  /// Called from the empty state.
  final VoidCallback? onStartVisit;

  /// Called to produce the wound report for the office.
  ///
  /// Only offered where there is something to report about: an empty report
  /// is a document that says nothing and still looks official.
  final VoidCallback? onCreateReport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final spacing = context.spacing;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The report carries its word rather than a sheet-of-paper icon:
            // this hands health data to whatever the nurse picks next, and
            // that is not a thing to guess at from a glyph.
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: spacing.minTouch),
              child: Padding(
                padding: EdgeInsets.only(top: spacing.s8),
                child: Row(
                  children: [
                    if (Navigator.of(context).canPop())
                      const BackButton()
                    else
                      SizedBox(width: spacing.s16),
                    const Spacer(),
                    if (onCreateReport != null && !history.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(right: spacing.s16),
                        child: OutlinedButton.icon(
                          onPressed: onCreateReport,
                          icon: const Icon(Icons.description_outlined),
                          label: Text(l10n.reportShare),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: history.isEmpty
                  ? _EmptyState(onStartVisit: onStartVisit)
                  : _Course(
                      history: history,
                      loadPhoto: loadPhoto,
                      woundLocation: woundLocation,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStartVisit});

  final VoidCallback? onStartVisit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.s16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.historyEmpty, style: theme.textTheme.headlineSmall),
          SizedBox(height: spacing.s8),
          Text(
            l10n.historyEmptyHint,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.s24),
          if (onStartVisit != null)
            FilledButton(
              onPressed: onStartVisit,
              child: Text(l10n.captureTitle),
            ),
        ],
      ),
    );
  }
}

/// Chart and visits.
class _Course extends StatelessWidget {
  const _Course({
    required this.history,
    required this.loadPhoto,
    required this.woundLocation,
  });

  final WoundHistory history;
  final PhotoLoader loadPhoto;
  final String? woundLocation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    // Newest first: the nurse standing in the flat wants today's visit, and
    // the chart underneath still runs left to right in time.
    final newestFirst = history.entries.reversed.toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        spacing.s16,
        spacing.s8,
        spacing.s16,
        spacing.s16,
      ),
      children: [
        Text(l10n.historyTitle, style: theme.textTheme.headlineMedium),
        if (woundLocation != null) ...[
          SizedBox(height: spacing.s4),
          Text(
            '$woundLocation · ${l10n.woundVisitCount(history.entries.length)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        SizedBox(height: spacing.s24),
        if (history.isComparable) ...[
          _ChartBlock(history: history),
        ] else
          Text(
            l10n.historySingleHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        SizedBox(height: spacing.s32),
        for (final entry in newestFirst)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.s12),
            child: _VisitRow(
              entry: entry,
              areaChange: history.areaChangeBefore(entry),
              loadPhoto: loadPhoto,
            ),
          ),
      ],
    );
  }
}

/// The curve with the two numbers that make it readable.
///
/// A line without a scale claims a trend without saying between which values
/// or over what period. Rather than drawing axes — which cost height a phone
/// does not have — the first and last measured value and the period are set
/// as text around it.
class _ChartBlock extends StatelessWidget {
  const _ChartBlock({required this.history});

  final WoundHistory history;

  /// One decimal, like everywhere the area is shown.
  static num _rounded(double value) => (value * 10).round() / 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final measured = [
      for (final entry in history.entries)
        if (entry.areaCm2 != null) entry,
    ];
    final first = measured.first;
    final last = measured.last;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(spacing.r12),
      ),
      padding: EdgeInsets.all(spacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.historyChartLatest(_rounded(last.areaCm2!)),
            style: theme.textTheme.headlineLarge,
          ),
          Text(
            l10n.historyChartFirst(_rounded(first.areaCm2!)),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing.s8),
          AreaChart(series: history.areaSeries, label: l10n.historyAreaLabel),
          SizedBox(height: spacing.s8),
          Text(
            l10n.historyChartSpan(first.recordedAt, last.recordedAt),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            l10n.historyAreaApprox,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// One visit: thumbnail, date, measurements, and how it compares.
class _VisitRow extends StatelessWidget {
  const _VisitRow({
    required this.entry,
    required this.areaChange,
    required this.loadPhoto,
  });

  final HistoryEntry entry;
  final double? areaChange;
  final PhotoLoader loadPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    final area = entry.areaCm2;
    final depth = entry.depthCm;
    final change = areaChange;

    return MergeSemantics(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(spacing.r12),
        ),
        padding: EdgeInsets.all(spacing.s12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhotoThumbnail(
              // The marked copy where there is one: the outline is what makes
              // two photos comparable at a glance.
              ref: entry.markedPhotoRef ?? entry.photoRef,
              loadPhoto: loadPhoto,
              noPhotoLabel: l10n.historyNoPhoto,
              missingLabel: l10n.historyPhotoMissing,
            ),
            SizedBox(width: spacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.historyDate(entry.recordedAt),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (entry.isOpen)
                        _Tag(
                          text: l10n.historyVisitOpen,
                          colour: status.pruefen,
                        ),
                    ],
                  ),
                  SizedBox(height: spacing.s4),
                  if (area == null)
                    Text(
                      l10n.historyNoMeasurements,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: status.luecke,
                      ),
                    )
                  else ...[
                    Text(
                      l10n.historyArea(_rounded(area)),
                      style: theme.textTheme.headlineSmall,
                    ),
                    if (change != null)
                      Text(
                        // Direction is in the words, never in colour alone
                        // (`23-a11y.md`) and not in a minus sign a gloved hand
                        // can miss in sunlight.
                        switch (change) {
                          0 => l10n.historyAreaUnchanged,
                          < 0 => l10n.historyAreaDecrease(_rounded(-change)),
                          _ => l10n.historyAreaIncrease(_rounded(change)),
                        },
                        style: theme.textTheme.bodyMedium?.copyWith(
                          // Growth is the alarm signal, so it may not be the
                          // quieter of the two: the amber that means "look at
                          // this" elsewhere in the app means it here too.
                          color: switch (change) {
                            0 => theme.colorScheme.onSurfaceVariant,
                            < 0 => status.sicher,
                            _ => status.pruefen,
                          },
                        ),
                      ),
                  ],
                  if (depth != null)
                    Text(
                      l10n.historyDepth(_rounded(depth)),
                      style: theme.textTheme.bodyMedium,
                    ),
                  if (entry.closedWithGaps) ...[
                    SizedBox(height: spacing.s4),
                    Text(
                      l10n.historyVisitWithGaps,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One decimal is what the measurements carry; more would suggest precision
  /// a folding rule against a wound does not have.
  static num _rounded(double value) => (value * 10).round() / 10;
}

/// A small label such as "visit open".
class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.colour});

  final String text;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.s8,
        vertical: spacing.s4,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: colour),
        borderRadius: BorderRadius.circular(spacing.r8),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(color: colour),
      ),
    );
  }
}
