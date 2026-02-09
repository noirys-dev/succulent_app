import 'package:flutter/material.dart';
import 'package:succulent_app/core/theme/app_colors.dart';

/// Calendar view for the back of the Bento flip card.
/// Shows a month grid with day selection and completion heatmap.
class BentoCalendarView extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Map<DateTime, double> completionData;
  final Function(DateTime) onDateSelected;
  final VoidCallback onMonthPrev;
  final VoidCallback onMonthNext;
  final VoidCallback onClose;

  const BentoCalendarView({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.completionData,
    required this.onDateSelected,
    required this.onMonthPrev,
    required this.onMonthNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header: Month navigation + close button
            _buildHeader(),
            const SizedBox(height: 12),
            // Weekday labels
            _buildWeekdayLabels(),
            const SizedBox(height: 8),
            // Day grid
            Expanded(child: _buildDayGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final monthName = monthNames[displayedMonth.month - 1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onMonthPrev,
          icon: const Icon(Icons.chevron_left, color: AppColors.charcoal),
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(
          '$monthName ${displayedMonth.year}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onMonthNext,
              icon: const Icon(Icons.chevron_right, color: AppColors.charcoal),
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return SizedBox(
          width: 28,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal.withValues(alpha: 0.5),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayGrid() {
    // Get first day of month and calculate grid
    final firstDayOfMonth =
        DateTime(displayedMonth.year, displayedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // Monday = 1, Sunday = 7. We want Monday as first day.
    final startingWeekday = firstDayOfMonth.weekday; // 1-7
    final leadingEmptyDays = startingWeekday - 1;

    final totalCells = leadingEmptyDays + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        if (index < leadingEmptyDays) {
          return const SizedBox.shrink();
        }

        final dayNumber = index - leadingEmptyDays + 1;
        if (dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final date =
            DateTime(displayedMonth.year, displayedMonth.month, dayNumber);
        final isSelected = _isSameDay(date, selectedDate);
        final isToday = _isSameDay(date, DateTime.now());

        // Get completion ratio for heatmap
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final completion = completionData[normalizedDate] ?? 0.0;

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.darkGreen
                  : (completion > 0
                      ? AppColors.lightGreen
                          .withValues(alpha: 0.2 + (completion * 0.4))
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected
                  ? Border.all(color: AppColors.darkGreen, width: 1.5)
                  : null,
            ),
            child: Center(
              child: Text(
                dayNumber.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (completion > 0.7
                          ? AppColors.darkGreen
                          : AppColors.charcoal),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
