import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/text/field_presentation.dart';
import '../../../shared/widgets/photo_thumbnail.dart';
import 'closing_view_model.dart';
import 'widgets/visit_chrome.dart';

/// Where the visit is closed.
///
/// The rule this screen exists for: **a gap may travel, an unclear value may
/// not.** Missing fields are named, counted and tappable, and they never block
/// closing — the alternative would be a nurse who leaves the flat with an open
/// record, and that is exactly the evening in the office the app is meant to
/// remove. What the visit is recorded as does change, and that distinction
/// survives into the office.
class ClosingScreen extends StatelessWidget {
  const ClosingScreen({
    required this.summary,
    this.photoRef,
    this.loadPhoto,
    this.onFinish,
    this.onFillGap,
    this.onBack,
    this.onSelectStep,
    super.key,
  });

  final ClosingSummary summary;

  /// Handle of the photo that travels with the visit, marked copy preferred.
  final String? photoRef;

  final PhotoLoader? loadPhoto;

  /// Called with whether the visit closes with gaps.
  final ValueChanged<bool>? onFinish;

  /// Called with the slot the nurse wants to fill after all.
  final ValueChanged<String>? onFillGap;

  /// Called to return to the record without closing.
  final VoidCallback? onBack;

  /// Called with the step of the visit the nurse tapped in the band.
  final void Function(VisitStep step)? onSelectStep;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // All four segments filled: this is the last step, and the band
            // is where the visit says so.
            Padding(
              padding: EdgeInsets.only(top: spacing.s8),
              child: VisitBand(
                current: VisitStep.closing,
                onSelect: onSelectStep,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  spacing.s16,
                  0,
                  spacing.s16,
                  spacing.s16,
                ),
                children: [
                  _Anchor(summary: summary),
                  SizedBox(height: spacing.s24),
                  _WhatTravels(
                    summary: summary,
                    photoRef: photoRef,
                    loadPhoto: loadPhoto,
                  ),
                  if (!summary.tissueAddsUp) ...[
                    SizedBox(height: spacing.s12),
                    _TissueLine(remainder: summary.tissueRemainder),
                  ],
                  if (summary.gapSlots.isNotEmpty) ...[
                    SizedBox(height: spacing.s24),
                    _GapList(slots: summary.gapSlots, onFillGap: onFillGap),
                  ],
                ],
              ),
            ),
            _FinishBar(summary: summary, onFinish: onFinish, onBack: onBack),
          ],
        ),
      ),
    );
  }
}

/// The one line that answers "where do I stand" without reading further.
class _Anchor extends StatelessWidget {
  const _Anchor({required this.summary});

  final ClosingSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    final complete = summary.isComplete;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing.s16),
        Row(
          children: [
            Icon(
              complete ? Icons.check_circle_outline : Icons.pending_outlined,
              // Never colour alone: the icon differs as well, and the headline
              // says the same thing in words (`23-a11y.md`).
              color: complete ? status.sicher : status.pruefen,
              size: 32,
            ),
            SizedBox(width: spacing.s12),
            Expanded(
              child: Text(
                complete
                    ? l10n.closingComplete
                    : l10n.closingGaps(summary.gapSlots.length),
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        // Only the sentence that is not already on the card below: how many
        // values were recorded is stated there, and twice is once too often.
        if (!complete) ...[
          SizedBox(height: spacing.s8),
          Text(
            l10n.closingGapsHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// What actually travels with the visit, on one card.
///
/// The photo is shown, not described: before leaving the flat the question is
/// whether the picture is really in the record, and a sentence saying "one
/// photo" is a claim while a thumbnail is the thing itself.
class _WhatTravels extends StatelessWidget {
  const _WhatTravels({
    required this.summary,
    required this.photoRef,
    required this.loadPhoto,
  });

  final ClosingSummary summary;
  final String? photoRef;
  final PhotoLoader? loadPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    final marked = summary.markedPhotoCount;
    final photoText = [
      l10n.closingPhoto(summary.photoCount),
      if (marked > 0) l10n.closingPhotoMarked(marked),
    ].join(' · ');
    final loader = loadPhoto;

    return MergeSemantics(
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(spacing.r12),
        ),
        padding: EdgeInsets.all(spacing.s16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loader != null)
              PhotoThumbnail(
                ref: photoRef,
                loadPhoto: loader,
                size: spacing.s64,
                noPhotoLabel: l10n.woundNoPhoto,
                missingLabel: l10n.woundPhotoMissing,
              )
            else
              Icon(
                summary.hasPhoto
                    ? Icons.photo_camera_outlined
                    : Icons.no_photography_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            SizedBox(width: spacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(photoText, style: theme.textTheme.bodyLarge),
                  SizedBox(height: spacing.s4),
                  Text(
                    l10n.closingRecorded(summary.recordedSlots.length),
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (!summary.hasPhoto) ...[
                    SizedBox(height: spacing.s4),
                    Text(
                      l10n.closingNoPhotoHint,
                      style: theme.textTheme.labelSmall?.copyWith(
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
}

/// Shown when the wound bed does not add up to 100 percent.
class _TissueLine extends StatelessWidget {
  const _TissueLine({required this.remainder});

  final int remainder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.percent, color: status.pruefen),
          SizedBox(width: spacing.s12),
          Expanded(
            child: Text(
              l10n.closingTissueRemainder(100 - remainder),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

/// The missing fields, each one a way back into the record.
class _GapList extends StatelessWidget {
  const _GapList({required this.slots, required this.onFillGap});

  final List<String> slots;
  final ValueChanged<String>? onFillGap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.closingMissingHeader,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: spacing.s8),
        for (final slot in slots)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.s8),
            child: Material(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(spacing.r12),
              child: InkWell(
                onTap: onFillGap == null ? null : () => onFillGap!(slot),
                borderRadius: BorderRadius.circular(spacing.r12),
                child: Container(
                  constraints: BoxConstraints(minHeight: spacing.s64),
                  padding: EdgeInsets.symmetric(horizontal: spacing.s16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          FieldPresentation.label(l10n, slot),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      Text(
                        l10n.confidenceMissing,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: status.luecke,
                        ),
                      ),
                      SizedBox(width: spacing.s8),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The primary action and the way back.
class _FinishBar extends StatelessWidget {
  const _FinishBar({
    required this.summary,
    required this.onFinish,
    required this.onBack,
  });

  final ClosingSummary summary;
  final ValueChanged<bool>? onFinish;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final withGaps = summary.closesWithGaps;

    // The same ground and hairline as the thumb zone on every other screen
    // of the visit.
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.fromLTRB(
          spacing.s16,
          spacing.s8,
          spacing.s16,
          spacing.s16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onBack != null) ...[
              TextButton(onPressed: onBack, child: Text(l10n.closingBack)),
              SizedBox(height: spacing.s8),
            ],
            SizedBox(
              height: spacing.s96,
              child: FilledButton(
                onPressed: onFinish == null
                    ? null
                    : () {
                        // Announced rather than only shown: the nurse is packing
                        // up and may not be looking at the screen when this
                        // lands (`23-a11y.md`).
                        SemanticsService.sendAnnouncement(
                          View.of(context),
                          l10n.closingDone,
                          Directionality.of(context),
                        );
                        onFinish!(withGaps);
                      },
                style: FilledButton.styleFrom(
                  // Through the button's own style: a text style taken from the
                  // theme carries onSurface and would undo the contrast against
                  // the filled background.
                  textStyle: theme.textTheme.titleLarge,
                ),
                // Deliberately different wording, not just a different state:
                // closing with gaps is a decision, and it should read like one.
                child: Text(
                  withGaps ? l10n.closingFinishWithGaps : l10n.closingFinish,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
