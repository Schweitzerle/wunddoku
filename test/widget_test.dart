import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/app/bootstrap.dart';
import 'package:wunddoku/core/id_generator.dart';
import 'package:wunddoku/data/db/app_database.dart';
import 'package:wunddoku/data/patient_repository.dart';
import 'package:wunddoku/data/visit_repository.dart';
import 'package:wunddoku/domain/model/ids.dart';
import 'package:wunddoku/domain/model/visit_draft.dart';
import 'package:wunddoku/main.dart';

import 'support/test_app.dart';

/// Builds what the corridor needs, on an in-memory database.
Future<AppDependencies> _dependencies() async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  final patients = PatientRepository(database);

  final patient = await patients.create(
    givenName: 'Erika',
    familyName: 'Mustermann',
    birthDate: DateTime(1948, 3, 14),
    street: '',
    postalCode: '',
    city: '',
  );

  final wound = WoundId(newId());
  await database
      .into(database.wounds)
      .insert(
        WoundsCompanion.insert(
          id: wound.value,
          patientId: patient.id.value,
          location: 'linker Unterschenkel, distal',
          createdAt: DateTime(2026, 8, 11),
        ),
      );

  return AppDependencies(
    database: database,
    patients: patients,
    visits: VisitRepository(database),
    demoWound: wound,
  );
}

void main() {
  testWidgets('the corridor opens a visit and starts in the recording step', (
    tester,
  ) async {
    final dependencies = await _dependencies();
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(
      TestApp(child: VisitCorridor(dependencies: dependencies)),
    );
    await tester.pump();

    expect(find.text('Befund sprechen'), findsOneWidget);
    expect(
      await dependencies.visits.openDraft(dependencies.demoWound),
      isNotNull,
      reason: 'a visit is opened so autosave has somewhere to write',
    );
  });

  testWidgets('an unfinished visit is resumed, not started over', (
    tester,
  ) async {
    final dependencies = await _dependencies();
    addTearDown(dependencies.dispose);

    // What the previous session left behind before the app was killed.
    final earlier = await dependencies.visits.startVisit(
      dependencies.demoWound,
    );
    await dependencies.visits.saveValue(
      earlier,
      'tissue.granulation',
      const PercentValue(60),
    );

    await tester.pumpWidget(
      TestApp(child: VisitCorridor(dependencies: dependencies)),
    );
    await tester.pump();

    final resumed = await dependencies.visits.openDraft(
      dependencies.demoWound,
    );
    expect(resumed, earlier, reason: 'the same visit, not a fresh one');

    final draft = await dependencies.visits.loadDraft(resumed!);
    expect(draft.tissueRemainder, 40);
  });

  testWidgets('a completed visit is not picked up again', (tester) async {
    final dependencies = await _dependencies();
    addTearDown(dependencies.dispose);

    final done = await dependencies.visits.startVisit(dependencies.demoWound);
    await dependencies.visits.completeVisit(done, withGaps: false);

    await tester.pumpWidget(
      TestApp(child: VisitCorridor(dependencies: dependencies)),
    );
    await tester.pump();

    final current = await dependencies.visits.openDraft(
      dependencies.demoWound,
    );
    expect(current, isNotNull);
    expect(current, isNot(done), reason: 'a finished visit stays finished');
  });

  testWidgets('a failed start-up refuses rather than working around it', (
    tester,
  ) async {
    // Completed after the shell subscribed: an already-failed future would
    // surface as an unhandled zone error before the builder ever sees it.
    final startup = Completer<AppDependencies>();
    await tester.pumpWidget(WunddokuApp(dependencies: startup.future));

    startup.completeError(
      StateError('SQLite was built without a cipher'),
    );
    await tester.pump();

    // Carrying on would mean storing health data unprotected, so the shell
    // says so and points at paper instead of opening the corridor.
    expect(
      find.text('Die Wunddokumentation lässt sich nicht öffnen.'),
      findsOneWidget,
    );
    expect(find.text('Befund sprechen'), findsNothing);
  });
}
