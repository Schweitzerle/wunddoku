import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/db/app_database.dart';
import 'package:wunddoku/data/patient_repository.dart';
import 'package:wunddoku/domain/model/patient.dart';
import 'package:wunddoku/features/patienten/ui/patient_list_screen.dart';
import 'package:wunddoku/features/patienten/ui/patient_list_view_model.dart';

import '../support/test_app.dart';

void main() {
  late AppDatabase database;
  late PatientRepository patients;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    patients = PatientRepository(database);
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
    final model = PatientListViewModel(patients);
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

  testWidgets('survives 200 percent text scaling', (tester) async {
    await addPatient('Erika', 'Mustermann');
    final model = PatientListViewModel(patients);
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
