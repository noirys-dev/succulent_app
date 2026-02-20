import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import 'package:succulent_app/features/tasks/models/task.dart';
import 'package:succulent_app/features/tasks/models/task_category.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPlayFocus;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onPlayFocus,
  });

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.watering:
        return AppColors.darkGreen;
      case TaskCategory.fertilizing:
        return AppColors.darkBrown;
      case TaskCategory.repotting:
        return AppColors.lightBrown;
      case TaskCategory.pruning:
        return AppColors.charcoal;
      case TaskCategory.monitoring:
        return AppColors.lightGreen;
      case TaskCategory.other:
        return AppColors.charcoal.withValues(alpha: 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDuration =
        task.durationMinutes != null && task.durationMinutes! > 0;
    final categoryColor = _getCategoryColor(task.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBrown.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Color Strip
              Container(
                width: 6,
                color: task.isCompleted
                    ? AppColors.lightGreen.withValues(alpha: 0.5)
                    : categoryColor,
              ),

              // Main Content
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onEdit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: task.isCompleted
                                  ? AppColors.charcoal.withValues(alpha: 0.4)
                                  : AppColors.charcoal,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              // Category Name
                              Text(
                                task.category.displayName.toLowerCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: task.isCompleted
                                      ? AppColors.charcoal
                                          .withValues(alpha: 0.3)
                                      : categoryColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (hasDuration) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(
                                    Icons.circle,
                                    size: 4,
                                    color: AppColors.charcoal
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                Icon(
                                  Icons.timer_outlined,
                                  size: 12,
                                  color:
                                      AppColors.charcoal.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${task.durationMinutes}m',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.charcoal
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Actions
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: AppColors.charcoal.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Play Button (if active)
                    if (hasDuration && !task.isCompleted && onPlayFocus != null)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onPlayFocus!();
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: AppColors.darkGreen,
                              size: 26,
                            ),
                          ),
                        ),
                      ),

                    // Divider if Play Button exists, or just spacing?
                    // Let's keep it simple. Just Play OR Checkbox? No, both.
                    // But maybe checkbox is always there.

                    // Checkbox
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onToggle();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: task.isCompleted
                                  ? AppColors.darkGreen
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: task.isCompleted
                                    ? AppColors.darkGreen
                                    : AppColors.lightBrown
                                        .withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: task.isCompleted
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
