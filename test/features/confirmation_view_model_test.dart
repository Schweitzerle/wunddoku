import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/capture/field_proposal.dart';
import 'package:wunddoku/domain/capture/transcript_interpreter.dart';
import 'package:wunddoku/features/besuch/ui/confirmation_view_model.dart';
import 'package:wunddoku/shared/text/field_presentation.dart';

void main() {
  const interpreter = TranscriptInterpreter();

  ConfirmationViewModel modelFor(String transcript) => ConfirmationViewModel(
    expectedSlots: FieldPresentation.woundBedSlots,
    result: interpreter.interpret(transcript),
  );

  ConfirmationEntry entryFor(ConfirmationViewModel model, String slotId) =>
      model.entries.firstWhere((e) => e.slotId == slotId);

  group('building the rows', () {
    test('every expected slot gets a row, spoken or not', () {
      final model = modelFor('Länge drei');
      expect(model.entries, hasLength(FieldPresentation.woundBedSlots.length));
    });

    test('an unspoken field is a gap, not an absent row', () {
      final model = modelFor('Länge drei');
      final width = entryFor(model, 'measurement.widthCm');
      expect(width.proposal, isNull);
      expect(width.isGap, isTrue);
      expect(width.blocksSaving, isFalse);
    });

    test('a proposal outside the expected slots is kept, not dropped', () {
      final model = ConfirmationViewModel(
        expectedSlots: const ['measurement.lengthCm'],
        result: interpreter.interpret('Länge drei, Exsudat gering, serös'),
      );
      expect(
        model.entries.map((e) => e.slotId),
        containsAll(<String>['exudate.amount', 'exudate.kind.serous']),
      );
    });

    test('a later utterance about the same field replaces the earlier', () {
      final model = ConfirmationViewModel(
        expectedSlots: const ['measurement.lengthCm'],
        result: interpreter.interpret('Länge drei. Länge vier.'),
      );
      final entry = entryFor(model, 'measurement.lengthCm');
      expect((entry.proposal! as MeasurementProposal).centimetres, 4);
    });

    test('without a recording there is nothing to confirm', () {
      final model = ConfirmationViewModel(
        expectedSlots: FieldPresentation.woundBedSlots,
      );
      expect(model.hasRecording, isFalse);
      expect(model.transcript, isEmpty);
    });
  });

  group('gap versus riddle', () {
    test('gaps do not block saving', () {
      final model = modelFor('Länge drei');
      expect(model.gapCount, greaterThan(0));
      expect(model.canAccept, isTrue);
    });

    test('an undecided low-confidence value blocks saving', () {
      final model = modelFor('Tiefe fünfzig');
      final depth = entryFor(model, 'measurement.depthCm');
      expect(depth.blocksSaving, isTrue);
      expect(model.blockingCount, 1);
      expect(model.canAccept, isFalse);
    });

    test('accepting the blocking value unblocks saving', () {
      final model = modelFor('Tiefe fünfzig');
      model.accept('measurement.depthCm');
      expect(model.canAccept, isTrue);
      expect(entryFor(model, 'measurement.depthCm').isSettled, isTrue);
    });

    test('discarding the blocking value turns it into a gap', () {
      final model = modelFor('Tiefe fünfzig');
      model.discard('measurement.depthCm');
      expect(model.canAccept, isTrue);
      final depth = entryFor(model, 'measurement.depthCm');
      expect(depth.isGap, isTrue);
      expect(depth.isSettled, isFalse);
    });

    test('a medium-confidence value asks for a look but does not block', () {
      final model = ConfirmationViewModel(
        expectedSlots: FieldPresentation.tissueSlots,
        result: interpreter.interpret('Granulationsgewebe sechzig'),
      );
      final granulation = entryFor(model, 'tissue.granulation');
      expect(granulation.proposal!.confidence, ConfidenceTier.medium);
      expect(granulation.needsAttention, isTrue);
      expect(granulation.blocksSaving, isFalse);
      expect(model.canAccept, isTrue);
    });
  });

  group('ordering', () {
    test('what needs work comes first: blocking, attention, gap, settled', () {
      final model = modelFor(
        'Länge drei, Tiefe fünfzig, Granulationsgewebe sechzig',
      );
      final ranks = model.entries.map((e) => e.sortRank).toList();
      expect(ranks, orderedEquals(List.of(ranks)..sort()));
      expect(model.entries.first.slotId, 'measurement.depthCm');
    });

    test('a decided row moves out of the way', () {
      final model = modelFor('Länge drei, Tiefe fünfzig');
      expect(model.entries.first.slotId, 'measurement.depthCm');

      model.accept('measurement.depthCm');
      expect(model.entries.first.slotId, isNot('measurement.depthCm'));
    });

    test('rows of equal rank keep the declared order', () {
      final model = modelFor('');
      expect(
        model.entries.map((e) => e.slotId),
        FieldPresentation.woundBedSlots,
      );
    });
  });

  group('the summary counts', () {
    test('add up over settled, attention and gap', () {
      final model = modelFor(
        'Länge drei Komma fünf, Breite zwei, Tiefe fünfzig, '
        'Granulationsgewebe sechzig',
      );
      expect(model.settledCount, 2);
      expect(model.attentionCount, 2);
      expect(
        model.settledCount + model.attentionCount + model.gapCount,
        model.entries.length,
      );
    });
  });

  group('notification', () {
    test('deciding notifies listeners once', () {
      final model = modelFor('Tiefe fünfzig');
      var notifications = 0;
      model.addListener(() => notifications++);

      model.accept('measurement.depthCm');
      expect(notifications, 1);
    });

    test('deciding the same way twice does not notify again', () {
      final model = modelFor('Tiefe fünfzig');
      model.accept('measurement.depthCm');

      var notifications = 0;
      model.addListener(() => notifications++);
      model.accept('measurement.depthCm');
      expect(notifications, 0);
    });

    test('deciding an empty field does nothing', () {
      final model = modelFor('Länge drei');
      var notifications = 0;
      model.addListener(() => notifications++);

      model.accept('measurement.widthCm');
      expect(notifications, 0);
      expect(entryFor(model, 'measurement.widthCm').isGap, isTrue);
    });
  });
}
