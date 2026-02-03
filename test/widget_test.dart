// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:succulent_app/main.dart';
import 'package:flutter/material.dart';
import 'package:succulent_app/core/di/injection.dart' as di;
import 'package:succulent_app/features/home/presentation/pages/home_screen.dart';

void main() {
  testWidgets('App launches and displays home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Initialize DI like main.dart
    await di.init();

    await tester.pumpWidget(const SucculentApp());
    // Let the splash duration elapse and settle navigation to HomeScreen
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Splash title not asserted — we navigate to HomeScreen below
    
    // Verify that HomeScreen is shown and greeting is present.
    expect(find.byType(HomeScreen), findsOneWidget);
    // Greeting text may vary; check for presence of a hello prefix.
    expect(
      find.byWidgetPredicate((widget) => widget is Text && (widget.data ?? '').contains('Hello')),
      findsWidgets,
    );
  });
}
