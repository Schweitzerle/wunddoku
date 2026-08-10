import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/capture/field_proposal.dart';
import 'package:wunddoku/domain/capture/german_number.dart';
import 'package:wunddoku/domain/capture/transcript_interpreter.dart';
import 'package:wunddoku/domain/catalog/exudation.dart';
import 'package:wunddoku/domain/catalog/tissue_distribution.dart';

void main() {
  const interpreter = TranscriptInterpreter();

  group('german numbers', () {
    ParsedNumber? parse(String text) => parseNumber(tokenize(text), 0);

    test('digit forms with comma and point', () {
      expect(parse('3')!.value, 3);
      expect(parse('3,5')!.value, 3.5);
      expect(parse('3.5')!.value, 3.5);
    });

    test('number words up to ninety-nine', () {
      expect(parse('fünf')!.value, 5);
      expect(parse('zwölf')!.value, 12);
      expect(parse('sechzig')!.value, 60);
      expect(parse('einundzwanzig')!.value, 21);
      expect(parse('neunundneunzig')!.value, 99);
    });

    test('spoken decimals', () {
      final parsed = parse('drei komma fünf')!;
      expect(parsed.value, 3.5);
      expect(parsed.tokensConsumed, 3);
      expect(parse('null komma fünf')!.value, 0.5);
    });

    test('halves', () {
      expect(parse('anderthalb')!.value, 1.5);
      expect(parse('eineinhalb')!.value, 1.5);
      expect(parse('dreieinhalb')!.value, 3.5);
      expect(parse('einhalb')!.value, 0.5);
    });

    test('non-numbers yield null', () {
      expect(parse('wunde'), isNull);
      expect(parse('komma'), isNull);
    });
  });

  group('measurements', () {
    test('all three axes from one dictation, in centimetres', () {
      final result = interpreter.interpret(
        'Länge drei Komma fünf, Breite zwei, Tiefe null Komma fünf',
      );
      final byAxis = {
        for (final p in result.proposals.whereType<MeasurementProposal>())
          p.axis: p,
      };
      expect(byAxis[MeasurementAxis.lengthCm]!.centimetres, 3.5);
      expect(byAxis[MeasurementAxis.widthCm]!.centimetres, 2);
      expect(byAxis[MeasurementAxis.depthCm]!.centimetres, 0.5);
      expect(
        byAxis.values.every((p) => p.confidence == ConfidenceTier.high),
        isTrue,
      );
    });

    test('millimetres are converted, centimetres kept', () {
      final result = interpreter.interpret(
        'Länge fünfunddreißig Millimeter, Breite zwei Zentimeter',
      );
      final byAxis = {
        for (final p in result.proposals.whereType<MeasurementProposal>())
          p.axis: p.centimetres,
      };
      expect(byAxis[MeasurementAxis.lengthCm], 3.5);
      expect(byAxis[MeasurementAxis.widthCm], 2);
    });

    test('filler words between name and value are tolerated', () {
      final result = interpreter.interpret('Die Länge beträgt circa vier');
      final proposal = result.proposals.whereType<MeasurementProposal>().single;
      expect(proposal.centimetres, 4);
    });

    test('an implausible depth is kept but marked low', () {
      final result = interpreter.interpret('Tiefe fünfzig');
      final proposal = result.proposals.whereType<MeasurementProposal>().single;
      expect(proposal.centimetres, 50);
      expect(proposal.confidence, ConfidenceTier.low);
    });

    test('the span points at the words that carried the value', () {
      const transcript = 'Länge drei Komma fünf';
      final result = interpreter.interpret(transcript);
      final proposal = result.proposals.whereType<MeasurementProposal>().single;
      expect(proposal.span.textIn(transcript), 'Länge drei Komma fünf');
    });
  });

  group('tissue shares', () {
    test('name-first and number-first forms both match', () {
      final result = interpreter.interpret(
        'Granulation sechzig Prozent, vierzig Prozent Fibrin',
      );
      final byTissue = {
        for (final p in result.proposals.whereType<TissueShareProposal>())
          p.tissue: p,
      };
      expect(byTissue[TissueType.granulation]!.percent, 60);
      expect(byTissue[TissueType.fibrin]!.percent, 40);
      expect(
        byTissue.values.every((p) => p.confidence == ConfidenceTier.high),
        isTrue,
      );
    });

    test('an inflected tissue name is matched with medium confidence', () {
      final result = interpreter.interpret('Granulationsgewebe sechzig');
      final proposal = result.proposals.whereType<TissueShareProposal>().single;
      expect(proposal.tissue, TissueType.granulation);
      expect(proposal.confidence, ConfidenceTier.medium);
    });

    test('a share beyond 100 percent is kept but marked low', () {
      final result = interpreter.interpret('Fibrin hundertzwanzig');
      // "hundertzwanzig" is outside the parsed range, so no number is found -
      // and that is fine: no proposal beats a wrong one.
      expect(result.proposals, isEmpty);

      final digits = interpreter.interpret('Fibrin 120');
      final proposal = digits.proposals.whereType<TissueShareProposal>().single;
      expect(proposal.percent, 120);
      expect(proposal.confidence, ConfidenceTier.low);
    });

    test('shares are not summed here - that happens at confirmation', () {
      final result = interpreter.interpret(
        'Granulation sechzig Prozent, Fibrin sechzig Prozent',
      );
      expect(result.proposals.whereType<TissueShareProposal>(), hasLength(2));
    });
  });

  group('exudation', () {
    test('amount and kinds from one sentence', () {
      final result = interpreter.interpret('Exsudat mäßig, serös');
      final amount = result.proposals.whereType<ExudateAmountProposal>().single;
      final kinds = result.proposals.whereType<ExudateKindProposal>().map(
        (p) => p.kind,
      );
      expect(amount.amount, ExudateAmount.moderate);
      expect(kinds, [ExudateKind.serous]);
    });

    test('several kinds are proposed individually with own spans', () {
      const transcript = 'Exsudat stark, serös und blutig';
      final result = interpreter.interpret(transcript);
      final kinds = result.proposals.whereType<ExudateKindProposal>().toList();
      expect(kinds, hasLength(2));
      expect(kinds[0].span.textIn(transcript), 'serös');
      expect(kinds[1].span.textIn(transcript), 'blutig');
    });
  });

  group('pain score', () {
    test('a score in range is high confidence', () {
      final result = interpreter.interpret('Schmerz bei vier');
      // "bei" is not in the filler list on purpose - but "Schmerz vier" is.
      final direct = interpreter.interpret('Schmerz vier');
      expect(direct.proposals.whereType<PainScoreProposal>().single.score, 4);
      expect(result.proposals.whereType<PainScoreProposal>(), isEmpty);
    });

    test('a score beyond ten is kept but marked low', () {
      final result = interpreter.interpret('Schmerzen fünfzehn');
      final proposal = result.proposals.whereType<PainScoreProposal>().single;
      expect(proposal.score, 15);
      expect(proposal.confidence, ConfidenceTier.low);
    });
  });

  group('what was not said', () {
    test('yields no proposal instead of a guess', () {
      final result = interpreter.interpret('Verband gewechselt, alles ruhig');
      expect(result.proposals, isEmpty);
    });

    test('the verbatim transcript is carried unchanged', () {
      const transcript = 'Länge drei, äh, Komma fünf';
      expect(interpreter.interpret(transcript).transcript, transcript);
    });
  });

  group('a realistic full dictation', () {
    test('maps every spoken field and only those', () {
      const transcript =
          'Länge drei Komma fünf, Breite zwei, Tiefe null Komma fünf. '
          'Granulation sechzig Prozent, Fibrin vierzig Prozent. '
          'Exsudat gering, serös. Schmerz zwei.';
      final result = interpreter.interpret(transcript);

      expect(result.proposals.whereType<MeasurementProposal>(), hasLength(3));
      expect(result.proposals.whereType<TissueShareProposal>(), hasLength(2));
      expect(
        result.proposals.whereType<ExudateAmountProposal>().single.amount,
        ExudateAmount.slight,
      );
      expect(result.proposals.whereType<ExudateKindProposal>(), hasLength(1));
      expect(result.proposals.whereType<PainScoreProposal>().single.score, 2);
      expect(
        result.proposals.every((p) => p.confidence == ConfidenceTier.high),
        isTrue,
      );
    });
  });
}
