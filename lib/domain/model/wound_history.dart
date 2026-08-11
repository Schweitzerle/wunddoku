import 'ids.dart';
import 'visit_draft.dart';

/// One visit as it appears in the progress view.
///
/// Carries the values, not the pictures: the photo bytes are read from the
/// encrypted media store only for the thumbnails actually on screen.
class HistoryEntry {
  const HistoryEntry({
    required this.visit,
    required this.recordedAt,
    required this.draft,
    required this.closedWithGaps,
    required this.isOpen,
    this.photoRef,
    this.markedPhotoRef,
  });

  final VisitId visit;

  /// When the visit was closed, or started while it is still open.
  final DateTime recordedAt;

  final VisitDraft draft;

  /// Whether the visit was closed with named gaps.
  final bool closedWithGaps;

  /// Whether this is the visit currently being worked on.
  final bool isOpen;

  /// Handle of the untouched photo, if the visit has one.
  final String? photoRef;

  /// Handle of the copy with the outline burnt in.
  final String? markedPhotoRef;

  /// Length times width, in square centimetres, or null when either is missing.
  ///
  /// Deliberately the plain rectangle of the two largest diameters, the figure
  /// wound documentation schemes ask for — **not** an ellipse and not the area
  /// enclosed by the outline. It is an approximation, it is labelled as one on
  /// screen, and it stays comparable between visits precisely because it is
  /// always computed the same crude way.
  double? get areaCm2 {
    final length = draft['measurement.lengthCm'];
    final width = draft['measurement.widthCm'];
    if (length is! CentimetreValue || width is! CentimetreValue) return null;
    return length.centimetres * width.centimetres;
  }

  /// The recorded depth in centimetres, or null.
  double? get depthCm {
    final depth = draft['measurement.depthCm'];
    return depth is CentimetreValue ? depth.centimetres : null;
  }
}

/// The visits of one wound, oldest first.
///
/// Oldest first because that is the direction a course runs; the view may
/// still show the newest at the top.
class WoundHistory {
  const WoundHistory(this.entries);

  final List<HistoryEntry> entries;

  bool get isEmpty => entries.isEmpty;

  /// Whether there is anything to compare at all.
  ///
  /// One visit is a record, two are a course. The distinction matters on
  /// screen: with a single visit the app says so instead of drawing a chart
  /// out of one point.
  bool get isComparable => entries.length >= 2;

  /// The area series, with a null wherever the visit has no measurements.
  ///
  /// Gaps stay gaps: an interpolated point would look like a measurement
  /// nobody took, and the whole record exists to be trusted.
  List<double?> get areaSeries => [for (final entry in entries) entry.areaCm2];

  /// The depth series, with the same rule about gaps.
  List<double?> get depthSeries => [for (final entry in entries) entry.depthCm];

  /// The change in area from [entry] to the visit before it.
  ///
  /// Null when either side has no area — the neighbouring visit is skipped
  /// rather than reached past, because "smaller than three weeks ago" is a
  /// different statement from "smaller than last week".
  double? areaChangeBefore(HistoryEntry entry) {
    final index = entries.indexOf(entry);
    if (index <= 0) return null;
    final current = entry.areaCm2;
    final previous = entries[index - 1].areaCm2;
    if (current == null || previous == null) return null;
    return current - previous;
  }
}
