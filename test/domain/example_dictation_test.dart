import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/data/capture/example_dictations.dart';
import 'package:wunddoku/domain/capture/field_proposal.dart';
import 'package:wunddoku/domain/capture/transcript_interpreter.dart';

/// The interpreter against what a real recogniser returns.
///
/// Every other interpreter test is written in the words a nurse speaks. These
/// are the strings a service actually hands over, which is a different thing
/// — see `lib/data/capture/example_dictations.dart`.
void main() {
  const interpreter = TranscriptInterpreter();

  CaptureResult interpret(String name) =>
      interpreter.interpret(exampleTranscripts[name]!);

  double? measurement(CaptureResult result, MeasurementAxis axis) {
    for (final proposal in result.proposals) {
      if (proposal is MeasurementProposal && proposal.axis == axis) {
        return proposal.centimetres;
      }
    }
    return null;
  }

  T? proposalOf<T extends FieldProposal>(CaptureResult result) {
    for (final proposal in result.proposals) {
      if (proposal is T) return proposal;
    }
    return null;
  }

  test('digits are numbers too', () {
    final result = interpret('befund_01.m4a');

    // The recogniser normalises spoken numbers to digits. A grammar that only
    // knows "vier Komma zwei" understands nothing of a real transcript.
    expect(measurement(result, MeasurementAxis.lengthCm), 4.2);
    expect(measurement(result, MeasurementAxis.widthCm), 2.8);
    expect(measurement(result, MeasurementAxis.depthCm), 0.5);
  });

  test('the percent sign counts as spoken "Prozent"', () {
    final result = interpret('befund_01.m4a');
    final shares = result.proposals.whereType<TissueShareProposal>().toList();

    expect(shares, hasLength(2));
    expect(shares.first.percent, 60);
    expect(shares.last.percent, 40);
  });

  test('a misheard technical word still lands in its field', () {
    final result = interpret('befund_01.m4a');

    // "Exsudat" comes back as "Excusat" and "serös" as "seriös": the
    // customer's vocabulary is foreign to a general model, and the finding
    // may not fall out of the record because of it.
    expect(proposalOf<ExudateAmountProposal>(result), isNotNull);
    expect(proposalOf<ExudateKindProposal>(result), isNotNull);
  });

  test('a correction beats the number it corrects', () {
    final result = interpret('befund_02.m4a');

    // "Länge 3, äh nein, 4,1" — taking the first number would put a wrong
    // measurement in the record, which is worse than taking none.
    expect(measurement(result, MeasurementAxis.lengthCm), 4.1);
    expect(measurement(result, MeasurementAxis.widthCm), 2);
  });

  test('the implausible depth is proposed but flagged', () {
    final result = interpret('befund_03.m4a');
    final depth = result.proposals
        .whereType<MeasurementProposal>()
        .firstWhere((p) => p.axis == MeasurementAxis.depthCm);

    expect(depth.centimetres, 50);
    expect(depth.confidence, ConfidenceTier.low);
  });

  test('a fragment yields what was said and nothing more', () {
    final result = interpret('befund_04.m4a');

    expect(measurement(result, MeasurementAxis.lengthCm), 2.5);
    expect(measurement(result, MeasurementAxis.widthCm), 1.2);
    expect(measurement(result, MeasurementAxis.depthCm), isNull);
    expect(proposalOf<PainScoreProposal>(result), isNull);
  });

  test('every example carries its transcript verbatim', () {
    for (final name in exampleDictations) {
      final transcript = exampleTranscripts[name];
      expect(transcript, isNotNull, reason: '$name has no transcript');
      expect(interpreter.interpret(transcript!).transcript, transcript);
    }
  });
}
