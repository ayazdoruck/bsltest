import 'package:flutter_test/flutter_test.dart';

import 'package:bslend/main.dart';

void main() {
  testWidgets('Splash screen shows with English (default) copy',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Bslend'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
