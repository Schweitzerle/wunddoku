import 'ids.dart';

/// A patient of the ambulatory wound care service.
///
/// The address doubles as the visit location — the nurses treat patients at
/// home. Only the fields the care process needs are recorded; insurance and
/// billing data are deliberately absent (data minimisation, see
/// `10-datenschutz-basis.md`).
class Patient {
  const Patient({
    required this.id,
    required this.givenName,
    required this.familyName,
    required this.birthDate,
    required this.street,
    required this.postalCode,
    required this.city,
    required this.createdAt,
  });

  final PatientId id;
  final String givenName;
  final String familyName;

  /// Date of birth; the time component is meaningless and always midnight.
  final DateTime birthDate;

  final String street;
  final String postalCode;
  final String city;

  final DateTime createdAt;

  /// The name as shown in lists: family name first, so an alphabetically
  /// sorted list reads naturally.
  String get displayName => '$familyName, $givenName';

  Patient copyWith({
    String? givenName,
    String? familyName,
    DateTime? birthDate,
    String? street,
    String? postalCode,
    String? city,
  }) => Patient(
    id: id,
    givenName: givenName ?? this.givenName,
    familyName: familyName ?? this.familyName,
    birthDate: birthDate ?? this.birthDate,
    street: street ?? this.street,
    postalCode: postalCode ?? this.postalCode,
    city: city ?? this.city,
    createdAt: createdAt,
  );

  @override
  bool operator ==(Object other) =>
      other is Patient &&
      other.id == id &&
      other.givenName == givenName &&
      other.familyName == familyName &&
      other.birthDate == birthDate &&
      other.street == street &&
      other.postalCode == postalCode &&
      other.city == city &&
      other.createdAt == createdAt;

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
  );
}
