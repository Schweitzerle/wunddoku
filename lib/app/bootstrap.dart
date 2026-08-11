import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../core/id_generator.dart';
import '../data/db/app_database.dart';
import '../data/db/database_key_store.dart';
import '../data/patient_repository.dart';
import '../data/visit_repository.dart';
import '../domain/model/ids.dart';

/// Everything the app needs at runtime, built once at start-up.
///
/// Assembled here rather than reached for from widgets: the database key
/// comes from the platform keystore, which is an async step, and the whole
/// point of the Art. 9 setup is that nothing opens the file without it.
class AppDependencies {
  const AppDependencies({
    required this.database,
    required this.patients,
    required this.visits,
    required this.demoWound,
  });

  final AppDatabase database;
  final PatientRepository patients;
  final VisitRepository visits;

  /// The wound the corridor documents while there is no patient list yet.
  final WoundId demoWound;

  Future<void> dispose() => database.close();
}

/// Opens the encrypted database and wires the repositories.
///
/// The key is generated on first run and stored in the keystore, so there is
/// never a moment where the file exists unencrypted.
Future<AppDependencies> bootstrap({DatabaseKeyStore? keyStore}) async {
  final directory = await getApplicationDocumentsDirectory();
  final key = await (keyStore ?? SecureDatabaseKeyStore()).obtainKey();
  final database = AppDatabase.encrypted(
    File('${directory.path}/wunddoku.sqlite'),
    key,
  );

  final patients = PatientRepository(database);
  final visits = VisitRepository(database);

  return AppDependencies(
    database: database,
    patients: patients,
    visits: visits,
    demoWound: await _ensureDemoWound(database, patients),
  );
}

/// Returns the wound the corridor works on, creating it on first run.
///
/// Stand-in for the patient and wound screens, which are slice 2. The data is
/// synthetic — no real patient reaches development or a screenshot
/// (`datenschutz-art9.md`).
Future<WoundId> _ensureDemoWound(
  AppDatabase database,
  PatientRepository patients,
) async {
  final existing = await database.select(database.wounds).get();
  if (existing.isNotEmpty) return WoundId(existing.first.id);

  final patient = await patients.create(
    givenName: 'Erika',
    familyName: 'Mustermann',
    birthDate: DateTime(1948, 3, 14),
    street: 'Heidestraße 17',
    postalCode: '93437',
    city: 'Furth im Wald',
  );

  final wound = WoundId(newId());
  await database
      .into(database.wounds)
      .insert(
        WoundsCompanion.insert(
          id: wound.value,
          patientId: patient.id.value,
          location: 'linker Unterschenkel, distal',
          createdAt: DateTime.now(),
        ),
      );
  return wound;
}
