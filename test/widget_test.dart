import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Muestra texto en pantalla', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('Hola SISPLAY')),
      ),
    );

    expect(find.text('Hola SISPLAY'), findsOneWidget);
  });
}