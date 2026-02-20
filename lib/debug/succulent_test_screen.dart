import 'package:flutter/material.dart';
import 'package:succulent_app/features/home/presentation/widgets/animated_succulent.dart';
import 'package:succulent_app/core/theme/app_colors.dart';

class SucculentTestScreen extends StatefulWidget {
  const SucculentTestScreen({super.key});

  @override
  State<SucculentTestScreen> createState() => _SucculentTestScreenState();
}

class _SucculentTestScreenState extends State<SucculentTestScreen> {
  int _streakCount = 0;

  void _increment() {
    setState(() {
      _streakCount++;
    });
  }

  void _decrement() {
    if (_streakCount > 0) {
      setState(() {
        _streakCount--;
      });
    }
  }

  void _reset() {
    setState(() {
      _streakCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creme,
      appBar: AppBar(
        title: const Text('Streak Animation Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.darkGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkGreen.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Center(
                child: AnimatedSucculent(
                  streakCount: _streakCount,
                  size: 160,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Streak: $_streakCount Days',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _decrement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                    foregroundColor: AppColors.darkGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _increment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 60),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '0 Gün: Tohum\n'
                '1 Gün: Filiz\n'
                '2 Gün: Filiz + Gün Işığı\n'
                '3 Gün: Bebek Sukulent\n'
                '4 Gün: Bebek Sukulent + Su Damlaları\n'
                '5 Gün: Yetişkin Sukulent\n'
                '6+ Gün: Yetişkin Sukulent + Gün Işığı',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
