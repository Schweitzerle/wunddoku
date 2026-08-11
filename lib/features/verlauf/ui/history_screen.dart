import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../domain/model/wound_history.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import 'widgets/area_chart.dart';

/// Reads the photo behind a handle, or null when it cannot be read.
typedef PhotoLoader = Future<Uint8List?> Function(String ref);

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
    this.onStartVisit,
    super.key,
  });

  final WoundHistory history;
  final PhotoLoader loadPhoto;

  /// Called from the empty state.
  final VoidCallback? onStartVisit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: SafeArea(
        child: history.isEmpty
            ? _EmptyState(onStartVisit: onStartVisit)
            : _Course(history: history, loadPhoto: loadPhoto),
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
  const _Course({required this.history, required this.loadPhoto});

  final WoundHistory history;
  final PhotoLoader loadPhoto;

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
        if (history.isComparable) ...[
          Text(
            l10n.historyAreaLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AreaChart(series: history.areaSeries, label: l10n.historyAreaLabel),
          Text(
            l10n.historyAreaApprox,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ] else
          Text(
            l10n.historySingleHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        SizedBox(height: spacing.s24),
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
            _Thumbnail(
              // The marked copy where there is one: the outline is what makes
              // two photos comparable at a glance.
              ref: entry.markedPhotoRef ?? entry.photoRef,
              loadPhoto: loadPhoto,
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
                        l10n.historyAreaChange(_rounded(change)),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          // Direction is in the sign as well, never in colour
                          // alone (`23-a11y.md`).
                          color: change <= 0
                              ? status.sicher
                              : theme.colorScheme.onSurfaceVariant,
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

/// The photo of a visit, small.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.ref, required this.loadPhoto});

  final String? ref;
  final PhotoLoader loadPhoto;

  /// Edge length of the thumbnail in logical pixels.
  static const _size = 72.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;
    final status = context.statusColors;
    final handle = ref;

    return ClipRRect(
      borderRadius: BorderRadius.circular(spacing.r8),
      child: SizedBox.square(
        dimension: _size,
        child: ColoredBox(
          color: status.mediaGround,
          child: handle == null
              ? _Placeholder(text: l10n.historyNoPhoto)
              : FutureBuilder<Uint8List?>(
                  future: loadPhoto(handle),
                  builder: (context, snapshot) => switch (snapshot) {
                    AsyncSnapshot(hasError: true) ||
                    AsyncSnapshot(
                      connectionState: ConnectionState.done,
                      data: null,
                    ) => _Placeholder(text: l10n.historyPhotoMissing),
                    AsyncSnapshot(:final data?) => Image.memory(
                      data,
                      fit: BoxFit.cover,
                      // A wound photo is several times the size of this box;
                      // decoding it at full resolution for a thumbnail is
                      // memory a field phone does not have to spare.
                      cacheWidth:
                          (_size * MediaQuery.devicePixelRatioOf(context))
                              .round(),
                    ),
                    _ => const SizedBox.shrink(),
                  },
                ),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.s4),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
