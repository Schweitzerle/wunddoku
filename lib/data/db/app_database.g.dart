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

class $VisitValuesTable extends VisitValues
    with TableInfo<$VisitValuesTable, VisitValueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES visits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _slotIdMeta = const VerificationMeta('slotId');
  @override
  late final GeneratedColumn<String> slotId = GeneratedColumn<String>(
    'slot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<StoredValueKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<StoredValueKind>($VisitValuesTable.$converterkind);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<double> number = GeneratedColumn<double>(
    'number',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    visitId,
    slotId,
    kind,
    number,
    code,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visit_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitValueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('slot_id')) {
      context.handle(
        _slotIdMeta,
        slotId.isAcceptableOrUnknown(data['slot_id']!, _slotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_slotIdMeta);
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {visitId, slotId};
  @override
  VisitValueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitValueRow(
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      slotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot_id'],
      )!,
      kind: $VisitValuesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}number'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $VisitValuesTable createAlias(String alias) {
    return $VisitValuesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StoredValueKind, String, String> $converterkind =
      const EnumNameConverter<StoredValueKind>(StoredValueKind.values);
}

class VisitValueRow extends DataClass implements Insertable<VisitValueRow> {
  final String visitId;

  /// Identifies the field; see `FieldProposal.slotId`.
  final String slotId;
  final StoredValueKind kind;

  /// The numeric value, for the kinds that have one.
  final double? number;

  /// The enum name, for the kinds that are catalogue entries.
  final String? code;
  final DateTime updatedAt;
  const VisitValueRow({
    required this.visitId,
    required this.slotId,
    required this.kind,
    this.number,
    this.code,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['visit_id'] = Variable<String>(visitId);
    map['slot_id'] = Variable<String>(slotId);
    {
      map['kind'] = Variable<String>(
        $VisitValuesTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || number != null) {
      map['number'] = Variable<double>(number);
    }
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VisitValuesCompanion toCompanion(bool nullToAbsent) {
    return VisitValuesCompanion(
      visitId: Value(visitId),
      slotId: Value(slotId),
      kind: Value(kind),
      number: number == null && nullToAbsent
          ? const Value.absent()
          : Value(number),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      updatedAt: Value(updatedAt),
    );
  }

  factory VisitValueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitValueRow(
      visitId: serializer.fromJson<String>(json['visitId']),
      slotId: serializer.fromJson<String>(json['slotId']),
      kind: $VisitValuesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      number: serializer.fromJson<double?>(json['number']),
      code: serializer.fromJson<String?>(json['code']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'visitId': serializer.toJson<String>(visitId),
      'slotId': serializer.toJson<String>(slotId),
      'kind': serializer.toJson<String>(
        $VisitValuesTable.$converterkind.toJson(kind),
      ),
      'number': serializer.toJson<double?>(number),
      'code': serializer.toJson<String?>(code),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  VisitValueRow copyWith({
    String? visitId,
    String? slotId,
    StoredValueKind? kind,
    Value<double?> number = const Value.absent(),
    Value<String?> code = const Value.absent(),
    DateTime? updatedAt,
  }) => VisitValueRow(
    visitId: visitId ?? this.visitId,
    slotId: slotId ?? this.slotId,
    kind: kind ?? this.kind,
    number: number.present ? number.value : this.number,
    code: code.present ? code.value : this.code,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VisitValueRow copyWithCompanion(VisitValuesCompanion data) {
    return VisitValueRow(
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      slotId: data.slotId.present ? data.slotId.value : this.slotId,
      kind: data.kind.present ? data.kind.value : this.kind,
      number: data.number.present ? data.number.value : this.number,
      code: data.code.present ? data.code.value : this.code,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitValueRow(')
          ..write('visitId: $visitId, ')
          ..write('slotId: $slotId, ')
          ..write('kind: $kind, ')
          ..write('number: $number, ')
          ..write('code: $code, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(visitId, slotId, kind, number, code, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitValueRow &&
          other.visitId == this.visitId &&
          other.slotId == this.slotId &&
          other.kind == this.kind &&
          other.number == this.number &&
          other.code == this.code &&
          other.updatedAt == this.updatedAt);
}

class VisitValuesCompanion extends UpdateCompanion<VisitValueRow> {
  final Value<String> visitId;
  final Value<String> slotId;
  final Value<StoredValueKind> kind;
  final Value<double?> number;
  final Value<String?> code;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VisitValuesCompanion({
    this.visitId = const Value.absent(),
    this.slotId = const Value.absent(),
    this.kind = const Value.absent(),
    this.number = const Value.absent(),
    this.code = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitValuesCompanion.insert({
    required String visitId,
    required String slotId,
    required StoredValueKind kind,
    this.number = const Value.absent(),
    this.code = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : visitId = Value(visitId),
       slotId = Value(slotId),
       kind = Value(kind),
       updatedAt = Value(updatedAt);
  static Insertable<VisitValueRow> custom({
    Expression<String>? visitId,
    Expression<String>? slotId,
    Expression<String>? kind,
    Expression<double>? number,
    Expression<String>? code,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (visitId != null) 'visit_id': visitId,
      if (slotId != null) 'slot_id': slotId,
      if (kind != null) 'kind': kind,
      if (number != null) 'number': number,
      if (code != null) 'code': code,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitValuesCompanion copyWith({
    Value<String>? visitId,
    Value<String>? slotId,
    Value<StoredValueKind>? kind,
    Value<double?>? number,
    Value<String?>? code,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VisitValuesCompanion(
      visitId: visitId ?? this.visitId,
      slotId: slotId ?? this.slotId,
      kind: kind ?? this.kind,
      number: number ?? this.number,
      code: code ?? this.code,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (slotId.present) {
      map['slot_id'] = Variable<String>(slotId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $VisitValuesTable.$converterkind.toSql(kind.value),
      );
    }
    if (number.present) {
      map['number'] = Variable<double>(number.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitValuesCompanion(')
          ..write('visitId: $visitId, ')
          ..write('slotId: $slotId, ')
          ..write('kind: $kind, ')
          ..write('number: $number, ')
          ..write('code: $code, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VisitPhotosTable extends VisitPhotos
    with TableInfo<$VisitPhotosTable, VisitPhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _visitIdMeta = const VerificationMeta(
    'visitId',
  );
  @override
  late final GeneratedColumn<String> visitId = GeneratedColumn<String>(
    'visit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES visits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _originalRefMeta = const VerificationMeta(
    'originalRef',
  );
  @override
  late final GeneratedColumn<String> originalRef = GeneratedColumn<String>(
    'original_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markedRefMeta = const VerificationMeta(
    'markedRef',
  );
  @override
  late final GeneratedColumn<String> markedRef = GeneratedColumn<String>(
    'marked_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markingMeta = const VerificationMeta(
    'marking',
  );
  @override
  late final GeneratedColumn<String> marking = GeneratedColumn<String>(
    'marking',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
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
    visitId,
    originalRef,
    markedRef,
    marking,
    takenAt,
    synchronized,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visit_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitPhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('visit_id')) {
      context.handle(
        _visitIdMeta,
        visitId.isAcceptableOrUnknown(data['visit_id']!, _visitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_visitIdMeta);
    }
    if (data.containsKey('original_ref')) {
      context.handle(
        _originalRefMeta,
        originalRef.isAcceptableOrUnknown(
          data['original_ref']!,
          _originalRefMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalRefMeta);
    }
    if (data.containsKey('marked_ref')) {
      context.handle(
        _markedRefMeta,
        markedRef.isAcceptableOrUnknown(data['marked_ref']!, _markedRefMeta),
      );
    }
    if (data.containsKey('marking')) {
      context.handle(
        _markingMeta,
        marking.isAcceptableOrUnknown(data['marking']!, _markingMeta),
      );
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
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
  VisitPhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitPhotoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      visitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}visit_id'],
      )!,
      originalRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_ref'],
      )!,
      markedRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marked_ref'],
      ),
      marking: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marking'],
      ),
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      synchronized: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synchronized'],
      )!,
    );
  }

  @override
  $VisitPhotosTable createAlias(String alias) {
    return $VisitPhotosTable(attachedDatabase, alias);
  }
}

class VisitPhotoRow extends DataClass implements Insertable<VisitPhotoRow> {
  final String id;
  final String visitId;

  /// Handle of the photo as the camera took it. Never overwritten.
  final String originalRef;

  /// Handle of the copy with the outline burnt in, once one was drawn.
  final String? markedRef;

  /// The outline as JSON, normalised to the image; see [ImageMarking.toJson].
  final String? marking;
  final DateTime takenAt;
  final bool synchronized;
  const VisitPhotoRow({
    required this.id,
    required this.visitId,
    required this.originalRef,
    this.markedRef,
    this.marking,
    required this.takenAt,
    required this.synchronized,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['visit_id'] = Variable<String>(visitId);
    map['original_ref'] = Variable<String>(originalRef);
    if (!nullToAbsent || markedRef != null) {
      map['marked_ref'] = Variable<String>(markedRef);
    }
    if (!nullToAbsent || marking != null) {
      map['marking'] = Variable<String>(marking);
    }
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['synchronized'] = Variable<bool>(synchronized);
    return map;
  }

  VisitPhotosCompanion toCompanion(bool nullToAbsent) {
    return VisitPhotosCompanion(
      id: Value(id),
      visitId: Value(visitId),
      originalRef: Value(originalRef),
      markedRef: markedRef == null && nullToAbsent
          ? const Value.absent()
          : Value(markedRef),
      marking: marking == null && nullToAbsent
          ? const Value.absent()
          : Value(marking),
      takenAt: Value(takenAt),
      synchronized: Value(synchronized),
    );
  }

  factory VisitPhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitPhotoRow(
      id: serializer.fromJson<String>(json['id']),
      visitId: serializer.fromJson<String>(json['visitId']),
      originalRef: serializer.fromJson<String>(json['originalRef']),
      markedRef: serializer.fromJson<String?>(json['markedRef']),
      marking: serializer.fromJson<String?>(json['marking']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      synchronized: serializer.fromJson<bool>(json['synchronized']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'visitId': serializer.toJson<String>(visitId),
      'originalRef': serializer.toJson<String>(originalRef),
      'markedRef': serializer.toJson<String?>(markedRef),
      'marking': serializer.toJson<String?>(marking),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'synchronized': serializer.toJson<bool>(synchronized),
    };
  }

  VisitPhotoRow copyWith({
    String? id,
    String? visitId,
    String? originalRef,
    Value<String?> markedRef = const Value.absent(),
    Value<String?> marking = const Value.absent(),
    DateTime? takenAt,
    bool? synchronized,
  }) => VisitPhotoRow(
    id: id ?? this.id,
    visitId: visitId ?? this.visitId,
    originalRef: originalRef ?? this.originalRef,
    markedRef: markedRef.present ? markedRef.value : this.markedRef,
    marking: marking.present ? marking.value : this.marking,
    takenAt: takenAt ?? this.takenAt,
    synchronized: synchronized ?? this.synchronized,
  );
  VisitPhotoRow copyWithCompanion(VisitPhotosCompanion data) {
    return VisitPhotoRow(
      id: data.id.present ? data.id.value : this.id,
      visitId: data.visitId.present ? data.visitId.value : this.visitId,
      originalRef: data.originalRef.present
          ? data.originalRef.value
          : this.originalRef,
      markedRef: data.markedRef.present ? data.markedRef.value : this.markedRef,
      marking: data.marking.present ? data.marking.value : this.marking,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      synchronized: data.synchronized.present
          ? data.synchronized.value
          : this.synchronized,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitPhotoRow(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('originalRef: $originalRef, ')
          ..write('markedRef: $markedRef, ')
          ..write('marking: $marking, ')
          ..write('takenAt: $takenAt, ')
          ..write('synchronized: $synchronized')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    visitId,
    originalRef,
    markedRef,
    marking,
    takenAt,
    synchronized,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitPhotoRow &&
          other.id == this.id &&
          other.visitId == this.visitId &&
          other.originalRef == this.originalRef &&
          other.markedRef == this.markedRef &&
          other.marking == this.marking &&
          other.takenAt == this.takenAt &&
          other.synchronized == this.synchronized);
}

class VisitPhotosCompanion extends UpdateCompanion<VisitPhotoRow> {
  final Value<String> id;
  final Value<String> visitId;
  final Value<String> originalRef;
  final Value<String?> markedRef;
  final Value<String?> marking;
  final Value<DateTime> takenAt;
  final Value<bool> synchronized;
  final Value<int> rowid;
  const VisitPhotosCompanion({
    this.id = const Value.absent(),
    this.visitId = const Value.absent(),
    this.originalRef = const Value.absent(),
    this.markedRef = const Value.absent(),
    this.marking = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.synchronized = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VisitPhotosCompanion.insert({
    required String id,
    required String visitId,
    required String originalRef,
    this.markedRef = const Value.absent(),
    this.marking = const Value.absent(),
    required DateTime takenAt,
    this.synchronized = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       visitId = Value(visitId),
       originalRef = Value(originalRef),
       takenAt = Value(takenAt);
  static Insertable<VisitPhotoRow> custom({
    Expression<String>? id,
    Expression<String>? visitId,
    Expression<String>? originalRef,
    Expression<String>? markedRef,
    Expression<String>? marking,
    Expression<DateTime>? takenAt,
    Expression<bool>? synchronized,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (visitId != null) 'visit_id': visitId,
      if (originalRef != null) 'original_ref': originalRef,
      if (markedRef != null) 'marked_ref': markedRef,
      if (marking != null) 'marking': marking,
      if (takenAt != null) 'taken_at': takenAt,
      if (synchronized != null) 'synchronized': synchronized,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VisitPhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? visitId,
    Value<String>? originalRef,
    Value<String?>? markedRef,
    Value<String?>? marking,
    Value<DateTime>? takenAt,
    Value<bool>? synchronized,
    Value<int>? rowid,
  }) {
    return VisitPhotosCompanion(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      originalRef: originalRef ?? this.originalRef,
      markedRef: markedRef ?? this.markedRef,
      marking: marking ?? this.marking,
      takenAt: takenAt ?? this.takenAt,
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
    if (visitId.present) {
      map['visit_id'] = Variable<String>(visitId.value);
    }
    if (originalRef.present) {
      map['original_ref'] = Variable<String>(originalRef.value);
    }
    if (markedRef.present) {
      map['marked_ref'] = Variable<String>(markedRef.value);
    }
    if (marking.present) {
      map['marking'] = Variable<String>(marking.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
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
    return (StringBuffer('VisitPhotosCompanion(')
          ..write('id: $id, ')
          ..write('visitId: $visitId, ')
          ..write('originalRef: $originalRef, ')
          ..write('markedRef: $markedRef, ')
          ..write('marking: $marking, ')
          ..write('takenAt: $takenAt, ')
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
  late final $VisitValuesTable visitValues = $VisitValuesTable(this);
  late final $VisitPhotosTable visitPhotos = $VisitPhotosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    patients,
    wounds,
    visits,
    visitValues,
    visitPhotos,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'visits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('visit_values', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'visits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('visit_photos', kind: UpdateKind.delete)],
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

  static MultiTypedResultKey<$VisitValuesTable, List<VisitValueRow>>
  _visitValuesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.visitValues,
    aliasName: 'visits__id__visit_values__visit_id',
  );

  $$VisitValuesTableProcessedTableManager get visitValuesRefs {
    final manager = $$VisitValuesTableTableManager(
      $_db,
      $_db.visitValues,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_visitValuesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VisitPhotosTable, List<VisitPhotoRow>>
  _visitPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.visitPhotos,
    aliasName: 'visits__id__visit_photos__visit_id',
  );

  $$VisitPhotosTableProcessedTableManager get visitPhotosRefs {
    final manager = $$VisitPhotosTableTableManager(
      $_db,
      $_db.visitPhotos,
    ).filter((f) => f.visitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_visitPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  Expression<bool> visitValuesRefs(
    Expression<bool> Function($$VisitValuesTableFilterComposer f) f,
  ) {
    final $$VisitValuesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visitValues,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitValuesTableFilterComposer(
            $db: $db,
            $table: $db.visitValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> visitPhotosRefs(
    Expression<bool> Function($$VisitPhotosTableFilterComposer f) f,
  ) {
    final $$VisitPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visitPhotos,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitPhotosTableFilterComposer(
            $db: $db,
            $table: $db.visitPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  Expression<T> visitValuesRefs<T extends Object>(
    Expression<T> Function($$VisitValuesTableAnnotationComposer a) f,
  ) {
    final $$VisitValuesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visitValues,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitValuesTableAnnotationComposer(
            $db: $db,
            $table: $db.visitValues,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> visitPhotosRefs<T extends Object>(
    Expression<T> Function($$VisitPhotosTableAnnotationComposer a) f,
  ) {
    final $$VisitPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.visitPhotos,
      getReferencedColumn: (t) => t.visitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.visitPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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
          PrefetchHooks Function({
            bool woundId,
            bool visitValuesRefs,
            bool visitPhotosRefs,
          })
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
          prefetchHooksCallback:
              ({
                woundId = false,
                visitValuesRefs = false,
                visitPhotosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (visitValuesRefs) db.visitValues,
                    if (visitPhotosRefs) db.visitPhotos,
                  ],
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
                    return [
                      if (visitValuesRefs)
                        await $_getPrefetchedData<
                          VisitRow,
                          $VisitsTable,
                          VisitValueRow
                        >(
                          currentTable: table,
                          referencedTable: $$VisitsTableReferences
                              ._visitValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).visitValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.visitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (visitPhotosRefs)
                        await $_getPrefetchedData<
                          VisitRow,
                          $VisitsTable,
                          VisitPhotoRow
                        >(
                          currentTable: table,
                          referencedTable: $$VisitsTableReferences
                              ._visitPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VisitsTableReferences(
                                db,
                                table,
                                p0,
                              ).visitPhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.visitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
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
      PrefetchHooks Function({
        bool woundId,
        bool visitValuesRefs,
        bool visitPhotosRefs,
      })
    >;
typedef $$VisitValuesTableCreateCompanionBuilder =
    VisitValuesCompanion Function({
      required String visitId,
      required String slotId,
      required StoredValueKind kind,
      Value<double?> number,
      Value<String?> code,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$VisitValuesTableUpdateCompanionBuilder =
    VisitValuesCompanion Function({
      Value<String> visitId,
      Value<String> slotId,
      Value<StoredValueKind> kind,
      Value<double?> number,
      Value<String?> code,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$VisitValuesTableReferences
    extends BaseReferences<_$AppDatabase, $VisitValuesTable, VisitValueRow> {
  $$VisitValuesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VisitsTable _visitIdTable(_$AppDatabase db) =>
      db.visits.createAlias('visit_values__visit_id__visits__id');

  $$VisitsTableProcessedTableManager get visitId {
    final $_column = $_itemColumn<String>('visit_id')!;

    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_visitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VisitValuesTableFilterComposer
    extends Composer<_$AppDatabase, $VisitValuesTable> {
  $$VisitValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StoredValueKind, StoredValueKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VisitsTableFilterComposer get visitId {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$VisitValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitValuesTable> {
  $$VisitValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get slotId => $composableBuilder(
    column: $table.slotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VisitsTableOrderingComposer get visitId {
    final $$VisitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableOrderingComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitValuesTable> {
  $$VisitValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get slotId =>
      $composableBuilder(column: $table.slotId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StoredValueKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VisitsTableAnnotationComposer get visitId {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$VisitValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitValuesTable,
          VisitValueRow,
          $$VisitValuesTableFilterComposer,
          $$VisitValuesTableOrderingComposer,
          $$VisitValuesTableAnnotationComposer,
          $$VisitValuesTableCreateCompanionBuilder,
          $$VisitValuesTableUpdateCompanionBuilder,
          (VisitValueRow, $$VisitValuesTableReferences),
          VisitValueRow,
          PrefetchHooks Function({bool visitId})
        > {
  $$VisitValuesTableTableManager(_$AppDatabase db, $VisitValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> visitId = const Value.absent(),
                Value<String> slotId = const Value.absent(),
                Value<StoredValueKind> kind = const Value.absent(),
                Value<double?> number = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitValuesCompanion(
                visitId: visitId,
                slotId: slotId,
                kind: kind,
                number: number,
                code: code,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String visitId,
                required String slotId,
                required StoredValueKind kind,
                Value<double?> number = const Value.absent(),
                Value<String?> code = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VisitValuesCompanion.insert(
                visitId: visitId,
                slotId: slotId,
                kind: kind,
                number: number,
                code: code,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VisitValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({visitId = false}) {
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
                    if (visitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.visitId,
                                referencedTable: $$VisitValuesTableReferences
                                    ._visitIdTable(db),
                                referencedColumn: $$VisitValuesTableReferences
                                    ._visitIdTable(db)
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

typedef $$VisitValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitValuesTable,
      VisitValueRow,
      $$VisitValuesTableFilterComposer,
      $$VisitValuesTableOrderingComposer,
      $$VisitValuesTableAnnotationComposer,
      $$VisitValuesTableCreateCompanionBuilder,
      $$VisitValuesTableUpdateCompanionBuilder,
      (VisitValueRow, $$VisitValuesTableReferences),
      VisitValueRow,
      PrefetchHooks Function({bool visitId})
    >;
typedef $$VisitPhotosTableCreateCompanionBuilder =
    VisitPhotosCompanion Function({
      required String id,
      required String visitId,
      required String originalRef,
      Value<String?> markedRef,
      Value<String?> marking,
      required DateTime takenAt,
      Value<bool> synchronized,
      Value<int> rowid,
    });
typedef $$VisitPhotosTableUpdateCompanionBuilder =
    VisitPhotosCompanion Function({
      Value<String> id,
      Value<String> visitId,
      Value<String> originalRef,
      Value<String?> markedRef,
      Value<String?> marking,
      Value<DateTime> takenAt,
      Value<bool> synchronized,
      Value<int> rowid,
    });

final class $$VisitPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $VisitPhotosTable, VisitPhotoRow> {
  $$VisitPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VisitsTable _visitIdTable(_$AppDatabase db) =>
      db.visits.createAlias('visit_photos__visit_id__visits__id');

  $$VisitsTableProcessedTableManager get visitId {
    final $_column = $_itemColumn<String>('visit_id')!;

    final manager = $$VisitsTableTableManager(
      $_db,
      $_db.visits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_visitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VisitPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $VisitPhotosTable> {
  $$VisitPhotosTableFilterComposer({
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

  ColumnFilters<String> get originalRef => $composableBuilder(
    column: $table.originalRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get markedRef => $composableBuilder(
    column: $table.markedRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marking => $composableBuilder(
    column: $table.marking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => ColumnFilters(column),
  );

  $$VisitsTableFilterComposer get visitId {
    final $$VisitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$VisitPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $VisitPhotosTable> {
  $$VisitPhotosTableOrderingComposer({
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

  ColumnOrderings<String> get originalRef => $composableBuilder(
    column: $table.originalRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get markedRef => $composableBuilder(
    column: $table.markedRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marking => $composableBuilder(
    column: $table.marking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => ColumnOrderings(column),
  );

  $$VisitsTableOrderingComposer get visitId {
    final $$VisitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VisitsTableOrderingComposer(
            $db: $db,
            $table: $db.visits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VisitPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $VisitPhotosTable> {
  $$VisitPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get originalRef => $composableBuilder(
    column: $table.originalRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get markedRef =>
      $composableBuilder(column: $table.markedRef, builder: (column) => column);

  GeneratedColumn<String> get marking =>
      $composableBuilder(column: $table.marking, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<bool> get synchronized => $composableBuilder(
    column: $table.synchronized,
    builder: (column) => column,
  );

  $$VisitsTableAnnotationComposer get visitId {
    final $$VisitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.visitId,
      referencedTable: $db.visits,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$VisitPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VisitPhotosTable,
          VisitPhotoRow,
          $$VisitPhotosTableFilterComposer,
          $$VisitPhotosTableOrderingComposer,
          $$VisitPhotosTableAnnotationComposer,
          $$VisitPhotosTableCreateCompanionBuilder,
          $$VisitPhotosTableUpdateCompanionBuilder,
          (VisitPhotoRow, $$VisitPhotosTableReferences),
          VisitPhotoRow,
          PrefetchHooks Function({bool visitId})
        > {
  $$VisitPhotosTableTableManager(_$AppDatabase db, $VisitPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> visitId = const Value.absent(),
                Value<String> originalRef = const Value.absent(),
                Value<String?> markedRef = const Value.absent(),
                Value<String?> marking = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<bool> synchronized = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitPhotosCompanion(
                id: id,
                visitId: visitId,
                originalRef: originalRef,
                markedRef: markedRef,
                marking: marking,
                takenAt: takenAt,
                synchronized: synchronized,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String visitId,
                required String originalRef,
                Value<String?> markedRef = const Value.absent(),
                Value<String?> marking = const Value.absent(),
                required DateTime takenAt,
                Value<bool> synchronized = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VisitPhotosCompanion.insert(
                id: id,
                visitId: visitId,
                originalRef: originalRef,
                markedRef: markedRef,
                marking: marking,
                takenAt: takenAt,
                synchronized: synchronized,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VisitPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({visitId = false}) {
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
                    if (visitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.visitId,
                                referencedTable: $$VisitPhotosTableReferences
                                    ._visitIdTable(db),
                                referencedColumn: $$VisitPhotosTableReferences
                                    ._visitIdTable(db)
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

typedef $$VisitPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VisitPhotosTable,
      VisitPhotoRow,
      $$VisitPhotosTableFilterComposer,
      $$VisitPhotosTableOrderingComposer,
      $$VisitPhotosTableAnnotationComposer,
      $$VisitPhotosTableCreateCompanionBuilder,
      $$VisitPhotosTableUpdateCompanionBuilder,
      (VisitPhotoRow, $$VisitPhotosTableReferences),
      VisitPhotoRow,
      PrefetchHooks Function({bool visitId})
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
  $$VisitValuesTableTableManager get visitValues =>
      $$VisitValuesTableTableManager(_db, _db.visitValues);
  $$VisitPhotosTableTableManager get visitPhotos =>
      $$VisitPhotosTableTableManager(_db, _db.visitPhotos);
}
