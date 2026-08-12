import 'visit_draft.dart';

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
    required this.isMarked,
  }) : valueCount = draft.values.length,
       gapCount = draft.gapsAmong(expectedSlots).length;

  const VisitStanding.empty()
    : valueCount = 0,
      gapCount = 0,
      photoCount = 0,
      isMarked = false;

  /// Fields the visit carries a value for, expected or not.
  final int valueCount;

  /// Expected fields that are still empty.
  final int gapCount;

  final int photoCount;

  /// Whether the most recent photo carries an outline.
  final bool isMarked;

  /// Whether nothing has been recorded yet.
  ///
  /// The examples of what can be said are worth their space on an empty
  /// visit and are in the way on a visit that is half done.
  bool get isEmpty => valueCount == 0 && photoCount == 0;
}
