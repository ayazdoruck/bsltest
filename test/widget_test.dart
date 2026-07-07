import 'package:flutter_test/flutter_test.dart';

import 'package:bslend/main.dart';

void main() {
  testWidgets('Splash screen shows branding and loading state (English default)',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // pumpAndSettle kullanilmiyor: splash ekrani gercek ag servislerini
    // (UDP soket, HTTP sunucu) baslatiyor, bu yuzden sadece ilk kareyi
    // (statik icerik + yukleme durumu) dogruluyoruz.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Bslend'), findsOneWidget);
    expect(find.text('Preparing your server...'), findsOneWidget);
  });
}
