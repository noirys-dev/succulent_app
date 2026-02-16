import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import 'package:succulent_app/features/focus/presentation/pages/focus_screen.dart';
import 'package:succulent_app/features/home/data/models/habit_model.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_event.dart';
import 'package:succulent_app/features/home/presentation/pages/home_screen_helpers.dart';

class HabitCard extends StatelessWidget {
  final HabitModel entry;
  final VoidCallback onEdit;
  final int index;

  const HabitCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDuration =
        HomeScreenHelpers.formatDurationText(entry.plannedDuration);
    final categoryLabel = HomeScreenHelpers.categoryLabelFromId(entry.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.darkGreen.withValues(alpha: 0.85),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onEdit, // Tap body to Edit
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Stack(
              children: [
                Row(
                  children: [
                    // Custom Checkbox
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          context
                              .read<HomeBloc>()
                              .add(ToggleHabitDoneEvent(entry.id));
                          HapticFeedback.lightImpact();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: entry.isDone
                                ? AppColors.darkGreen
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.darkGreen,
                              width: 2,
                            ),
                          ),
                          child: entry.isDone
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Opacity(
                        opacity: entry.isDone ? 0.5 : 1.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoal,
                                decoration: entry.isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  formattedDuration,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.charcoal
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  categoryLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.charcoal
                                        .withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Productivity Play Button
                if (categoryLabel == 'Productivity' && !entry.isDone)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FocusScreen(
                                  taskTitle: entry.title,
                                  plannedDuration: entry.plannedDuration,
                                  taskIndex: index,
                                ),
                              ),
                            );

                            if (result != null && result['completed'] == true) {
                              final updated =
                                  result['updatedDuration'] as Duration?;

                              if (context.mounted) {
                                context.read<HomeBloc>().add(UpdateHabitEvent(
                                      id: entry.id,
                                      plannedDuration: updated,
                                    ));
                                context
                                    .read<HomeBloc>()
                                    .add(ToggleHabitDoneEvent(entry.id));
                              }
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.lightGreen.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color:
                                    AppColors.darkGreen.withValues(alpha: 0.9),
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
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
