import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:succulent_app/core/classification/classifier.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_event.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_state.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import '../pages/home_screen_helpers.dart';

/// Input Section Widget for adding new habits
class HomeScreenInputSection extends StatefulWidget {
  final TextEditingController habitController;
  final FocusNode habitFocusNode;
  final String selectedDuration;
  final bool isInputOpen;
  final VoidCallback onToggleInput;
  final Function(String) onDurationChanged;
  final Function() onOpenDurationPicker;
  final VoidCallback onOpenCategorySheet;

  const HomeScreenInputSection({
    super.key,
    required this.habitController,
    required this.habitFocusNode,
    required this.selectedDuration,
    required this.isInputOpen,
    required this.onToggleInput,
    required this.onDurationChanged,
    required this.onOpenDurationPicker,
    required this.onOpenCategorySheet,
  });

  @override
  State<HomeScreenInputSection> createState() => _HomeScreenInputSectionState();
}

class _HomeScreenInputSectionState extends State<HomeScreenInputSection> {
  Duration? _parseDuration(String text) {
    final match = RegExp(r'(\d+)?h?\.?\s*(\d+)?m?').firstMatch(text.trim());
    if (match == null) return null;

    final hours = match.group(1) != null ? int.parse(match.group(1)!) : 0;
    final minutes = match.group(2) != null ? int.parse(match.group(2)!) : 0;

    return Duration(hours: hours, minutes: minutes);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, currentState) {
        return Container(
          color: Colors.transparent,
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.habitController,
                        focusNode: widget.habitFocusNode,
                        maxLines: 1,
                        decoration: InputDecoration(
                          hintText: "What's your next move?",
                          hintStyle: TextStyle(
                              color: AppColors.charcoal.withValues(alpha: 0.6)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: AppColors.lightGreen
                                    .withValues(alpha: 0.6)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: AppColors.lightGreen
                                    .withValues(alpha: 0.6)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.darkGreen),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: widget.onOpenDurationPicker,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.charcoal,
                        side: BorderSide(
                            color: AppColors.lightGreen.withValues(alpha: 0.6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        widget.selectedDuration,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                if ((currentState.suggestedCategory ??
                        currentState.selectedCategory) !=
                    null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: widget.onOpenCategorySheet,
                      child: Chip(
                        label: Text(
                          HomeScreenHelpers.categoryLabel(
                            currentState.selectedCategory ??
                                currentState.suggestedCategory!,
                          ),
                        ),
                        backgroundColor:
                            AppColors.lightGreen.withValues(alpha: 0.4),
                        side: BorderSide(
                          color: AppColors.darkGreen.withValues(alpha: 0.8),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkGreen.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final habitText = widget.habitController.text.trim();
                      if (habitText.isEmpty) return;

                      final classifiedCategory =
                          Classifier.classifyEn(habitText).category;
                      final finalCategory = currentState.selectedCategory ??
                          currentState.suggestedCategory ??
                          classifiedCategory;

                      context.read<HomeBloc>().add(AddHabitEvent(
                            title: habitText,
                            duration: _parseDuration(widget.selectedDuration) ??
                                const Duration(minutes: 20),
                            category: finalCategory,
                          ));

                      widget.onToggleInput();
                      widget.habitController.clear();
                      FocusScope.of(context).unfocus();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: AppColors.creme,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Add Habit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
