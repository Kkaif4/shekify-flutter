import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shekify compile smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Shekify Test'))),
      ),
    );

    expect(find.text('Shekify Test'), findsOneWidget);
  });
}
