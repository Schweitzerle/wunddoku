/// Undermining and wound pockets, located by the clock method.
///
/// The clock face is laid over the patient: twelve o'clock points towards the
/// head, six o'clock towards the feet. The published assessment form records an
/// undermining as a *range* — "Unterminierung, Angabe nach der Uhrmethode
/// (z. B. von 12 h – 3 h)" — not as a single position.
///
/// See `docs/fachkataloge.md`, section 5.
library;

/// A position on the clock face, 1 to 12.
///
/// Twelve o'clock is the direction of the patient's head.
extension type const ClockPosition._(int hour) {
  /// Creates a position from [hour], which must be in 1..12.
  factory ClockPosition(int hour) {
    if (hour < 1 || hour > 12) {
      throw RangeError.range(hour, 1, 12, 'hour');
    }
    return ClockPosition._(hour);
  }

  /// The hour as shown to the user, 1 to 12.
  int get value => hour;

  /// Towards the head — the reference direction of the method.
  static const ClockPosition head = ClockPosition._(12);

  /// Towards the feet.
  static const ClockPosition feet = ClockPosition._(6);
}

/// An undermining or pocket, given as an arc on the clock face plus its depth.
///
/// A point finding is the case [from] == [to]; its [spanHours] is zero.
class WoundPocket {
  /// Creates a pocket running clockwise from [from] to [to].
  ///
  /// [depthCm] must be positive. The arc is directed: `from 10 to 2` is a
  /// four-hour arc across twelve o'clock, while `from 2 to 10` is the eight-hour
  /// arc the other way round. Sorting the two ends would silently turn one into
  /// the other, so the order is preserved as given.
  WoundPocket({required this.from, required this.to, required this.depthCm}) {
    if (!depthCm.isFinite || depthCm <= 0) {
      throw ArgumentError.value(depthCm, 'depthCm', 'must be positive');
    }
  }

  /// Start of the arc, clockwise.
  final ClockPosition from;

  /// End of the arc, clockwise.
  final ClockPosition to;

  /// Depth in centimetres, measured with a probe.
  final double depthCm;

  /// Length of the arc in hours, 0 to 11.
  ///
  /// Wraps across twelve o'clock: `from 10 to 2` yields 4.
  int get spanHours => (to.value - from.value) % 12;

  /// Whether the finding names a single position rather than an arc.
  bool get isPoint => from.value == to.value;

  /// Whether the arc runs across twelve o'clock.
  bool get crossesTwelve => !isPoint && to.value < from.value;

  /// Every clock position the arc touches, in clockwise order.
  List<ClockPosition> get coveredPositions => [
    for (var step = 0; step <= spanHours; step++)
      ClockPosition((from.value + step - 1) % 12 + 1),
  ];

  @override
  bool operator ==(Object other) =>
      other is WoundPocket &&
      other.from == from &&
      other.to == to &&
      other.depthCm == depthCm;

  @override
  int get hashCode => Object.hash(from, to, depthCm);

  @override
  String toString() => 'WoundPocket(${from.value}h–${to.value}h, ${depthCm}cm)';
}
