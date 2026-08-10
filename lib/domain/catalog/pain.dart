/// Pain: intensity, quality, therapy and measures.
///
/// The briefing asks for an intensity of 0 to 10 and a quality list it leaves
/// open ("brennend/stechend/…"). The open part is not invented here — see
/// [PainQuality] and the open question in `PROGRESS.md`.
///
/// See `docs/fachkataloge.md`, section 6.
library;

/// Numeric rating of pain, 0 to 10.
extension type const PainScore._(int value) {
  /// Creates a score from [value], which must be in 0..10.
  factory PainScore(int value) {
    if (value < 0 || value > 10) {
      throw RangeError.range(value, 0, 10, 'value');
    }
    return PainScore._(value);
  }

  /// No pain reported.
  static const PainScore none = PainScore._(0);

  /// The rating as shown to the user.
  int get score => value;
}

/// What the rating refers to.
///
/// Pain at rest and pain caused by the dressing change are different
/// quantities, and the second is the one that drives the treatment decision.
/// Recording a score without saying which one it is makes the series
/// uncomparable over time.
enum PainContext {
  /// Ruheschmerz
  atRest,

  /// Schmerzen durch den Verbandwechsel
  duringDressingChange,
}

/// Quality of the pain.
///
/// **Incomplete by design.** The briefing names two anchors and continues with
/// an ellipsis; the remaining values have to come from the client. Until then
/// [PainFinding.additionalQualities] carries what the user said verbatim, so
/// nothing is lost and nothing is invented.
enum PainQuality {
  /// brennend
  burning,

  /// stechend
  stabbing,
}

/// Where a pain therapy acts.
enum PainTherapyRoute {
  /// lokale Schmerztherapie
  local,

  /// systemische Schmerztherapie
  systemic,
}

/// A complete pain finding for one visit.
class PainFinding {
  PainFinding({
    required this.score,
    required this.context,
    Set<PainQuality> qualities = const {},
    Set<String> additionalQualities = const {},
    Set<PainTherapyRoute> therapyRoutes = const {},
    this.measures = '',
  }) : qualities = Set.unmodifiable(qualities),
       additionalQualities = Set.unmodifiable(additionalQualities),
       therapyRoutes = Set.unmodifiable(therapyRoutes) {
    if (score == PainScore.none &&
        (qualities.isNotEmpty || additionalQualities.isNotEmpty)) {
      throw ArgumentError('a score of 0 cannot carry a pain quality');
    }
  }

  final PainScore score;
  final PainContext context;

  /// Qualities from the confirmed catalogue.
  final Set<PainQuality> qualities;

  /// Wordings the user gave that the catalogue does not cover yet.
  ///
  /// These are kept verbatim rather than forced into a nearby enum value. They
  /// are also the material from which the missing catalogue entries will be
  /// derived once the client confirms the full list.
  final Set<String> additionalQualities;

  final Set<PainTherapyRoute> therapyRoutes;

  /// Measures taken, in the nurse's own words.
  final String measures;

  @override
  String toString() =>
      'PainFinding(${score.score}/10, $context, '
      '{${qualities.map((q) => q.name).join(', ')}})';
}
