import 'package:flutter/material.dart';
import 'package:succulent_app/core/theme/app_colors.dart';

import 'package:succulent_app/features/home/presentation/pages/home_screen_helpers.dart';

class DateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Show 7 days: 3 before, today, 3 after (or just last 7 days)
    // For now, let's show the last 7 days ending today.
    final today = DateTime.now();
    final dates = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = HomeScreenHelpers.isSameDay(date, selectedDate);
          final isToday = HomeScreenHelpers.isSameDay(date, today);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.darkGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.darkGreen
                      : AppColors.charcoal.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.charcoal,
                      ),
                    ),
                    if (isToday && !isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.darkGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
