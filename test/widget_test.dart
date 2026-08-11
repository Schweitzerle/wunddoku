import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/main.dart';

void main() {
  testWidgets('the app starts in the recording step of the visit', (
    tester,
  ) async {
    await tester.pumpWidget(const WunddokuApp());
    await tester.pump();

    expect(find.text('Befund sprechen'), findsOneWidget);
    expect(find.text('Aufnahme starten'), findsOneWidget);
  });
}
