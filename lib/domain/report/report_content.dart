import '../model/visit_draft.dart';
import '../model/wound_history.dart';

/// Why two photos of the same wound may not be worth comparing.
enum ComparabilityNote {
  /// Nothing speaks against comparing.
  none,

  /// No photo at all for this visit.
  missingPhoto,

  /// Photo taken without the previous one as a framing aid.
  ///
  /// The first photo of a wound has nothing to line up against, so the
  /// distance is whatever it happened to be. Saying so is cheaper than a
  /// reader assuming the wound grew.
  noFramingAid,
}

/// One visit as it appears in the report.
class ReportVisit {
  const ReportVisit({
    required this.recordedAt,
    required this.draft,
    required this.areaCm2,
    required this.depthCm,
    required this.gapSlots,
    required this.closedWithGaps,
    required this.photoRef,
    required this.comparability,
  });

  final DateTime recordedAt;
  final VisitDraft draft;
  final double? areaCm2;
  final double? depthCm;

  /// The expected fields this visit does not carry, in reading order.
  ///
  /// Printed as gaps. A report that smooths over what is missing is more
  /// dangerous than one that shows it — see `docs/ux/nachprozess.md`.
  final List<String> gapSlots;

  final bool closedWithGaps;

  /// Handle of the photo to print; the marked copy where there is one.
  final String? photoRef;

  final ComparabilityNote comparability;
}

/// Everything a wound report says, without a word of prose.
///
/// Pure data on purpose. The report must not be a second formulation of the
/// finding — that is precisely the duplicated work the app removes — so the
/// text is assembled from these values at render time and never entered
/// twice.
class ReportContent {
  const ReportContent({
    required this.patientName,
    required this.birthDate,
    required this.woundLocation,
    required this.icd10Code,
    required this.visits,
    required this.createdAt,
  });

  /// Builds the content from a wound's course.
  ///
  /// [expectedSlots] decides what counts as a gap; it is the same list the
  /// closing screen uses, so the report and the app agree on completeness.
  factory ReportContent.fromHistory({
    required WoundHistory history,
    required List<String> expectedSlots,
    required String patientName,
    required DateTime birthDate,
    required String woundLocation,
    required String? icd10Code,
    required DateTime createdAt,
    DateTime? from,
    DateTime? to,
  }) {
    final entries = [
      for (final entry in history.entries)
        if ((from == null || !entry.recordedAt.isBefore(from)) &&
            (to == null || !entry.recordedAt.isAfter(to)))
          entry,
    ];

    return ReportContent(
      patientName: patientName,
      birthDate: birthDate,
      woundLocation: woundLocation,
      icd10Code: icd10Code,
      createdAt: createdAt,
      visits: [
        for (var i = 0; i < entries.length; i++)
          _visitOf(entries[i], i == 0, expectedSlots),
      ],
    );
  }

  static ReportVisit _visitOf(
    HistoryEntry entry,
    bool isFirst,
    List<String> expectedSlots,
  ) {
    final photo = entry.markedPhotoRef ?? entry.photoRef;
    return ReportVisit(
      recordedAt: entry.recordedAt,
      draft: entry.draft,
      areaCm2: entry.areaCm2,
      depthCm: entry.depthCm,
      gapSlots: entry.draft.gapsAmong(expectedSlots).toList(),
      closedWithGaps: entry.closedWithGaps,
      photoRef: photo,
      comparability: switch (photo) {
        null => ComparabilityNote.missingPhoto,
        _ when isFirst => ComparabilityNote.noFramingAid,
        _ => ComparabilityNote.none,
      },
    );
  }

  final String patientName;
  final DateTime birthDate;
  final String woundLocation;

  /// ICD-10-GM code of the underlying diagnosis, if one was assigned.
  final String? icd10Code;

  final List<ReportVisit> visits;

  /// When the report was produced — printed, because a wound report without a
  /// date is worthless a week later.
  final DateTime createdAt;

  bool get isEmpty => visits.isEmpty;

  /// Whether any visit in this report carries gaps.
  ///
  /// Drives the note on the first page: the reader has to learn that before
  /// reading the figures, not after.
  bool get hasGaps =>
      visits.any((visit) => visit.gapSlots.isNotEmpty || visit.closedWithGaps);

  /// The first and last date covered, or null when there is nothing.
  (DateTime, DateTime)? get period =>
      visits.isEmpty ? null : (visits.first.recordedAt, visits.last.recordedAt);
}
