/// Share of each tissue type in the wound bed, in percent.
///
/// The published assessment form states the rule explicitly: "wieviel % nimmt
/// die Gewebsart/Struktur von 100 % Wundfläche ein?". The shares therefore add
/// up to exactly 100 — that is an invariant of the finding, not a hint for the
/// user interface.
///
/// See `docs/fachkataloge.md`, section 2.
library;

/// The tissue types that make up the wound bed.
enum TissueType {
  /// Nekrose
  ///
  /// The source form separates dry from moist necrosis. The briefing does not,
  /// so necrosis is kept undivided here; splitting it is an open question in
  /// `PROGRESS.md`.
  necrosis,

  /// Fibrinbelag
  fibrin,

  /// Granulationsgewebe
  granulation,

  /// Epithelgewebe
  epithelialisation,

  /// Andere Strukturen — exposed tendon, bone, foreign material.
  other,
}

/// Percentage shares of the tissue types, summing to 100.
class TissueDistribution {
  /// Creates a distribution from whole-percent [shares].
  ///
  /// Throws [ArgumentError] when a share is outside 0..100 or when the shares
  /// do not add up to exactly 100. Use [validate] to check user input before
  /// building the value object.
  factory TissueDistribution(Map<TissueType, int> shares) {
    final problem = validate(shares);
    if (problem != null) {
      throw ArgumentError.value(shares, 'shares', problem.name);
    }
    final normalized = <TissueType, int>{
      for (final type in TissueType.values)
        if ((shares[type] ?? 0) > 0) type: shares[type]!,
    };
    return TissueDistribution._(Map.unmodifiable(normalized));
  }

  const TissueDistribution._(this._shares);

  final Map<TissueType, int> _shares;

  /// Share of [type] in percent; zero when the type is not present.
  int operator [](TissueType type) => _shares[type] ?? 0;

  /// The tissue types actually present, in enum order.
  Iterable<TissueType> get presentTypes =>
      TissueType.values.where((type) => this[type] > 0);

  /// Checks [shares] and returns the first problem found, or null when valid.
  ///
  /// Kept separate from the constructor so a form can show the reason while the
  /// user is still typing, instead of catching an exception.
  static TissueDistributionProblem? validate(Map<TissueType, int> shares) {
    var sum = 0;
    for (final entry in shares.entries) {
      if (entry.value < 0 || entry.value > 100) {
        return TissueDistributionProblem.shareOutOfRange;
      }
      sum += entry.value;
    }
    if (sum != 100) {
      return sum < 100
          ? TissueDistributionProblem.sumBelowHundred
          : TissueDistributionProblem.sumAboveHundred;
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (other is! TissueDistribution) return false;
    return TissueType.values.every((type) => this[type] == other[type]);
  }

  @override
  int get hashCode =>
      Object.hashAll(TissueType.values.map((type) => this[type]));

  @override
  String toString() {
    final parts = presentTypes.map((type) => '${type.name} ${this[type]}%');
    return 'TissueDistribution(${parts.join(', ')})';
  }
}

/// Why a set of tissue shares was rejected.
enum TissueDistributionProblem {
  shareOutOfRange,
  sumBelowHundred,
  sumAboveHundred,
}
