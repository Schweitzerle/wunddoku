import 'package:flutter/material.dart';

import '../../../domain/model/wound_history.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/text/field_presentation.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/photo_thumbnail.dart';

/// One visit of a wound, in full.
///
/// The course answers "is the treatment working"; this answers "what did we
/// actually write down that day". It is where a question from the office ends
/// up — and where a gap has to be visible as a gap, because a visit that
/// recorded nothing about the wound margin is a different fact from a visit
/// where the margin was normal.
class VisitDetailScreen extends StatelessWidget {
  const VisitDetailScreen({
    required this.entry,
    required this.areaChange,
    required this.expectedSlots,
    required this.loadPhoto,
    this.transcript,
    super.key,
  });

  final HistoryEntry entry;

  /// Against the visit before it, or null when there is none.
  final double? areaChange;

  /// Everything this kind of visit is expected to record.
  final List<String> expectedSlots;

  final PhotoLoader loadPhoto;

  /// What was said that day, verbatim.
  ///
  /// The evidence that the finding came from the nurse's own words — and the
  /// only place where a misheard term ("Excusat" for "Exsudat") can still be
  /// recognised as one weeks later. Null on a visit entered through the
  /// cards, where nothing was spoken.
  final String? transcript;

  /// One decimal, like everywhere the area is shown.
  static num _rounded(double value) => (value * 10).round() / 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    final recorded = [
      for (final slot in expectedSlots)
        if (entry.draft[slot] != null) slot,
    ];
    // Through the draft rather than by slot, so a wound bed whose shares add
    // up is not reported as two missing entries here and as complete on the
    // visit screen.
    final gaps = entry.draft.gapsAmong(expectedSlots).toList();
    final area = entry.areaCm2;
    final change = areaChange;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(top: spacing.s8, bottom: spacing.s24),
          children: [
            Row(
              children: [
                if (Navigator.of(context).canPop())
                  const BackButton()
                else
                  SizedBox(width: spacing.s16),
                Expanded(
                  child: Text(
                    l10n.historyTitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SizedBox(width: spacing.s16),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.s16,
                spacing.s8,
                spacing.s16,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.historyDate(entry.recordedAt),
                    style: theme.textTheme.headlineMedium,
                  ),
                  SizedBox(height: spacing.s4),
                  // How the visit was left. "Closed with gaps" is not a
                  // failure state, it is what the record says about that day
                  // and it travels to the office.
                  Text(
                    switch (entry) {
                      HistoryEntry(isOpen: true) => l10n.historyVisitOpen,
                      HistoryEntry(closedWithGaps: true) =>
                        l10n.historyVisitWithGaps,
                      _ => l10n.visitDetailComplete,
                    },
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: entry.isOpen || entry.closedWithGaps
                          ? status.pruefen
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.s16),
            // The photo at the size a wound is looked at, not at thumbnail
            // size: this screen is opened *because* someone wants to see it.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.s16),
              child: LayoutBuilder(
                builder: (context, constraints) => PhotoThumbnail(
                  ref: entry.markedPhotoRef ?? entry.photoRef,
                  loadPhoto: loadPhoto,
                  size: constraints.maxWidth,
                  noPhotoLabel: l10n.historyNoPhoto,
                  missingLabel: l10n.historyPhotoMissing,
                ),
              ),
            ),
            if (area != null) ...[
              SizedBox(height: spacing.s16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s16),
                child: MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.historyArea(_rounded(area)),
                        style: theme.textTheme.headlineLarge,
                      ),
                      if (change != null)
                        Text(
                          switch (change) {
                            0 => l10n.historyAreaUnchanged,
                            < 0 => l10n.historyAreaDecrease(_rounded(-change)),
                            _ => l10n.historyAreaIncrease(_rounded(change)),
                          },
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: change > 0
                                ? status.pruefen
                                : theme.colorScheme.onSurfaceVariant,
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
                ),
              ),
            ],
            if (recorded.isNotEmpty) ...[
              _SectionHeading(text: l10n.visitDetailRecorded),
              for (final slot in recorded)
                _ValueRow(
                  label: FieldPresentation.label(l10n, slot),
                  value: FieldPresentation.storedValue(
                    l10n,
                    entry.draft[slot]!,
                  ),
                ),
            ],
            if (gaps.isNotEmpty) ...[
              _SectionHeading(text: l10n.visitDetailGaps),
              for (final slot in gaps)
                _ValueRow(
                  label: FieldPresentation.label(l10n, slot),
                  value: l10n.confidenceMissing,
                  quiet: true,
                ),
            ],
            if (transcript != null && transcript!.isNotEmpty) ...[
              _SectionHeading(text: l10n.provenanceTitle),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.s16),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    spacing.s12,
                    spacing.s8,
                    spacing.s12,
                    spacing.s8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: theme.colorScheme.outline,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    transcript!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.s16,
        spacing.s24,
        spacing.s16,
        spacing.s8,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// One field of the record: what it is called, and what it holds.
class _ValueRow extends StatelessWidget {
  const _ValueRow({
    required this.label,
    required this.value,
    this.quiet = false,
  });

  final String label;
  final String value;

  /// Whether this row states an absence rather than a value.
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    return MergeSemantics(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.s16,
          vertical: spacing.s8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(width: spacing.s16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: quiet
                    ? theme.textTheme.bodyMedium?.copyWith(
                        color: status.luecke,
                      )
                    : theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
