import 'package:flutter_test/flutter_test.dart';

import 'package:bslend/main.dart';

void main() {
  testWidgets('Splash ekranı açılır ve Başlayalım butonu görünür',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bslend'), findsOneWidget);
    expect(find.text('Başlayalım'), findsOneWidget);
  });
}
