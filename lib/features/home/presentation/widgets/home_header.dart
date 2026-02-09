import 'package:flutter/material.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import '../pages/home_screen_helpers.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final int completedHabits;
  final int totalHabits;
  final int streakCount;
  final Duration focusedTime;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.completedHabits,
    required this.totalHabits,
    required this.streakCount,
    required this.focusedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hello, $userName!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Today · ${HomeScreenHelpers.formatShortDate(DateTime.now())}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.charcoal,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(80),
              border: Border.all(
                color: AppColors.darkGreen.withValues(alpha: 0.85),
              ),
            ),
            child: const Center(
              child: Text(
                '🌱',
                style: TextStyle(fontSize: 64),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const SizedBox(height: 28),
        // Bento Grid Section
        Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildBentoTile(
                icon: '🌵',
                label: 'Streak',
                value: '$streakCount days',
                color: AppColors.lightGreen.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _buildBentoTile(
                icon: '⏱️',
                label: 'Focused',
                value: _formatDuration(focusedTime),
                color: AppColors.darkGreen.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBentoTile({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.darkGreen.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.charcoal.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
