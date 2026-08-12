import 'dart:convert';

import 'package:drift/drift.dart';

import '../core/id_generator.dart';
import '../domain/catalog/exudation.dart';
import '../domain/model/ids.dart';
import '../domain/model/image_marking.dart';
import '../domain/model/visit_draft.dart';
import '../domain/model/wound_history.dart';
import 'db/app_database.dart';
import 'media/media_store.dart';

/// One stored photo with everything needed to show and compare it.
class VisitPhoto {
  const VisitPhoto({
    required this.id,
    required this.originalRef,
    required this.markedRef,
    required this.marking,
    required this.takenAt,
  });

  final String id;

  /// The photo as the camera took it.
  final MediaRef originalRef;

  /// The copy with the outline burnt in, if one was drawn.
  final MediaRef? markedRef;

  /// The outline as geometry, which is what makes visits comparable.
  final ImageMarking? marking;

  final DateTime takenAt;
}

/// Single source of truth for visits and the values recorded in them.
///
/// Writes are per field, not per visit: the nurse can be interrupted by a
/// phone call, a flat battery or an accidental back gesture at any point, and
/// none of those may cost a finding (`/eps:field-app-muster`). Reading the
/// draft back is what makes the re-entry point come from the record rather
/// than from the navigation stack.
class VisitRepository {
  VisitRepository(this._db, this._media, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final MediaStore _media;
  final DateTime Function() _clock;

  /// Starts a visit for [woundId] and returns its id.
  Future<VisitId> startVisit(WoundId woundId) async {
    final id = VisitId(newId());
    await _db
        .into(_db.visits)
        .insert(
          VisitsCompanion.insert(
            id: id.value,
            woundId: woundId.value,
            startedAt: _clock(),
            status: VisitStatus.draft,
          ),
        );
    return id;
  }

  /// The visit that is still being worked on for [woundId], or null.
  ///
  /// A visit stays a draft until it is closed, so finding one on start-up is
  /// how the app resumes where the nurse left off.
  Future<VisitId?> openDraft(WoundId woundId) async {
    final row =
        await (_db.select(_db.visits)
              ..where(
                (v) =>
                    v.woundId.equals(woundId.value) &
                    v.status.equalsValue(VisitStatus.draft),
              )
              ..orderBy([(v) => OrderingTerm.desc(v.startedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : VisitId(row.id);
  }

  /// Stores [value] for [slotId]; null clears the field back to a gap.
  ///
  /// One row, one write. Called after every single change, which is why it
  /// must stay this small.
  Future<void> saveValue(
    VisitId visit,
    String slotId,
    VisitValue? value,
  ) async {
    if (value == null) {
      await (_db.delete(_db.visitValues)..where(
            (v) => v.visitId.equals(visit.value) & v.slotId.equals(slotId),
          ))
          .go();
      return;
    }

    final (kind, number, code) = _encode(value);
    await _db
        .into(_db.visitValues)
        .insertOnConflictUpdate(
          VisitValuesCompanion.insert(
            visitId: visit.value,
            slotId: slotId,
            kind: kind,
            number: Value(number),
            code: Value(code),
            updatedAt: _clock(),
          ),
        );
  }

  /// Everything recorded for [visit] so far.
  Future<VisitDraft> loadDraft(VisitId visit) async {
    final rows = await (_db.select(
      _db.visitValues,
    )..where((v) => v.visitId.equals(visit.value))).get();

    // Null-aware element: a row that cannot be decoded drops out instead of
    // becoming a value nobody entered.
    return VisitDraft(
      values: {for (final row in rows) row.slotId: ?_decode(row)},
    );
  }

  /// Closes [visit].
  ///
  /// [withGaps] records that fields were left empty on purpose — allowed, and
  /// deliberately distinguishable from a complete finding later in the office.
  Future<void> completeVisit(VisitId visit, {required bool withGaps}) async {
    await (_db.update(
      _db.visits,
    )..where((v) => v.id.equals(visit.value))).write(
      VisitsCompanion(
        completedAt: Value(_clock()),
        status: Value(
          withGaps ? VisitStatus.completeWithGaps : VisitStatus.complete,
        ),
      ),
    );
  }

  /// Stores a photo of [visit] and returns the record.
  ///
  /// [original] goes into the media store untouched. [marked] is the copy with
  /// the outline burnt in and is a second file — the briefing asks for both,
  /// and a report that shows the mark must never be the only remaining
  /// version of the wound.
  Future<VisitPhoto> savePhoto(
    VisitId visit,
    Uint8List original, {
    ImageMarking? marking,
    Uint8List? marked,
  }) async {
    final originalRef = await _media.save(original, kind: MediaKind.photo);
    final markedRef = marked == null
        ? null
        : await _media.save(marked, kind: MediaKind.markedPhoto);

    final photo = VisitPhoto(
      id: newId(),
      originalRef: originalRef,
      markedRef: markedRef,
      marking: marking,
      takenAt: _clock(),
    );

    await _db
        .into(_db.visitPhotos)
        .insert(
          VisitPhotosCompanion.insert(
            id: photo.id,
            visitId: visit.value,
            originalRef: originalRef.name,
            markedRef: Value(markedRef?.name),
            marking: Value(
              marking == null ? null : jsonEncode(marking.toJson()),
            ),
            takenAt: photo.takenAt,
          ),
        );
    return photo;
  }

  /// The photos of [visit], newest last.
  Future<List<VisitPhoto>> photosOf(VisitId visit) async {
    final rows =
        await (_db.select(_db.visitPhotos)
              ..where((p) => p.visitId.equals(visit.value))
              ..orderBy([(p) => OrderingTerm.asc(p.takenAt)]))
            .get();
    return [for (final row in rows) _photo(row)];
  }

  /// The most recent photo taken for [wound] before [visit].
  ///
  /// This is what the viewfinder shows as a framing aid and what the marking
  /// screen draws behind the current outline: without the previous picture,
  /// two visits' photos are not comparable and the record loses the very
  /// thing that carries the clinical value.
  Future<VisitPhoto?> lastPhotoOfWound(WoundId wound, {VisitId? before}) async {
    final query = _db.select(_db.visitPhotos).join([
      innerJoin(_db.visits, _db.visits.id.equalsExp(_db.visitPhotos.visitId)),
    ])..where(_db.visits.woundId.equals(wound.value));
    if (before != null) {
      query.where(_db.visits.id.equals(before.value).not());
    }
    query
      ..orderBy([OrderingTerm.desc(_db.visitPhotos.takenAt)])
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row == null ? null : _photo(row.readTable(_db.visitPhotos));
  }

  /// Reads the image bytes behind [ref].
  Future<Uint8List> photoBytes(MediaRef ref) => _media.read(ref);

  /// Removes [photo] from the record and from the device.
  ///
  /// The row and both files go together. A row without files would show an
  /// empty frame in the report; files without a row would be health data no
  /// deletion path reaches.
  Future<void> deletePhoto(VisitPhoto photo) async {
    await (_db.delete(
      _db.visitPhotos,
    )..where((p) => p.id.equals(photo.id))).go();
    await _media.delete(photo.originalRef);
    final marked = photo.markedRef;
    if (marked != null) await _media.delete(marked);
  }

  VisitPhoto _photo(VisitPhotoRow row) {
    final stored = row.marking;
    ImageMarking? marking;
    if (stored != null) {
      final decoded = jsonDecode(stored);
      // A marking that cannot be read becomes no marking: an outline landing
      // beside the wound is worse than a photo without one.
      if (decoded is Map<String, Object?>) {
        marking = ImageMarking.fromJson(decoded);
      }
    }

    return VisitPhoto(
      id: row.id,
      originalRef: MediaRef(row.originalRef),
      markedRef: row.markedRef == null ? null : MediaRef(row.markedRef!),
      marking: marking,
      takenAt: row.takenAt,
    );
  }

  /// Every visit of [wound] with its values and photo handles, oldest first.
  ///
  /// One query per table rather than per visit: a wound documented weekly for
  /// a year is fifty visits, and a round trip each would be felt on the
  /// phones in the field.
  Future<WoundHistory> historyOf(WoundId wound) async {
    final visits =
        await (_db.select(_db.visits)
              ..where((v) => v.woundId.equals(wound.value))
              ..orderBy([(v) => OrderingTerm.asc(v.startedAt)]))
            .get();
    if (visits.isEmpty) return const WoundHistory([]);

    final ids = [for (final visit in visits) visit.id];
    final values = await (_db.select(
      _db.visitValues,
    )..where((v) => v.visitId.isIn(ids))).get();
    final photos =
        await (_db.select(_db.visitPhotos)
              ..where((p) => p.visitId.isIn(ids))
              ..orderBy([(p) => OrderingTerm.asc(p.takenAt)]))
            .get();

    final valuesByVisit = <String, Map<String, VisitValue>>{};
    for (final row in values) {
      final value = _decode(row);
      if (value == null) continue;
      valuesByVisit.putIfAbsent(row.visitId, () => {})[row.slotId] = value;
    }

    // The last photo of a visit is the one that counts: an earlier one was
    // retaken, and a retake is a correction, not a second finding.
    final photoByVisit = {for (final row in photos) row.visitId: row};

    return WoundHistory([
      for (final visit in visits)
        HistoryEntry(
          visit: VisitId(visit.id),
          recordedAt: visit.completedAt ?? visit.startedAt,
          draft: VisitDraft(values: valuesByVisit[visit.id] ?? const {}),
          closedWithGaps: visit.status == VisitStatus.completeWithGaps,
          isOpen: visit.status == VisitStatus.draft,
          photoRef: photoByVisit[visit.id]?.originalRef,
          markedPhotoRef: photoByVisit[visit.id]?.markedRef,
        ),
    ]);
  }

  /// How many visits are documented per wound, for the given wounds.
  ///
  /// One query for the whole list, for the same reason as
  /// `WoundRepository.countsByPatient`.
  Future<Map<WoundId, int>> countsOfWounds(List<WoundId> wounds) async {
    if (wounds.isEmpty) return const {};

    final count = _db.visits.id.count();
    final query = _db.selectOnly(_db.visits)
      ..addColumns([_db.visits.woundId, count])
      ..where(_db.visits.woundId.isIn([for (final id in wounds) id.value]))
      ..groupBy([_db.visits.woundId]);

    return {
      for (final row in await query.get())
        WoundId(row.read(_db.visits.woundId)!): row.read(count) ?? 0,
    };
  }

  /// Stores the verbatim transcript with the visit.
  Future<void> saveTranscript(VisitId visit, String transcript) async {
    await (_db.update(_db.visits)..where((v) => v.id.equals(visit.value)))
        .write(VisitsCompanion(transcript: Value(transcript)));
  }

  (StoredValueKind, double?, String?) _encode(VisitValue value) =>
      switch (value) {
        CentimetreValue(:final centimetres) => (
          StoredValueKind.centimetres,
          centimetres,
          null,
        ),
        PercentValue(:final percent) => (
          StoredValueKind.percent,
          percent.toDouble(),
          null,
        ),
        ScoreValue(:final score) => (
          StoredValueKind.score,
          score.toDouble(),
          null,
        ),
        ExudateAmountValue(:final amount) => (
          StoredValueKind.exudateAmount,
          null,
          amount.name,
        ),
        ExudateKindValue(:final kind) => (
          StoredValueKind.exudateKind,
          null,
          kind.name,
        ),
      };

  /// Reads a row back, or null when it cannot be trusted.
  ///
  /// A row whose number or code is missing is damaged, not empty. Dropping it
  /// turns the field into a visible gap, which is the safe outcome — the
  /// alternative would be a value nobody entered.
  VisitValue? _decode(VisitValueRow row) => switch (row.kind) {
    StoredValueKind.centimetres =>
      row.number == null ? null : CentimetreValue(row.number!),
    StoredValueKind.percent =>
      row.number == null ? null : PercentValue(row.number!.round()),
    StoredValueKind.score =>
      row.number == null ? null : ScoreValue(row.number!.round()),
    StoredValueKind.exudateAmount => switch (_byName(
      ExudateAmount.values,
      row.code,
    )) {
      final amount? => ExudateAmountValue(amount),
      _ => null,
    },
    StoredValueKind.exudateKind => switch (_byName(
      ExudateKind.values,
      row.code,
    )) {
      final kind? => ExudateKindValue(kind),
      _ => null,
    },
  };

  /// The enum value called [name], or null when the catalogue no longer knows
  /// it — which happens when a value was written by an older version.
  T? _byName<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
