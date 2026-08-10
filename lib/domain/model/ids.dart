/// Typed identifiers for the three aggregate roots.
///
/// Extension types keep the ids from being mixed up — a [WoundId] cannot be
/// passed where a [PatientId] is expected, although both are strings in the
/// database.
library;

/// Identifier of a patient record.
extension type const PatientId(String value) {}

/// Identifier of a wound belonging to one patient.
extension type const WoundId(String value) {}

/// Identifier of a single visit documenting one wound.
extension type const VisitId(String value) {}
