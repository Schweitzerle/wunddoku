import 'package:drift/drift.dart';

import '../core/id_generator.dart';
import '../domain/model/ids.dart';
import '../domain/model/wound.dart';
import 'db/app_database.dart';

/// Single source of truth for the wounds of a patient.
///
/// Separate from [PatientRepository] because a wound is what the work
/// actually revolves around: visits, photos and the course all hang off it,
/// and a patient with three wounds has three separate stories to keep apart.
class WoundRepository {
  WoundRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Records a new wound of [patient] at [location].
  ///
  /// Throws [ArgumentError] when the location is blank: it is what tells two
  /// wounds of one patient apart, and an unnamed second wound could not be
  /// distinguished from the first in any list, photo series or report.
  Future<Wound> create({
    required PatientId patient,
    required String location,
    String? icd10Code,
  }) async {
    final trimmed = location.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(location, 'location', 'must not be blank');
    }

    final wound = Wound(
      id: WoundId(newId()),
      patientId: patient,
      location: trimmed,
      icd10Code: icd10Code?.trim(),
      createdAt: _clock(),
      closedAt: null,
    );

    await _db
        .into(_db.wounds)
        .insert(
          WoundsCompanion.insert(
            id: wound.id.value,
            patientId: patient.value,
            location: wound.location,
            icd10Code: Value(wound.icd10Code),
            createdAt: wound.createdAt,
          ),
        );
    return wound;
  }

  /// The wounds of [patient]: open ones first, newest first within each group.
  ///
  /// The nurse standing in the flat is treating an open wound; a healed one is
  /// history and belongs below it rather than in the way.
  Future<List<Wound>> ofPatient(PatientId patient) async {
    final rows =
        await (_db.select(_db.wounds)
              ..where((w) => w.patientId.equals(patient.value))
              ..orderBy([
                (w) => OrderingTerm.asc(w.closedAt.isNotNull()),
                (w) => OrderingTerm.desc(w.createdAt),
              ]))
            .get();
    return [for (final row in rows) _toDomain(row)];
  }

  /// How many wounds are on file per patient.
  ///
  /// One query for the whole list rather than one per row: a tour with twenty
  /// patients would otherwise be twenty round trips before the first name
  /// appears.
  Future<Map<PatientId, int>> countsByPatient() async {
    final count = _db.wounds.id.count();
    final query = _db.selectOnly(_db.wounds)
      ..addColumns([_db.wounds.patientId, count])
      ..groupBy([_db.wounds.patientId]);

    return {
      for (final row in await query.get())
        PatientId(row.read(_db.wounds.patientId)!): row.read(count) ?? 0,
    };
  }

  /// The wound with [id], or null when no such record exists.
  Future<Wound?> byId(WoundId id) async {
    final row = await (_db.select(
      _db.wounds,
    )..where((w) => w.id.equals(id.value))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// Records [wound] as healed.
  Future<void> close(WoundId wound) => _setClosedAt(wound, _clock());

  /// Takes [wound] back into treatment.
  ///
  /// A healed wound that breaks down again is the same wound, not a new one:
  /// its course is the reason anyone would want to see it.
  Future<void> reopen(WoundId wound) => _setClosedAt(wound, null);

  Future<void> _setClosedAt(WoundId wound, DateTime? closedAt) async {
    await (_db.update(
      _db.wounds,
    )..where((w) => w.id.equals(wound.value))).write(
      WoundsCompanion(closedAt: Value(closedAt)),
    );
  }

  Wound _toDomain(WoundRow row) => Wound(
    id: WoundId(row.id),
    patientId: PatientId(row.patientId),
    location: row.location,
    icd10Code: row.icd10Code,
    createdAt: row.createdAt,
    closedAt: row.closedAt,
  );
}
