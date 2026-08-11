import 'package:flutter/foundation.dart';

import '../../../domain/capture/field_proposal.dart';

/// What the nurse has decided about one proposed value.
enum FieldDecision {
  /// Not touched yet.
  pending,

  /// Deliberately confirmed, whatever the confidence was.
  accepted,

  /// Rejected — the field stays empty and is shown as a gap.
  discarded,
}

/// One row of the confirmation view: a record field and what is known about
/// it after a recording.
@immutable
class ConfirmationEntry {
  const ConfirmationEntry({
    required this.slotId,
    required this.proposal,
    required this.decision,
  });

  /// Identifies the record field; see [FieldProposal.slotId].
  final String slotId;

  /// What the interpreter heard, or null when the field was not spoken about.
  final FieldProposal? proposal;

  final FieldDecision decision;

  /// Whether the field will stay empty.
  ///
  /// Nothing was said, or the nurse threw the proposal away. Both are gaps and
  /// both are allowed — an empty field is visibly empty, which is the point.
  bool get isGap => proposal == null || decision == FieldDecision.discarded;

  /// Whether this entry keeps the record from being saved.
  ///
  /// Only an undecided low-confidence value does. A gap looks like a gap; a
  /// misheard value looks like a correct one, which is why the two are treated
  /// differently.
  bool get blocksSaving =>
      proposal != null &&
      decision == FieldDecision.pending &&
      proposal!.confidence == ConfidenceTier.low;

  /// Whether the value is settled and goes into the record.
  bool get isSettled =>
      proposal != null &&
      (decision == FieldDecision.accepted ||
          (decision == FieldDecision.pending &&
              proposal!.confidence == ConfidenceTier.high));

  /// Whether the value is worth a second look before accepting.
  bool get needsAttention =>
      proposal != null &&
      decision == FieldDecision.pending &&
      proposal!.confidence != ConfidenceTier.high;

  /// Rank used to sort the list: what needs work comes first.
  ///
  /// Undecided low, then undecided medium, then gaps, then settled values.
  /// Deliberately not the order of the form — under time pressure the nurse
  /// should not have to hunt for the rows that still need her.
  int get sortRank {
    if (blocksSaving) return 0;
    if (needsAttention) return 1;
    if (isGap) return 2;
    return 3;
  }

  ConfirmationEntry copyWith({
    FieldProposal? proposal,
    FieldDecision? decision,
  }) => ConfirmationEntry(
    slotId: slotId,
    proposal: proposal ?? this.proposal,
    decision: decision ?? this.decision,
  );
}

/// Drives the confirmation view.
///
/// Holds the outcome of one recording and the nurse's decisions on it. Kept as
/// a plain [ChangeNotifier] — the visit draft is persisted after every change
/// anyway, so the database, not this object, is the source of truth (see
/// `DECISIONS.md`, 2026-08-10, on doing without a state-management library).
class ConfirmationViewModel extends ChangeNotifier {
  /// Builds the rows for [expectedSlots], filled from [result].
  ///
  /// Every expected slot gets a row even when nothing was said about it —
  /// that is what makes a gap visible instead of merely absent. Proposals for
  /// slots outside [expectedSlots] are appended, so a nurse who mentions
  /// something unasked does not lose it.
  ConfirmationViewModel({
    required List<String> expectedSlots,
    CaptureResult? result,
  }) : _transcript = result?.transcript ?? '' {
    final bySlot = <String, FieldProposal>{};
    for (final proposal in result?.proposals ?? const <FieldProposal>[]) {
      // A later utterance about the same field replaces the earlier one.
      bySlot[proposal.slotId] = proposal;
    }

    final slots = <String>[
      ...expectedSlots,
      ...bySlot.keys.where((slot) => !expectedSlots.contains(slot)),
    ];
    _entries = [
      for (final slot in slots)
        ConfirmationEntry(
          slotId: slot,
          proposal: bySlot[slot],
          decision: FieldDecision.pending,
        ),
    ];
  }

  final String _transcript;
  late List<ConfirmationEntry> _entries;

  /// The verbatim transcript the proposals came from.
  String get transcript => _transcript;

  /// Whether a recording has been interpreted at all.
  bool get hasRecording => _transcript.isNotEmpty;

  /// The rows, most in need of attention first.
  ///
  /// Ties keep the order the slots were declared in, so the list does not
  /// reshuffle for no reason between rebuilds.
  List<ConfirmationEntry> get entries {
    final sorted = [..._entries];
    mergeSort(sorted, compare: (a, b) => a.sortRank.compareTo(b.sortRank));
    return List.unmodifiable(sorted);
  }

  /// Rows that still want a decision, most urgent first.
  ///
  /// These are the only rows drawn at full size — the screen gives its space
  /// to what still needs the nurse, not to what is already done.
  List<ConfirmationEntry> get attentionEntries => List.unmodifiable(
    entries.where((e) => e.needsAttention),
  );

  /// Rows that will stay empty, in the declared order.
  List<ConfirmationEntry> get gapEntries =>
      List.unmodifiable(_entries.where((e) => e.isGap));

  /// Rows whose value goes into the record as it stands.
  List<ConfirmationEntry> get settledEntries =>
      List.unmodifiable(_entries.where((e) => e.isSettled));

  /// Number of values that go into the record as they stand.
  int get settledCount => _entries.where((e) => e.isSettled).length;

  /// Number of values that want a look before saving, blocking ones included.
  int get attentionCount => _entries.where((e) => e.needsAttention).length;

  /// Number of fields that will stay empty.
  int get gapCount => _entries.where((e) => e.isGap).length;

  /// Number of values that currently block saving.
  int get blockingCount => _entries.where((e) => e.blocksSaving).length;

  /// Whether the record may be taken over.
  ///
  /// Gaps do not stand in the way; undecided low-confidence values do.
  bool get canAccept => blockingCount == 0;

  /// Confirms the proposal for [slotId].
  void accept(String slotId) => _decide(slotId, FieldDecision.accepted);

  /// Throws the proposal for [slotId] away; the field becomes a gap.
  void discard(String slotId) => _decide(slotId, FieldDecision.discarded);

  void _decide(String slotId, FieldDecision decision) {
    final index = _entries.indexWhere((e) => e.slotId == slotId);
    if (index < 0 || _entries[index].proposal == null) return;
    if (_entries[index].decision == decision) return;

    _entries[index] = _entries[index].copyWith(decision: decision);
    notifyListeners();
  }
}
