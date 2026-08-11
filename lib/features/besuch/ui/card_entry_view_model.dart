import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/visit_repository.dart';
import '../../../domain/catalog/exudation.dart';
import '../../../domain/model/ids.dart';
import '../../../domain/catalog/tissue_distribution.dart';
import '../../../domain/model/visit_draft.dart';

/// Drives the card mode — the way into the record that needs no speech.
///
/// Equal in standing to the spoken path, not a fallback: it is what the nurse
/// uses when the microphone is refused, when the patient would rather she did
/// not speak, or when three taps are simply faster than a sentence. It writes
/// into the same [VisitDraft] the confirmation view writes into.
///
/// Every field is entered by choosing, never by typing. Free text is the last
/// resort in a field app (`/eps:field-app-muster`), and with gloves on it is
/// no resort at all.
class CardEntryViewModel extends ChangeNotifier {
  CardEntryViewModel({
    VisitDraft draft = const VisitDraft(),
    VisitRepository? repository,
    VisitId? visit,
  }) : _draft = draft,
       _repository = repository,
       _visit = visit;

  /// Where each change is written, or null while nothing is persisted yet.
  ///
  /// Optional so the screen can be exercised in tests and previews without a
  /// database; in the app both are always present.
  final VisitRepository? _repository;
  final VisitId? _visit;

  VisitDraft _draft;

  /// The write in flight, exposed so a test can wait for it.
  ///
  /// Saving is not awaited by the callers: a step must feel immediate, and a
  /// disk write is not something the nurse should wait on.
  Future<void>? get pendingWrite => _pendingWrite;
  Future<void>? _pendingWrite;

  /// The values entered so far.
  VisitDraft get draft => _draft;

  /// How many percent of the wound bed are still unassigned.
  int get tissueRemainder => _draft.tissueRemainder;

  /// Whether the tissue shares add up to exactly 100.
  ///
  /// The wound bed is a whole; a distribution that does not add up is not a
  /// finding yet. Shown as a remainder, not as an error.
  bool get isTissueComplete =>
      _draft.tissueDistribution != null || _draft.tissueRemainder == 100;

  /// The share entered for [type], or zero.
  int tissueShare(TissueType type) {
    final value = _draft['tissue.${type.name}'];
    return value is PercentValue ? value.percent : 0;
  }

  /// The measurement entered for [slotId] in centimetres, or null.
  double? measurement(String slotId) {
    final value = _draft[slotId];
    return value is CentimetreValue ? value.centimetres : null;
  }

  /// The exudate amount entered, or null.
  ExudateAmount? get exudateAmount {
    final value = _draft['exudate.amount'];
    return value is ExudateAmountValue ? value.amount : null;
  }

  /// Whether [kind] was marked as observed.
  bool hasExudateKind(ExudateKind kind) =>
      _draft.has('exudate.kind.${kind.name}');

  /// Adds [step] percent to [type], clamped so a share never leaves 0..100.
  ///
  /// The remainder is allowed to go negative while the nurse redistributes —
  /// blocking the step would force her to clear a field before raising
  /// another, which is slower and teaches nothing.
  void adjustTissue(TissueType type, int step) {
    final next = (tissueShare(type) + step).clamp(0, 100);
    _write('tissue.${type.name}', next == 0 ? null : PercentValue(next));
  }

  /// Sets the measurement for [slotId]; null clears it back to a gap.
  void setMeasurement(String slotId, double? centimetres) {
    _write(slotId, centimetres == null ? null : CentimetreValue(centimetres));
  }

  /// Adds [step] centimetres to [slotId], never below zero.
  void adjustMeasurement(String slotId, double step) {
    final next = ((measurement(slotId) ?? 0) + step).clamp(0.0, 99.9);
    // A measurement of zero is not a finding, it is an unmade measurement.
    setMeasurement(slotId, next == 0 ? null : _round(next));
  }

  /// Selects the exudate amount; selecting the same one again clears it.
  void toggleExudateAmount(ExudateAmount amount) {
    final clearing = exudateAmount == amount;
    _write('exudate.amount', clearing ? null : ExudateAmountValue(amount));

    // "No exudate" cannot carry a kind - the catalogue forbids the pair.
    if (!clearing && amount == ExudateAmount.none) {
      for (final kind in ExudateKind.values) {
        _write('exudate.kind.${kind.name}', null, silent: true);
      }
    }
  }

  /// Marks or unmarks [kind] as observed.
  ///
  /// Ignored while the amount says there is no exudate: the two would
  /// contradict each other, and the catalogue rejects that pair.
  void toggleExudateKind(ExudateKind kind) {
    if (exudateAmount == ExudateAmount.none) return;
    final slot = 'exudate.kind.${kind.name}';
    _write(slot, _draft.has(slot) ? null : ExudateKindValue(kind));
  }

  double _round(double value) => (value * 10).round() / 10;

  void _write(String slotId, VisitValue? value, {bool silent = false}) {
    _draft = value == null
        ? _draft.without(slotId)
        : _draft.withValue(slotId, value);

    // Autosave after every single field, per the field-app rules: a phone
    // call, a flat battery or a stray back gesture must not cost a finding.
    final repository = _repository;
    final visit = _visit;
    if (repository != null && visit != null) {
      _pendingWrite = repository.saveValue(visit, slotId, value);
      unawaited(_pendingWrite);
    }

    if (!silent) notifyListeners();
  }
}
