import 'package:flutter/material.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import 'dart:math' as math;
import '../pages/home_screen_helpers.dart';
import 'flip_card_bento.dart';
import 'bento_calendar_view.dart';

class HomeSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String userName;
  final int completedHabits;
  final int totalHabits;
  final int streakCount;
  final Duration focusedTime;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final double topPadding;
  // Calendar flip card state
  final bool isCalendarOpen;
  final DateTime displayedMonth;
  final Map<DateTime, double> completionData;
  final VoidCallback onToggleCalendar;
  final Function(DateTime) onChangeMonth;

  HomeSliverHeaderDelegate({
    required this.userName,
    required this.completedHabits,
    required this.totalHabits,
    required this.streakCount,
    required this.focusedTime,
    required this.selectedDate,
    required this.onDateSelected,
    required this.topPadding,
    required this.isCalendarOpen,
    required this.displayedMonth,
    required this.completionData,
    required this.onToggleCalendar,
    required this.onChangeMonth,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 0.0 = Fully Expanded, 1.0 = Fully Collapsed
    final double progress = shrinkOffset / (maxExtent - minExtent);
    final double clampedProgress = progress.clamp(0.0, 1.0);

    // Fade out expanded content
    final double fadeOut = (1.0 - clampedProgress * 2).clamp(0.0, 1.0);
    // Fade in collapsed content
    final double fadeIn = (clampedProgress - 0.5).clamp(0.0, 0.5) * 2;

    // Element Positions & Sizes
    // Plant Emoji
    const double plantSizeExpanded = 160.0;
    const double plantSizeCollapsed = 40.0;
    final double currentPlantSize = Color.lerp(null, null, clampedProgress) ==
            null // Dummy lerp usage
        ? math.max(
            plantSizeCollapsed, plantSizeExpanded * (1 - clampedProgress * 0.8))
        : plantSizeCollapsed;

    // Calculate vertical position for the plant
    // Expanded: Inside Bento Card (Top ~75)
    // Collapsed: Top ~6 (inside SafeArea)
    final double plantTop =
        uiLerp(75 + topPadding, topPadding + 6, clampedProgress);
    // Calculate horizontal position
    // Expanded: Center
    // Collapsed: Left padding
    final double screenWidth = MediaQuery.of(context).size.width;
    final double plantLeft =
        uiLerp((screenWidth - currentPlantSize) / 2, 24.0, clampedProgress);

    return Container(
      color: Color.lerp(Colors.white, AppColors.creme, 0.2)!,
      child: Stack(
        children: [
          // 1. Static Greeting & Date (Fades out)
          Positioned(
            top: topPadding + 10,
            left: 24,
            right: 24,
            child: Opacity(
              opacity: fadeOut,
              child: Row(
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
            ),
          ),

          // 2. Flip Card Bento (Front: Plant+Stats, Back: Calendar)
          Positioned(
            top: topPadding + 60,
            left: 24,
            right: 24,
            height: 260,
            child: Opacity(
              opacity: fadeOut,
              child: FlipCardBento(
                isFlipped: isCalendarOpen,
                onFlipRequested: onToggleCalendar,
                front: _buildBentoFront(currentPlantSize),
                back: BentoCalendarView(
                  displayedMonth: displayedMonth,
                  selectedDate: selectedDate,
                  completionData: completionData,
                  onDateSelected: onDateSelected,
                  // Sınır kontrolleri
                  canGoPrev: displayedMonth.isAfter(DateTime(2025, 1, 1)),
                  canGoNext: displayedMonth.year < DateTime.now().year ||
                      displayedMonth.month < 12,
                  onMonthPrev: () {
                    final prevMonth = DateTime(
                        displayedMonth.year, displayedMonth.month - 1, 1);
                    if (!prevMonth.isBefore(DateTime(2025, 1, 1))) {
                      onChangeMonth(prevMonth);
                    }
                  },
                  onMonthNext: () {
                    final nextMonth = DateTime(
                        displayedMonth.year, displayedMonth.month + 1, 1);
                    final maxDate = DateTime(DateTime.now().year, 12, 1);
                    if (!nextMonth.isAfter(maxDate)) {
                      onChangeMonth(nextMonth);
                    }
                  },
                  onTodayPress: () {
                    onChangeMonth(DateTime.now());
                  },
                  onClose: onToggleCalendar,
                ),
              ),
            ),
          ),

          // 3. Info Card (Visible ONLY when calendar is open)
          if (isCalendarOpen)
            Positioned(
              top: topPadding + 330,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: fadeOut,
                child: _buildSelectedDayDetails(),
              ),
            ),

          // 4. DateStrip (only visible when calendar is closed)
          if (!isCalendarOpen)
            Positioned(
              top: topPadding + 340,
              left: 0,
              right: 0,
              height: 40,
              child: Opacity(
                opacity: fadeOut,
                child: _buildDateStrip(),
              ),
            ),

          // 4. Plant + Progress Ring (Hero Element) - Only when not flipped
          // And only visible when scrolling starts
          if (!isCalendarOpen)
            Positioned(
              top: plantTop,
              left: plantLeft,
              width: currentPlantSize,
              height: currentPlantSize,
              child: Opacity(
                opacity: (clampedProgress * 2).clamp(0.0, 1.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress Ring
                    SizedBox(
                      width: currentPlantSize,
                      height: currentPlantSize,
                      child: CircularProgressIndicator(
                        value: totalHabits == 0
                            ? 0.0
                            : completedHabits / totalHabits,
                        strokeWidth: uiLerp(12, 4, clampedProgress),
                        backgroundColor:
                            AppColors.lightGreen.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.darkGreen),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // The Plant
                    Center(
                      child: Text(
                        '🌱',
                        style: TextStyle(fontSize: currentPlantSize * 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Collapsed Title (Fades in)
          Positioned(
            top: topPadding + 14,
            left: 80,
            child: Opacity(
              opacity: fadeIn,
              child: const Text(
                'My Garden',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoFront(double plantSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGreen.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Internal Plant + Ring (Visible during flip/at rest)
          Positioned(
            top: 15,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: totalHabits == 0
                            ? 0.0
                            : completedHabits / totalHabits,
                        strokeWidth: 12,
                        backgroundColor:
                            AppColors.lightGreen.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.darkGreen),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    const Center(
                      child: Text(
                        '🌱',
                        style: TextStyle(fontSize: 160 * 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Stats Area at bottom of card
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Row(
              children: [
                _buildCompactStat(
                  Icons.local_fire_department_rounded,
                  '$streakCount days',
                  const Color(0xFFE67E22),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: AppColors.charcoal.withValues(alpha: 0.1),
                ),
                _buildCompactStat(
                  Icons.access_time_rounded,
                  _formatDuration(focusedTime),
                  AppColors.darkGreen,
                ),
              ],
            ),
          ),
          // Calendar toggle button
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onToggleCalendar,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: AppColors.darkGreen,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(IconData icon, String value, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    final today = DateTime.now();
    final dates = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    return ListView.separated(
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
            width: 40,
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

  double uiLerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  double get maxExtent => 440.0 + topPadding; // Adjusted for new Bento layout

  @override
  double get minExtent => 60.0 + topPadding; // Collapsed height

  Widget _buildSelectedDayDetails() {
    final monthNames = [
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
    final dateStr =
        "${selectedDate.day} ${monthNames[selectedDate.month - 1]} ${selectedDate.year}";

    final normalizedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final completion = completionData[normalizedDate] ?? 0.0;

    final now = DateTime.now();
    final isFuture =
        normalizedDate.isAfter(DateTime(now.year, now.month, now.day));

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isFuture) {
      statusText = "Not Available Yet";
      statusColor = AppColors.charcoal.withValues(alpha: 0.4);
      statusIcon = Icons.access_time_rounded;
    } else if (completion == 0) {
      statusText = "No Habits Done";
      statusColor = AppColors.charcoal.withValues(alpha: 0.6);
      statusIcon = Icons.info_outline_rounded;
    } else {
      statusText = "${(completion * 100).toInt()}% Done";
      statusColor = AppColors.darkGreen;
      statusIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              Text(
                HomeScreenHelpers.isSameDay(selectedDate, now)
                    ? 'Today'
                    : (isFuture ? 'Future' : 'Timeline'),
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.charcoal.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant HomeSliverHeaderDelegate oldDelegate) {
    return oldDelegate.completedHabits != completedHabits ||
        oldDelegate.totalHabits != totalHabits ||
        oldDelegate.selectedDate != selectedDate ||
        oldDelegate.streakCount != streakCount ||
        oldDelegate.focusedTime != focusedTime ||
        oldDelegate.isCalendarOpen != isCalendarOpen ||
        oldDelegate.displayedMonth != displayedMonth ||
        oldDelegate.completionData != completionData;
  }
}
