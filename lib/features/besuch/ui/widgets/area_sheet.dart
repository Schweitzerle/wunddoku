import 'package:flutter/material.dart';

import '../../../../domain/model/visit_standing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../card_entry_view_model.dart';
import 'finding_cards.dart';

/// One area of the finding, filled in without leaving the visit.
///
/// Changing a single value is not a change of place. A sheet keeps the visit
/// underneath, so the row that sent the nurse here is still there when she is
/// done — and the tick behind the sheet is the answer to whether it worked.
class AreaSheet extends StatelessWidget {
  const AreaSheet({required this.area, required this.viewModel, super.key});

  final StandingAreaId area;
  final CardEntryViewModel viewModel;

  /// Shows the sheet for [area] and returns when it is closed.
  static Future<void> show(
    BuildContext context, {
    required StandingAreaId area,
    required CardEntryViewModel viewModel,
  }) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    // The card can outgrow half the screen at large text sizes; without this
    // the sheet would clip it rather than scroll.
    constraints: const BoxConstraints(maxHeight: double.infinity),
    builder: (_) => AreaSheet(area: area, viewModel: viewModel),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;

    return SafeArea(
      top: false,
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            spacing.s16,
            0,
            spacing.s16,
            spacing.s16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              switch (area) {
                StandingAreaId.measurements => MeasurementCard(
                  viewModel: viewModel,
                ),
                StandingAreaId.woundBed => WoundBedCard(viewModel: viewModel),
                StandingAreaId.exudate => ExudationCard(viewModel: viewModel),
                // The photo has a screen of its own; it never reaches here.
                StandingAreaId.pain ||
                StandingAreaId.photo => PainCard(viewModel: viewModel),
              },
              SizedBox(height: spacing.s16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cardsDone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
