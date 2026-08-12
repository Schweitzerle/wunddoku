import 'ids.dart';

/// One wound of one patient, followed across visits.
///
/// A patient can carry several at once — a heel and a lower leg are two
/// courses, two photo series and two reports, and mixing them up would put a
/// finding on the wrong wound.
class Wound {
  const Wound({
    required this.id,
    required this.patientId,
    required this.location,
    required this.icd10Code,
    required this.createdAt,
    required this.closedAt,
  });

  final WoundId id;
  final PatientId patientId;

  /// Where on the body the wound sits, in the nurse's words.
  ///
  /// Free text for now; whether the customer keeps a fixed body-site
  /// catalogue is an open question in `PROGRESS.md`.
  final String location;

  /// ICD-10-GM code of the underlying diagnosis, once assigned.
  final String? icd10Code;

  final DateTime createdAt;

  /// When the wound was recorded as healed; null while it is open.
  final DateTime? closedAt;

  /// Whether this wound is still being treated.
  bool get isOpen => closedAt == null;
}
