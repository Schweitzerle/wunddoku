import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/model/ids.dart';
import 'package:wunddoku/domain/model/patient.dart';
import 'package:wunddoku/domain/model/wound.dart';
import 'package:wunddoku/features/patienten/ui/patient_screen.dart';
import 'package:wunddoku/features/patienten/ui/wound_form_screen.dart';

import '../support/phone.dart';
import '../support/test_app.dart';

/// No photo files in a widget test; the thumbnail falls back to its label.
Future<Uint8List?> _noPhoto(String ref) async => null;

final _patient = Patient(
  id: const PatientId('p1'),
  givenName: 'Erika',
  familyName: 'Mustermann',
  birthDate: DateTime(1948, 3, 14),
  street: 'Musterweg 1',
  postalCode: '12345',
  city: 'Musterstadt',
  createdAt: DateTime(2026, 8, 1),
);

Wound _wound({
  required String id,
  required String location,
  DateTime? closedAt,
  String? icd10Code,
}) => Wound(
  id: WoundId(id),
  patientId: _patient.id,
  location: location,
  icd10Code: icd10Code,
  createdAt: DateTime(2026, 7, 14),
  closedAt: closedAt,
);

void main() {
  group('the patient screen', () {
    testWidgets('names the person and their birth date', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: const [],
            standingOf: (_) => const WoundStanding.none(),
            loadPhoto: _noPhoto,
          ),
        ),
      );

      expect(find.text('Mustermann, Erika'), findsOneWidget);
      expect(find.textContaining('geb. 14.3.1948'), findsOneWidget);
    });

    testWidgets('says when no wound is on file', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: const [],
            standingOf: (_) => const WoundStanding.none(),
            loadPhoto: _noPhoto,
            onAddWound: () {},
          ),
        ),
      );

      expect(
        find.text('Für diesen Patienten ist noch keine Wunde angelegt.'),
        findsOneWidget,
      );
      expect(find.text('Wunde anlegen'), findsOneWidget);
    });

    testWidgets('a healed wound is marked as healed, not hidden', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: [
              _wound(id: 'w1', location: 'linker Unterschenkel'),
              _wound(
                id: 'w2',
                location: 'Ferse rechts',
                closedAt: DateTime(2026, 8, 1),
              ),
            ],
            standingOf: (wound) => wound.id.value == 'w1'
                ? const WoundStanding(visitCount: 3)
                : const WoundStanding.none(),
            loadPhoto: _noPhoto,
            onOpenWound: (_) {},
            onShowHistory: (_) {},
          ),
        ),
      );

      // The course of a healed wound is exactly what someone asks about when
      // it breaks down again.
      expect(find.textContaining('seit 14.7.2026 in Behandlung'), findsOneWidget);
      expect(find.textContaining('abgeheilt am 1.8.2026'), findsOneWidget);
      expect(find.textContaining('3 Besuche'), findsOneWidget);
      expect(find.textContaining('noch kein Besuch'), findsOneWidget);
    });

    testWidgets('tapping a wound opens it', (tester) async {
      Wound? opened;
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: [_wound(id: 'w1', location: 'Ferse rechts')],
            standingOf: (_) => const WoundStanding(visitCount: 1),
            loadPhoto: _noPhoto,
            onOpenWound: (wound) => opened = wound,
          ),
        ),
      );

      // The action is on the card and carries a word: tapping the card
      // itself was an affordance nobody could see.
      await tester.tap(find.text('Besuch beginnen'));
      await tester.pumpAndSettle();

      expect(opened?.id.value, 'w1');
    });

    testWidgets('the card says how the wound is doing', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: [_wound(id: 'w1', location: 'linker Unterschenkel')],
            standingOf: (_) => const WoundStanding(
              visitCount: 7,
              areaCm2: 7,
              areaChangeCm2: -1.4,
            ),
            loadPhoto: _noPhoto,
            onOpenWound: (_) {},
            onShowHistory: (_) {},
          ),
        ),
      );

      // The figure the treatment is judged by, and which way it moved — the
      // whole reason to look at a wound before touching it.
      expect(find.text('7 cm²'), findsOneWidget);
      expect(
        find.text('1,4 cm² kleiner als beim vorigen Besuch'),
        findsOneWidget,
      );
      expect(find.textContaining('7 Besuche'), findsOneWidget);
    });

    testWidgets('a wound growing is said in the colour of "check"', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: [_wound(id: 'w1', location: 'linker Unterschenkel')],
            standingOf: (_) => const WoundStanding(
              visitCount: 2,
              areaCm2: 9,
              areaChangeCm2: 2,
            ),
            loadPhoto: _noPhoto,
            onOpenWound: (_) {},
          ),
        ),
      );

      expect(
        find.text('2 cm² größer als beim vorigen Besuch'),
        findsOneWidget,
      );
    });

    testWidgets('a wound without measurements shows no area at all', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: [_wound(id: 'w1', location: 'linker Unterschenkel')],
            standingOf: (_) => const WoundStanding(visitCount: 1),
            loadPhoto: _noPhoto,
            onOpenWound: (_) {},
          ),
        ),
      );

      // A gap, not a zero: 0 cm² would be a finding nobody made.
      expect(find.textContaining('cm²'), findsNothing);
      expect(find.byIcon(Icons.image_outlined), findsOne);
    });

    testWidgets('a healed wound keeps its course and loses the visit', (
      tester,
    ) async {
      var history = 0;
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: [
              _wound(
                id: 'w2',
                location: 'Ferse rechts',
                closedAt: DateTime(2026, 8, 1),
              ),
            ],
            standingOf: (_) => const WoundStanding(visitCount: 12),
            loadPhoto: _noPhoto,
            onOpenWound: (_) {},
            onShowHistory: (_) => history++,
          ),
        ),
      );

      expect(find.text('Besuch beginnen'), findsNothing);
      await tester.tap(find.text('Verlauf ansehen'));
      expect(history, 1);
    });

    testWidgets('golden: a patient with an open and a healed wound', (
      tester,
    ) async {
      await useScreen(tester);
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: [
              _wound(
                id: 'w1',
                location: 'linker Unterschenkel, distal',
                icd10Code: 'L97.4',
              ),
              _wound(
                id: 'w2',
                location: 'Ferse rechts',
                closedAt: DateTime(2026, 8, 1),
              ),
            ],
            standingOf: (wound) => wound.id.value == 'w1'
                ? const WoundStanding(
                    visitCount: 7,
                    areaCm2: 7,
                    areaChangeCm2: -1.4,
                  )
                : const WoundStanding(visitCount: 12),
            loadPhoto: _noPhoto,
            onOpenWound: (_) {},
            onShowHistory: (_) {},
            onAddWound: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PatientScreen),
        matchesGoldenFile('goldens/patient_wounds.png'),
      );
    });

    testWidgets('golden: the wound card at 200 percent text', (tester) async {
      await useScreen(tester, size: narrowSize);
      await tester.pumpWidget(
        TestApp(
          textScale: 2,
          child: PatientScreen(
            patient: _patient,
            wounds: [
              _wound(id: 'w1', location: 'linker Unterschenkel, distal'),
            ],
            standingOf: (_) => const WoundStanding(
              visitCount: 7,
              areaCm2: 7,
              areaChangeCm2: -1.4,
            ),
            loadPhoto: _noPhoto,
            onOpenWound: (_) {},
            onShowHistory: (_) {},
            onAddWound: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await expectLater(
        find.byType(PatientScreen),
        matchesGoldenFile('goldens/patient_wounds_text200.png'),
      );
    });

    testWidgets('meets the four guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: [
              _wound(id: 'w1', location: 'Ferse rechts', icd10Code: 'I83.0'),
            ],
            standingOf: (_) => const WoundStanding(
              visitCount: 2,
              areaCm2: 7,
              areaChangeCm2: -1.4,
            ),
            loadPhoto: _noPhoto,
            onAddWound: () {},
            onOpenWound: (_) {},
            onShowHistory: (_) {},
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });
  });

  group('the wound form', () {
    testWidgets('refuses a wound without a location, and says why', (
      tester,
    ) async {
      WoundDraft? saved;
      await tester.pumpWidget(
        TestApp(child: WoundFormScreen(onSave: (draft) => saved = draft)),
      );

      await tester.tap(find.text('Anlegen'));
      await tester.pumpAndSettle();

      expect(saved, isNull);
      expect(
        find.text(
          'Ohne Lokalisation lassen sich zwei Wunden nicht auseinanderhalten.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the diagnosis code stays optional', (tester) async {
      WoundDraft? saved;
      await tester.pumpWidget(
        TestApp(child: WoundFormScreen(onSave: (draft) => saved = draft)),
      );

      await tester.enterText(
        find.byType(TextFormField).first,
        'linker Unterschenkel, distal',
      );
      await tester.tap(find.text('Anlegen'));
      await tester.pumpAndSettle();

      // The nurse at the dressing does not carry the ICD-10 catalogue in her
      // head; the code follows from the office.
      expect(saved?.location, 'linker Unterschenkel, distal');
      expect(saved?.icd10Code, isNull);
    });
  });
}
