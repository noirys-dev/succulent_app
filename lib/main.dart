import 'package:flutter/material.dart';
import 'package:succulent_app/screens/splash_screen.dart';

void main() {
  runApp(const SucculentApp());
}

class SucculentApp extends StatelessWidget {
  const SucculentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Succulent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Brawler',
      ),
      home: const SplashScreen(),
    );
  }
}
