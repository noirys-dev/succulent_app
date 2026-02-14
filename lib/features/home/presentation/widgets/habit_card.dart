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
    return GestureDetector(
      onTap: () {
        context.read<HomeBloc>().add(ToggleHabitDoneEvent(entry.id));
        HapticFeedback.lightImpact();
      },
      onLongPress: () {
        if (entry.isDone) return;
        HapticFeedback.mediumImpact();
        onEdit();
      },
      child: Opacity(
        opacity: entry.isDone ? 0.6 : 1.0,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightGreen.withValues(alpha: 0.50),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.darkGreen.withValues(alpha: 0.85),
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                      decoration: entry.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        formattedDuration,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.charcoal.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        categoryLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.charcoal.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                            color: AppColors.lightGreen.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.darkGreen.withValues(alpha: 0.9),
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
    );
  }
}
