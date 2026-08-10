/// AVLON wound and pressure ulcer classification after G. Kammerlander et al.
///
/// The classification has two independent parts:
///
/// * a single [AvlonGrade] describing how deep the tissue defect reaches, and
/// * zero or more [AvlonModifier]s naming the circulatory or neurological
///   condition that accompanies it.
///
/// The five letters A-V-L-O-N are those modifiers. They are *not* five
/// separately graded dimensions — the whole point of the scheme is that
/// pressure ulcers, diabetic foot and other wounds share **one** depth scale,
/// with the underlying condition added on top.
///
/// Burns and frostbite are deliberately outside the scope of the
/// classification.
///
/// Source: "AVLON Wund-/und Dekubitusklassifikation (Graduierung)" nach
/// G. Kammerlander et al. 2006, Teil 2 der Wundklassifikation/Wundgraduierung
/// nach G. Kammerlander et al. 2007, © Akademie für Zertifiziertes
/// Wundmanagement – KAMMERLANDER-WFI 2008. See `docs/fachkataloge.md`,
/// section 8.
library;

/// Depth of the tissue defect.
///
/// Ordered from least to most severe; [index] is meaningful as a rank and is
/// used as the persisted representation, so do not reorder.
enum AvlonGrade {
  /// Grad Ia — persistierende Rötung/Entzündung an der Epidermis sichtbar,
  /// aber **ohne** sichtbaren Gewebedefekt.
  ///
  /// The only grade without a tissue defect; see [hasTissueDefect].
  ia('Ia'),

  /// Grad Ib — Gewebedefekt innerhalb der Epidermis bzw. bis an die Dermis
  /// reichend.
  ib('Ib'),

  /// Grad II — Gewebedefekt innerhalb der Dermis bzw. bis an die Subcutis
  /// reichend.
  ii('II'),

  /// Grad III — Gewebedefekt innerhalb der Subcutis bzw. bis an die Fascie
  /// reichend (oberflächliches, epifasciales Kompartement).
  iii('III'),

  /// Grad IV — Gewebedefekt innerhalb oder bis in den Faszien-, Sehnen-,
  /// Muskelbereich (tiefe Kompartemente).
  iv('IV'),

  /// Grad V — Gewebedefekt innerhalb oder bis in den/die Knochen,
  /// Gelenksbereich, Körperhöhle.
  v('V');

  const AvlonGrade(this.label);

  /// The grade as written in the classification, e.g. `III`.
  final String label;

  /// Whether this grade describes an actual tissue defect.
  ///
  /// Only [AvlonGrade.ia] does not — it is visible inflammation over intact
  /// tissue. A wound bed finding therefore cannot accompany it.
  bool get hasTissueDefect => this != AvlonGrade.ia;
}

/// An accompanying condition, added to the grade.
///
/// The letters spell AVLON; the order of the values follows the acronym.
enum AvlonModifier {
  /// A — arterielle Perfusionsstörung
  arterialPerfusion('A'),

  /// V — venöse Zirkulationsstörung
  venousCirculation('V'),

  /// L — lymphangiöse Abflussstörung
  lymphaticDrainage('L'),

  /// O — Osteo-Arthropathie
  osteoarthropathy('O'),

  /// N — Neuropathie
  neuropathy('N');

  const AvlonModifier(this.letter);

  /// The single letter used in the acronym.
  final String letter;
}

/// A complete AVLON classification: one grade plus the modifiers that apply.
class AvlonClassification {
  /// Creates a classification for [grade] with the given [modifiers].
  ///
  /// An empty modifier set is valid and means the wound was graded without an
  /// accompanying condition — it does not mean the question was skipped. Use
  /// [unassessed] for "not yet classified".
  AvlonClassification({
    required this.grade,
    Set<AvlonModifier> modifiers = const {},
  }) : modifiers = Set.unmodifiable(modifiers);

  // A wound that has not been classified yet holds `null` rather than a
  // default grade. Kept distinct on purpose: a guessed grade in a wound record
  // is worse than a visible gap, because nothing tells the two apart later.

  /// Depth of the tissue defect.
  final AvlonGrade grade;

  /// Accompanying conditions, possibly empty.
  final Set<AvlonModifier> modifiers;

  /// The classification as written, e.g. `Grad III + A + N`.
  ///
  /// The source poster shows the grade and the modifiers as a matrix and does
  /// not fix a shorthand notation, so this rendering is the project's own. It
  /// belongs to the domain rather than the UI because it also goes into the
  /// exported report.
  String get label {
    final letters = AvlonModifier.values
        .where(modifiers.contains)
        .map((m) => ' + ${m.letter}')
        .join();
    return 'Grad ${grade.label}$letters';
  }

  /// Returns a copy with [modifier] added.
  AvlonClassification withModifier(AvlonModifier modifier) =>
      AvlonClassification(grade: grade, modifiers: {...modifiers, modifier});

  /// Returns a copy with [modifier] removed.
  AvlonClassification withoutModifier(AvlonModifier modifier) =>
      AvlonClassification(
        grade: grade,
        modifiers: {...modifiers}..remove(modifier),
      );

  /// Returns a copy graded as [newGrade].
  AvlonClassification withGrade(AvlonGrade newGrade) =>
      AvlonClassification(grade: newGrade, modifiers: modifiers);

  @override
  bool operator ==(Object other) =>
      other is AvlonClassification &&
      other.grade == grade &&
      other.modifiers.length == modifiers.length &&
      other.modifiers.containsAll(modifiers);

  @override
  int get hashCode => Object.hash(grade, Object.hashAllUnordered(modifiers));

  @override
  String toString() => 'AvlonClassification($label)';
}
