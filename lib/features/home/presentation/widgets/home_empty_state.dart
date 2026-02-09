import 'package:flutter/material.dart';
import 'package:succulent_app/core/theme/app_colors.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.spa_outlined,
              size: 48,
              color: AppColors.darkGreen.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No habits yet.",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the + button to plant one!",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
