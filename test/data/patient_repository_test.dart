import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/db/app_database.dart';
import 'package:wunddoku/data/db/database_key_store.dart';
import 'package:wunddoku/data/patient_repository.dart';
import 'package:wunddoku/domain/model/ids.dart';

void main() {
  late AppDatabase db;
  late PatientRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = PatientRepository(db, clock: () => DateTime(2026, 8, 10));
  });

  tearDown(() async {
    await db.close();
  });

  Future<PatientId> createMustermann() async {
    final patient = await repository.create(
      givenName: 'Erika',
      familyName: 'Mustermann',
      birthDate: DateTime(1948, 3, 14),
      street: 'Heidestraße 17',
      postalCode: '93437',
      city: 'Furth im Wald',
    );
    return patient.id;
  }

  group('patient repository', () {
    test('a created patient can be read back unchanged', () async {
      final id = await createMustermann();

      final stored = await repository.byId(id);
      expect(stored, isNotNull);
      expect(stored!.displayName, 'Mustermann, Erika');
      expect(stored.birthDate, DateTime(1948, 3, 14));
      expect(stored.city, 'Furth im Wald');
      expect(stored.createdAt, DateTime(2026, 8, 10));
    });

    test('an unknown id yields null, not an error', () async {
      expect(await repository.byId(const PatientId('missing')), isNull);
    });

    test('names are trimmed on the way in', () async {
      final patient = await repository.create(
        givenName: '  Erika ',
        familyName: ' Mustermann ',
        birthDate: DateTime(1948, 3, 14),
        street: ' Heidestraße 17 ',
        postalCode: ' 93437 ',
        city: ' Furth im Wald ',
      );
      expect(patient.givenName, 'Erika');
      expect(patient.familyName, 'Mustermann');
      expect(patient.street, 'Heidestraße 17');
    });

    test('the list is sorted by family name, then given name', () async {
      for (final (given, family) in [
        ('Berta', 'Zorn'),
        ('Anna', 'Adam'),
        ('Berta', 'Adam'),
      ]) {
        await repository.create(
          givenName: given,
          familyName: family,
          birthDate: DateTime(1950),
          street: '',
          postalCode: '',
          city: '',
        );
      }

      final names = (await repository.all()).map((p) => p.displayName);
      expect(names, ['Adam, Anna', 'Adam, Berta', 'Zorn, Berta']);
    });

    test('search matches given and family name, case-insensitively', () async {
      await createMustermann();

      expect(await repository.search('muster'), hasLength(1));
      expect(await repository.search('ERIKA'), hasLength(1));
      expect(await repository.search('Schulze'), isEmpty);
    });

    test('an empty search returns everyone', () async {
      await createMustermann();
      expect(await repository.search('   '), hasLength(1));
    });

    test('deleting a patient cascades to wounds and visits', () async {
      final id = await createMustermann();
      await db
          .into(db.wounds)
          .insert(
            WoundsCompanion.insert(
              id: 'w1',
              patientId: id.value,
              location: 'linker Unterschenkel, distal',
              createdAt: DateTime(2026, 8, 10),
            ),
          );
      await db
          .into(db.visits)
          .insert(
            VisitsCompanion.insert(
              id: 'v1',
              woundId: 'w1',
              startedAt: DateTime(2026, 8, 10, 9, 30),
              status: VisitStatus.draft,
            ),
          );

      await repository.delete(id);

      expect(await repository.byId(id), isNull);
      expect(await db.select(db.wounds).get(), isEmpty);
      expect(await db.select(db.visits).get(), isEmpty);
    });
  });

  group('database key', () {
    test('generated keys are 64 lowercase hex characters', () {
      final key = SecureDatabaseKeyStore.generateKey();
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(key), isTrue);
    });

    test('two generated keys differ', () {
      expect(
        SecureDatabaseKeyStore.generateKey(),
        isNot(SecureDatabaseKeyStore.generateKey()),
      );
    });
  });

  group('encryption self-test', () {
    test('the bundled SQLite reports a cipher', () {
      // This is the same check AppDatabase.encrypted performs before applying
      // the key. If it fails, the sqlite3mc user_define in pubspec.yaml is not
      // in effect and the database would be stored in plain text.
      final raw = sqlite3.openInMemory();
      try {
        final cipher = raw.select('PRAGMA cipher;');
        expect(
          cipher,
          isNotEmpty,
          reason: 'sqlite3 was built without SQLite3 Multiple Ciphers',
        );
      } finally {
        raw.close();
      }
    });
  });
}
