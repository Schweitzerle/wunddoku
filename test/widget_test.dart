import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/app/bootstrap.dart';
import 'package:wunddoku/core/id_generator.dart';
import 'package:wunddoku/data/db/app_database.dart';
import 'package:wunddoku/data/media/wound_camera.dart';
import 'package:wunddoku/data/patient_repository.dart';
import 'package:wunddoku/data/visit_repository.dart';
import 'package:wunddoku/domain/model/ids.dart';
import 'package:wunddoku/domain/model/visit_draft.dart';
import 'package:wunddoku/features/besuch/ui/widgets/marking_editor.dart';
import 'package:wunddoku/main.dart';

import 'support/fake_camera.dart';
import 'support/fake_media_store.dart';
import 'support/test_app.dart';

/// Builds what the corridor needs, on an in-memory database.
Future<AppDependencies> _dependencies({
  WoundCamera Function()? camera,
  FakeMediaStore? store,
}) async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  final patients = PatientRepository(database);
  final media = store ?? FakeMediaStore();

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
    visits: VisitRepository(database, media),
    media: media,
    demoWound: wound,
    camera: camera ?? PackageWoundCamera.new,
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

    final resumed = await dependencies.visits.openDraft(dependencies.demoWound);
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

    final current = await dependencies.visits.openDraft(dependencies.demoWound);
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

    startup.completeError(StateError('SQLite was built without a cipher'));
    await tester.pump();

    // Carrying on would mean storing health data unprotected, so the shell
    // says so and points at paper instead of opening the corridor.
    expect(
      find.text('Die Wunddokumentation lässt sich nicht öffnen.'),
      findsOneWidget,
    );
    expect(find.text('Befund sprechen'), findsNothing);
  });

  testWidgets('photographing and marking leaves two files and one outline', (
    tester,
  ) async {
    late final Uint8List photo;
    await tester.runAsync(() async => photo = await _syntheticPhoto());

    final media = FakeMediaStore();
    final dependencies = await _dependencies(
      store: media,
      camera: () => FakeCamera(photo: photo),
    );
    addTearDown(dependencies.dispose);

    await tester.pumpWidget(
      TestApp(
        child: VisitCorridor(
          dependencies: dependencies,
          // Real encoding never returns inside the fake async zone; the
          // drawing itself is checked against real images elsewhere.
          burn: (_, _) async => Uint8List.fromList([7, 7, 7]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wunde fotografieren'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Foto aufnehmen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Foto übernehmen'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Punkte'));
    await tester.pump();
    final editor = find.byType(MarkingEditor);
    for (final offset in const [
      Offset(-30, -20),
      Offset(30, -20),
      Offset(0, 25),
    ]) {
      await tester.tapAt(tester.getCenter(editor) + offset);
      await tester.pump();
    }

    await tester.tap(find.text('Markierung übernehmen'));
    await tester.pumpAndSettle();

    final visit = await dependencies.visits.openDraft(dependencies.demoWound);
    final stored = await dependencies.visits.photosOf(visit!);

    // The original untouched, the marked copy beside it, and the outline as
    // geometry — the three things the briefing asks for.
    expect(stored, hasLength(1));
    expect(
      await dependencies.visits.photoBytes(stored.single.originalRef),
      photo,
    );
    expect(stored.single.markedRef, isNotNull);
    expect(stored.single.marking!.outline, hasLength(3));
    expect(media.files, hasLength(2));
  });
}

/// A synthetic wound photo — never a real one (`datenschutz-art9.md`).
Future<Uint8List> _syntheticPhoto() async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder, const Rect.fromLTWH(0, 0, 120, 90))
    ..drawRect(
      const Rect.fromLTWH(0, 0, 120, 90),
      Paint()..color = const Color(0xFFB08068),
    )
    ..drawOval(
      const Rect.fromLTWH(35, 25, 50, 40),
      Paint()..color = const Color(0xFF9C3B2E),
    );

  final image = await recorder.endRecording().toImage(120, 90);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}
