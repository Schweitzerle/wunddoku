import '../catalog/exudation.dart';
import '../catalog/tissue_distribution.dart';

/// How sure the interpreter is about a proposed value.
///
/// The tiers drive the confirmation view (see `docs/ux/flows.md`, flow 2):
/// [high] is taken over silently, [medium] is marked for a second look, and
/// [low] blocks saving until the nurse decides. "Not said" is not a tier —
/// it is the *absence* of a proposal, and the caller renders it as a gap.
enum ConfidenceTier { high, medium, low }

/// Where in the verbatim transcript a proposal comes from.
///
/// Character offsets into the transcript string, end exclusive. The span is
/// the provenance the nurse can call up for any value (JS-4): tapping a field
/// highlights exactly these characters.
class TranscriptSpan {
  const TranscriptSpan(this.start, this.end)
    : assert(start >= 0 && end >= start);

  final int start;
  final int end;

  /// The spanned text within [transcript].
  String textIn(String transcript) => transcript.substring(start, end);

  @override
  bool operator ==(Object other) =>
      other is TranscriptSpan && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'TranscriptSpan($start..$end)';
}

/// A single value the interpreter proposes for one field of the record.
///
/// Proposals are typed — a measurement carries centimetres, a tissue share
/// carries its [TissueType] — so the confirmation view cannot mix fields up
/// and nothing downstream parses strings again.
sealed class FieldProposal {
  const FieldProposal({required this.confidence, required this.span});

  /// How sure the interpreter is; see [ConfidenceTier].
  final ConfidenceTier confidence;

  /// Where in the transcript the value was heard.
  final TranscriptSpan span;

  /// Stable identifier of the record field this proposal fills.
  ///
  /// Two proposals with the same id are two attempts at the same field — the
  /// later one replaces the earlier, which is what makes re-dictating a single
  /// field work.
  String get slotId;
}

/// Which of the three wound measurements a [MeasurementProposal] fills.
enum MeasurementAxis { lengthCm, widthCm, depthCm }

/// A wound measurement in centimetres.
class MeasurementProposal extends FieldProposal {
  const MeasurementProposal({
    required this.axis,
    required this.centimetres,
    required super.confidence,
    required super.span,
  });

  final MeasurementAxis axis;
  final double centimetres;

  @override
  String get slotId => 'measurement.${axis.name}';
}

/// A tissue share of the wound bed in percent.
///
/// The 100 % invariant is *not* checked here — single utterances arrive one
/// by one. It is enforced by [TissueDistribution] when the confirmed shares
/// are assembled into the record.
class TissueShareProposal extends FieldProposal {
  const TissueShareProposal({
    required this.tissue,
    required this.percent,
    required super.confidence,
    required super.span,
  });

  final TissueType tissue;
  final int percent;

  @override
  String get slotId => 'tissue.${tissue.name}';
}

/// The estimated exudate amount.
class ExudateAmountProposal extends FieldProposal {
  const ExudateAmountProposal({
    required this.amount,
    required super.confidence,
    required super.span,
  });

  final ExudateAmount amount;

  @override
  String get slotId => 'exudate.amount';
}

/// One observed exudate kind.
///
/// Emitted per kind rather than as a set so each keeps its own provenance in
/// the transcript.
class ExudateKindProposal extends FieldProposal {
  const ExudateKindProposal({
    required this.kind,
    required super.confidence,
    required super.span,
  });

  final ExudateKind kind;

  @override
  String get slotId => 'exudate.kind.${kind.name}';
}

/// The pain intensity on the 0-10 scale.
class PainScoreProposal extends FieldProposal {
  const PainScoreProposal({
    required this.score,
    required super.confidence,
    required super.span,
  });

  /// The spoken value. Out-of-range values are still carried (with
  /// [ConfidenceTier.low]) so the confirmation view can show what was heard
  /// instead of a silent nothing.
  final int score;

  @override
  String get slotId => 'pain.score';
}

/// Everything one spoken recording yielded.
class CaptureResult {
  const CaptureResult({required this.transcript, required this.proposals});

  /// The verbatim transcript. Stored with the visit as evidence; never
  /// paraphrased.
  final String transcript;

  final List<FieldProposal> proposals;
}
