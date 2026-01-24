import 'package:flutter/material.dart';
import 'package:succulent_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:succulent_app/debug/classification_test_screen.dart';

void main() {
  runApp(const SucculentApp());
}

bool kShowClassificationTest = true;

class SucculentApp extends StatelessWidget {
  const SucculentApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Toggle this flag to open the classification test screen

    return MaterialApp(
      title: 'Succulent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Brawler',
      ),
      home: kShowClassificationTest
          ? const ClassificationTestScreen()
          : const SplashScreen(),
    );
  }
}
