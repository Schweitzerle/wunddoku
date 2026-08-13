import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/catalog/exudation.dart';
import 'package:wunddoku/domain/model/ids.dart';
import 'package:wunddoku/domain/model/visit_draft.dart';
import 'package:wunddoku/domain/model/wound_history.dart';
import 'package:wunddoku/features/verlauf/ui/visit_detail_screen.dart';
import 'package:wunddoku/shared/text/field_presentation.dart';

import '../support/phone.dart';
import '../support/test_app.dart';

/// No photo files in a widget test; the picture falls back to its mark.
Future<Uint8List?> _noPhoto(String ref) async => null;

HistoryEntry _entry({bool closedWithGaps = true, bool isOpen = false}) =>
    HistoryEntry(
      visit: const VisitId('v1'),
      recordedAt: DateTime(2026, 8, 12),
      draft: const VisitDraft(
        values: {
          'measurement.lengthCm': CentimetreValue(3.5),
          'measurement.widthCm': CentimetreValue(2),
          'tissue.granulation': PercentValue(60),
          'exudate.amount': ExudateAmountValue(ExudateAmount.slight),
        },
      ),
      closedWithGaps: closedWithGaps,
      isOpen: isOpen,
      photoRef: 'photo_1',
    );

Widget _screen({bool closedWithGaps = true, bool isOpen = false}) =>
    TestApp(
      child: VisitDetailScreen(
        entry: _entry(closedWithGaps: closedWithGaps, isOpen: isOpen),
        areaChange: -1.4,
        expectedSlots: FieldPresentation.woundBedSlots,
        loadPhoto: _noPhoto,
      ),
    );

void main() {
  testWidgets('the visit says what it recorded and what it did not', (
    tester,
  ) async {
    await useScreen(tester);
    await tester.pumpWidget(_screen());
    await tester.pumpAndSettle();

    expect(find.text('12. Aug. 2026'), findsOneWidget);
    expect(find.text('7 cm²'), findsOneWidget);
    expect(
      find.text('1,4 cm² kleiner als beim vorigen Besuch'),
      findsOneWidget,
    );

    // Both halves stand there. A visit that recorded nothing about the wound
    // margin is a different fact from a visit where the margin was normal,
    // and the office cannot tell them apart from an absence.
    expect(find.text('Erfasst'), findsOneWidget);
    expect(find.text('Nicht erfasst'), findsOneWidget);
    expect(find.text('Länge'), findsOneWidget);
    expect(find.text('3,5 cm'), findsOneWidget);
    expect(find.text('Granulation'), findsOneWidget);
    expect(find.text('60 %'), findsOneWidget);
    expect(find.text('gering'), findsOneWidget);
    expect(find.text('fehlt'), findsWidgets);
  });

  testWidgets('how the visit was left is stated, not implied', (tester) async {
    await useScreen(tester);
    await tester.pumpWidget(_screen());
    await tester.pumpAndSettle();
    expect(find.text('Mit Lücken abgeschlossen'), findsOneWidget);

    await tester.pumpWidget(_screen(closedWithGaps: false));
    await tester.pumpAndSettle();
    expect(find.text('Vollständig abgeschlossen'), findsOneWidget);

    await tester.pumpWidget(_screen(closedWithGaps: false, isOpen: true));
    await tester.pumpAndSettle();
    expect(find.text('Besuch offen'), findsOneWidget);
  });

  testWidgets('the words the finding was spoken in stay with it', (
    tester,
  ) async {
    await useScreen(tester);
    await tester.pumpWidget(
      TestApp(
        child: VisitDetailScreen(
          entry: _entry(),
          areaChange: -1.4,
          expectedSlots: FieldPresentation.woundBedSlots,
          loadPhoto: _noPhoto,
          transcript: 'Länge vier Komma zwei, Breite zwei Komma acht. '
              'Excusat gering, seriös.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Weeks later this is the only place where a misheard term is still
    // recognisable as one. It sits at the end of the record, so the test
    // scrolls the way the reader would.
    await tester.scrollUntilVisible(find.text('Wortlaut'), 300);
    expect(find.text('Wortlaut'), findsOneWidget);
    expect(find.textContaining('Excusat gering'), findsOneWidget);
  });

  testWidgets('a visit entered through the cards has no wording', (
    tester,
  ) async {
    await useScreen(tester);
    await tester.pumpWidget(_screen());
    await tester.pumpAndSettle();

    expect(find.text('Wortlaut'), findsNothing);
  });

  testWidgets('meets the four guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await useScreen(tester);
    await tester.pumpWidget(_screen());
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });

  testWidgets('survives 200 percent text on a narrow phone', (tester) async {
    await useScreen(tester, size: narrowSize);
    await tester.pumpWidget(
      TestApp(
        textScale: 2,
        child: VisitDetailScreen(
          entry: _entry(),
          areaChange: -1.4,
          expectedSlots: FieldPresentation.woundBedSlots,
          loadPhoto: _noPhoto,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('golden: a visit closed with gaps', (tester) async {
    await useScreen(tester);
    await tester.pumpWidget(_screen());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(VisitDetailScreen),
      matchesGoldenFile('goldens/visit_detail.png'),
    );
  });
}
