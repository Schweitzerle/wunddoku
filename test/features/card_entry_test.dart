import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/catalog/exudation.dart';
import 'package:wunddoku/domain/catalog/tissue_distribution.dart';
import 'package:wunddoku/domain/model/visit_draft.dart';
import 'package:wunddoku/features/besuch/ui/card_entry_screen.dart';
import 'package:wunddoku/features/besuch/ui/card_entry_view_model.dart';

import '../support/test_app.dart';

void main() {
  late CardEntryViewModel viewModel;

  setUp(() {
    viewModel = CardEntryViewModel();
    addTearDown(viewModel.dispose);
  });

  group('tissue shares', () {
    test('start empty and count down from a whole', () {
      expect(viewModel.tissueRemainder, 100);
      expect(viewModel.tissueShare(TissueType.granulation), 0);
    });

    test('stepping assigns in fives and lowers the remainder', () {
      viewModel
        ..adjustTissue(TissueType.granulation, 5)
        ..adjustTissue(TissueType.granulation, 5);

      expect(viewModel.tissueShare(TissueType.granulation), 10);
      expect(viewModel.tissueRemainder, 90);
    });

    test('a share back at zero becomes a gap again, not a zero value', () {
      viewModel
        ..adjustTissue(TissueType.fibrin, 5)
        ..adjustTissue(TissueType.fibrin, -5);

      expect(viewModel.draft.has('tissue.fibrin'), isFalse);
      expect(viewModel.tissueRemainder, 100);
    });

    test('over-assigning is allowed while redistributing', () {
      for (var i = 0; i < 21; i++) {
        viewModel.adjustTissue(TissueType.granulation, 5);
      }
      viewModel.adjustTissue(TissueType.fibrin, 5);

      // 100 + 5: the nurse has to be able to raise one before clearing
      // another, so the remainder goes negative instead of the step failing.
      expect(viewModel.tissueRemainder, -5);
      expect(viewModel.draft.tissueDistribution, isNull);
    });

    test('a distribution is a finding only once it adds up to 100', () {
      for (var i = 0; i < 12; i++) {
        viewModel.adjustTissue(TissueType.granulation, 5);
      }
      expect(viewModel.draft.tissueDistribution, isNull);

      for (var i = 0; i < 8; i++) {
        viewModel.adjustTissue(TissueType.fibrin, 5);
      }

      final distribution = viewModel.draft.tissueDistribution;
      expect(distribution, isNotNull);
      expect(distribution![TissueType.granulation], 60);
      expect(distribution[TissueType.fibrin], 40);
    });
  });

  group('measurements', () {
    test('step in half centimetres and start as a gap', () {
      expect(viewModel.measurement('measurement.lengthCm'), isNull);

      viewModel.adjustMeasurement('measurement.lengthCm', 0.5);
      viewModel.adjustMeasurement('measurement.lengthCm', 0.5);

      expect(viewModel.measurement('measurement.lengthCm'), 1.0);
    });

    test('stepping back to zero clears the field', () {
      viewModel.adjustMeasurement('measurement.depthCm', 0.5);
      viewModel.adjustMeasurement('measurement.depthCm', -0.5);

      // Zero centimetres is not a finding, it is an unmade measurement.
      expect(viewModel.draft.has('measurement.depthCm'), isFalse);
    });

    test('never goes below zero', () {
      viewModel.adjustMeasurement('measurement.widthCm', -0.5);
      expect(viewModel.draft.has('measurement.widthCm'), isFalse);
    });
  });

  group('exudation', () {
    test('choosing an amount twice clears it', () {
      viewModel.toggleExudateAmount(ExudateAmount.moderate);
      expect(viewModel.exudateAmount, ExudateAmount.moderate);

      viewModel.toggleExudateAmount(ExudateAmount.moderate);
      expect(viewModel.exudateAmount, isNull);
    });

    test('no exudate clears any kind and refuses new ones', () {
      viewModel
        ..toggleExudateAmount(ExudateAmount.slight)
        ..toggleExudateKind(ExudateKind.serous);
      expect(viewModel.hasExudateKind(ExudateKind.serous), isTrue);

      viewModel.toggleExudateAmount(ExudateAmount.none);
      expect(viewModel.hasExudateKind(ExudateKind.serous), isFalse);

      viewModel.toggleExudateKind(ExudateKind.bloody);
      expect(viewModel.hasExudateKind(ExudateKind.bloody), isFalse);
    });

    test('several kinds can be observed at once', () {
      viewModel
        ..toggleExudateAmount(ExudateAmount.heavy)
        ..toggleExudateKind(ExudateKind.serous)
        ..toggleExudateKind(ExudateKind.bloody);

      expect(viewModel.hasExudateKind(ExudateKind.serous), isTrue);
      expect(viewModel.hasExudateKind(ExudateKind.bloody), isTrue);
    });
  });

  group('the screen', () {
    testWidgets('shows the remainder rather than an error', (tester) async {
      await tester.pumpWidget(
        TestApp(child: CardEntryScreen(viewModel: viewModel)),
      );

      expect(find.text('100 % nicht vergeben'), findsOneWidget);

      // Two taps on the granulation plus.
      await tester.tap(find.byTooltip('Granulation erhöhen'));
      await tester.pump();
      await tester.tap(find.byTooltip('Granulation erhöhen'));
      await tester.pump();

      expect(find.text('90 % nicht vergeben'), findsOneWidget);
      expect(find.text('10 %'), findsOneWidget);
    });

    testWidgets('reports completion once the shares add up', (tester) async {
      for (var i = 0; i < 20; i++) {
        viewModel.adjustTissue(TissueType.granulation, 5);
      }
      await tester.pumpWidget(
        TestApp(child: CardEntryScreen(viewModel: viewModel)),
      );

      expect(find.text('Vollständig verteilt'), findsOneWidget);
    });

    testWidgets('names the overshoot instead of blocking the step', (
      tester,
    ) async {
      // A single share is clamped at 100, so the overshoot needs a second one.
      for (var i = 0; i < 21; i++) {
        viewModel.adjustTissue(TissueType.granulation, 5);
      }
      viewModel.adjustTissue(TissueType.fibrin, 5);

      await tester.pumpWidget(
        TestApp(child: CardEntryScreen(viewModel: viewModel)),
      );

      expect(find.text('5 % zu viel vergeben'), findsOneWidget);
    });

    testWidgets('an unentered measurement reads as a gap, not as zero', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(child: CardEntryScreen(viewModel: viewModel)),
      );

      expect(find.text('0 cm'), findsNothing);
      expect(find.text('—'), findsWidgets);
    });

    testWidgets('finishing hands back what was entered', (tester) async {
      VisitDraft? handed;
      await tester.pumpWidget(
        TestApp(
          child: CardEntryScreen(
            viewModel: viewModel,
            onDone: (draft) => handed = draft,
          ),
        ),
      );

      await tester.tap(find.byTooltip('Fibrin erhöhen'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Fertig'));

      expect(handed, isNotNull);
      expect(handed!['tissue.fibrin'], const PercentValue(5));
    });

    testWidgets('meets the four guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(child: CardEntryScreen(viewModel: viewModel)),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('survives 200 percent text scaling', (tester) async {
      await tester.pumpWidget(
        TestApp(textScale: 2, child: CardEntryScreen(viewModel: viewModel)),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('goldens', () {
    testWidgets('empty', (tester) async {
      await tester.pumpWidget(
        TestApp(child: CardEntryScreen(viewModel: viewModel)),
      );
      await tester.pump();
      await expectLater(
        find.byType(CardEntryScreen),
        matchesGoldenFile('goldens/cards_empty.png'),
      );
    });

    testWidgets('part way through', (tester) async {
      for (var i = 0; i < 12; i++) {
        viewModel.adjustTissue(TissueType.granulation, 5);
      }
      viewModel
        ..adjustMeasurement('measurement.lengthCm', 3.5)
        ..toggleExudateAmount(ExudateAmount.slight)
        ..toggleExudateKind(ExudateKind.serous);

      await tester.pumpWidget(
        TestApp(child: CardEntryScreen(viewModel: viewModel)),
      );
      await tester.pump();
      await expectLater(
        find.byType(CardEntryScreen),
        matchesGoldenFile('goldens/cards_partial.png'),
      );
    });
  });
}
