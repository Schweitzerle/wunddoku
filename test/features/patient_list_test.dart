import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/db/app_database.dart';
import 'package:wunddoku/data/patient_repository.dart';
import 'package:wunddoku/data/visit_repository.dart';
import 'package:wunddoku/data/wound_repository.dart';
import 'package:wunddoku/domain/model/patient.dart';
import 'package:wunddoku/features/patienten/ui/patient_list_screen.dart';
import 'package:wunddoku/features/patienten/ui/patient_list_view_model.dart';

import '../support/fake_media_store.dart';
import '../support/phone.dart';
import '../support/test_app.dart';

void main() {
  late AppDatabase database;
  late PatientRepository patients;
  late VisitRepository visits;
  late WoundRepository wounds;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    patients = PatientRepository(database);
    visits = VisitRepository(database, FakeMediaStore());
    wounds = WoundRepository(database);
  });

  tearDown(() => database.close());

  Future<void> addPatient(String given, String family) => patients.create(
    givenName: given,
    familyName: family,
    birthDate: DateTime(1948, 3, 14),
    street: 'Musterweg 1',
    postalCode: '12345',
    city: 'Musterstadt',
  );

  Future<PatientListViewModel> pumpList(
    WidgetTester tester, {
    void Function(Patient)? onOpen,
    int wounds = 1,
  }) async {
    final model = PatientListViewModel(patients, visits);
    addTearDown(model.dispose);
    await tester.pumpWidget(
      TestApp(
        child: PatientListScreen(
          viewModel: model,
          woundCount: (_) => wounds,
          onOpen: onOpen,
          onAdd: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    return model;
  }

  testWidgets('an empty file says so and points at the way out', (
    tester,
  ) async {
    await pumpList(tester);

    expect(find.text('Noch kein Patient angelegt.'), findsOneWidget);
    expect(find.text('Patient anlegen'), findsOneWidget);
  });

  testWidgets('patients are listed by family name', (tester) async {
    await addPatient('Erika', 'Mustermann');
    await addPatient('Hans', 'Beispiel');
    await pumpList(tester);

    final names = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .where((t) => t.contains(','))
        .toList();
    expect(names.first, 'Beispiel, Hans');
    expect(names.last, 'Mustermann, Erika');
  });

  testWidgets('the row carries what tells two people apart', (tester) async {
    await addPatient('Erika', 'Mustermann');
    await pumpList(tester, wounds: 2);

    // Same name twice is normal in a small town; the birth date is what the
    // nurse checks, and the wound count says what is waiting.
    expect(find.textContaining('geb. 14.3.1948'), findsOneWidget);
    expect(find.textContaining('2 Wunden'), findsOneWidget);
  });

  testWidgets('a search that finds nothing says which search', (tester) async {
    await addPatient('Erika', 'Mustermann');
    final model = await pumpList(tester);

    await model.searchFor('Schmidt');
    await tester.pumpAndSettle();

    // Not the same situation as an empty file, and it must not read like one.
    expect(find.text('Kein Treffer für „Schmidt“.'), findsOneWidget);
    expect(find.text('Noch kein Patient angelegt.'), findsNothing);
  });

  testWidgets('tapping a patient opens them', (tester) async {
    await addPatient('Erika', 'Mustermann');
    Patient? opened;
    await pumpList(tester, onOpen: (patient) => opened = patient);

    await tester.tap(find.text('Mustermann, Erika'));
    await tester.pumpAndSettle();

    expect(opened?.familyName, 'Mustermann');
  });

  testWidgets('meets the four guidelines', (tester) async {
    await addPatient('Erika', 'Mustermann');
    final handle = tester.ensureSemantics();
    await pumpList(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });

  testWidgets('an unfinished visit lifts the patient out of the alphabet', (
    tester,
  ) async {
    await addPatient('Erika', 'Mustermann');
    final zwilling = await patients.create(
      givenName: 'Hans',
      familyName: 'Beispiel',
      birthDate: DateTime(1950, 1, 1),
      street: 'Musterweg 2',
      postalCode: '12345',
      city: 'Musterstadt',
    );
    final wound = await wounds.create(
      patient: zwilling.id,
      location: 'linker Unterschenkel',
    );
    await visits.startVisit(wound.id);

    await pumpList(tester);

    // A visit begun and not closed is the work that has to end today. It may
    // not sit somewhere in the alphabet.
    expect(find.text('Besuch offen · 1'), findsOneWidget);
    expect(find.text('Alle übrigen · 1'), findsOneWidget);
    expect(find.text('Besuch offen'), findsOneWidget);
  });

  testWidgets('with every visit open there is no heading over nothing', (
    tester,
  ) async {
    // Found on the device: "Alle übrigen · 0" described an empty space.
    final patient = await patients.create(
      givenName: 'Hans',
      familyName: 'Beispiel',
      birthDate: DateTime(1950, 1, 1),
      street: 'Musterweg 2',
      postalCode: '12345',
      city: 'Musterstadt',
    );
    final wound = await wounds.create(
      patient: patient.id,
      location: 'linker Unterschenkel',
    );
    await visits.startVisit(wound.id);

    await pumpList(tester);

    expect(find.text('Besuch offen · 1'), findsOneWidget);
    expect(find.textContaining('Alle übrigen'), findsNothing);
  });

  testWidgets('a closed visit leaves no mark on the list', (tester) async {
    final patient = await patients.create(
      givenName: 'Hans',
      familyName: 'Beispiel',
      birthDate: DateTime(1950, 1, 1),
      street: 'Musterweg 2',
      postalCode: '12345',
      city: 'Musterstadt',
    );
    final wound = await wounds.create(
      patient: patient.id,
      location: 'linker Unterschenkel',
    );
    final visit = await visits.startVisit(wound.id);
    await visits.completeVisit(visit, withGaps: false);

    await pumpList(tester);

    expect(find.text('Besuch offen'), findsNothing);
    expect(find.textContaining('Alle übrigen'), findsNothing);
  });

  testWidgets('searching drops the headings and shows the hits', (
    tester,
  ) async {
    await addPatient('Erika', 'Mustermann');
    final other = await patients.create(
      givenName: 'Hans',
      familyName: 'Beispiel',
      birthDate: DateTime(1950, 1, 1),
      street: 'Musterweg 2',
      postalCode: '12345',
      city: 'Musterstadt',
    );
    final wound = await wounds.create(
      patient: other.id,
      location: 'linker Unterschenkel',
    );
    await visits.startVisit(wound.id);

    final model = await pumpList(tester);
    await model.searchFor('Muster');
    await tester.pumpAndSettle();

    // Someone typing a name is looking for that person; a heading between
    // them and the hit is in the way.
    expect(find.textContaining('Besuch offen ·'), findsNothing);
    expect(find.text('Mustermann, Erika'), findsOneWidget);
  });

  testWidgets('golden: the list with an unfinished visit', (tester) async {
    await useScreen(tester);
    await addPatient('Erika', 'Mustermann');
    await addPatient('Nour', 'Abadi');
    final open = await patients.create(
      givenName: 'Ilse',
      familyName: 'Brandt',
      birthDate: DateTime(1948, 3, 4),
      street: 'Lindenweg 12',
      postalCode: '34117',
      city: 'Kassel',
    );
    final wound = await wounds.create(
      patient: open.id,
      location: 'linker Unterschenkel',
    );
    await visits.startVisit(wound.id);

    await pumpList(tester, wounds: 2);

    await expectLater(
      find.byType(PatientListScreen),
      matchesGoldenFile('goldens/patients_list.png'),
    );
  });

  testWidgets('golden: the list at 200 percent text on a narrow phone', (
    tester,
  ) async {
    await useScreen(tester, size: narrowSize);
    await addPatient('Erika', 'Mustermann');

    final model = PatientListViewModel(patients, visits);
    addTearDown(model.dispose);
    await tester.pumpWidget(
      TestApp(
        textScale: 2,
        child: PatientListScreen(
          viewModel: model,
          woundCount: (_) => 2,
          onAdd: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(PatientListScreen),
      matchesGoldenFile('goldens/patients_list_text200.png'),
    );
  });

  testWidgets('survives 200 percent text scaling', (tester) async {
    await addPatient('Erika', 'Mustermann');
    final model = PatientListViewModel(patients, visits);
    addTearDown(model.dispose);

    await tester.pumpWidget(
      TestApp(
        textScale: 2,
        child: PatientListScreen(
          viewModel: model,
          woundCount: (_) => 1,
          onAdd: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
