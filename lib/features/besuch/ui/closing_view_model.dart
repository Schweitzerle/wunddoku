import '../../../domain/catalog/tissue_distribution.dart';
import '../../../domain/model/visit_draft.dart';

/// What the closing screen has to say about a visit.
///
/// Plain data derived from the draft, so the rule that decides everything here
/// is checkable without a widget: **a gap may travel, an unclear value may
/// not.** Unclear values never reach this screen — the confirmation blocks
/// them — so closing is always possible, and the only question is whether the
/// visit is recorded as complete or as complete with named gaps.
class ClosingSummary {
  ClosingSummary({
    required VisitDraft draft,
    required this.expectedSlots,
    required this.photoCount,
    required this.markedPhotoCount,
  }) : recordedSlots = [
         for (final slot in expectedSlots)
           if (draft.has(slot)) slot,
       ],
       gapSlots = draft.gapsAmong(expectedSlots).toList(),
       tissueRemainder = draft.tissueRemainder,
       _hasTissueValues = TissueType.values.any(
         (tissue) => draft.has('tissue.${tissue.name}'),
       );

  /// Every slot this visit is expected to carry, in reading order.
  final List<String> expectedSlots;

  /// The slots that carry a value.
  final List<String> recordedSlots;

  /// The slots still empty, in the same order.
  final List<String> gapSlots;

  /// How much of the wound bed is unassigned, in percent.
  ///
  /// Zero once the tissue shares add up to 100. Not a gap of its own: the
  /// remainder can be deliberate while the visit is being recorded, and it is
  /// shown rather than silently rounded away.
  final int tissueRemainder;

  final int photoCount;
  final int markedPhotoCount;

  /// Whether any share of the wound bed was entered at all.
  final bool _hasTissueValues;

  /// Whether every expected field carries a value.
  bool get isComplete => gapSlots.isEmpty;

  /// Whether the wound bed adds up.
  ///
  /// Kept apart from [isComplete] because a share of 100 is a statement about
  /// the same fields, not an extra field. A visit where no share was entered
  /// at all adds up by definition — those fields are gaps, and saying "0 %
  /// instead of 100 %" on top of the gap list is noise, not a finding.
  bool get tissueAddsUp => !_hasTissueValues || tissueRemainder == 0;

  /// Whether the visit carries at least one photo.
  bool get hasPhoto => photoCount > 0;

  /// What the closed visit is recorded as.
  ///
  /// The distinction survives into the office: a finding that was left
  /// incomplete on purpose must stay distinguishable from a complete one.
  bool get closesWithGaps => !isComplete || !tissueAddsUp;
}
