import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

part 'app_database.g.dart';

/// How far a visit record has been taken.
enum VisitStatus {
  /// Still being edited during the visit.
  draft,

  /// Closed with named gaps — allowed, the gaps stay visible.
  completeWithGaps,

  /// Closed with every required field filled.
  complete,
}

/// Patient master data.
///
/// Every table carries a `synchronized` flag although nothing synchronises
/// yet — retrofitting the column later would touch every migration, adding it
/// now costs one default. See `docs/ux/nachprozess.md`.
@DataClassName('PatientRow')
class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get givenName => text()();
  TextColumn get familyName => text()();
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get street => text()();
  TextColumn get postalCode => text()();
  TextColumn get city => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synchronized => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One wound of one patient. A patient can have several open wounds at once.
@DataClassName('WoundRow')
class Wounds extends Table {
  TextColumn get id => text()();
  TextColumn get patientId =>
      text().references(Patients, #id, onDelete: KeyAction.cascade)();

  /// Where on the body the wound sits, in the nurse's words.
  ///
  /// Free text for now; whether the client wants a fixed body-site catalogue
  /// is an open question in `PROGRESS.md`.
  TextColumn get location => text()();

  /// ICD-10-GM code of the underlying diagnosis, once assigned.
  TextColumn get icd10Code => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  /// Set when the wound is closed/healed; open wounds have null.
  DateTimeColumn get closedAt => dateTime().nullable()();

  BoolColumn get synchronized => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One visit documenting one wound at one point in time.
///
/// Visits are append-only: a later correction becomes a new record referring
/// to this one, never an overwrite (see the conflict strategy in
/// `docs/ux/nachprozess.md`). The findings themselves are added by later
/// migrations as the corresponding cards are built.
@DataClassName('VisitRow')
class Visits extends Table {
  TextColumn get id => text()();
  TextColumn get woundId =>
      text().references(Wounds, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => textEnum<VisitStatus>()();

  /// The verbatim transcript of the spoken record.
  ///
  /// Stored with the visit because it is the evidence a field value came from
  /// the nurse's own words — it must survive as long as the finding does.
  TextColumn get transcript => text().nullable()();

  BoolColumn get synchronized => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// What kind of value a row in [VisitValues] holds.
///
/// Stored alongside the value so the row can be read back into the right
/// [VisitValue] without the reader having to know the slot catalogue.
enum StoredValueKind {
  /// A length in centimetres, in [VisitValues.number].
  centimetres,

  /// A share of the wound bed in percent, in [VisitValues.number].
  percent,

  /// A rating on the 0-10 pain scale, in [VisitValues.number].
  score,

  /// An [ExudateAmount], by enum name in [VisitValues.code].
  exudateAmount,

  /// An [ExudateKind], by enum name in [VisitValues.code].
  exudateKind,
}

/// One confirmed value of one visit, keyed by its slot.
///
/// Key-value rather than a column per field: the slot catalogue grows with
/// every finding card the client asks for, and eight cards' worth of columns
/// would mean a migration for each of them. The type is not lost — [kind]
/// carries it, and the repository maps rows back into the sealed value types.
///
/// Autosave writes a single row, which is why saving one field never has to
/// touch the rest of the visit.
@DataClassName('VisitValueRow')
class VisitValues extends Table {
  TextColumn get visitId =>
      text().references(Visits, #id, onDelete: KeyAction.cascade)();

  /// Identifies the field; see `FieldProposal.slotId`.
  TextColumn get slotId => text()();

  TextColumn get kind => textEnum<StoredValueKind>()();

  /// The numeric value, for the kinds that have one.
  RealColumn get number => real().nullable()();

  /// The enum name, for the kinds that are catalogue entries.
  TextColumn get code => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {visitId, slotId};
}

/// The local database, encrypted at rest.
@DriftDatabase(tables: [Patients, Wounds, Visits, VisitValues])
class AppDatabase extends _$AppDatabase {
  /// Opens the production database at [file], encrypted with [hexKey].
  ///
  /// Fails loudly when the bundled SQLite build has no cipher — a database
  /// that silently opens unencrypted would look exactly like a working one,
  /// which is the worst possible failure mode for health data.
  AppDatabase.encrypted(File file, String hexKey)
    : super(
        NativeDatabase.createInBackground(
          file,
          setup: (db) => _applyKey(db, hexKey),
        ),
      );

  /// Opens an in-memory database for tests.
  AppDatabase.forTesting(super.executor);

  static void _applyKey(Database db, String hexKey) {
    // The key reaches SQLite inside a quoted literal, so it must not be able
    // to break out of it. It is generated as hex, this guards the invariant.
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(hexKey)) {
      throw ArgumentError('database key must be 64 lowercase hex characters');
    }
    final cipher = db.select('PRAGMA cipher;');
    if (cipher.isEmpty) {
      throw StateError(
        'SQLite was built without a cipher - refusing to store health data '
        'unencrypted. Check the sqlite3mc user_define in pubspec.yaml.',
      );
    }
    db.execute("PRAGMA key = '$hexKey';");
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(visitValues);
    },
    beforeOpen: (details) async {
      // Referential integrity carries the deletion path: removing a patient
      // removes their wounds and visits (Art. 9 requires a working delete).
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );
}
