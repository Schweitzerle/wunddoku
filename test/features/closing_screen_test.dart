import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/catalog/exudation.dart';
import 'package:wunddoku/domain/model/visit_draft.dart';
import 'package:wunddoku/features/besuch/ui/closing_screen.dart';
import 'package:wunddoku/features/besuch/ui/closing_view_model.dart';
import 'package:wunddoku/features/besuch/ui/field_presentation.dart';

import '../support/test_app.dart';

/// A draft with every expected field filled and the wound bed adding up.
VisitDraft _complete() => const VisitDraft(
  values: {
    'measurement.lengthCm': CentimetreValue(3.5),
    'measurement.widthCm': CentimetreValue(2),
    'measurement.depthCm': CentimetreValue(0.5),
    'tissue.necrosis': PercentValue(0),
    'tissue.fibrin': PercentValue(40),
    'tissue.granulation': PercentValue(60),
    'tissue.epithelialisation': PercentValue(0),
    'exudate.amount': ExudateAmountValue(ExudateAmount.slight),
    'pain.score': ScoreValue(3),
  },
);

ClosingSummary _summary({
  VisitDraft? draft,
  int photoCount = 1,
  int markedPhotoCount = 1,
}) => ClosingSummary(
  draft: draft ?? _complete(),
  expectedSlots: FieldPresentation.woundBedSlots,
  photoCount: photoCount,
  markedPhotoCount: markedPhotoCount,
);

void main() {
  group('the summary', () {
    test('a full draft closes without gaps', () {
      final summary = _summary();

      expect(summary.isComplete, isTrue);
      expect(summary.tissueAddsUp, isTrue);
      expect(summary.closesWithGaps, isFalse);
      expect(summary.recordedSlots, hasLength(9));
    });

    test('missing fields are named in reading order, not counted away', () {
      final summary = _summary(
        draft: _complete().without('measurement.depthCm').without('pain.score'),
      );

      expect(summary.gapSlots, ['measurement.depthCm', 'pain.score']);
      expect(summary.closesWithGaps, isTrue);
    });

    test('a wound bed that does not add up closes with gaps too', () {
      final summary = _summary(
        draft: _complete().withValue(
          'tissue.granulation',
          const PercentValue(45),
        ),
      );

      // Every field carries a value, but the shares say 85 percent of the
      // wound bed. That is a finding to name, not one to round away.
      expect(summary.isComplete, isTrue);
      expect(summary.tissueAddsUp, isFalse);
      expect(summary.tissueRemainder, 15);
      expect(summary.closesWithGaps, isTrue);
    });

    test('a visit with nothing entered is not told its shares are zero', () {
      final summary = _summary(draft: const VisitDraft());

      // Every tissue field is already in the gap list. Repeating it as a
      // percentage finding would be noise on the screen that matters most.
      expect(summary.gapSlots, hasLength(9));
      expect(summary.tissueAddsUp, isTrue);
      expect(summary.closesWithGaps, isTrue);
    });
  });

  group('the screen', () {
    testWidgets('a complete visit closes as complete', (tester) async {
      bool? withGaps;
      await tester.pumpWidget(
        TestApp(
          child: ClosingScreen(
            summary: _summary(),
            onFinish: (value) => withGaps = value,
          ),
        ),
      );

      expect(find.text('Befund vollständig'), findsOneWidget);
      expect(find.text('9 erfasst'), findsOneWidget);
      expect(find.text('Fehlt noch'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Besuch abschließen'));
      expect(withGaps, isFalse);
    });

    testWidgets('gaps never block closing', (tester) async {
      bool? withGaps;
      await tester.pumpWidget(
        TestApp(
          child: ClosingScreen(
            summary: _summary(draft: _complete().without('pain.score')),
            onFinish: (value) => withGaps = value,
          ),
        ),
      );

      // The rule the screen exists for: a gap may travel. Blocking here would
      // send the nurse home with an open record — the very evening in the
      // office the app removes.
      expect(find.text('Eine Angabe fehlt'), findsOneWidget);
      expect(
        find.text(
          'Lücken dürfen mitgehen. Der Befund wird als unvollständig '
          'geführt.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Mit Lücken abschließen'));
      expect(withGaps, isTrue);
    });

    testWidgets('every gap is a way back into the record', (tester) async {
      String? tapped;
      await tester.pumpWidget(
        TestApp(
          child: ClosingScreen(
            summary: _summary(
              draft: _complete().without('measurement.depthCm'),
            ),
            onFillGap: (slot) => tapped = slot,
          ),
        ),
      );

      await tester.tap(find.text('Tiefe'));
      expect(tapped, 'measurement.depthCm');
    });

    testWidgets('the wound bed remainder is shown as a percentage', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: ClosingScreen(
            summary: _summary(
              draft: _complete().withValue(
                'tissue.granulation',
                const PercentValue(45),
              ),
            ),
          ),
        ),
      );

      expect(
        find.text('Gewebeanteile ergeben 85 %, nicht 100 %.'),
        findsOneWidget,
      );
    });

    testWidgets('a visit without a photo says what that costs later', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: ClosingScreen(
            summary: _summary(photoCount: 0, markedPhotoCount: 0),
          ),
        ),
      );

      expect(find.text('Kein Foto'), findsOneWidget);
      expect(
        find.text('Ohne Foto lässt sich der Verlauf später nicht vergleichen.'),
        findsOneWidget,
      );

      // Still not a blocker: the finding counts, the photo is an aid.
      expect(
        find.widgetWithText(FilledButton, 'Besuch abschließen'),
        findsOneWidget,
      );
    });

    testWidgets('a marked photo is named as such', (tester) async {
      await tester.pumpWidget(
        TestApp(child: ClosingScreen(summary: _summary())),
      );

      expect(find.text('Ein Foto · mit Markierung'), findsOneWidget);
    });
  });

  group('accessibility', () {
    testWidgets('meets the four guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: ClosingScreen(
            summary: _summary(draft: _complete().without('pain.score')),
            onFinish: (_) {},
            onFillGap: (_) {},
            onBack: () {},
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('survives 200 percent text scaling', (tester) async {
      await tester.pumpWidget(
        TestApp(
          textScale: 2,
          child: ClosingScreen(
            summary: _summary(
              draft: _complete()
                  .without('pain.score')
                  .without('measurement.depthCm'),
            ),
            onFinish: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('goldens', () {
    testWidgets('complete, light theme', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: ClosingScreen(summary: _summary(), onFinish: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ClosingScreen),
        matchesGoldenFile('goldens/closing_complete.png'),
      );
    });

    testWidgets('with gaps, dark theme', (tester) async {
      await tester.pumpWidget(
        TestApp(
          brightness: Brightness.dark,
          child: ClosingScreen(
            summary: _summary(
              draft: _complete()
                  .without('pain.score')
                  .without('measurement.depthCm'),
              photoCount: 0,
              markedPhotoCount: 0,
            ),
            onFinish: (_) {},
            onFillGap: (_) {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ClosingScreen),
        matchesGoldenFile('goldens/closing_gaps_dark.png'),
      );
    });
  });
}
