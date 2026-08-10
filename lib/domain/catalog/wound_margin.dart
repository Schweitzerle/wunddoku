/// Findings for the wound edge (Wundrand) and the surrounding skin
/// (Wundumgebung).
///
/// The value lists come from the client's own audit list; the surrounding skin
/// uses the same features plus three of its own. Both are multiple choice — an
/// edge can be reddened and oedematous at the same time.
///
/// See `docs/fachkataloge.md`, section 3, for the comparison with the published
/// assessment form.
library;

/// A single observable feature of the wound edge or the surrounding skin.
enum MarginFeature {
  /// Normal — unremarkable. Excludes every other feature.
  normal,

  /// Mazeration — softening of the skin through prolonged contact with fluid.
  maceration,

  /// Rötung
  redness,

  /// Trocken
  dry,

  /// Livide — a bluish discolouration, a sign of deeper tissue damage.
  livid,

  /// Atroph
  atrophic,

  /// Ödematös
  oedematous,

  /// Infektion — surrounding skin only.
  infection,

  /// Mykose — surrounding skin only.
  mycosis,

  /// Juckreiz — surrounding skin only.
  itching;

  /// Whether this feature may be recorded for the wound edge.
  ///
  /// The last three exist only for the surrounding skin.
  bool get appliesToEdge => switch (this) {
    MarginFeature.infection ||
    MarginFeature.mycosis ||
    MarginFeature.itching => false,
    _ => true,
  };
}

/// Which of the two areas a finding describes.
enum MarginArea {
  /// Wundrand
  edge,

  /// Wundumgebung
  surroundingSkin;

  /// The features that may be recorded for this area.
  Set<MarginFeature> get allowedFeatures => switch (this) {
    MarginArea.edge =>
      MarginFeature.values.where((f) => f.appliesToEdge).toSet(),
    MarginArea.surroundingSkin => MarginFeature.values.toSet(),
  };
}

/// The features observed on one area, as a multiple-choice finding.
class MarginFinding {
  /// Creates a finding for [area] from [features].
  ///
  /// Throws [ArgumentError] when a feature does not apply to the area, or when
  /// [MarginFeature.normal] appears next to another feature — "normal" is the
  /// statement that there is nothing else to report, so the combination would
  /// contradict itself.
  factory MarginFinding({
    required MarginArea area,
    required Set<MarginFeature> features,
  }) {
    final problem = validate(area: area, features: features);
    if (problem != null) {
      throw ArgumentError.value(features, 'features', problem.name);
    }
    return MarginFinding._(area, Set.unmodifiable(features));
  }

  const MarginFinding._(this.area, this.features);

  final MarginArea area;
  final Set<MarginFeature> features;

  /// Whether anything was recorded at all. An empty finding is a gap, not a
  /// statement that the area is normal.
  bool get isEmpty => features.isEmpty;

  /// Checks a selection and returns the first problem, or null when valid.
  static MarginProblem? validate({
    required MarginArea area,
    required Set<MarginFeature> features,
  }) {
    final allowed = area.allowedFeatures;
    if (features.any((feature) => !allowed.contains(feature))) {
      return MarginProblem.featureNotAllowedForArea;
    }
    if (features.contains(MarginFeature.normal) && features.length > 1) {
      return MarginProblem.normalCombinedWithOtherFeature;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is MarginFinding &&
      other.area == area &&
      other.features.length == features.length &&
      other.features.containsAll(features);

  @override
  int get hashCode => Object.hash(area, Object.hashAllUnordered(features));

  @override
  String toString() =>
      'MarginFinding($area, {${features.map((f) => f.name).join(', ')}})';
}

/// Why a margin selection was rejected.
enum MarginProblem { featureNotAllowedForArea, normalCombinedWithOtherFeature }
