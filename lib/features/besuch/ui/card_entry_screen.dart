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
class CardEntryScreen extends StatefulWidget {
  const CardEntryScreen({
    required this.viewModel,
    this.focusSlot,
    this.onDone,
    super.key,
  });

  final CardEntryViewModel viewModel;

  /// The field this screen was opened for, if it was opened for one.
  ///
  /// Its card is brought into view: arriving at the top of three cards when
  /// one of them is the reason for being here costs a scroll with gloves on.
  final String? focusSlot;

  /// Called with the values entered when the nurse is finished.
  final void Function(VisitDraft draft)? onDone;

  @override
  State<CardEntryScreen> createState() => _CardEntryScreenState();
}

class _CardEntryScreenState extends State<CardEntryScreen> {
  final _woundBed = GlobalKey();
  final _measurements = GlobalKey();
  final _exudation = GlobalKey();
  final _pain = GlobalKey();

  @override
  void initState() {
    super.initState();
    final slot = widget.focusSlot;
    if (slot == null) return;
    final key = switch (slot.split('.').first) {
      'tissue' => _woundBed,
      'measurement' => _measurements,
      'pain' => _pain,
      _ => _exudation,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context != null) Scrollable.ensureVisible(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final onDone = widget.onDone;
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
                    WoundBedCard(key: _woundBed, viewModel: viewModel),
                    SizedBox(height: spacing.s12),
                    MeasurementCard(key: _measurements, viewModel: viewModel),
                    SizedBox(height: spacing.s12),
                    ExudationCard(key: _exudation, viewModel: viewModel),
                    SizedBox(height: spacing.s12),
                    PainCard(key: _pain, viewModel: viewModel),
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
