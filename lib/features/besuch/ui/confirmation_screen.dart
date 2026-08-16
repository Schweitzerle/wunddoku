import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import 'confirmation_view_model.dart';
import 'widgets/confirmation_row.dart';
import 'widgets/confirmation_zones.dart';
import 'widgets/provenance_sheet.dart';
import 'widgets/visit_chrome.dart';

/// The screen where the nurse checks what the system understood.
///
/// Deliberately placed *after* the dressing is back on: during the recording
/// both hands are busy and the eyes are on the wound, so capture and checking
/// are separated in time rather than crammed into one screen. See
/// `docs/ux/flows.md`.
class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({
    required this.viewModel,
    this.visitDate,
    this.onAccept,
    this.onBackToCapture,
    this.onEnterValue,
    this.onSelectStep,
    super.key,
  });

  final ConfirmationViewModel viewModel;

  /// When the open visit was started, for the visit header.
  final DateTime? visitDate;

  /// Called when the checked values are taken into the record.
  final VoidCallback? onAccept;

  /// Called from the empty state to return to the recording step.
  final VoidCallback? onBackToCapture;

  /// Called with the slot the nurse wants to fill in by hand.
  ///
  /// The repair for a proposal that is wrong or was never understood: the
  /// card for that field opens on top of this screen, so the decisions still
  /// waiting here are not lost on the way.
  final void Function(String slotId)? onEnterValue;

  /// Called with the step of the visit the nurse tapped in the band.
  final void Function(VisitStep step)? onSelectStep;

  @override
  Widget build(BuildContext context) {
    // The band rather than a title: "Prüfen" as a word in a bar said where
    // the screen was, not where the visit was.
    final header = VisitHeader(
      step: VisitStep.check,
      visitDate: visitDate,
      onBack: Navigator.of(context).canPop()
          ? () => Navigator.of(context).maybePop()
          : null,
      onSelectStep: onSelectStep,
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Expanded(
                child: viewModel.hasRecording
                    ? _ConfirmationBody(
                        viewModel: viewModel,
                        onAccept: onAccept,
                        onEnterValue: onEnterValue,
                      )
                    : _EmptyState(onBackToCapture: onBackToCapture),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmationBody extends StatelessWidget {
  const _ConfirmationBody({
    required this.viewModel,
    required this.onAccept,
    required this.onEnterValue,
  });

  final ConfirmationViewModel viewModel;
  final VoidCallback? onAccept;
  final void Function(String slotId)? onEnterValue;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final attention = viewModel.attentionEntries;

    // Three zones instead of one flat list: what needs work is drawn large,
    // what is missing is one collapsed line, what is done sits compact at the
    // bottom. The screen gives its space in proportion to the work left.
    return Column(
      // Without stretch the head block shrinks to its widest line and the
      // outer Column centres it, so it no longer aligns with the list below.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryBar(viewModel: viewModel),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              spacing.s16,
              0,
              spacing.s16,
              spacing.s24,
            ),
            children: [
              for (final entry in attention) ...[
                ConfirmationRow(
                  // Keyed by slot so a row keeps its element when the list
                  // re-sorts after a decision.
                  key: ValueKey(entry.slotId),
                  entry: entry,
                  quote: entry.proposal?.span.textIn(viewModel.transcript),
                  onShowProvenance: () => _showProvenance(context, entry),
                  onAccept: () => viewModel.accept(entry.slotId),
                  onDiscard: () => viewModel.discard(entry.slotId),
                  onEnter: onEnterValue == null
                      ? null
                      : () => onEnterValue!(entry.slotId),
                ),
                SizedBox(height: spacing.s12),
              ],
              GapZone(entries: viewModel.gapEntries),
              SettledZone(
                entries: viewModel.settledEntries,
                onShowProvenance: (slotId) => _showProvenance(
                  context,
                  viewModel.entries.firstWhere((e) => e.slotId == slotId),
                ),
              ),
            ],
          ),
        ),
        _AcceptBar(viewModel: viewModel, onAccept: onAccept),
      ],
    );
  }

  void _showProvenance(BuildContext context, ConfirmationEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ProvenanceSheet(
        transcript: viewModel.transcript,
        span: entry.proposal?.span,
      ),
    );
  }
}

/// The anchor at the head of the screen.
///
/// How much is left to do is the most important thing on this screen, so it
/// is set as a headline rather than as fine print — the previous version put
/// it in 13 px grey and it read like a footnote.
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.viewModel});

  final ConfirmationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;
    final open = viewModel.attentionCount;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.s16,
        spacing.s8,
        spacing.s16,
        spacing.s20,
      ),
      child: Semantics(
        // Announced when the numbers change, so the nurse learns that a
        // decision landed without having to look for it.
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              open == 0
                  ? l10n.confirmationAllClear
                  : l10n.confirmationNeedsDecision(open),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: open == 0 ? theme.colorScheme.onSurface : status.pruefen,
              ),
            ),
            SizedBox(height: spacing.s4),
            Text(
              l10n.confirmationSummary(
                viewModel.settledCount,
                viewModel.attentionCount,
                viewModel.gapCount,
              ),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The primary action, plus the reason when it is blocked.
class _AcceptBar extends StatelessWidget {
  const _AcceptBar({required this.viewModel, required this.onAccept});

  final ConfirmationViewModel viewModel;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final status = context.statusColors;
    final blocked = !viewModel.canAccept;

    // The same ground and the same line as the thumb zone on the capture
    // screen: two surface tones in this palette are 1.09:1 apart, which is
    // no boundary at all in daylight.
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.fromLTRB(
          spacing.s16,
          spacing.s16,
          spacing.s16,
          spacing.s16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (blocked) ...[
              Text(
                l10n.confirmationBlocked(viewModel.blockingCount),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: status.entscheiden,
                ),
              ),
              SizedBox(height: spacing.s8),
            ],
            FilledButton(
              onPressed: blocked ? null : onAccept,
              child: Text(l10n.confirmationAccept),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBackToCapture});

  final VoidCallback? onBackToCapture;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.confirmationEmpty,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.s8),
            Text(
              l10n.confirmationEmptyHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.s32),
            FilledButton(
              onPressed: onBackToCapture,
              child: Text(l10n.confirmationBackToCapture),
            ),
          ],
        ),
      ),
    );
  }
}
