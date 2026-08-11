import '../capture/field_proposal.dart';
import '../catalog/exudation.dart';
import '../catalog/tissue_distribution.dart';

/// The confirmed values of one visit, however they were entered.
///
/// Both ways into the record end here: the confirmation view writes what the
/// nurse accepted, the card mode writes what she selected. Nothing downstream
/// can tell the two apart — and nothing should, because a value is a value
/// once she has stood behind it.
///
/// A field that has no entry is a gap. Gaps are allowed and stay visible; see
/// `docs/ux/flows.md`.
class VisitDraft {
  const VisitDraft({this.values = const {}});

  /// Confirmed values by slot id; see [FieldProposal.slotId].
  final Map<String, VisitValue> values;

  /// The value stored for [slotId], or null when the field is still a gap.
  VisitValue? operator [](String slotId) => values[slotId];

  /// Whether [slotId] carries a value.
  bool has(String slotId) => values.containsKey(slotId);

  /// The slots from [expected] that are still empty, in the given order.
  Iterable<String> gapsAmong(Iterable<String> expected) =>
      expected.where((slot) => !has(slot));

  /// Returns a copy with [value] stored for [slotId].
  VisitDraft withValue(String slotId, VisitValue value) =>
      VisitDraft(values: {...values, slotId: value});

  /// Returns a copy with [slotId] cleared back to a gap.
  VisitDraft without(String slotId) =>
      VisitDraft(values: {...values}..remove(slotId));

  /// Returns a copy with every accepted proposal from [entries] written in.
  ///
  /// Entries without a value, or ones the nurse threw away, leave their slot
  /// untouched — an accepted decision never fills a neighbouring gap.
  VisitDraft withProposals(Iterable<FieldProposal> proposals) {
    final merged = {...values};
    for (final proposal in proposals) {
      merged[proposal.slotId] = VisitValue.fromProposal(proposal);
    }
    return VisitDraft(values: merged);
  }

  /// The tissue shares entered so far, or null when none were.
  ///
  /// Returns a [TissueDistribution] only when the shares add up to 100 — the
  /// invariant of the finding. While the nurse is still distributing them the
  /// draft holds the individual values and this stays null.
  TissueDistribution? get tissueDistribution {
    final shares = <TissueType, int>{};
    for (final type in TissueType.values) {
      final value = values['tissue.${type.name}'];
      if (value is PercentValue) shares[type] = value.percent;
    }
    if (shares.isEmpty) return null;
    if (TissueDistribution.validate(shares) != null) return null;
    return TissueDistribution(shares);
  }

  /// How many percent of the wound bed are not distributed yet.
  ///
  /// Negative when more than a whole wound has been assigned. Drawn as a
  /// remainder rather than reported as an error: the nurse is distributing a
  /// whole, and seeing what is left is the natural way to do that.
  int get tissueRemainder {
    var assigned = 0;
    for (final type in TissueType.values) {
      final value = values['tissue.${type.name}'];
      if (value is PercentValue) assigned += value.percent;
    }
    return 100 - assigned;
  }
}

/// One confirmed value in a [VisitDraft].
sealed class VisitValue {
  const VisitValue();

  /// Lifts a confirmed [proposal] into a stored value.
  factory VisitValue.fromProposal(FieldProposal proposal) =>
      switch (proposal) {
        MeasurementProposal(:final centimetres) => CentimetreValue(centimetres),
        TissueShareProposal(:final percent) => PercentValue(percent),
        PainScoreProposal(:final score) => ScoreValue(score),
        ExudateAmountProposal(:final amount) => ExudateAmountValue(amount),
        ExudateKindProposal(:final kind) => ExudateKindValue(kind),
      };
}

/// A length in centimetres.
class CentimetreValue extends VisitValue {
  const CentimetreValue(this.centimetres);

  final double centimetres;

  @override
  bool operator ==(Object other) =>
      other is CentimetreValue && other.centimetres == centimetres;

  @override
  int get hashCode => centimetres.hashCode;
}

/// A share of the wound bed in percent.
class PercentValue extends VisitValue {
  const PercentValue(this.percent);

  final int percent;

  @override
  bool operator ==(Object other) =>
      other is PercentValue && other.percent == percent;

  @override
  int get hashCode => percent.hashCode;
}

/// A rating on the 0-10 pain scale.
class ScoreValue extends VisitValue {
  const ScoreValue(this.score);

  final int score;

  @override
  bool operator ==(Object other) => other is ScoreValue && other.score == score;

  @override
  int get hashCode => score.hashCode;
}

/// The estimated amount of exudate.
class ExudateAmountValue extends VisitValue {
  const ExudateAmountValue(this.amount);

  final ExudateAmount amount;

  @override
  bool operator ==(Object other) =>
      other is ExudateAmountValue && other.amount == amount;

  @override
  int get hashCode => amount.hashCode;
}

/// One observed kind of exudate.
class ExudateKindValue extends VisitValue {
  const ExudateKindValue(this.kind);

  final ExudateKind kind;

  @override
  bool operator ==(Object other) =>
      other is ExudateKindValue && other.kind == kind;

  @override
  int get hashCode => kind.hashCode;
}
