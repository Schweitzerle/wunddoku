import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import 'confirmation_view_model.dart';
import 'widgets/confirmation_row.dart';
import 'widgets/provenance_sheet.dart';

/// The screen where the nurse checks what the system understood.
///
/// Deliberately placed *after* the dressing is back on: during the recording
/// both hands are busy and the eyes are on the wound, so capture and checking
/// are separated in time rather than crammed into one screen. See
/// `docs/ux/flows.md`.
class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({
    required this.viewModel,
    this.onAccept,
    this.onBackToCapture,
    super.key,
  });

  final ConfirmationViewModel viewModel;

  /// Called when the checked values are taken into the record.
  final VoidCallback? onAccept;

  /// Called from the empty state to return to the recording step.
  final VoidCallback? onBackToCapture;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.confirmationTitle)),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => viewModel.hasRecording
            ? _ConfirmationBody(
                viewModel: viewModel,
                onAccept: onAccept,
              )
            : _EmptyState(onBackToCapture: onBackToCapture),
      ),
    );
  }
}

class _ConfirmationBody extends StatelessWidget {
  const _ConfirmationBody({required this.viewModel, required this.onAccept});

  final ConfirmationViewModel viewModel;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final entries = viewModel.entries;

    return Column(
      children: [
        _SummaryBar(viewModel: viewModel),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: spacing.s16),
            itemCount: entries.length,
            separatorBuilder: (_, _) => SizedBox(height: spacing.s8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ConfirmationRow(
                // Keyed by slot so a row keeps its element when the list
                // re-sorts after a decision.
                key: ValueKey(entry.slotId),
                entry: entry,
                onShowProvenance: () => _showProvenance(context, index),
                onAccept: () => viewModel.accept(entry.slotId),
                onDiscard: () => viewModel.discard(entry.slotId),
              );
            },
          ),
        ),
        _AcceptBar(viewModel: viewModel, onAccept: onAccept),
      ],
    );
  }

  void _showProvenance(BuildContext context, int index) {
    final entry = viewModel.entries[index];
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

/// The one-line tally above the list.
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.viewModel});

  final ConfirmationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.s16,
        spacing.s8,
        spacing.s16,
        spacing.s16,
      ),
      child: Semantics(
        // Announced when the numbers change, so the nurse learns that a
        // decision landed without having to look for it.
        liveRegion: true,
        child: Text(
          l10n.confirmationSummary(
            viewModel.settledCount,
            viewModel.attentionCount,
            viewModel.gapCount,
          ),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
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

    return SafeArea(
      minimum: EdgeInsets.fromLTRB(
        spacing.s16,
        spacing.s24,
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
