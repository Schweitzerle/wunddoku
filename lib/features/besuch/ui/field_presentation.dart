import '../../../domain/capture/field_proposal.dart';
import '../../../domain/catalog/exudation.dart';
import '../../../domain/catalog/tissue_distribution.dart';
import '../../../l10n/app_localizations.dart';

/// Turns slot ids and proposals into the words that appear on screen.
///
/// Lives next to the view rather than in the domain because it needs the
/// localisation; the domain stays free of Flutter. The specialist terms come
/// from the customer's catalogue and are not reworded — see
/// `docs/fachkataloge.md`.
abstract final class FieldPresentation {
  /// The label of the field [slotId] fills.
  ///
  /// Falls back to the raw id for slots that have no label yet, which keeps an
  /// unexpected proposal visible instead of swallowing it.
  static String label(AppLocalizations l10n, String slotId) => switch (slotId) {
    'measurement.lengthCm' => l10n.fieldLengthCm,
    'measurement.widthCm' => l10n.fieldWidthCm,
    'measurement.depthCm' => l10n.fieldDepthCm,
    'tissue.necrosis' => l10n.fieldTissueNecrosis,
    'tissue.fibrin' => l10n.fieldTissueFibrin,
    'tissue.granulation' => l10n.fieldTissueGranulation,
    'tissue.epithelialisation' => l10n.fieldTissueEpithelialisation,
    'tissue.other' => l10n.fieldTissueOther,
    'exudate.amount' => l10n.fieldExudateAmount,
    'pain.score' => l10n.fieldPainScore,
    _ when slotId.startsWith('exudate.kind.') => l10n.fieldExudateKind,
    _ => slotId,
  };

  /// The value of [proposal] as the nurse reads it, units included.
  static String value(AppLocalizations l10n, FieldProposal proposal) =>
      switch (proposal) {
        MeasurementProposal(:final centimetres) => l10n.valueCentimetres(
          _formatCentimetres(centimetres),
        ),
        TissueShareProposal(:final percent) => l10n.valuePercent(percent),
        PainScoreProposal(:final score) => l10n.valuePainScore(score),
        ExudateAmountProposal(:final amount) => _amount(l10n, amount),
        ExudateKindProposal(:final kind) => _kind(l10n, kind),
      };

  /// German decimal notation, without a trailing zero on whole numbers.
  ///
  /// `3.5` reads as `3,5`, `2.0` as `2` — a measurement written `2,0 cm`
  /// suggests a precision the ruler does not have.
  static String _formatCentimetres(double centimetres) {
    final rounded = (centimetres * 10).round() / 10;
    final text = rounded == rounded.roundToDouble()
        ? rounded.toStringAsFixed(0)
        : rounded.toStringAsFixed(1);
    return text.replaceAll('.', ',');
  }

  static String _amount(AppLocalizations l10n, ExudateAmount amount) =>
      switch (amount) {
        ExudateAmount.none => l10n.exudateAmountNone,
        ExudateAmount.slight => l10n.exudateAmountSlight,
        ExudateAmount.moderate => l10n.exudateAmountModerate,
        ExudateAmount.heavy => l10n.exudateAmountHeavy,
      };

  static String _kind(AppLocalizations l10n, ExudateKind kind) =>
      switch (kind) {
        ExudateKind.serous => l10n.exudateKindSerous,
        ExudateKind.purulent => l10n.exudateKindPurulent,
        ExudateKind.bloody => l10n.exudateKindBloody,
      };

  /// The slots the wound-bed card expects in a visit.
  ///
  /// Declaring them explicitly is what turns "nothing was said" into a visible
  /// gap rather than a missing row. Order is the reading order of the card;
  /// the confirmation view re-sorts by urgency on top of it.
  static const List<String> woundBedSlots = [
    'measurement.lengthCm',
    'measurement.widthCm',
    'measurement.depthCm',
    'tissue.necrosis',
    'tissue.fibrin',
    'tissue.granulation',
    'tissue.epithelialisation',
    'exudate.amount',
    'pain.score',
  ];

  /// Tissue slot ids in the order of the catalogue.
  static List<String> get tissueSlots => [
    for (final tissue in TissueType.values) 'tissue.${tissue.name}',
  ];
}
