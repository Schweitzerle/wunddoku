import 'package:flutter_test/flutter_test.dart';
import 'package:wunddoku/main.dart';

void main() {
  testWidgets('the app starts and shows the confirmation view', (tester) async {
    await tester.pumpWidget(const WunddokuApp());
    await tester.pumpAndSettle();

    expect(find.text('Prüfen'), findsOneWidget);
    // The example dictation carries one implausible value, so the primary
    // action starts out blocked.
    expect(find.textContaining('entschieden werden'), findsOneWidget);
  });
}
