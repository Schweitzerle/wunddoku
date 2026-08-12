import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../data/db/app_database.dart';
import '../data/db/database_key_store.dart';
import '../data/media/media_store.dart';
import '../data/media/wound_camera.dart';
import '../data/patient_repository.dart';
import '../data/visit_repository.dart';
import '../data/wound_repository.dart';

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
    required this.media,
    required this.wounds,
    this.camera = PackageWoundCamera.new,
  });

  final AppDatabase database;
  final PatientRepository patients;
  final VisitRepository visits;
  final WoundRepository wounds;
  final MediaStore media;

  /// Builds a camera for one trip to the viewfinder.
  ///
  /// A factory, not an instance: the camera is released when the photo screen
  /// is left, so the next photo needs a fresh one. Replaced in tests, where no
  /// hardware exists.
  final WoundCamera Function() camera;

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

  // The media key is derived from the database key rather than stored
  // separately: one secret in the keystore, one place to rotate.
  final media = EncryptedMediaStore(
    directory: await defaultMediaDirectory(),
    key: await EncryptedMediaStore.deriveKey(key),
  );

  final patients = PatientRepository(database);
  final visits = VisitRepository(database, media);

  return AppDependencies(
    database: database,
    patients: patients,
    visits: visits,
    media: media,
    wounds: WoundRepository(database),
  );
}
