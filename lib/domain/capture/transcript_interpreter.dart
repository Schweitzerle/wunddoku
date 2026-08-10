import '../catalog/exudation.dart';
import '../catalog/tissue_distribution.dart';
import 'field_proposal.dart';
import 'german_number.dart';

/// Maps a verbatim transcript onto typed field proposals.
///
/// This is the second stage of the two-stage capture path (`/eps:ki-architektur`)
/// and deliberately pure Dart: it runs identically on canned transcripts in
/// tests, on device transcription and behind a cloud recogniser, so the whole
/// confirmation UX can be built and measured without a Mistral key.
///
/// Three rules from `/eps:freihaendige-erfassung` govern every match:
///
/// * Recognised text is mapped onto the catalogue's closed vocabularies —
///   no match means low confidence or no proposal, never a free string.
/// * What was not said is not proposed. Absence is rendered as a gap by the
///   confirmation view.
/// * Out-of-range values are proposed with [ConfidenceTier.low] instead of
///   being dropped, so the nurse sees what was heard and decides.
class TranscriptInterpreter {
  const TranscriptInterpreter();

  /// Words that may sit between a field name and its value
  /// ("Länge *ist circa* drei Komma fünf").
  static const _fillers = {'ist', 'beträgt', 'circa', 'etwa', 'ca', 'von'};

  static const _measurementKeywords = {
    'länge': MeasurementAxis.lengthCm,
    'breite': MeasurementAxis.widthCm,
    'tiefe': MeasurementAxis.depthCm,
  };

  static const _tissueKeywords = {
    'nekrose': TissueType.necrosis,
    'fibrin': TissueType.fibrin,
    'granulation': TissueType.granulation,
    'epithelisation': TissueType.epithelialisation,
  };

  static const _amountWords = {
    'kein': ExudateAmount.none,
    'keins': ExudateAmount.none,
    'gering': ExudateAmount.slight,
    'mäßig': ExudateAmount.moderate,
    'mässig': ExudateAmount.moderate,
    'stark': ExudateAmount.heavy,
  };

  static const _kindWords = {
    'serös': ExudateKind.serous,
    'seröses': ExudateKind.serous,
    'eitrig': ExudateKind.purulent,
    'eitriges': ExudateKind.purulent,
    'blutig': ExudateKind.bloody,
    'blutiges': ExudateKind.bloody,
  };

  /// Interprets [transcript] and returns it together with every proposal
  /// found.
  CaptureResult interpret(String transcript) {
    final tokens = tokenize(transcript);
    final proposals = <FieldProposal>[
      ..._measurements(tokens),
      ..._tissueShares(tokens),
      ..._exudation(tokens),
      ..._painScore(tokens),
    ];
    return CaptureResult(transcript: transcript, proposals: proposals);
  }

  /// Index of the first non-filler token at or after [index], skipping at
  /// most two fillers.
  int _skipFillers(List<Token> tokens, int index) {
    var i = index;
    while (i < tokens.length &&
        i - index < 2 &&
        _fillers.contains(tokens[i].text)) {
      i++;
    }
    return i;
  }

  /// Converts a parsed value to centimetres based on a trailing unit token,
  /// returning the value and the index after the last consumed token.
  (double, int) _applyUnit(List<Token> tokens, double value, int nextIndex) {
    if (nextIndex < tokens.length) {
      final unit = tokens[nextIndex].text;
      if (unit == 'millimeter' || unit == 'mm') {
        return (value / 10, nextIndex + 1);
      }
      if (unit == 'zentimeter' || unit == 'cm') return (value, nextIndex + 1);
    }
    // No unit spoken: centimetres are the domain default (the measuring
    // rulers used in wound care are centimetre-scaled).
    return (value, nextIndex);
  }

  Iterable<MeasurementProposal> _measurements(List<Token> tokens) sync* {
    for (var i = 0; i < tokens.length; i++) {
      final axis = _measurementKeywords[tokens[i].text];
      if (axis == null) continue;

      final numberStart = _skipFillers(tokens, i + 1);
      final parsed = parseNumber(tokens, numberStart);
      if (parsed == null) continue;

      final afterNumber = numberStart + parsed.tokensConsumed;
      final (centimetres, end) = _applyUnit(tokens, parsed.value, afterNumber);

      // Plausibility bounds from the domain: a leg wound is not half a metre
      // long, and depth beyond 20 cm is a misheard number, not a finding.
      final limit = axis == MeasurementAxis.depthCm ? 20 : 50;
      final plausible = centimetres > 0 && centimetres <= limit;

      yield MeasurementProposal(
        axis: axis,
        centimetres: centimetres,
        confidence: plausible ? ConfidenceTier.high : ConfidenceTier.low,
        span: TranscriptSpan(tokens[i].start, tokens[end - 1].end),
      );
    }
  }

  /// The tissue type a token names, with the confidence of the name match.
  (TissueType, ConfidenceTier)? _tissueFor(String word) {
    final exact = _tissueKeywords[word];
    if (exact != null) return (exact, ConfidenceTier.high);
    // Tolerate inflected or compound forms ("Granulationsgewebe",
    // "epithelisiert") — same stem, but only medium confidence.
    for (final entry in _tissueKeywords.entries) {
      if (word.length >= 5 &&
          (word.startsWith(entry.key) || entry.key.startsWith(word))) {
        return (entry.value, ConfidenceTier.medium);
      }
    }
    return null;
  }

  Iterable<TissueShareProposal> _tissueShares(List<Token> tokens) sync* {
    for (var i = 0; i < tokens.length; i++) {
      final match = _tissueFor(tokens[i].text);
      if (match == null) continue;
      final (tissue, nameConfidence) = match;

      // Form A: "Granulation sechzig Prozent". Form B: "sechzig Prozent
      // Granulation" - the number sits before the name.
      var numberStart = _skipFillers(tokens, i + 1);
      var parsed = parseNumber(tokens, numberStart);
      var spanStart = tokens[i].start;
      int spanEndIndex;
      if (parsed != null) {
        spanEndIndex = numberStart + parsed.tokensConsumed - 1;
        if (spanEndIndex + 1 < tokens.length &&
            tokens[spanEndIndex + 1].text == 'prozent') {
          spanEndIndex++;
        }
      } else if (i >= 2 &&
          tokens[i - 1].text == 'prozent' &&
          (parsed = parseNumber(tokens, i - 2)) != null) {
        numberStart = i - 2;
        spanStart = tokens[i - 2].start;
        spanEndIndex = i;
      } else {
        continue;
      }

      final percent = parsed!.value;
      final isWholePercent =
          percent == percent.roundToDouble() && percent >= 0 && percent <= 100;

      yield TissueShareProposal(
        tissue: tissue,
        percent: percent.round(),
        confidence: isWholePercent ? nameConfidence : ConfidenceTier.low,
        span: TranscriptSpan(spanStart, tokens[spanEndIndex].end),
      );
    }
  }

  Iterable<FieldProposal> _exudation(List<Token> tokens) sync* {
    for (var i = 0; i < tokens.length; i++) {
      final word = tokens[i].text;

      if (word.startsWith('exsudat')) {
        for (var j = i + 1; j < tokens.length && j <= i + 3; j++) {
          final amount = _amountWords[tokens[j].text];
          if (amount != null) {
            yield ExudateAmountProposal(
              amount: amount,
              confidence: ConfidenceTier.high,
              span: TranscriptSpan(tokens[i].start, tokens[j].end),
            );
            break;
          }
        }
      }

      final kind = _kindWords[word];
      if (kind != null) {
        yield ExudateKindProposal(
          kind: kind,
          confidence: ConfidenceTier.high,
          span: TranscriptSpan(tokens[i].start, tokens[i].end),
        );
      }
    }
  }

  Iterable<PainScoreProposal> _painScore(List<Token> tokens) sync* {
    for (var i = 0; i < tokens.length; i++) {
      if (!tokens[i].text.startsWith('schmerz')) continue;

      final numberStart = _skipFillers(tokens, i + 1);
      final parsed = parseNumber(tokens, numberStart);
      if (parsed == null) continue;

      final value = parsed.value;
      final isValidScore =
          value == value.roundToDouble() && value >= 0 && value <= 10;

      yield PainScoreProposal(
        score: value.round(),
        confidence: isValidScore ? ConfidenceTier.high : ConfidenceTier.low,
        span: TranscriptSpan(
          tokens[i].start,
          tokens[numberStart + parsed.tokensConsumed - 1].end,
        ),
      );
      break;
    }
  }
}
