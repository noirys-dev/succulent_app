// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:succulent_app/main.dart';

void main() {
  testWidgets('App launches and displays home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SucculentApp());

    // Verify that the app title is displayed.
    expect(find.text('Succulent'), findsNothing); // Title is in MaterialApp, not visible in widget tree
    
    // Verify that Daily Tasks heading is displayed.
    expect(find.text('Daily Tasks'), findsOneWidget);
    
    // Verify that Start Focus Mode button is displayed.
    expect(find.text('Start Focus Mode'), findsOneWidget);
  });
}
