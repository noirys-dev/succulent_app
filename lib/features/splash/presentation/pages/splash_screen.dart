import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:succulent_app/features/home/presentation/pages/home_screen.dart';
import 'package:succulent_app/core/theme/app_colors.dart';

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
    return Scaffold(
      backgroundColor: AppColors.creme,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.creme,
              AppColors.lightGreen.withValues(alpha: 0.85),
              Color.lerp(AppColors.lightGreen, AppColors.darkGreen, 0.5)!,
              AppColors.darkGreen.withValues(alpha: 0.75),
              AppColors.lightGreen.withValues(alpha: 0.4),
              AppColors.darkBrown.withValues(alpha: 0.3),
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
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 3),
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
                    color: AppColors.charcoal,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(0, 3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
                const CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.darkGreen),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
