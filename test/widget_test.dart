import 'package:flutter_test/flutter_test.dart';

import 'package:qivo_2027/main.dart' as app;

void main() {
  testWidgets('Qivo home screen renders core promise', (tester) async {
    app.main();
    await tester.pump();

    expect(find.text('Find the right words in real time.'), findsOneWidget);
    expect(find.text('Start Live Assist'), findsWidgets);
  });
}
