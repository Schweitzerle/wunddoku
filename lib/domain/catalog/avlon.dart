/// AVLON classification after Kammerlander.
///
/// **The grade definitions are not verified.** AVLON exists — the Akademie-ZWM
/// sells a poster "AVLON Wund- und Dekubitusklassifikation" — but neither the
/// expansion of the acronym nor the steps of the scale are published in any
/// freely available source. The dimensions below follow the client's audit
/// list; [AvlonGrade] is provisional and deliberately defined in exactly one
/// place so that replacing it costs a single edit.
///
/// Read `docs/fachkataloge.md`, section 8, before changing anything here. The
/// open question and how to close it are tracked in `PROGRESS.md`.
library;

/// The five dimensions assessed, as named in the client's audit list.
enum AvlonDimension {
  /// Arteriell
  arterial,

  /// Venös
  venous,

  /// Lymphangiös
  lymphangial,

  /// Osteo-Arthropathie
  osteoarthropathic,

  /// Neuropathie
  neuropathic,
}

/// Severity grade of a single dimension.
///
/// **Provisional.** The briefing states the range as "Grad Ia–IV"; the
/// intermediate steps below follow the usual a/b subdivision of that notation
/// but are not confirmed against a source. Do not present these to a clinical
/// user as authoritative until the question in `PROGRESS.md` is closed.
enum AvlonGrade {
  ia('Ia'),
  ib('Ib'),
  iia('IIa'),
  iib('IIb'),
  iii('III'),
  iv('IV');

  const AvlonGrade(this.label);

  /// The grade as written in the classification, e.g. `IIa`.
  final String label;
}

/// An AVLON assessment: a grade for each dimension that was assessed.
///
/// A dimension that was not assessed is absent from the map rather than
/// carrying a default. A guessed grade in a wound record is worse than a
/// visible gap, because nothing distinguishes it from an observed one.
class AvlonAssessment {
  AvlonAssessment(Map<AvlonDimension, AvlonGrade> grades)
    : _grades = Map.unmodifiable(grades);

  /// An assessment in which nothing has been recorded yet.
  static const AvlonAssessment empty = AvlonAssessment._const({});

  const AvlonAssessment._const(this._grades);

  final Map<AvlonDimension, AvlonGrade> _grades;

  /// The grade recorded for [dimension], or null when it was not assessed.
  AvlonGrade? operator [](AvlonDimension dimension) => _grades[dimension];

  /// The dimensions that carry no grade yet.
  Iterable<AvlonDimension> get missingDimensions =>
      AvlonDimension.values.where((d) => !_grades.containsKey(d));

  /// Whether every dimension has been assessed.
  bool get isComplete => missingDimensions.isEmpty;

  /// Returns a copy with [grade] recorded for [dimension].
  AvlonAssessment withGrade(AvlonDimension dimension, AvlonGrade grade) =>
      AvlonAssessment({..._grades, dimension: grade});

  @override
  bool operator ==(Object other) {
    if (other is! AvlonAssessment) return false;
    return AvlonDimension.values.every((d) => this[d] == other[d]);
  }

  @override
  int get hashCode => Object.hashAll(AvlonDimension.values.map((d) => this[d]));

  @override
  String toString() {
    final parts = _grades.entries.map((e) => '${e.key.name}=${e.value.label}');
    return 'AvlonAssessment(${parts.join(', ')})';
  }
}
