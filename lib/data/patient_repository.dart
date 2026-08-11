import 'package:drift/drift.dart';

import '../core/id_generator.dart';
import '../domain/model/ids.dart';
import '../domain/model/patient.dart';
import 'db/app_database.dart';

/// Single source of truth for patient records.
///
/// ViewModels talk to this repository only; neither drift types nor SQL leak
/// past it. Reads are offline reads by definition — there is no remote source.
class PatientRepository {
  PatientRepository(this._db, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  /// Creates and stores a new patient, returning the stored record.
  Future<Patient> create({
    required String givenName,
    required String familyName,
    required DateTime birthDate,
    required String street,
    required String postalCode,
    required String city,
  }) async {
    final patient = Patient(
      id: PatientId(newId()),
      givenName: givenName.trim(),
      familyName: familyName.trim(),
      birthDate: birthDate,
      street: street.trim(),
      postalCode: postalCode.trim(),
      city: city.trim(),
      createdAt: _clock(),
    );
    await _db
        .into(_db.patients)
        .insert(
          PatientsCompanion.insert(
            id: patient.id.value,
            givenName: patient.givenName,
            familyName: patient.familyName,
            birthDate: patient.birthDate,
            street: patient.street,
            postalCode: patient.postalCode,
            city: patient.city,
            createdAt: patient.createdAt,
          ),
        );
    return patient;
  }

  /// The patient with [id], or null when no such record exists.
  Future<Patient?> byId(PatientId id) async {
    final row = await (_db.select(
      _db.patients,
    )..where((p) => p.id.equals(id.value))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  /// All patients, sorted by family name then given name.
  Future<List<Patient>> all() async {
    final rows =
        await (_db.select(_db.patients)..orderBy([
              (p) => OrderingTerm.asc(p.familyName),
              (p) => OrderingTerm.asc(p.givenName),
            ]))
            .get();
    return rows.map(_toDomain).toList();
  }

  /// Patients whose given or family name contains [query],
  /// case-insensitively. An empty query returns everyone.
  Future<List<Patient>> search(String query) async {
    final needle = query.trim();
    if (needle.isEmpty) return all();
    final pattern = '%$needle%';
    final rows =
        await (_db.select(_db.patients)
              ..where(
                (p) => p.familyName.like(pattern) | p.givenName.like(pattern),
              )
              ..orderBy([(p) => OrderingTerm.asc(p.familyName)]))
            .get();
    return rows.map(_toDomain).toList();
  }

  /// Deletes the patient and, through the schema's cascade, every wound and
  /// visit belonging to them. This is the deletion path required for Art. 9
  /// data; media files are handled by their own store when media lands.
  Future<void> delete(PatientId id) async {
    await (_db.delete(_db.patients)..where((p) => p.id.equals(id.value))).go();
  }

  /// Patient and wound behind [wound], as the report header needs them.
  ///
  /// Returns null when the wound is gone — a report about a deleted record is
  /// not something to fall back to.
  Future<WoundContext?> contextOfWound(WoundId wound) async {
    final row = await (_db.select(
      _db.wounds,
    )..where((w) => w.id.equals(wound.value))).getSingleOrNull();
    if (row == null) return null;

    final patient = await byId(PatientId(row.patientId));
    if (patient == null) return null;

    return WoundContext(
      patient: patient,
      location: row.location,
      icd10Code: row.icd10Code,
    );
  }

  Patient _toDomain(PatientRow row) => Patient(
    id: PatientId(row.id),
    givenName: row.givenName,
    familyName: row.familyName,
    birthDate: row.birthDate,
    street: row.street,
    postalCode: row.postalCode,
    city: row.city,
    createdAt: row.createdAt,
  );
}

/// One wound with the patient it belongs to.
class WoundContext {
  const WoundContext({
    required this.patient,
    required this.location,
    required this.icd10Code,
  });

  final Patient patient;

  /// Where on the body the wound sits, in the nurse's words.
  final String location;

  /// ICD-10-GM code of the underlying diagnosis, if one was assigned.
  final String? icd10Code;
}
