import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/capture/field_proposal.dart';
import 'package:wunddoku/domain/capture/transcript_interpreter.dart';

/// What different recogniser sizes leave of a finding.
///
/// The strings below are verbatim output of Whisper `tiny`, `base`, `small`,
/// `medium` and `large-v3` (German, int8, CPU) on the four bundled example
/// recordings — measured on 2026-08-12, see `DECISIONS.md`. They are here so
/// the choice of model rests on what reaches the record rather than on how
/// the text reads.
///
/// The question these tests answer is not "is the transcript nice" but "does
/// the measurement survive": a lost value shows up as a gap, a wrong one does
/// not show up at all.
void main() {
  const interpreter = TranscriptInterpreter();

  const outputs = <String, Map<String, String>>{
    'tiny': {
      'befund_01':
          'Länge 4,2 breite 2,8, tief in 0,5, Granulation 60% fibrin 40% '
          'exkussat gering Servus, Schmerzstrahe',
      'befund_02': 'Länge 3, 9, 4, 1, 2, excursat, mäßig, 0s.',
      'befund_03':
          'Länge da kommen wir fünf, breitet zwei, die für fünfzig, keine '
          'Relationsgewieb ist 60%.',
    },
    'base': {
      'befund_01':
          'Länge 4,2, 2,8, tiefe 0,5, granulation 60%, vibrier 40%, '
          'exkussart gering, seriös, schmerz 3.',
      'befund_02': 'Länge 3, 9, 4,1, breite 2, exkussart mäßig, serös.',
      'befund_03': 'Länge diei.5, breite 2,5, karrelationsgewebe ist 60%.',
    },
    'small': {
      'befund_01':
          'Länge 4,2, Breite 2,8, Tiefe 0,5, Granulation 60%, Fibrin 40%, '
          'Exkusat gering, seriös, Schmerz 3.',
      'befund_02': 'Länge 3, 9, 4,1, Breite 2, exklusiv mäßig, sehr rös.',
      'befund_03': 'Länge 3,5, Breite 2, Tiefe 50, Karolationsgewiebe 60%.',
    },
    'medium': {
      'befund_01':
          'Länge 4,2 Breite 2,8 Tiefe 0,5 Granulation 60% Fibrin 40% '
          'Exkursat gering Seriös Schmerz 3',
      'befund_02': 'Länge 3, nein 4,1, Breite 2, Exkursat mäßig serös.',
      'befund_03': 'Länge 3,5, Breite 2, Tiefe 50, Granulationsgewebe 60%',
    },
    'large-v3': {
      'befund_01':
          'Länge 4,2, Breite 2,8, Tiefe 0,5, Granulation 60%, Fibrin 40%, '
          'Excusat gering, seriös, Schmerz 3.',
      'befund_02': 'Länge 3, äh nein, 4,1, Breite 2, Excusat mäßig, seriös.',
      'befund_03': 'Länge 3,5, Breite 2, Tiefe 50, Granulationsgewebe 60%.',
    },
  };

  /// The measurements the interpreter pulls out, by axis.
  Map<MeasurementAxis, double> measurements(String transcript) => {
    for (final proposal
        in interpreter.interpret(transcript).proposals.whereType<
          MeasurementProposal
        >())
      proposal.axis: proposal.centimetres,
  };

  group('a wrong measurement is worse than a missing one', () {
    test('tiny and base put numbers in the record that were never spoken', () {
      // base heard "breite 2,5" where 2 was said, and lost the depth
      // entirely. A gap is visible; 2,5 cm is not.
      final base = measurements(outputs['base']!['befund_03']!);
      expect(base[MeasurementAxis.widthCm], 2.5);
      expect(base[MeasurementAxis.depthCm], isNull);

      // tiny does not even leave a number to be wrong about.
      final tiny = measurements(outputs['tiny']!['befund_03']!);
      expect(tiny[MeasurementAxis.lengthCm], isNot(3.5));
    });

    test('from small upwards the measurements survive intact', () {
      for (final size in ['small', 'medium', 'large-v3']) {
        final values = measurements(outputs[size]!['befund_03']!);
        expect(values[MeasurementAxis.lengthCm], 3.5, reason: size);
        expect(values[MeasurementAxis.widthCm], 2, reason: size);
        expect(values[MeasurementAxis.depthCm], 50, reason: size);
      }
    });
  });

  group('the spoken correction', () {
    test('only medium and above transcribe the retraction at all', () {
      // "äh nein" / "nein" is what tells the interpreter the first number was
      // taken back. Without it there is nothing to work with, and the wrong
      // measurement is the one that looks confident.
      for (final size in ['medium', 'large-v3']) {
        final values = measurements(outputs[size]!['befund_02']!);
        expect(values[MeasurementAxis.lengthCm], 4.1, reason: size);
      }

      for (final size in ['tiny', 'base', 'small']) {
        final values = measurements(outputs[size]!['befund_02']!);
        expect(values[MeasurementAxis.lengthCm], isNot(4.1), reason: size);
      }
    });
  });

  group('the customer vocabulary', () {
    bool hasExudate(String transcript) => interpreter
        .interpret(transcript)
        .proposals
        .whereType<ExudateAmountProposal>()
        .isNotEmpty;

    test('is where every size struggles, in different ways', () {
      // large-v3 "Excusat" and small "Exkusat" are within the edit distance
      // the interpreter tolerates; medium's "Exkursat" is not. Widening the
      // tolerance far enough to catch it would start matching other words —
      // the answer is the customer's own word list, which is an open question
      // in PROGRESS.md, not a looser guess.
      expect(hasExudate(outputs['large-v3']!['befund_01']!), isTrue);
      expect(hasExudate(outputs['small']!['befund_01']!), isTrue);
      expect(hasExudate(outputs['medium']!['befund_01']!), isFalse);
    });
  });
}
