import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/features/patienten/ui/patient_form_screen.dart';

import '../support/test_app.dart';

void main() {
  Future<PatientDraft?> pumpForm(WidgetTester tester) async {
    PatientDraft? saved;
    await tester.pumpWidget(
      TestApp(child: PatientFormScreen(onSave: (draft) => saved = draft)),
    );
    await tester.pumpAndSettle();
    return saved;
  }

  testWidgets('an incomplete form is refused with the fields named', (
    tester,
  ) async {
    PatientDraft? saved;
    await tester.pumpWidget(
      TestApp(child: PatientFormScreen(onSave: (draft) => saved = draft)),
    );

    await tester.tap(find.text('Anlegen'));
    await tester.pumpAndSettle();

    expect(saved, isNull);
    // Given name, family name and birth date: three complaints, and the birth
    // date one has to be its own because it is not a text field.
    expect(find.text('Pflichtangabe'), findsNWidgets(3));
  });

  testWidgets('an address is optional, a name is not', (tester) async {
    PatientDraft? saved;
    await tester.pumpWidget(
      TestApp(child: PatientFormScreen(onSave: (draft) => saved = draft)),
    );

    await tester.enterText(find.byType(TextFormField).first, 'Erika');
    await tester.enterText(find.byType(TextFormField).at(1), 'Mustermann');
    await tester.tap(find.text('Geburtsdatum wählen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Anlegen'));
    await tester.pumpAndSettle();

    // A nurse standing in the flat has the person in front of her; the
    // address can follow from the office.
    expect(saved, isNotNull);
    expect(saved!.givenName, 'Erika');
    expect(saved!.familyName, 'Mustermann');
    expect(saved!.street, isEmpty);
  });

  testWidgets('meets the four guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpForm(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });

  testWidgets('survives 200 percent text scaling', (tester) async {
    await tester.pumpWidget(
      TestApp(textScale: 2, child: PatientFormScreen(onSave: (_) {})),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
