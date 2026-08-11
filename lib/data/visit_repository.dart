import 'package:drift/drift.dart';

import '../core/id_generator.dart';
import '../domain/catalog/exudation.dart';
import '../domain/model/ids.dart';
import '../domain/model/visit_draft.dart';
import 'db/app_database.dart';

/// Single source of truth for visits and the values recorded in them.
///
/// Writes are per field, not per visit: the nurse can be interrupted by a
/// phone call, a flat battery or an accidental back gesture at any point, and
/// none of those may cost a finding (`/eps:field-app-muster`). Reading the
/// draft back is what makes the re-entry point come from the record rather
/// than from the navigation stack.
class VisitRepository {
  VisitRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Starts a visit for [woundId] and returns its id.
  Future<VisitId> startVisit(WoundId woundId) async {
    final id = VisitId(newId());
    await _db
        .into(_db.visits)
        .insert(
          VisitsCompanion.insert(
            id: id.value,
            woundId: woundId.value,
            startedAt: _clock(),
            status: VisitStatus.draft,
          ),
        );
    return id;
  }

  /// The visit that is still being worked on for [woundId], or null.
  ///
  /// A visit stays a draft until it is closed, so finding one on start-up is
  /// how the app resumes where the nurse left off.
  Future<VisitId?> openDraft(WoundId woundId) async {
    final row =
        await (_db.select(_db.visits)
              ..where(
                (v) =>
                    v.woundId.equals(woundId.value) &
                    v.status.equalsValue(VisitStatus.draft),
              )
              ..orderBy([(v) => OrderingTerm.desc(v.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : VisitId(row.id);
  }

  /// Stores [value] for [slotId]; null clears the field back to a gap.
  ///
  /// One row, one write. Called after every single change, which is why it
  /// must stay this small.
  Future<void> saveValue(VisitId visit, String slotId, VisitValue? value) async {
    if (value == null) {
      await (_db.delete(_db.visitValues)..where(
            (v) => v.visitId.equals(visit.value) & v.slotId.equals(slotId),
          ))
          .go();
      return;
    }

    final (kind, number, code) = _encode(value);
    await _db
        .into(_db.visitValues)
        .insertOnConflictUpdate(
          VisitValuesCompanion.insert(
            visitId: visit.value,
            slotId: slotId,
            kind: kind,
            number: Value(number),
            code: Value(code),
            updatedAt: _clock(),
          ),
        );
  }

  /// Everything recorded for [visit] so far.
  Future<VisitDraft> loadDraft(VisitId visit) async {
    final rows = await (_db.select(
      _db.visitValues,
    )..where((v) => v.visitId.equals(visit.value))).get();

    // Null-aware element: a row that cannot be decoded drops out instead of
    // becoming a value nobody entered.
    return VisitDraft(
      values: {for (final row in rows) row.slotId: ?_decode(row)},
    );
  }

  /// Closes [visit].
  ///
  /// [withGaps] records that fields were left empty on purpose — allowed, and
  /// deliberately distinguishable from a complete finding later in the office.
  Future<void> completeVisit(VisitId visit, {required bool withGaps}) async {
    await (_db.update(_db.visits)..where((v) => v.id.equals(visit.value)))
        .write(
          VisitsCompanion(
            completedAt: Value(_clock()),
            status: Value(
              withGaps ? VisitStatus.completeWithGaps : VisitStatus.complete,
            ),
          ),
        );
  }

  /// Stores the verbatim transcript with the visit.
  Future<void> saveTranscript(VisitId visit, String transcript) async {
    await (_db.update(_db.visits)..where((v) => v.id.equals(visit.value)))
        .write(VisitsCompanion(transcript: Value(transcript)));
  }

  (StoredValueKind, double?, String?) _encode(VisitValue value) =>
      switch (value) {
        CentimetreValue(:final centimetres) => (
          StoredValueKind.centimetres,
          centimetres,
          null,
        ),
        PercentValue(:final percent) => (
          StoredValueKind.percent,
          percent.toDouble(),
          null,
        ),
        ScoreValue(:final score) => (
          StoredValueKind.score,
          score.toDouble(),
          null,
        ),
        ExudateAmountValue(:final amount) => (
          StoredValueKind.exudateAmount,
          null,
          amount.name,
        ),
        ExudateKindValue(:final kind) => (
          StoredValueKind.exudateKind,
          null,
          kind.name,
        ),
      };

  /// Reads a row back, or null when it cannot be trusted.
  ///
  /// A row whose number or code is missing is damaged, not empty. Dropping it
  /// turns the field into a visible gap, which is the safe outcome — the
  /// alternative would be a value nobody entered.
  VisitValue? _decode(VisitValueRow row) => switch (row.kind) {
    StoredValueKind.centimetres => row.number == null
        ? null
        : CentimetreValue(row.number!),
    StoredValueKind.percent => row.number == null
        ? null
        : PercentValue(row.number!.round()),
    StoredValueKind.score => row.number == null
        ? null
        : ScoreValue(row.number!.round()),
    StoredValueKind.exudateAmount =>
      switch (_byName(ExudateAmount.values, row.code)) {
        final amount? => ExudateAmountValue(amount),
        _ => null,
      },
    StoredValueKind.exudateKind =>
      switch (_byName(ExudateKind.values, row.code)) {
        final kind? => ExudateKindValue(kind),
        _ => null,
      },
  };

  /// The enum value called [name], or null when the catalogue no longer knows
  /// it — which happens when a value was written by an older version.
  T? _byName<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
