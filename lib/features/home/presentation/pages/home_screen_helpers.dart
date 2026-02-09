import 'package:flutter/material.dart';
import 'package:succulent_app/core/classification/category.dart';
import 'package:succulent_app/core/theme/app_colors.dart';

/// Helper methods for HomeScreen state and UI utilities
class HomeScreenHelpers {
  static String formatShortDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  static String categoryLabel(CategoryId id) {
    return kCategories.firstWhere((cat) => cat.id == id).label;
  }

  static String formatDurationText(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final List<String> parts = [];

    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add('${m}m');

    return parts.isEmpty ? '0m' : parts.join(' ');
  }

  static Duration clampDuration(Duration d) {
    if (d.inMinutes < 10) return const Duration(minutes: 10);
    if (d.inHours > 2) return const Duration(hours: 2);
    return d;
  }

  /// Build segment button for duration picker
  static Widget buildSegmentButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? AppColors.darkGreen
                  : AppColors.charcoal.withValues(alpha: 0.6),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  /// Build wheel widget for duration picker
  static Widget buildWheel({
    required FixedExtentScrollController controller,
    required List<int> items,
    required int selectedItem,
    required String label,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 50,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 40,
            perspective: 0.005,
            diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) => onChanged(items[index]),
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: items.length,
              builder: (context, index) {
                final val = items[index];
                final isSelected = selectedItem == val;
                return Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isSelected ? 24 : 18,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppColors.darkGreen
                          : AppColors.charcoal.withValues(alpha: 0.3),
                    ),
                    child: Text('$val'),
                  ),
                );
              },
            ),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }

  static Duration? parseDuration(String text) {
    if (text.isEmpty) return null;
    final match = RegExp(r'(\d+)?h?\.?\s*(\d+)?m?').firstMatch(text.trim());
    if (match == null) return null;

    final hours = match.group(1) != null ? int.parse(match.group(1)!) : 0;
    final minutes = match.group(2) != null ? int.parse(match.group(2)!) : 0;

    return Duration(hours: hours, minutes: minutes);
  }

  static String categoryLabelFromId(CategoryId id) {
    return kCategories.firstWhere((cat) => cat.id == id).label;
  }

  static bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
