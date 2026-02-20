import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:succulent_app/core/classification/category.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import 'package:succulent_app/features/focus/presentation/pages/focus_screen.dart';
import 'package:succulent_app/features/home/data/models/habit_model.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_event.dart';
import 'package:succulent_app/features/home/presentation/pages/home_screen_helpers.dart';

class HabitCard extends StatefulWidget {
  final HabitModel entry;
  final VoidCallback onEdit;
  final int index;
  final bool isReadOnly;

  const HabitCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.index,
    this.isReadOnly = false,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkAnimController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _checkAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _checkAnimController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(CategoryId category) {
    switch (category) {
      case CategoryId.productivity:
        return const Color(0xFF5B8A72);
      case CategoryId.physicalActivity:
        return const Color(0xFFD4845A);
      case CategoryId.chores:
        return const Color(0xFF9B8B7E);
      case CategoryId.health:
        return const Color(0xFF7AA886);
      case CategoryId.social:
        return const Color(0xFFB07BA8);
      case CategoryId.general:
        return const Color(0xFF8B8B8B);
    }
  }

  IconData _getCategoryIcon(CategoryId category) {
    switch (category) {
      case CategoryId.productivity:
        return Icons.bolt_rounded;
      case CategoryId.physicalActivity:
        return Icons.directions_run_rounded;
      case CategoryId.chores:
        return Icons.home_rounded;
      case CategoryId.health:
        return Icons.favorite_rounded;
      case CategoryId.social:
        return Icons.group_rounded;
      case CategoryId.general:
        return Icons.star_rounded;
    }
  }

  void _onToggle() {
    if (widget.isReadOnly) return;
    _checkAnimController.forward(from: 0);
    HapticFeedback.lightImpact();
    context.read<HomeBloc>().add(ToggleHabitDoneEvent(widget.entry.id));
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final formattedDuration =
        HomeScreenHelpers.formatDurationText(entry.plannedDuration);
    final categoryLabel = HomeScreenHelpers.categoryLabelFromId(entry.category);
    final categoryColor = _getCategoryColor(entry.category);
    final categoryIcon = _getCategoryIcon(entry.category);
    final isProductivity = entry.category == CategoryId.productivity;

    // View-only mode for historical data checking
    if (widget.isReadOnly) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6), // Faded background
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Disabled Checkbox (always unchecked look or locked)
            SizedBox(
              width: 38,
              height: 38,
              child: Center(
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: AppColors.charcoal.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Opacity(
                opacity: 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildDurationBadge(formattedDuration, false),
                        const SizedBox(width: 8),
                        _buildCategoryChip(
                            categoryLabel, categoryColor, categoryIcon, false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedBuilder(
      animation: _checkAnimController,
      builder: (context, child) {
        // TweenSequence yerine manuel hesaplama (daha güvenli)
        double scale = 1.0;
        final t = _checkAnimController.value;
        if (t < 0.4) {
          // 0.0 -> 0.4 aralığında: 1.0 -> 0.85
          scale = 1.0 - (0.15 * (t / 0.4));
        } else if (t < 0.75) {
          // 0.4 -> 0.75 aralığında: 0.85 -> 1.08
          final progress = (t - 0.4) / 0.35;
          scale = 0.85 + (0.23 * progress);
        } else {
          // 0.75 -> 1.0 aralığında: 1.08 -> 1.0
          final progress = (t - 0.75) / 0.25;
          scale = 1.08 - (0.08 * progress);
        }

        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onEdit,
                borderRadius: BorderRadius.circular(18),
                splashColor: categoryColor.withValues(alpha: 0.08),
                highlightColor: categoryColor.withValues(alpha: 0.04),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        entry.isDone ? const Color(0xFFF5F3EF) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: entry.isDone
                          ? AppColors.charcoal.withValues(alpha: 0.06)
                          : categoryColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: entry.isDone
                        ? []
                        : [
                            BoxShadow(
                              color: categoryColor.withValues(alpha: 0.08),
                              offset: const Offset(0, 4),
                              blurRadius: 16,
                              spreadRadius: -2,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              offset: const Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                  ),
                  child: Row(
                    children: [
                      // ── Custom Checkbox with category accent ──
                      _buildCheckbox(entry, categoryColor),
                      const SizedBox(width: 14),

                      // ── Main content ──
                      Expanded(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: entry.isDone ? 0.45 : 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Task Title
                              Text(
                                entry.title,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.charcoal,
                                  decoration: entry.isDone
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor:
                                      AppColors.charcoal.withValues(alpha: 0.4),
                                  decorationThickness: 1.5,
                                  height: 1.2,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),

                              // Duration + Category Row
                              Row(
                                children: [
                                  // Duration Badge
                                  _buildDurationBadge(
                                      formattedDuration, entry.isDone),
                                  const SizedBox(width: 8),

                                  // Category Chip
                                  _buildCategoryChip(
                                    categoryLabel,
                                    categoryColor,
                                    categoryIcon,
                                    entry.isDone,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Play button for Productivity ──
                      if (isProductivity && !entry.isDone)
                        _buildPlayButton(entry),

                      // ── Drag Handle removed ──
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(HabitModel entry, Color accentColor) {
    return GestureDetector(
      onTap: _onToggle,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: entry.isDone
                  ? accentColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: entry.isDone
                    ? accentColor.withValues(alpha: 0.6)
                    : accentColor.withValues(alpha: 0.35),
                width: entry.isDone ? 2 : 1.8,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: entry.isDone
                  ? Icon(
                      Icons.check_rounded,
                      key: const ValueKey('checked'),
                      size: 16,
                      color: accentColor,
                    )
                  : const SizedBox.shrink(key: ValueKey('unchecked')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationBadge(String duration, bool isDone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.charcoal.withValues(alpha: 0.04)
            : AppColors.charcoal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 11,
            color: AppColors.charcoal.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 4),
          Text(
            duration,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal.withValues(alpha: 0.55),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    String label,
    Color color,
    IconData icon,
    bool isDone,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDone
            ? color.withValues(alpha: 0.06)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: isDone
                ? color.withValues(alpha: 0.5)
                : color.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDone
                  ? color.withValues(alpha: 0.5)
                  : color.withValues(alpha: 0.85),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(HabitModel entry) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.selectionClick();
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FocusScreen(
                taskTitle: entry.title,
                plannedDuration: entry.plannedDuration,
                taskIndex: widget.index,
              ),
            ),
          );

          if (!mounted) return;
          if (result != null && result['completed'] == true) {
            final updated = result['updatedDuration'] as Duration?;

            context.read<HomeBloc>().add(UpdateHabitEvent(
                  id: entry.id,
                  plannedDuration: updated,
                ));
            context.read<HomeBloc>().add(ToggleHabitDoneEvent(entry.id));
          }
        },
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.darkGreen.withValues(alpha: 0.12),
                AppColors.lightGreen.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.darkGreen.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.play_arrow_rounded,
              size: 18,
              color: AppColors.darkGreen,
            ),
          ),
        ),
      ),
    );
  }
}
