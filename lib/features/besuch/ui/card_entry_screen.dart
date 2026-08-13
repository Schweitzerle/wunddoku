import 'package:flutter/material.dart';

import '../../../domain/model/visit_draft.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import 'card_entry_view_model.dart';
import 'widgets/finding_cards.dart';

/// The card mode: the way into the record that needs no speech.
///
/// Equal in standing to the spoken path. Everything here is entered by
/// choosing or stepping, never by typing — the nurse wears gloves, and a
/// keyboard is not an option at the bedside.
class CardEntryScreen extends StatelessWidget {
  const CardEntryScreen({required this.viewModel, this.onDone, super.key});

  final CardEntryViewModel viewModel;

  /// Called with the values entered when the nurse is finished.
  final void Function(VisitDraft draft)? onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = context.spacing;

    return Scaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) => SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title in the body at 30, like every other screen: a 56 dp bar
              // cannot carry the size contrast this palette lives on.
              Padding(
                padding: EdgeInsets.only(top: spacing.s8),
                child: Row(
                  children: [
                    if (Navigator.of(context).canPop())
                      const BackButton()
                    else
                      SizedBox(width: spacing.s16),
                    Expanded(
                      child: Text(
                        l10n.cardsTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    SizedBox(width: spacing.s16),
                  ],
                ),
              ),
              SizedBox(height: spacing.s12),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    spacing.s16,
                    spacing.s8,
                    spacing.s16,
                    spacing.s24,
                  ),
                  children: [
                    WoundBedCard(viewModel: viewModel),
                    SizedBox(height: spacing.s12),
                    MeasurementCard(viewModel: viewModel),
                    SizedBox(height: spacing.s12),
                    ExudationCard(viewModel: viewModel),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  spacing.s16,
                  spacing.s16,
                  spacing.s16,
                  spacing.s16,
                ),
                child: SafeArea(
                  top: false,
                  child: FilledButton(
                    // Nothing blocks finishing here. Every value on this screen
                    // was chosen by the nurse herself, so none of it can be a
                    // misread guess — the case the confirmation view guards
                    // against does not exist on this path.
                    onPressed: () => onDone?.call(viewModel.draft),
                    child: Text(l10n.cardsDone),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
