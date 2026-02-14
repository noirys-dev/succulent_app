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
    return HomeScreenHelpers.parseDuration(text);
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
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: AppColors.darkGreen.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: widget.onOpenDurationPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.charcoal.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.selectedDuration,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if ((currentState.suggestedCategory ??
                        currentState.selectedCategory) !=
                    null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        // Close keyboard to focus on sheet
                        FocusScope.of(context).unfocus();
                        widget.onOpenCategorySheet();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.lightGreen.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.darkGreen.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon: Sparkles for AI suggestion, Tag for manual selection
                            Icon(
                              currentState.selectedCategory != null
                                  ? Icons.label_outline_rounded
                                  : Icons.auto_awesome,
                              size: 14,
                              color: AppColors.darkGreen.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              HomeScreenHelpers.categoryLabel(
                                currentState.selectedCategory ??
                                    currentState.suggestedCategory!,
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGreen,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: AppColors.charcoal.withValues(alpha: 0.4),
                            ),
                          ],
                        ),
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
