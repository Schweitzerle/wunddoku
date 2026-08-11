import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/db/app_database.dart';
import 'package:wunddoku/data/visit_repository.dart';
import 'package:wunddoku/domain/catalog/exudation.dart';
import 'package:wunddoku/domain/catalog/tissue_distribution.dart';
import 'package:wunddoku/domain/model/ids.dart';
import 'package:wunddoku/domain/model/visit_draft.dart';
import 'package:wunddoku/features/besuch/ui/card_entry_view_model.dart';

void main() {
  late AppDatabase db;
  late VisitRepository repository;
  const wound = WoundId('w1');

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = VisitRepository(db, clock: () => DateTime(2026, 8, 11));

    // A visit needs its wound, and a wound needs its patient.
    await db
        .into(db.patients)
        .insert(
          PatientsCompanion.insert(
            id: 'p1',
            givenName: 'Erika',
            familyName: 'Mustermann',
            birthDate: DateTime(1948, 3, 14),
            street: '',
            postalCode: '',
            city: '',
            createdAt: DateTime(2026, 8, 11),
          ),
        );
    await db
        .into(db.wounds)
        .insert(
          WoundsCompanion.insert(
            id: wound.value,
            patientId: 'p1',
            location: 'linker Unterschenkel, distal',
            createdAt: DateTime(2026, 8, 11),
          ),
        );
  });

  tearDown(() async => db.close());

  group('the draft survives', () {
    test('a value written for a slot reads back as the same value', () async {
      final visit = await repository.startVisit(wound);

      await repository.saveValue(
        visit,
        'measurement.lengthCm',
        const CentimetreValue(3.5),
      );
      await repository.saveValue(visit, 'tissue.granulation', const PercentValue(60));
      await repository.saveValue(
        visit,
        'exudate.amount',
        const ExudateAmountValue(ExudateAmount.slight),
      );
      await repository.saveValue(
        visit,
        'exudate.kind.serous',
        const ExudateKindValue(ExudateKind.serous),
      );

      final draft = await repository.loadDraft(visit);
      expect(draft['measurement.lengthCm'], const CentimetreValue(3.5));
      expect(draft['tissue.granulation'], const PercentValue(60));
      expect(
        draft['exudate.amount'],
        const ExudateAmountValue(ExudateAmount.slight),
      );
      expect(
        draft['exudate.kind.serous'],
        const ExudateKindValue(ExudateKind.serous),
      );
    });

    test('writing the same slot again replaces it, it does not pile up', () async {
      final visit = await repository.startVisit(wound);

      await repository.saveValue(visit, 'tissue.fibrin', const PercentValue(20));
      await repository.saveValue(visit, 'tissue.fibrin', const PercentValue(40));

      final draft = await repository.loadDraft(visit);
      expect(draft['tissue.fibrin'], const PercentValue(40));
      expect(draft.values, hasLength(1));
    });

    test('clearing a value turns the field back into a gap', () async {
      final visit = await repository.startVisit(wound);

      await repository.saveValue(visit, 'tissue.fibrin', const PercentValue(20));
      await repository.saveValue(visit, 'tissue.fibrin', null);

      final draft = await repository.loadDraft(visit);
      expect(draft.has('tissue.fibrin'), isFalse);
    });

    test('the tissue invariant survives the round trip', () async {
      final visit = await repository.startVisit(wound);

      await repository.saveValue(
        visit,
        'tissue.granulation',
        const PercentValue(60),
      );
      await repository.saveValue(visit, 'tissue.fibrin', const PercentValue(40));

      final distribution = (await repository.loadDraft(visit))
          .tissueDistribution;
      expect(distribution, isNotNull);
      expect(distribution![TissueType.granulation], 60);
    });
  });

  group('resuming', () {
    test('an open visit is found again, a closed one is not', () async {
      final visit = await repository.startVisit(wound);
      expect(await repository.openDraft(wound), visit);

      await repository.completeVisit(visit, withGaps: true);
      expect(await repository.openDraft(wound), isNull);
    });

    test('closing records whether gaps were left on purpose', () async {
      final visit = await repository.startVisit(wound);
      await repository.completeVisit(visit, withGaps: true);

      final row = await (db.select(
        db.visits,
      )..where((v) => v.id.equals(visit.value))).getSingle();
      expect(row.status, VisitStatus.completeWithGaps);
      expect(row.completedAt, isNotNull);
    });

    test('the verbatim transcript is kept with the visit', () async {
      final visit = await repository.startVisit(wound);
      await repository.saveTranscript(visit, 'Länge drei Komma fünf');

      final row = await (db.select(
        db.visits,
      )..where((v) => v.id.equals(visit.value))).getSingle();
      expect(row.transcript, 'Länge drei Komma fünf');
    });

    test('deleting the patient takes the recorded values with it', () async {
      final visit = await repository.startVisit(wound);
      await repository.saveValue(visit, 'tissue.fibrin', const PercentValue(20));

      await (db.delete(db.patients)..where((p) => p.id.equals('p1'))).go();

      // The Art. 9 deletion path has to reach the findings, not just the
      // patient row that names them.
      expect(await db.select(db.visitValues).get(), isEmpty);
    });
  });

  group('autosave from the card mode', () {
    test('every step is written on its own', () async {
      final visit = await repository.startVisit(wound);
      final entry = CardEntryViewModel(repository: repository, visit: visit);
      addTearDown(entry.dispose);

      entry.adjustTissue(TissueType.granulation, 5);
      await entry.pendingWrite;
      expect(
        (await repository.loadDraft(visit))['tissue.granulation'],
        const PercentValue(5),
      );

      entry.adjustTissue(TissueType.granulation, 5);
      await entry.pendingWrite;
      expect(
        (await repository.loadDraft(visit))['tissue.granulation'],
        const PercentValue(10),
      );

      // Stepping back to zero must clear the row, not store a zero.
      entry
        ..adjustTissue(TissueType.granulation, -5)
        ..adjustTissue(TissueType.granulation, -5);
      await entry.pendingWrite;
      expect(
        (await repository.loadDraft(visit)).has('tissue.granulation'),
        isFalse,
      );
    });

    test('a resumed visit starts from what was written', () async {
      final visit = await repository.startVisit(wound);
      final first = CardEntryViewModel(repository: repository, visit: visit);
      first
        ..adjustTissue(TissueType.granulation, 5)
        ..adjustMeasurement('measurement.lengthCm', 0.5);
      await first.pendingWrite;
      first.dispose();

      // What a fresh session sees after the app was killed mid-visit.
      final resumed = CardEntryViewModel(
        draft: await repository.loadDraft(visit),
        repository: repository,
        visit: visit,
      );
      addTearDown(resumed.dispose);

      expect(resumed.tissueShare(TissueType.granulation), 5);
      expect(resumed.measurement('measurement.lengthCm'), 0.5);
      expect(resumed.tissueRemainder, 95);
    });
  });
}
