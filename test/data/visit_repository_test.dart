import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/db/app_database.dart';
import 'package:wunddoku/data/visit_repository.dart';

import '../support/fake_media_store.dart';
import 'package:wunddoku/domain/catalog/exudation.dart';
import 'package:wunddoku/domain/catalog/tissue_distribution.dart';
import 'package:wunddoku/domain/model/ids.dart';
import 'package:wunddoku/domain/model/image_marking.dart';
import 'package:wunddoku/domain/model/visit_draft.dart';
import 'package:wunddoku/features/besuch/ui/card_entry_view_model.dart';

void main() {
  late AppDatabase db;
  late VisitRepository repository;
  late FakeMediaStore media;
  const wound = WoundId('w1');

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    media = FakeMediaStore();
    repository = VisitRepository(db, media, clock: () => DateTime(2026, 8, 11));

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
      await repository.saveValue(
        visit,
        'tissue.granulation',
        const PercentValue(60),
      );
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

    test(
      'writing the same slot again replaces it, it does not pile up',
      () async {
        final visit = await repository.startVisit(wound);

        await repository.saveValue(
          visit,
          'tissue.fibrin',
          const PercentValue(20),
        );
        await repository.saveValue(
          visit,
          'tissue.fibrin',
          const PercentValue(40),
        );

        final draft = await repository.loadDraft(visit);
        expect(draft['tissue.fibrin'], const PercentValue(40));
        expect(draft.values, hasLength(1));
      },
    );

    test('clearing a value turns the field back into a gap', () async {
      final visit = await repository.startVisit(wound);

      await repository.saveValue(
        visit,
        'tissue.fibrin',
        const PercentValue(20),
      );
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
      await repository.saveValue(
        visit,
        'tissue.fibrin',
        const PercentValue(40),
      );

      final distribution = (await repository.loadDraft(
        visit,
      )).tissueDistribution;
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

    test('the verbatim dictation reads back with the visit', () async {
      final visit = await repository.startVisit(wound);
      expect(await repository.transcriptOf(visit), isNull);

      await repository.saveTranscript(visit, 'Länge drei Komma fünf');
      expect(await repository.transcriptOf(visit), 'Länge drei Komma fünf');
    });

    test('a resumed visit still knows which day it belongs to', () async {
      // The header of every screen inside a visit shows this date, so a draft
      // picked up the next morning is not mistaken for today's visit.
      final visit = await repository.startVisit(wound);
      expect(await repository.startedAt(visit), DateTime(2026, 8, 11));
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
      await repository.saveValue(
        visit,
        'tissue.fibrin',
        const PercentValue(20),
      );

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

  group('photos', () {
    final original = Uint8List.fromList([1, 2, 3, 4, 5]);
    final marked = Uint8List.fromList([9, 9, 9]);
    final marking = ImageMarking(
      outline: const [Offset(0.2, 0.3), Offset(0.8, 0.3), Offset(0.5, 0.9)],
      tool: MarkingTool.points,
      createdAt: DateTime(2026, 8, 11),
    );

    test('the original and the marked copy are two files', () async {
      final visit = await repository.startVisit(wound);
      final photo = await repository.savePhoto(
        visit,
        original,
        marking: marking,
        marked: marked,
      );

      // The briefing asks for both. A report that shows the mark must never
      // be the only surviving version of the wound.
      expect(photo.markedRef, isNotNull);
      expect(media.files, hasLength(2));
      expect(await repository.photoBytes(photo.originalRef), original);
      expect(await repository.photoBytes(photo.markedRef!), marked);
    });

    test('the outline survives a restart as geometry', () async {
      final visit = await repository.startVisit(wound);
      await repository.savePhoto(visit, original, marking: marking);

      final stored = (await repository.photosOf(visit)).single;
      expect(stored.marking!.tool, MarkingTool.points);
      expect(stored.marking!.outline, hasLength(3));
      expect(stored.marking!.outline.first.dx, closeTo(0.2, 0.0001));
    });

    test('a damaged outline becomes no outline, not a wrong one', () async {
      final visit = await repository.startVisit(wound);
      final photo = await repository.savePhoto(
        visit,
        original,
        marking: marking,
      );

      await (db.update(db.visitPhotos)..where((p) => p.id.equals(photo.id)))
          .write(const VisitPhotosCompanion(marking: Value('{"tool":"???"}')));

      final stored = (await repository.photosOf(visit)).single;
      expect(stored.marking, isNull);
      expect(stored.originalRef, photo.originalRef);
    });

    test('the previous visit supplies the framing aid', () async {
      final earlier = await repository.startVisit(wound);
      final first = await repository.savePhoto(earlier, original);
      await repository.completeVisit(earlier, withGaps: false);

      final current = await repository.startVisit(wound);
      final aid = await repository.lastPhotoOfWound(wound, before: current);

      // Comparability across weeks is what carries the clinical value.
      expect(aid!.originalRef, first.originalRef);
    });

    test('the current visit is not its own framing aid', () async {
      final visit = await repository.startVisit(wound);
      await repository.savePhoto(visit, original);

      expect(await repository.lastPhotoOfWound(wound, before: visit), isNull);
    });

    test('deleting takes the row and both files', () async {
      final visit = await repository.startVisit(wound);
      final photo = await repository.savePhoto(visit, original, marked: marked);

      await repository.deletePhoto(photo);

      // Art. 9 asks for a deletion path that actually reaches the data. Files
      // left behind would be health data no delete ever touches again.
      expect(await repository.photosOf(visit), isEmpty);
      expect(media.files, isEmpty);
    });
  });

  group('history', () {
    final photo = Uint8List.fromList([1, 2, 3]);

    test('is empty for a wound nobody has visited', () async {
      final history = await repository.historyOf(wound);

      expect(history.isEmpty, isTrue);
      expect(history.isComparable, isFalse);
    });

    test('runs oldest first and carries values and photos', () async {
      final first = await repository.startVisit(wound);
      await repository.saveValue(
        first,
        'measurement.lengthCm',
        const CentimetreValue(4),
      );
      await repository.saveValue(
        first,
        'measurement.widthCm',
        const CentimetreValue(3),
      );
      await repository.savePhoto(first, photo, marked: photo);
      await repository.completeVisit(first, withGaps: true);

      final second = await repository.startVisit(wound);
      await repository.saveValue(
        second,
        'measurement.lengthCm',
        const CentimetreValue(3),
      );
      await repository.saveValue(
        second,
        'measurement.widthCm',
        const CentimetreValue(2),
      );

      final history = await repository.historyOf(wound);
      expect(history.entries.map((e) => e.visit), [first, second]);
      expect(history.entries.first.areaCm2, 12);
      expect(history.entries.first.closedWithGaps, isTrue);
      expect(history.entries.first.markedPhotoRef, isNotNull);
      expect(history.entries.last.isOpen, isTrue);

      // The number that answers "is it getting better": four square
      // centimetres less than the visit before.
      expect(history.areaChangeBefore(history.entries.last), -6);
    });

    test('a visit without measurements leaves a gap, not a guess', () async {
      final first = await repository.startVisit(wound);
      await repository.saveValue(
        first,
        'measurement.lengthCm',
        const CentimetreValue(4),
      );
      await repository.saveValue(
        first,
        'measurement.widthCm',
        const CentimetreValue(3),
      );
      await repository.completeVisit(first, withGaps: false);

      final second = await repository.startVisit(wound);
      await repository.completeVisit(second, withGaps: true);

      final history = await repository.historyOf(wound);

      // Interpolating here would draw a measurement nobody took.
      expect(history.areaSeries, [12, null]);
      expect(history.areaChangeBefore(history.entries.last), isNull);
    });

    test('a retaken photo replaces the earlier one in the history', () async {
      final visit = await repository.startVisit(wound);
      await repository.savePhoto(visit, photo);
      final retake = await repository.savePhoto(visit, photo);

      final history = await repository.historyOf(wound);
      expect(history.entries.single.photoRef, retake.originalRef.name);
    });
  });
}
