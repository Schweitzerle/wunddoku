// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients
    with TableInfo<$PatientsTable, PatientRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _givenNameMeta = const VerificationMeta(
    'givenName',
  );
  @override
  late final GeneratedColumn<String> givenName = GeneratedColumn<String>(
    'given_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyNameMeta = const VerificationMeta(
    'familyName',
  );
  @override
  late final GeneratedColumn<String> familyName = GeneratedColumn<String>(
    'family_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
    'street',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postalCodeMeta = const VerificationMeta(
    'postalCode',
  );
  @override
  late final GeneratedColumn<String> postalCode = GeneratedColumn<String>(
    'postal_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _synchronizedMeta = const VerificationMeta(
    'synchronized',
  );
  @override
  late final GeneratedColumn<bool> synchronized = GeneratedColumn<bool>(
    'synchronized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchronized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    givenName,
    familyName,
    birthDate,
    street,
    postalCode,
    city,
    createdAt,
    synchronized,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatientRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('given_name')) {
      context.handle(
        _givenNameMeta,
        givenName.isAcceptableOrUnknown(data['given_name']!, _givenNameMeta),
      );
    } else if (isInserting) {
      context.missing(_givenNameMeta);
    }
    if (data.containsKey('family_name')) {
      context.handle(
        _familyNameMeta,
        familyName.isAcceptableOrUnknown(data['family_name']!, _familyNameMeta),
      );
    } else if (isInserting) {
      context.missing(_familyNameMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('street')) {
      context.handle(
        _streetMeta,
        street.isAcceptableOrUnknown(data['street']!, _streetMeta),
      );
    } else if (isInserting) {
      context.missing(_streetMeta);
    }
    if (data.containsKey('postal_code')) {
      context.handle(
        _postalCodeMeta,
        postalCode.isAcceptableOrUnknown(data['postal_code']!, _postalCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_postalCodeMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synchronized')) {
      context.handle(
        _synchronizedMeta,
        synchronized.isAcceptableOrUnknown(
          data['synchronized']!,
          _synchronizedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PatientRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      givenName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}given_name'],
      )!,
      familyName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_name'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      )!,
      street: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street'],
      )!,
      postalCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postal_code'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      synchronized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchronized'],
      )!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class PatientRow extends DataClass implements Insertable<PatientRow> {
  final String id;
  final String givenName;
  final String familyName;
  final DateTime birthDate;
  final String street;
  final String postalCode;
  final String city;
  final DateTime createdAt;
  final bool synchronized;
  const PatientRow({
    required this.id,
    required this.givenName,
    required this.familyName,
    required this.birthDate,
    required this.street,
    required this.postalCode,
    required this.city,
    required this.createdAt,
    required this.synchronized,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['given_name'] = Variable<String>(givenName);
    map['family_name'] = Variable<String>(familyName);
    map['birth_date'] = Variable<DateTime>(birthDate);
    map['street'] = Variable<String>(street);
    map['postal_code'] = Variable<String>(postalCode);
    map['city'] = Variable<String>(city);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['synchronized'] = Variable<bool>(synchronized);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      givenName: Value(givenName),
      familyName: Value(familyName),
      birthDate: Value(birthDate),
      street: Value(street),
      postalCode: Value(postalCode),
      city: Value(city),
      createdAt: Value(createdAt),
      synchronized: Value(synchronized),
    );
  }

  factory PatientRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientRow(
      id: serializer.fromJson<String>(json['id']),
      givenName: serializer.fromJson<String>(json['givenName']),
      familyName: serializer.fromJson<String>(json['familyName']),
      birthDate: serializer.fromJson<DateTime>(json['birthDate']),
      street: serializer.fromJson<String>(json['street']),
      postalCode: serializer.fromJson<String>(json['postalCode']),
      city: serializer.fromJson<String>(json['city']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      synchronized: serializer.fromJson<bool>(json['synchronized']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'givenName': serializer.toJson<String>(givenName),
      'familyName': serializer.toJson<String>(familyName),
      'birthDate': serializer.toJson<DateTime>(birthDate),
      'street': serializer.toJson<String>(street),
      'postalCode': serializer.toJson<String>(postalCode),
      'city': serializer.toJson<String>(city),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'synchronized': serializer.toJson<bool>(synchronized),
    };
  }

  PatientRow copyWith({
    String? id,
    String? givenName,
    String? familyName,
    DateTime? birthDate,
    String? street,
    String? postalCode,
    String? city,
    DateTime? createdAt,
    bool? synchronized,
  }) => PatientRow(
    id: id ?? this.id,
    givenName: givenName ?? this.givenName,
    familyName: familyName ?? this.familyName,
    birthDate: birthDate ?? this.birthDate,
    street: street ?? this.street,
    postalCode: postalCode ?? this.postalCode,
    city: city ?? this.city,
    createdAt: createdAt ?? this.createdAt,
    synchronized: synchronized ?? this.synchronized,
  );
  PatientRow copyWithCompanion(PatientsCompanion data) {
    return PatientRow(
      id: data.id.present ? data.id.value : this.id,
      givenName: data.givenName.present ? data.givenName.value : this.givenName,
      familyName: data.familyName.present
          ? data.familyName.value
          : this.familyName,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      street: data.street.present ? data.street.value : this.street,
      postalCode: data.postalCode.present
          ? data.postalCode.value
          : this.postalCode,
      city: data.city.present ? data.city.value : this.city,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      synchronized: data.synchronized.present
          ? data.synchronized.value
          : this.synchronized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientRow(')
          ..write('id: $id, ')
          ..write('givenName: $givenName, ')
          ..write('familyName: $familyName, ')
          ..write('birthDate: $birthDate, ')
          ..write('street: $street, ')
          ..write('postalCode: $postalCode, ')
          ..write('city: $city, ')
          ..write('createdAt: $createdAt, ')
          ..write('synchronized: $synchronized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    givenName,
    familyName,
    birthDate,
    street,
    postalCode,
    city,
    createdAt,
    synchronized,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientRow &&
          other.id == this.id &&
          other.givenName == this.givenName &&
          other.familyName == this.familyName &&
          other.birthDate == this.birthDate &&
          other.street == this.street &&
          other.postalCode == this.postalCode &&
          other.city == this.city &&
          other.createdAt == this.createdAt &&
          other.synchronized == this.synchronized);
}

class PatientsCompanion extends UpdateCompanion<PatientRow> {
  final Value<String> id;
  final Value<String> givenName;
  final Value<String> familyName;
  final Value<DateTime> birthDate;
  final Value<String> street;
  final Value<String> postalCode;
  final Value<String> city;
  final Value<DateTime> createdAt;
  final Value<bool> synchronized;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.givenName = const Value.absent(),
    this.familyName = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.street = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.city = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.synchronized = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    required String givenName,
    required String familyName,
    required DateTime birthDate,
    required String street,
    required String postalCode,
    required String city,
    required DateTime createdAt,
    this.synchronized = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       givenName = Value(givenName),
       familyName = Value(familyName),
       birthDate = Value(birthDate),
       street = Value(street),
       postalCode = Value(postalCode),
       city = Value(city),
       createdAt = Value(createdAt);
  static Insertable<PatientRow> custom({
    Expression<String>? id,
    Expression<String>? givenName,
    Expression<String>? familyName,
    Expression<DateTime>? birthDate,
    Expression<String>? street,
    Expression<String>? postalCode,
    Expression<String>? city,
    Expression<DateTime>? createdAt,
    Expression<bool>? synchronized,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (givenName != null) 'given_name': givenName,
      if (familyName != null) 'family_name': familyName,
      if (birthDate != null) 'birth_date': birthDate,
      if (street != null) 'street': street,
      if (postalCode != null) 'postal_code': postalCode,
      if (city != null) 'city': city,
      if (createdAt != null) 'created_at': createdAt,
      if (synchronized != null) 'synchronized': synchronized,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith({
    Value<String>? id,
    Value<String>? givenName,
    Value<String>? familyName,
    Value<DateTime>? birthDate,
    Value<String>? street,
    Value<String>? postalCode,
    Value<String>? city,
    Value<DateTime>? createdAt,
    Value<bool>? synchronized,
    Value<int>? rowid,
  }) {
    return PatientsCompanion(
      id: id ?? this.id,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      birthDate: birthDate ?? this.birthDate,
      street: street ?? this.street,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      synchronized: synchronized ?? this.synchronized,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (givenName.present) {
      map['given_name'] = Variable<String>(givenName.value);
    }
    if (familyName.present) {
      map['family_name'] = Variable<String>(familyName.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (street.present) {
      map['street'] = Variable<String>(street.value);
    }
    if (postalCode.present) {
      map['postal_code'] = Variable<String>(postalCode.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (synchronized.present) {
      map['synchronized'] = Variable<bool>(synchronized.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('givenName: $givenName, ')
          ..write('familyName: $familyName, ')
          ..write('birthDate: $birthDate, ')
          ..write('street: $street, ')
          ..write('postalCode: $postalCode, ')
          ..write('city: $city, ')
          ..write('createdAt: $createdAt, ')
          ..write('synchronized: $synchronized, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WoundsTable extends Wounds with TableInfo<$WoundsTable, WoundRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WoundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _icd10CodeMeta = const VerificationMeta(
    'icd10Code',
  );
  @override
  late final GeneratedColumn<String> icd10Code = GeneratedColumn<String>(
    'icd10_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchronizedMeta = const VerificationMeta(
    'synchronized',
  );
  @override
  late final GeneratedColumn<bool> synchronized = GeneratedColumn<bool>(
    'synchronized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchronized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    location,
    icd10Code,
    createdAt,
    closedAt,
    synchronized,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wounds';
  @override
  VerificationContext validateIntegrity(
    Insertable<WoundRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('icd10_code')) {
      context.handle(
        _icd10CodeMeta,
        icd10Code.isAcceptableOrUnknown(data['icd10_code']!, _icd10CodeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('synchronized')) {
      context.handle(
        _synchronizedMeta,
        synchronized.isAcceptableOrUnknown(
          data['synchronized']!,
          _synchronizedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WoundRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WoundRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      icd10Code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icd10_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      synchronized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchronized'],
      )!,
    );
  }

  @override
  $WoundsTable createAlias(String alias) {
    return $WoundsTable(attachedDatabase, alias);
  }
}

class WoundRow extends DataClass implements Insertable<WoundRow> {
  final String id;
  final String patientId;

  /// Where on the body the wound sits, in the nurse's words.
  ///
  /// Free text for now; whether the client wants a fixed body-site catalogue
  /// is an open question in `PROGRESS.md`.
  final String location;

  /// ICD-10-GM code of the underlying diagnosis, once assigned.
  final String? icd10Code;
  final DateTime createdAt;

  /// Set when the wound is closed/healed; open wounds have null.
  final DateTime? closedAt;
  final bool synchronized;
  const WoundRow({
    required this.id,
    required this.patientId,
    required this.location,
    this.icd10Code,
    required this.createdAt,
    this.closedAt,
    required this.synchronized,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['location'] = Variable<String>(location);
    if (!nullToAbsent || icd10Code != null) {
      map['icd10_code'] = Variable<String>(icd10Code);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['synchronized'] = Variable<bool>(synchronized);
    return map;
  }

  WoundsCompanion toCompanion(bool nullToAbsent) {
    return WoundsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      location: Value(location),
      icd10Code: icd10Code == null && nullToAbsent
          ? const Value.absent()
          : Value(icd10Code),
      createdAt: Value(createdAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      synchronized: Value(synchronized),
    );
  }

  factory WoundRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WoundRow(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      location: serializer.fromJson<String>(json['location']),
      icd10Code: serializer.fromJson<String?>(json['icd10Code']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      synchronized: serializer.fromJson<bool>(json['synchronized']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'location': serializer.toJson<String>(location),
      'icd10Code': serializer.toJson<String?>(icd10Code),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'synchronized': serializer.toJson<bool>(synchronized),
    };
  }

  WoundRow copyWith({
    String? id,
    String? patientId,
    String? location,
    Value<String?> icd10Code = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> closedAt = const Value.absent(),
    bool? synchronized,
  }) => WoundRow(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    location: location ?? this.location,
    icd10Code: icd10Code.present ? icd10Code.value : this.icd10Code,
    createdAt: createdAt ?? this.createdAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    synchronized: synchronized ?? this.synchronized,
  );
  WoundRow copyWithCompanion(WoundsCompanion data) {
    return WoundRow(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      location: data.location.present ? data.location.value : this.location,
      icd10Code: data.icd10Code.present ? data.icd10Code.value : this.icd10Code,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      synchronized: data.synchronized.present
          ? data.synchronized.value
          : this.synchronized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WoundRow(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('location: $location, ')
          ..write('icd10Code: $icd10Code, ')
          ..write('createdAt: $createdAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('synchronized: $synchronized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    location,
    icd10Code,
    createdAt,
    closedAt,
    synchronized,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WoundRow &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.location == this.location &&
          other.icd10Code == this.icd10Code &&
          other.createdAt == this.createdAt &&
          other.closedAt == this.closedAt &&
          other.synchronized == this.synchronized);
}

class WoundsCompanion extends UpdateCompanion<WoundRow> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> location;
  final Value<String?> icd10Code;
  final Value<DateTime> createdAt;
  final Value<DateTime?> closedAt;
  final Value<bool> synchronized;
  final Value<int> rowid;
  const WoundsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.location = const Value.absent(),
    this.icd10Code = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.synchronized = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WoundsCompanion.insert({
    required String id,
    required String patientId,
    required String location,
    this.icd10Code = const Value.absent(),
    required DateTime createdAt,
    this.closedAt = const Value.absent(),
    this.synchronized = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       location = Value(location),
       createdAt = Value(createdAt);
  static Insertable<WoundRow> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? location,
    Expression<String>? icd10Code,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? closedAt,
    Expression<bool>? synchronized,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (location != null) 'location': location,
      if (icd10Code != null) 'icd10_code': icd10Code,
      if (createdAt != null) 'created_at': createdAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (synchronized != null) 'synchronized': synchronized,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WoundsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? location,
    Value<String?>? icd10Code,
    Value<DateTime>? createdAt,
    Value<DateTime?>? closedAt,
    Value<bool>? synchronized,
    Value<int>? rowid,
  }) {
    return WoundsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      location: location ?? this.location,
      icd10Code: icd10Code ?? this.icd10Code,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      synchronized: synchronized ?? this.synchronized,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (icd10Code.present) {
      map['icd10_code'] = Variable<String>(icd10Code.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (synchronized.present) {
      map['synchronized'] = Variable<bool>(synchronized.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WoundsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('location: $location, ')
          ..write('icd10Code: $icd10Code, ')
          ..write('createdAt: $createdAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('synchronized: $synchronized, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitsTable extends Visits with TableInfo<$VisitsTable, VisitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _woundIdMeta = const VerificationMeta(
    'woundId',
  );
  @override
  late final GeneratedColumn<String> woundId = GeneratedColumn<String>(
    'wound_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wounds (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<VisitStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<VisitStatus>($VisitsTable.$converterstatus);
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _synchronizedMeta = const VerificationMeta(
    'synchronized',
  );
  @override
  late final GeneratedColumn<bool> synchronized = GeneratedColumn<bool>(
    'synchronized',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synchronized" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    woundId,
    startedAt,
    completedAt,
    status,
    transcript,
    synchronized,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visits';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('wound_id')) {
      context.handle(
        _woundIdMeta,
        woundId.isAcceptableOrUnknown(data['wound_id']!, _woundIdMeta),
      );
    } else if (isInserting) {
      context.missing(_woundIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    }
    if (data.containsKey('synchronized')) {
      context.handle(
        _synchronizedMeta,
        synchronized.isAcceptableOrUnknown(
          data['synchronized']!,
          _synchronizedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VisitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      woundId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wound_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      status: $VisitsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
      synchronized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchronized'],
      )!,
    );
  }

  @override
  $VisitsTable createAlias(String alias) {
    return $VisitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<VisitStatus, String, String> $converterstatus =
      const EnumNameConverter<VisitStatus>(VisitStatus.values);
}

class VisitRow extends DataClass implements Insertable<VisitRow> {
  final String id;
  final String woundId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final VisitStatus status;

  /// The verbatim transcript of the spoken record.
  ///
  /// Stored with the visit because it is the evidence a field value came from
  /// the nurse's own words — it must survive as long as the finding does.
  final String? transcript;
  final bool synchronized;
  const VisitRow({
    required this.id,
    required this.woundId,
    required this.startedAt,
    this.completedAt,
    required this.status,
    this.transcript,
    required this.synchronized,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['wound_id'] = Variable<String>(woundId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    {
      map['status'] = Variable<String>(
        $VisitsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    map['synchronized'] = Variable<bool>(synchronized);
    return map;
  }

  VisitsCompanion toCompanion(bool nullToAbsent) {
    return VisitsCompanion(
      id: Value(id),
      woundId: Value(woundId),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      status: Value(status),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      synchronized: Value(synchronized),
    );
  }

  factory VisitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitRow(
      id: serializer.fromJson<String>(json['id']),
      woundId: serializer.fromJson<String>(json['woundId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      status: $VisitsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      transcript: serializer.fromJson<String?>(json['transcript']),
      synchronized: serializer.fromJson<bool>(json['synchronized']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'woundId': serializer.toJson<String>(woundId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'status': serializer.toJson<String>(
        $VisitsTable.$converterstatus.toJson(status),
      ),
      'transcript': serializer.toJson<String?>(transcript),
      'synchronized': serializer.toJson<bool>(synchronized),
    };
  }

  VisitRow copyWith({
    String? id,
    String? woundId,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    VisitStatus? status,
    Value<String?> transcript = const Value.absent(),
    bool? synchronized,
  }) => VisitRow(
    id: id ?? this.id,
    woundId: woundId ?? this.woundId,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    status: status ?? this.status,
    transcript: transcript.present ? transcript.value : this.transcript,
    synchronized: synchronized ?? this.synchronized,
  );
  VisitRow copyWithCompanion(VisitsCompanion data) {
    return VisitRow(
      id: data.id.present ? data.id.value : this.id,
      woundId: data.woundId.present ? data.woundId.value : this.woundId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      status: data.status.present ? data.status.value : this.status,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      synchronized: data.synchronized.present
          ? data.synchronized.value
          : this.synchronized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitRow(')
          ..write('id: $id, ')
          ..write('woundId: $woundId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('transcript: $transcript, ')
          ..write('synchronized: $synchronized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    woundId,
    startedAt,
    completedAt,
    status,
    transcript,
    synchronized,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitRow &&
          other.id == this.id &&
          other.woundId == this.woundId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.status == this.status &&
          other.transcript == this.transcript &&
          other.synchronized == this.synchronized);
}

class VisitsCompanion extends UpdateCompanion<VisitRow> {
  final Value<String> id;
  final Value<String> woundId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<VisitStatus> status;
  final Value<String?> transcript;
  final Value<bool> synchronized;
  final Value<int> rowid;
  const VisitsCompanion({
    this.id = const Value.absent(),
    this.woundId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.transcript = const Value.absent(),
    this.synchronized = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitsCompanion.insert({
    required String id,
    required String woundId,
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    required VisitStatus status,
    this.transcript = const Value.absent(),
    this.synchronized = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       woundId = Value(woundId),
       startedAt = Value(startedAt),
       status = Value(status);
  static Insertable<VisitRow> custom({
    Expression<String>? id,
    Expression<String>? woundId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? status,
    Expression<String>? transcript,
    Expression<bool>? synchronized,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (woundId != null) 'wound_id': woundId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (status != null) 'status': status,
      if (transcript != null) 'transcript': transcript,
      if (synchronized != null) 'synchronized': synchronized,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitsCompanion copyWith({
    Value<String>? id,
    Value<String>? woundId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<VisitStatus>? status,
    Value<String?>? transcript,
    Value<bool>? synchronized,
    Value<int>? rowid,
  }) {
    return VisitsCompanion(
      id: id ?? this.id,
      woundId: woundId ?? this.woundId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      synchronized: synchronized ?? this.synchronized,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (woundId.present) {
      map['wound_id'] = Variable<String>(woundId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $VisitsTable.$converterstatus.toSql(status.value),
      );
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (synchronized.present) {
      map['synchronized'] = Variable<bool>(synchronized.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitsCompanion(')
          ..write('id: $id, ')
          ..write('woundId: $woundId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('status: $status, ')
          ..write('transcript: $transcript, ')
          ..write('synchronized: $synchronized, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $WoundsTable wounds = $WoundsTable(this);
  late final $VisitsTable visits = $VisitsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    patients,
    wounds,
    visits,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'patients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('wounds', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wounds',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('visits', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PatientsTableCreateCompanionBuilder =
    PatientsCompanion Function({
      required String id,
      required String givenName,
      required String familyName,
      required DateTime birthDate,
      required String street,
      required String postalCode,
      required String city,
      required DateTime createdAt,
      Value<bool> synchronized,
      Value<int> rowid,
    });
typedef $$PatientsTableUpdateCompanionBuilder =
    PatientsCompanion Function({
      Value<String> id,
      Value<String> givenName,
      Value<String> familyName,
      Value<DateTime> birthDate,
      Value<String> street,
      Value<String> postalCode,
      Value<String> city,
      Value<DateTime> createdAt,
      Value<bool> synchronized,
      Value<int> rowid,
    });

final class $$PatientsTableReferences
    extends BaseReferences<_$AppDatabase, $PatientsTable, PatientRow> {
  $$PatientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WoundsTable, List<WoundRow>> _woundsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.wounds,
    aliasName: 'patients__id__wounds__patient_id',
  );

  $$WoundsTableProcessedTableManager get woundsRefs {
    final manager = $$WoundsTableTableManager(
      $_db,
      $_db.wounds,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_woundsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get givenName => $composableBuilder(
    column: $table.givenName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> woundsRefs(
    Expression<bool> Function($$WoundsTableFilterComposer f) f,
  ) {
    final $$WoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wounds,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WoundsTableFilterComposer(
            $db: $db,
            $table: $db.wounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get givenName => $composableBuilder(
    column: $table.givenName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get givenName =>
      $composableBuilder(column: $table.givenName, builder: (column) => column);

  GeneratedColumn<String> get familyName => $composableBuilder(
    column: $table.familyName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => column,
  );

  Expression<T> woundsRefs<T extends Object>(
    Expression<T> Function($$WoundsTableAnnotationComposer a) f,
  ) {
    final $$WoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wounds,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.wounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTable,
          PatientRow,
          $$PatientsTableFilterComposer,
          $$PatientsTableOrderingComposer,
          $$PatientsTableAnnotationComposer,
          $$PatientsTableCreateCompanionBuilder,
          $$PatientsTableUpdateCompanionBuilder,
          (PatientRow, $$PatientsTableReferences),
          PatientRow,
          PrefetchHooks Function({bool woundsRefs})
        > {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> givenName = const Value.absent(),
                Value<String> familyName = const Value.absent(),
                Value<DateTime> birthDate = const Value.absent(),
                Value<String> street = const Value.absent(),
                Value<String> postalCode = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> synchronized = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion(
                id: id,
                givenName: givenName,
                familyName: familyName,
                birthDate: birthDate,
                street: street,
                postalCode: postalCode,
                city: city,
                createdAt: createdAt,
                synchronized: synchronized,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String givenName,
                required String familyName,
                required DateTime birthDate,
                required String street,
                required String postalCode,
                required String city,
                required DateTime createdAt,
                Value<bool> synchronized = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsCompanion.insert(
                id: id,
                givenName: givenName,
                familyName: familyName,
                birthDate: birthDate,
                street: street,
                postalCode: postalCode,
                city: city,
                createdAt: createdAt,
                synchronized: synchronized,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PatientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({woundsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (woundsRefs) db.wounds],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (woundsRefs)
                    await $_getPrefetchedData<
                      PatientRow,
                      $PatientsTable,
                      WoundRow
                    >(
                      currentTable: table,
                      referencedTable: $$PatientsTableReferences
                          ._woundsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PatientsTableReferences(db, table, p0).woundsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.patientId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PatientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTable,
      PatientRow,
      $$PatientsTableFilterComposer,
      $$PatientsTableOrderingComposer,
      $$PatientsTableAnnotationComposer,
      $$PatientsTableCreateCompanionBuilder,
      $$PatientsTableUpdateCompanionBuilder,
      (PatientRow, $$PatientsTableReferences),
      PatientRow,
      PrefetchHooks Function({bool woundsRefs})
    >;
typedef $$WoundsTableCreateCompanionBuilder =
    WoundsCompanion Function({
      required String id,
      required String patientId,
      required String location,
      Value<String?> icd10Code,
      required DateTime createdAt,
      Value<DateTime?> closedAt,
      Value<bool> synchronized,
      Value<int> rowid,
    });
typedef $$WoundsTableUpdateCompanionBuilder =
    WoundsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> location,
      Value<String?> icd10Code,
      Value<DateTime> createdAt,
      Value<DateTime?> closedAt,
      Value<bool> synchronized,
      Value<int> rowid,
    });

final class $$WoundsTableReferences
    extends BaseReferences<_$AppDatabase, $WoundsTable, WoundRow> {
  $$WoundsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PatientsTable _patientIdTable(_$AppDatabase db) =>
      db.patients.createAlias('wounds__patient_id__patients__id');

  $$PatientsTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableManager(
      $_db,
      $_db.patients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$VisitsTable, List<VisitRow>> _visitsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.visits,
    aliasName: 'wounds__id__visits__wound_id',
  );

  $$VisitsTableProcessedTableManager get visitsRefs {
    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.woundId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_visitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WoundsTableFilterComposer
    extends Composer<_$AppDatabase, $WoundsTable> {
  $$WoundsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icd10Code => $composableBuilder(
    column: $table.icd10Code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableFilterComposer get patientId {
    final $$PatientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableFilterComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> visitsRefs(
    Expression<bool> Function($$VisitsTableFilterComposer f) f,
  ) {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.woundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableFilterComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WoundsTableOrderingComposer
    extends Composer<_$AppDatabase, $WoundsTable> {
  $$WoundsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icd10Code => $composableBuilder(
    column: $table.icd10Code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableOrderingComposer get patientId {
    final $$PatientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableOrderingComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WoundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WoundsTable> {
  $$WoundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get icd10Code =>
      $composableBuilder(column: $table.icd10Code, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => column,
  );

  $$PatientsTableAnnotationComposer get patientId {
    final $$PatientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableAnnotationComposer(
            $db: $db,
            $table: $db.patients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> visitsRefs<T extends Object>(
    Expression<T> Function($$VisitsTableAnnotationComposer a) f,
  ) {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.woundId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableAnnotationComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WoundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WoundsTable,
          WoundRow,
          $$WoundsTableFilterComposer,
          $$WoundsTableOrderingComposer,
          $$WoundsTableAnnotationComposer,
          $$WoundsTableCreateCompanionBuilder,
          $$WoundsTableUpdateCompanionBuilder,
          (WoundRow, $$WoundsTableReferences),
          WoundRow,
          PrefetchHooks Function({bool patientId, bool visitsRefs})
        > {
  $$WoundsTableTableManager(_$AppDatabase db, $WoundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WoundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WoundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WoundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String?> icd10Code = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<bool> synchronized = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WoundsCompanion(
                id: id,
                patientId: patientId,
                location: location,
                icd10Code: icd10Code,
                createdAt: createdAt,
                closedAt: closedAt,
                synchronized: synchronized,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String location,
                Value<String?> icd10Code = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> closedAt = const Value.absent(),
                Value<bool> synchronized = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WoundsCompanion.insert(
                id: id,
                patientId: patientId,
                location: location,
                icd10Code: icd10Code,
                createdAt: createdAt,
                closedAt: closedAt,
                synchronized: synchronized,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WoundsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({patientId = false, visitsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (visitsRefs) db.visits],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (patientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.patientId,
                                referencedTable: $$WoundsTableReferences
                                    ._patientIdTable(db),
                                referencedColumn: $$WoundsTableReferences
                                    ._patientIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (visitsRefs)
                    await $_getPrefetchedData<WoundRow, $WoundsTable, VisitRow>(
                      currentTable: table,
                      referencedTable: $$WoundsTableReferences._visitsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$WoundsTableReferences(db, table, p0).visitsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.woundId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WoundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WoundsTable,
      WoundRow,
      $$WoundsTableFilterComposer,
      $$WoundsTableOrderingComposer,
      $$WoundsTableAnnotationComposer,
      $$WoundsTableCreateCompanionBuilder,
      $$WoundsTableUpdateCompanionBuilder,
      (WoundRow, $$WoundsTableReferences),
      WoundRow,
      PrefetchHooks Function({bool patientId, bool visitsRefs})
    >;
typedef $$VisitsTableCreateCompanionBuilder =
    VisitsCompanion Function({
      required String id,
      required String woundId,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      required VisitStatus status,
      Value<String?> transcript,
      Value<bool> synchronized,
      Value<int> rowid,
    });
typedef $$VisitsTableUpdateCompanionBuilder =
    VisitsCompanion Function({
      Value<String> id,
      Value<String> woundId,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<VisitStatus> status,
      Value<String?> transcript,
      Value<bool> synchronized,
      Value<int> rowid,
    });

final class $$VisitsTableReferences
    extends BaseReferences<_$AppDatabase, $VisitsTable, VisitRow> {
  $$VisitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WoundsTable _woundIdTable(_$AppDatabase db) =>
      db.wounds.createAlias('visits__wound_id__wounds__id');

  $$WoundsTableProcessedTableManager get woundId {
    final $_column = $_itemColumn<String>('wound_id')!;

    final manager = $$WoundsTableTableManager(
      $_db,
      $_db.wounds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_woundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VisitsTableFilterComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<VisitStatus, VisitStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => ColumnFilters(column),
  );

  $$WoundsTableFilterComposer get woundId {
    final $$WoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.woundId,
      referencedTable: $db.wounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WoundsTableFilterComposer(
            $db: $db,
            $table: $db.wounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitsTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => ColumnOrderings(column),
  );

  $$WoundsTableOrderingComposer get woundId {
    final $$WoundsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.woundId,
      referencedTable: $db.wounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WoundsTableOrderingComposer(
            $db: $db,
            $table: $db.wounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitsTable> {
  $$VisitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<VisitStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => column,
  );

  $$WoundsTableAnnotationComposer get woundId {
    final $$WoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.woundId,
      referencedTable: $db.wounds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.wounds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitsTable,
          VisitRow,
          $$VisitsTableFilterComposer,
          $$VisitsTableOrderingComposer,
          $$VisitsTableAnnotationComposer,
          $$VisitsTableCreateCompanionBuilder,
          $$VisitsTableUpdateCompanionBuilder,
          (VisitRow, $$VisitsTableReferences),
          VisitRow,
          PrefetchHooks Function({bool woundId})
        > {
  $$VisitsTableTableManager(_$AppDatabase db, $VisitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> woundId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<VisitStatus> status = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<bool> synchronized = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion(
                id: id,
                woundId: woundId,
                startedAt: startedAt,
                completedAt: completedAt,
                status: status,
                transcript: transcript,
                synchronized: synchronized,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String woundId,
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                required VisitStatus status,
                Value<String?> transcript = const Value.absent(),
                Value<bool> synchronized = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitsCompanion.insert(
                id: id,
                woundId: woundId,
                startedAt: startedAt,
                completedAt: completedAt,
                status: status,
                transcript: transcript,
                synchronized: synchronized,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VisitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({woundId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (woundId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.woundId,
                                referencedTable: $$VisitsTableReferences
                                    ._woundIdTable(db),
                                referencedColumn: $$VisitsTableReferences
                                    ._woundIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VisitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitsTable,
      VisitRow,
      $$VisitsTableFilterComposer,
      $$VisitsTableOrderingComposer,
      $$VisitsTableAnnotationComposer,
      $$VisitsTableCreateCompanionBuilder,
      $$VisitsTableUpdateCompanionBuilder,
      (VisitRow, $$VisitsTableReferences),
      VisitRow,
      PrefetchHooks Function({bool woundId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$WoundsTableTableManager get wounds =>
      $$WoundsTableTableManager(_db, _db.wounds);
  $$VisitsTableTableManager get visits =>
      $$VisitsTableTableManager(_db, _db.visits);
}
