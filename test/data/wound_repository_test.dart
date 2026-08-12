import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/db/app_database.dart';
import 'package:wunddoku/data/patient_repository.dart';
import 'package:wunddoku/data/wound_repository.dart';
import 'package:wunddoku/domain/model/ids.dart';
import 'package:wunddoku/domain/model/patient.dart';

void main() {
  late AppDatabase database;
  late PatientRepository patients;
  late WoundRepository wounds;
  late Patient patient;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    patients = PatientRepository(database);
    wounds = WoundRepository(database, clock: () => DateTime(2026, 8, 12));
    patient = await patients.create(
      givenName: 'Erika',
      familyName: 'Mustermann',
      birthDate: DateTime(1948, 3, 14),
      street: 'Musterweg 1',
      postalCode: '12345',
      city: 'Musterstadt',
    );
  });

  tearDown(() => database.close());

  test('a wound is created against its patient and starts open', () async {
    final wound = await wounds.create(
      patient: patient.id,
      location: 'linker Unterschenkel, distal',
    );

    expect(wound.patientId, patient.id);
    expect(wound.location, 'linker Unterschenkel, distal');
    expect(wound.isOpen, isTrue);
    expect(wound.icd10Code, isNull);
  });

  test('the location is trimmed on the way in', () async {
    final wound = await wounds.create(
      patient: patient.id,
      location: '  Ferse rechts  ',
    );

    expect(wound.location, 'Ferse rechts');
  });

  test('a wound without a location is refused', () async {
    // The location is what tells two wounds of one patient apart; an empty
    // one would make the second wound indistinguishable from the first.
    expect(
      () => wounds.create(patient: patient.id, location: '   '),
      throwsArgumentError,
    );
  });

  test('open wounds come first, newest of each group first', () async {
    final older = await wounds.create(
      patient: patient.id,
      location: 'Ferse rechts',
    );
    final newer = await wounds.create(
      patient: patient.id,
      location: 'linker Unterschenkel',
    );
    await wounds.close(older.id);

    final listed = await wounds.ofPatient(patient.id);

    // The nurse standing in the flat is treating an open wound; a healed one
    // is history and belongs below it.
    expect(listed.map((w) => w.id), [newer.id, older.id]);
    expect(listed.last.isOpen, isFalse);
  });

  test('another patient never sees this patient in their list', () async {
    final other = await patients.create(
      givenName: 'Hans',
      familyName: 'Beispiel',
      birthDate: DateTime(1950, 1, 1),
      street: '',
      postalCode: '',
      city: '',
    );
    await wounds.create(patient: patient.id, location: 'Ferse rechts');

    expect(await wounds.ofPatient(other.id), isEmpty);
  });

  test('a closed wound can be reopened when it breaks down again', () async {
    final wound = await wounds.create(
      patient: patient.id,
      location: 'Ferse rechts',
    );
    await wounds.close(wound.id);
    await wounds.reopen(wound.id);

    final listed = await wounds.ofPatient(patient.id);
    expect(listed.single.isOpen, isTrue);
  });

  test('an unknown id yields null, not an error', () async {
    expect(await wounds.byId(const WoundId('nope')), isNull);
  });
}
