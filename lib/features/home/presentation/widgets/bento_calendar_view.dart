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
  final VoidCallback onTodayPress;
  final VoidCallback onClose;
  final bool canGoPrev;
  final bool canGoNext;

  const BentoCalendarView({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.completionData,
    required this.onDateSelected,
    required this.onMonthPrev,
    required this.onMonthNext,
    required this.onTodayPress,
    required this.onClose,
    this.canGoPrev = true,
    this.canGoNext = true,
  });

  @override
  Widget build(BuildContext context) {
    const monthNames = [
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
    final monthName = monthNames[displayedMonth.month - 1];

    return GestureDetector(
      // Swipe (Kaydırma) ile ay değiştirme
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0 && canGoPrev) {
          onMonthPrev(); // Sağa kaydır -> Önceki Ay
        } else if (details.primaryVelocity! < 0 && canGoNext) {
          onMonthNext(); // Sola kaydır -> Sonraki Ay
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGreen.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          // Stack kullanarak öğeleri üst üste ve sabitliyoruz
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  const SizedBox(height: 2), // 6 -> 2
                  _buildHeader(monthName),
                  const SizedBox(height: 4), // 8 -> 4
                  _buildHorizontalWeekdayLabels(),
                  const SizedBox(height: 2),
                  _buildHeatmapGrid(),
                ],
              ),
            ),
            // Skalayı kartın en altına sabitliyoruz (Hücrelerden bağımsız)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Center(child: _buildMinimalLegend()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String monthName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Sol: Yenile (Today) Butonu
        GestureDetector(
          onTap: onTodayPress,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.darkGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.today_rounded,
                size: 16, color: AppColors.darkGreen),
          ),
        ),

        // Orta: Ay ve Yıl
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sol ok (İpucu)
            Icon(Icons.chevron_left_rounded,
                size: 16, color: AppColors.charcoal.withValues(alpha: 0.2)),
            const SizedBox(width: 4),
            Text(
              '$monthName ${displayedMonth.year}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(width: 4),
            // Sağ ok (İpucu)
            Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.charcoal.withValues(alpha: 0.2)),
          ],
        ),

        // Sağ: Kapat (Close) Butonu
        GestureDetector(
          onTap: onClose,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.charcoal.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close_rounded,
                size: 16, color: AppColors.charcoal.withValues(alpha: 0.4)),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalWeekdayLabels() {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekdays.map((day) {
        return Expanded(
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.charcoal.withValues(alpha: 0.3),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeatmapGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final firstDayOfMonth =
            DateTime(displayedMonth.year, displayedMonth.month, 1);
        final lastDayOfMonth =
            DateTime(displayedMonth.year, displayedMonth.month + 1, 0);
        final daysInMonth = lastDayOfMonth.day;
        final startingWeekday = firstDayOfMonth.weekday; // 1-7 (Mon=1)
        final leadingEmptyDays = startingWeekday - 1;

        const crossAxisCount = 7;
        const mainAxisSpacing = 2.0;
        const crossAxisSpacing = 6.0;
        const childAspectRatio = 1.4;

        // Hesaplamalar
        final cellWidth =
            (constraints.maxWidth - (crossAxisSpacing * (crossAxisCount - 1))) /
                crossAxisCount;
        final cellHeight = cellWidth / childAspectRatio;
        final totalRows =
            ((leadingEmptyDays + daysInMonth) / crossAxisCount).ceil();
        final totalHeight =
            (totalRows * cellHeight) + ((totalRows - 1) * mainAxisSpacing);

        return GestureDetector(
          onTapUp: (details) {
            final x = details.localPosition.dx;
            final y = details.localPosition.dy;

            final col = (x / (cellWidth + crossAxisSpacing)).floor();
            final row = (y / (cellHeight + mainAxisSpacing)).floor();

            if (col >= 0 && col < 7) {
              final index = (row * 7) + col;
              final dayNumber = index - leadingEmptyDays + 1;

              if (dayNumber >= 1 && dayNumber <= daysInMonth) {
                final date = DateTime(
                    displayedMonth.year, displayedMonth.month, dayNumber);
                final now = DateTime.now();
                // Gelecek tarih kontrolü
                if (!date.isAfter(DateTime(now.year, now.month, now.day))) {
                  onDateSelected(date);
                }
              }
            }
          },
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(constraints.maxWidth, totalHeight),
              isComplex: true, // Hint to engine that this is expensive
              willChange:
                  false, // The painter only changes when dependencies change
              painter: _HeatmapPainter(
                displayedMonth: displayedMonth,
                selectedDate: selectedDate,
                completionData: completionData,
                leadingEmptyDays: leadingEmptyDays,
                daysInMonth: daysInMonth,
                cellWidth: cellWidth,
                cellHeight: cellHeight,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimalLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...[0.05, 0.3, 0.5, 0.8, 1.0].map((alpha) => Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: AppColors.darkGreen.withValues(alpha: alpha),
                borderRadius: BorderRadius.circular(1.5),
              ),
            )),
      ],
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Map<DateTime, double> completionData;
  final int leadingEmptyDays;
  final int daysInMonth;
  final double cellWidth;
  final double cellHeight;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  _HeatmapPainter({
    required this.displayedMonth,
    required this.selectedDate,
    required this.completionData,
    required this.leadingEmptyDays,
    required this.daysInMonth,
    required this.cellWidth,
    required this.cellHeight,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int index = 0; index < leadingEmptyDays + daysInMonth; index++) {
      if (index < leadingEmptyDays) continue;

      final dayNumber = index - leadingEmptyDays + 1;
      final date =
          DateTime(displayedMonth.year, displayedMonth.month, dayNumber);
      final isFuture = date.isAfter(today);
      final isSelected = _isSameDay(date, selectedDate);
      final isToday = _isSameDay(date, today);
      final completion = completionData[date] ?? 0.0;

      final row = index ~/ 7;
      final col = index % 7;

      final left = col * (cellWidth + crossAxisSpacing);
      final top = row * (cellHeight + mainAxisSpacing);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, cellWidth, cellHeight),
        const Radius.circular(4),
      );

      // Hücre Rengi
      final Paint paint = Paint()..style = PaintingStyle.fill;
      if (isFuture) {
        paint.color = AppColors.charcoal.withValues(alpha: 0.04);
      } else if (isSelected) {
        paint.color = AppColors.darkGreen;
      } else if (completion == 0) {
        paint.color = AppColors.charcoal.withValues(alpha: 0.06);
      } else {
        paint.color =
            AppColors.darkGreen.withValues(alpha: 0.2 + (completion * 0.8));
      }
      canvas.drawRRect(rect, paint);

      // Border (Bugün veya Seçili)
      if (isToday || (isSelected && !isFuture)) {
        final Paint borderPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = isToday ? 1.5 : 2.0
          ..color = AppColors.darkGreen;
        canvas.drawRRect(rect, borderPaint);
      }
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.displayedMonth != displayedMonth ||
        oldDelegate.selectedDate != selectedDate ||
        oldDelegate.completionData != completionData;
  }
}
