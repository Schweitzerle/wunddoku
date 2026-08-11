import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/capture/transcript_interpreter.dart';
import 'package:wunddoku/features/besuch/ui/confirmation_screen.dart';
import 'package:wunddoku/features/besuch/ui/confirmation_view_model.dart';
import 'package:wunddoku/features/besuch/ui/field_presentation.dart';
import 'package:wunddoku/features/besuch/ui/widgets/provenance_sheet.dart';

import '../support/test_app.dart';

/// A dictation that exercises every state the row can be in: two values heard
/// clearly, one implausible (blocks), one inflected term (needs a look), and
/// several fields never mentioned (gaps).
const _mixedDictation =
    'Länge drei Komma fünf, Breite zwei, Tiefe fünfzig. '
    'Granulationsgewebe sechzig Prozent. Exsudat gering, serös.';

ConfirmationViewModel _model([String transcript = _mixedDictation]) =>
    ConfirmationViewModel(
      expectedSlots: FieldPresentation.woundBedSlots,
      result: const TranscriptInterpreter().interpret(transcript),
    );

void main() {
  group('behaviour', () {
    testWidgets('the empty state explains the screen and offers a way on', (
      tester,
    ) async {
      var backTapped = false;
      await tester.pumpWidget(
        TestApp(
          child: ConfirmationScreen(
            viewModel: ConfirmationViewModel(
              expectedSlots: FieldPresentation.woundBedSlots,
            ),
            onBackToCapture: () => backTapped = true,
          ),
        ),
      );

      expect(find.text('Noch nichts erfasst.'), findsOneWidget);
      await tester.tap(find.text('Zur Erfassung'));
      expect(backTapped, isTrue);
    });

    testWidgets('accepting is blocked while a value is undecided', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(child: ConfirmationScreen(viewModel: _model())),
      );

      expect(
        find.text('Ein Wert muss noch entschieden werden.'),
        findsOneWidget,
      );
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Übernehmen'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('deciding the blocking value releases the primary action', (
      tester,
    ) async {
      var accepted = false;
      final model = _model();
      await tester.pumpWidget(
        TestApp(
          child: ConfirmationScreen(
            viewModel: model,
            onAccept: () => accepted = true,
          ),
        ),
      );

      // The blocking row sorts to the top, so its discard button is the first.
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      expect(find.textContaining('entschieden werden'), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Übernehmen'));
      expect(accepted, isTrue);
    });

    testWidgets('a blocking value shows the word, never the guessed number', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(child: ConfirmationScreen(viewModel: _model())),
      );

      expect(find.text('Entscheiden'), findsOneWidget);
      expect(find.text('50 cm'), findsNothing);
    });

    testWidgets('unspoken fields are shown as gaps, not hidden', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(child: ConfirmationScreen(viewModel: _model())),
      );

      expect(find.text('fehlt'), findsWidgets);
      expect(find.text('Nekrose'), findsOneWidget);
    });

    testWidgets('tapping a row shows where the value came from', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(child: ConfirmationScreen(viewModel: _model())),
      );

      await tester.scrollUntilVisible(find.text('Länge'), 100);
      await tester.tap(find.text('Länge'));
      await tester.pumpAndSettle();

      expect(find.text('Wortlaut'), findsOneWidget);
      final sheet = tester.widget<ProvenanceSheet>(
        find.byType(ProvenanceSheet),
      );
      expect(sheet.span!.textIn(sheet.transcript), 'Länge drei Komma fünf');
    });

    testWidgets('the summary counts what is settled, open and missing', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(child: ConfirmationScreen(viewModel: _model())),
      );

      // Length, width and exudate amount are settled, plus the extra row for
      // the exudate kind; depth blocks and granulation wants a look; necrosis,
      // fibrin, epithelialisation and the pain score were never mentioned.
      expect(find.text('4 übernommen · 2 prüfen · 4 fehlen'), findsOneWidget);
    });
  });

  group('accessibility', () {
    testWidgets('meets the four guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(child: ConfirmationScreen(viewModel: _model())),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });

    testWidgets('the confidence reaches a screen reader as words', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(child: ConfirmationScreen(viewModel: _model())),
      );

      expect(
        find.bySemanticsLabel('Tiefe, Entscheiden, Entscheiden'),
        findsOne,
      );
      expect(find.bySemanticsLabel('Nekrose, fehlt, fehlt'), findsOne);

      // Settled rows sort to the bottom and start out below the fold.
      await tester.scrollUntilVisible(find.text('Länge'), 100);
      expect(find.bySemanticsLabel('Länge, 3,5 cm, Sicher erkannt'), findsOne);

      handle.dispose();
    });

    testWidgets('survives 200 percent text scaling without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(textScale: 2, child: ConfirmationScreen(viewModel: _model())),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out at 320 dp width', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        TestApp(child: ConfirmationScreen(viewModel: _model())),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('goldens', () {
    testWidgets('light theme', (tester) async {
      await tester.pumpWidget(
        TestApp(child: ConfirmationScreen(viewModel: _model())),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ConfirmationScreen),
        matchesGoldenFile('goldens/confirmation_light.png'),
      );
    });

    testWidgets('dark theme', (tester) async {
      await tester.pumpWidget(
        TestApp(
          brightness: Brightness.dark,
          child: ConfirmationScreen(viewModel: _model()),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ConfirmationScreen),
        matchesGoldenFile('goldens/confirmation_dark.png'),
      );
    });

    testWidgets('200 percent text scaling', (tester) async {
      await tester.pumpWidget(
        TestApp(textScale: 2, child: ConfirmationScreen(viewModel: _model())),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ConfirmationScreen),
        matchesGoldenFile('goldens/confirmation_text200.png'),
      );
    });
  });
}
