import 'package:flutter/material.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import 'package:succulent_app/core/optimization/app_performance.dart';

class PomodoroTile extends StatelessWidget {
  final String title;
  final String duration;
  final String breakTime;
  final IconData icon;
  final VoidCallback onTap;

  const PomodoroTile({
    super.key,
    required this.title,
    required this.duration,
    required this.breakTime,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final perf = AppPerformance.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.lightGreen.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGreen.withValues(alpha: 0.05),
                blurRadius: perf.shadowBlurRadiusSmall,
                offset: Offset(0, perf.shadowOffsetYSmall),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.darkGreen, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$duration focus · $breakTime',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.charcoal.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                color: AppColors.lightGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
