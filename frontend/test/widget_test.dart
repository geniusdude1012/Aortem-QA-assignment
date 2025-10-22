// frontend/test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test - App structure', (WidgetTester tester) async {
    // Build a simple test widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Test App'))),
      ),
    );

    // Verify the text is present
    expect(find.text('Test App'), findsOneWidget);
  });

  testWidgets('Text field interaction test', (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Test Field'),
          ),
        ),
      ),
    );

    // Find and tap the text field
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter text
    await tester.enterText(textField, 'Hello World');
    expect(controller.text, 'Hello World');
  });

  testWidgets('Button tap test', (WidgetTester tester) async {
    var buttonTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {
              buttonTapped = true;
            },
            child: const Text('Test Button'),
          ),
        ),
      ),
    );

    // Find and tap the button
    final button = find.byType(ElevatedButton);
    expect(button, findsOneWidget);

    await tester.tap(button);
    expect(buttonTapped, true);
  });
}
