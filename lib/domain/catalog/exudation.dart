/// Exudation: how much fluid the wound produces and of what kind.
///
/// The client's audit list asks for an estimate (kein/gering/mäßig/stark). The
/// published assessment form instead records an observable fact — the state of
/// the dressing — which two people can reproduce. Both are modelled; which one
/// is authoritative is an open question in `PROGRESS.md`.
///
/// See `docs/fachkataloge.md`, section 4.
library;

/// Estimated amount of exudate, as specified by the client.
enum ExudateAmount {
  /// kein
  none,

  /// gering
  slight,

  /// mäßig
  moderate,

  /// stark
  heavy,
}

/// Kind of exudate, as specified by the client.
///
/// Multiple choice: exudate can be serous and bloody at once.
enum ExudateKind {
  /// serös
  serous,

  /// eitrig
  purulent,

  /// blutig
  bloody,
}

/// The dressing state as an observed proxy for the amount.
///
/// Ordered from dry to soaked; [index] is meaningful as a rank, so do not
/// reorder.
enum DressingSaturation {
  /// Verband trocken
  dressingDry,

  /// Verband feucht
  dressingMoist,

  /// Verband nass
  dressingWet,

  /// Verband nass, Kleidung feucht
  dressingWetClothingMoist,

  /// Verband nass, Kleidung nass
  dressingWetClothingWet,
}

/// A complete exudation finding.
class ExudationFinding {
  ExudationFinding({
    required this.amount,
    required Set<ExudateKind> kinds,
    this.dressingSaturation,
  }) : kinds = Set.unmodifiable(kinds) {
    if (amount == ExudateAmount.none && kinds.isNotEmpty) {
      throw ArgumentError.value(
        kinds,
        'kinds',
        'no exudate cannot have a kind',
      );
    }
  }

  /// Estimated amount.
  final ExudateAmount amount;

  /// Observed kinds; empty when [amount] is [ExudateAmount.none].
  final Set<ExudateKind> kinds;

  /// Optional second axis: what the dressing looked like.
  ///
  /// Null means it was not recorded — deliberately not defaulted, because a
  /// guessed dressing state would look exactly like an observed one.
  final DressingSaturation? dressingSaturation;

  @override
  bool operator ==(Object other) =>
      other is ExudationFinding &&
      other.amount == amount &&
      other.dressingSaturation == dressingSaturation &&
      other.kinds.length == kinds.length &&
      other.kinds.containsAll(kinds);

  @override
  int get hashCode =>
      Object.hash(amount, dressingSaturation, Object.hashAllUnordered(kinds));

  @override
  String toString() =>
      'ExudationFinding($amount, {${kinds.map((k) => k.name).join(', ')}}, '
      'dressing: $dressingSaturation)';
}
