import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/domain/model/ids.dart';
import 'package:wunddoku/domain/model/patient.dart';
import 'package:wunddoku/domain/model/wound.dart';
import 'package:wunddoku/features/patienten/ui/patient_screen.dart';
import 'package:wunddoku/features/patienten/ui/wound_form_screen.dart';

import '../support/test_app.dart';

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
            visitCount: (_) => 0,
          ),
        ),
      );

      expect(find.text('Mustermann, Erika'), findsOneWidget);
      expect(find.text('geb. 14.3.1948'), findsOneWidget);
    });

    testWidgets('says when no wound is on file', (tester) async {
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: const [],
            visitCount: (_) => 0,
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
            visitCount: (wound) => wound.id.value == 'w1' ? 3 : 0,
          ),
        ),
      );

      // The course of a healed wound is exactly what someone asks about when
      // it breaks down again.
      expect(find.text('seit 14.7.2026 in Behandlung'), findsOneWidget);
      expect(find.text('abgeheilt am 1.8.2026'), findsOneWidget);
      expect(find.text('3 Besuche'), findsOneWidget);
      expect(find.text('noch kein Besuch'), findsOneWidget);
    });

    testWidgets('tapping a wound opens it', (tester) async {
      Wound? opened;
      await tester.pumpWidget(
        TestApp(
          child: PatientScreen(
            patient: _patient,
            wounds: [_wound(id: 'w1', location: 'Ferse rechts')],
            visitCount: (_) => 1,
            onOpenWound: (wound) => opened = wound,
          ),
        ),
      );

      await tester.tap(find.text('Ferse rechts'));
      await tester.pumpAndSettle();

      expect(opened?.id.value, 'w1');
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
            visitCount: (_) => 2,
            onAddWound: () {},
            onOpenWound: (_) {},
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
