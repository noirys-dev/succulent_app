import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:succulent_app/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const brown = Color(0xFFA76D5A); // #a76d5a
    const lightBrown = Color(0xFFE4B69D); // #e4b69d
    const darkGreen = Color(0xFF76966B); // #76966b
    const lightGreen = Color(0xFFC3CE98); // #c3ce98
    const cream = Color(0xFFF9EEDB); // #f9eedb
    const darkGray = Color(0xFF636262);

    return Scaffold(
      backgroundColor: cream,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cream,
              lightGreen.withOpacity(0.85),
              Color.lerp(lightGreen, darkGreen, 0.5)!,
              darkGreen.withOpacity(0.75),
              lightBrown.withOpacity(0.4),
              brown.withOpacity(0.3),
            ],
            stops: const [0.0, 0.32, 0.5, 0.68, 0.88, 1.0],
          ),
        ),
        child: Center(
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'Brawler',
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: SvgPicture.asset(
                        'assets/splash-icon.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Succulent',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(0, 3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Growth, without the grind',
                  style: TextStyle(
                    fontSize: 18,
                    color: darkGray,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.15),
                        offset: Offset(0, 3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(darkGreen),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
