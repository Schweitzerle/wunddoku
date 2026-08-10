/// Wound stages of the WCS classification as modified by G. Kammerlander
/// (1996/2001).
///
/// The briefing calls this the "Farbschema-Matrix". It combines three criteria:
/// the colour interpretation of the wound bed ([WcsStage]), the exudation level
/// ([WcsCondition]) and a separate check for local signs of infection.
///
/// See `docs/fachkataloge.md`, section 1, for the source and the verbatim
/// German labels.
library;

/// One of the eight colour stages of the wound bed.
///
/// The order of the values follows the healing direction of the original table,
/// from necrosis towards epithelialised skin. Do not reorder: [index] is used
/// as the persisted representation.
enum WcsStage {
  /// schwarz — Nekrose
  black,

  /// schwarz-gelb — Nekrose + Fibrinbelag
  blackYellow,

  /// schwarz-gelb-rot — Nekrose + Fibrinbelag + Granulation
  blackYellowRed,

  /// gelb — Fibrinbelag
  yellow,

  /// rot-gelb — Granulation + Fibrinbelag
  redYellow,

  /// rot — Granulation
  red,

  /// rot-rosa — Granulation + Epithelisation
  redPink,

  /// rosarot — Epithelisiert
  pinkRed;

  /// The conditions that may be recorded for this stage.
  ///
  /// The condition axis is *not* uniform across the stages: necrosis and
  /// epithelialised skin carry their own vocabularies in the source table. A
  /// flat dry/moist/wet enum across all eight stages would already misstate the
  /// classification.
  Set<WcsCondition> get allowedConditions => switch (this) {
    WcsStage.black => const {
      WcsCondition.necroticDry,
      WcsCondition.necroticMoistToWet,
      WcsCondition.necrosisEdgeFirm,
      WcsCondition.necrosisEdgePartlyLoose,
    },
    WcsStage.pinkRed => const {
      WcsCondition.skinUnstableThinBrittle,
      WcsCondition.skinPartlyEczematous,
      WcsCondition.skinDry,
      WcsCondition.skinNormal,
    },
    _ => const {WcsCondition.dry, WcsCondition.moist, WcsCondition.wet},
  };

  /// Whether [condition] may be combined with this stage.
  bool allows(WcsCondition condition) => allowedConditions.contains(condition);
}

/// Exudation level, recorded as criterion 2 of the WCS table.
///
/// Which values are permitted depends on the [WcsStage] — see
/// [WcsStage.allowedConditions].
enum WcsCondition {
  /// trocken
  dry,

  /// feucht
  moist,

  /// nass
  wet,

  /// schwarz (nekrotisch) trocken
  necroticDry,

  /// schwarz (nekrotisch) feucht-nass
  necroticMoistToWet,

  /// Rand der Nekrose fest verpackt
  necrosisEdgeFirm,

  /// Rand der Nekrose teilweise locker
  necrosisEdgePartlyLoose,

  /// instabile, dünne brüchige Haut
  skinUnstableThinBrittle,

  /// teils ekzematisierte Haut
  skinPartlyEczematous,

  /// trockene Haut
  skinDry,

  /// normale Hautkonsistenz
  skinNormal,
}

/// A complete WCS finding: colour stage, condition and the separate infection
/// check that forms criterion 3 of the table.
///
/// Construction fails when [condition] is not permitted for [stage]. That is
/// deliberate — an impossible combination must not reach storage, because
/// nothing downstream would notice it.
class WcsFinding {
  WcsFinding({
    required this.stage,
    required this.condition,
    required this.signsOfInfection,
  }) {
    if (!stage.allows(condition)) {
      throw ArgumentError.value(
        condition,
        'condition',
        'not permitted for stage $stage',
      );
    }
  }

  final WcsStage stage;
  final WcsCondition condition;

  /// Criterion 3 of the table: local signs of infection, assessed separately
  /// from the colour stage.
  final bool signsOfInfection;

  @override
  bool operator ==(Object other) =>
      other is WcsFinding &&
      other.stage == stage &&
      other.condition == condition &&
      other.signsOfInfection == signsOfInfection;

  @override
  int get hashCode => Object.hash(stage, condition, signsOfInfection);

  @override
  String toString() =>
      'WcsFinding($stage, $condition, infection: $signsOfInfection)';
}
