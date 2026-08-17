import 'visit_draft.dart';

/// One area of the finding, and how far it is.
///
/// The nurse thinks in areas — measurements, wound bed, exudate, pain,
/// photo — not in nine slot ids. Grouping the record the way she groups it is
/// what turns "8 Werte, 2 fehlen" into something she can act on
/// (NN/g, *Reduce Cognitive Load in Forms*: group related fields).
class StandingArea {
  const StandingArea({
    required this.id,
    required this.done,
    required this.total,
    required this.focusSlot,
  });

  /// Identifies the area for the label and for the card it leads to.
  final StandingAreaId id;

  /// How many of its parts the visit holds.
  final int done;

  /// How many parts it has. One for the areas that are a single value.
  final int total;

  /// A slot of this area, so tapping it opens the right card.
  final String focusSlot;

  bool get isComplete => done >= total;
  bool get isUntouched => done == 0;
}

/// The areas a wound finding is made of, in the order they are spoken.
enum StandingAreaId {
  measurements,
  woundBed,
  exudate,
  pain,
  photo;

  /// The area a record field belongs to.
  ///
  /// One place for the mapping: the check screen and the finding list both
  /// have to land on the same card for the same field.
  static StandingAreaId ofSlot(String slotId) =>
      switch (slotId.split('.').first) {
        'measurement' => StandingAreaId.measurements,
        'tissue' => StandingAreaId.woundBed,
        'pain' => StandingAreaId.pain,
        _ => StandingAreaId.exudate,
      };
}


/// What a visit already holds, counted for the capture screen.
///
/// The re-entry point after an interruption comes from the record, not from
/// the navigation stack (`/eps:field-app-muster`). That only helps if the
/// screen says what the record holds — otherwise a visit with five values and
/// a photo looks exactly like one that was just started.
class VisitStanding {
  VisitStanding({
    required VisitDraft draft,
    required List<String> expectedSlots,
    required this.photoCount,
    required this.markedPhotoCount,
  }) : valueCount = draft.values.length,
       gapCount = draft.gapsAmong(expectedSlots).length,
       areas = _areasOf(draft, photoCount);

  /// A visit that holds nothing yet.
  ///
  /// The areas are still listed: they are what the finding is made of, and
  /// on an empty visit they are the only way in that is not the microphone.
  VisitStanding.empty()
    : valueCount = 0,
      gapCount = 0,
      photoCount = 0,
      markedPhotoCount = 0,
      areas = _areasOf(const VisitDraft(), 0);

  /// The finding by area, in the order the areas are spoken in.
  final List<StandingArea> areas;

  static List<StandingArea> _areasOf(VisitDraft draft, int photoCount) {
    int held(List<String> slots) =>
        slots.where(draft.has).length;

    const measurements = [
      'measurement.lengthCm',
      'measurement.widthCm',
      'measurement.depthCm',
    ];
    const tissue = [
      'tissue.necrosis',
      'tissue.fibrin',
      'tissue.granulation',
      'tissue.epithelialisation',
    ];

    return [
      StandingArea(
        id: StandingAreaId.measurements,
        done: held(measurements),
        total: measurements.length,
        focusSlot: measurements.first,
      ),
      // The wound bed is complete when the shares add up, not when four
      // numbers exist: three shares of 100 % together are the whole, and a
      // fourth at zero is a statement, not a gap.
      StandingArea(
        id: StandingAreaId.woundBed,
        done: draft.tissueDistribution == null ? held(tissue) : 1,
        total: draft.tissueDistribution == null ? tissue.length : 1,
        focusSlot: tissue.first,
      ),
      StandingArea(
        id: StandingAreaId.exudate,
        done: held(const ['exudate.amount']),
        total: 1,
        focusSlot: 'exudate.amount',
      ),
      StandingArea(
        id: StandingAreaId.pain,
        done: held(const ['pain.score']),
        total: 1,
        focusSlot: 'pain.score',
      ),
      StandingArea(
        id: StandingAreaId.photo,
        done: photoCount > 0 ? 1 : 0,
        total: 1,
        focusSlot: 'photo',
      ),
    ];
  }

  /// Fields the visit carries a value for, expected or not.
  final int valueCount;

  /// Expected fields that are still empty.
  final int gapCount;

  final int photoCount;

  /// How many of those photos carry an outline.
  ///
  /// A count rather than a flag about the latest photo: after a retake a
  /// visit can hold two pictures of which only one is marked, and "2 Fotos
  /// mit Markierung" would claim both are.
  final int markedPhotoCount;

  /// Whether nothing has been recorded yet.
  ///
  /// The examples of what can be said are worth their space on an empty
  /// visit and are in the way on a visit that is half done.
  bool get isEmpty => valueCount == 0 && photoCount == 0;
}
