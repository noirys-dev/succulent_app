import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import 'package:succulent_app/features/home/data/models/habit_model.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_event.dart';
import 'package:succulent_app/features/home/presentation/widgets/duration_picker_sheet.dart';
import 'package:succulent_app/core/classification/category.dart';
import '../pages/home_screen_helpers.dart';

class EditHabitSheet extends StatefulWidget {
  final HabitModel entry;
  final int index;

  const EditHabitSheet({
    super.key,
    required this.entry,
    required this.index,
  });

  @override
  State<EditHabitSheet> createState() => _EditHabitSheetState();
}

class _EditHabitSheetState extends State<EditHabitSheet> {
  late TextEditingController textController;
  late Duration tempDuration;
  late String formattedDuration;
  late CategoryId tempCategory;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.entry.title);
    tempDuration = widget.entry.plannedDuration;
    formattedDuration = HomeScreenHelpers.formatDurationText(tempDuration);
    tempCategory = widget.entry.category;

    // Auto-focus on text field for quick editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    const sheetColor = Color(0xFFFAF9F6); // Elegant Off-White
    return Container(
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: AppColors.lightGreen.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Habit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: AppColors.darkBrown,
                    onPressed: () {
                      context
                          .read<HomeBloc>()
                          .add(RemoveHabitEvent(widget.entry.id));
                      Navigator.of(context).pop();
                      HapticFeedback.mediumImpact();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: textController,
                maxLines: 1,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: AppColors.charcoal,
                ),
                decoration: InputDecoration(
                  hintText: "What's the plan?",
                  hintStyle: TextStyle(
                    color: AppColors.charcoal.withValues(alpha: 0.4),
                    fontSize: 18,
                  ),
                  filled: true,
                  fillColor: Colors.white, // Pure white against off-white bg
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: AppColors.darkGreen.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildZenCapsule(
                    icon: Icons.timer_outlined,
                    label: formattedDuration,
                    onTap: () {
                      const sheetColor = Color(0xFFFAF9F6);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: sheetColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(32)),
                        ),
                        builder: (_) => DurationPickerSheet(
                          initialDuration: tempDuration,
                          onDurationSelected: (val) {
                            setState(() {
                              tempDuration = val;
                              formattedDuration =
                                  HomeScreenHelpers.formatDurationText(val);
                            });
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildZenCapsule(
                    icon: Icons.label_outline_rounded,
                    label: HomeScreenHelpers.categoryLabel(tempCategory),
                    onTap: _showCategoryPicker,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final newText = textController.text.trim();
                    if (newText.isEmpty) return;
                    context.read<HomeBloc>().add(UpdateHabitEvent(
                          id: widget.entry.id,
                          title: newText,
                          plannedDuration: tempDuration,
                          category: tempCategory,
                        ));
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Update Habit',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
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

  Widget _buildZenCapsule({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.charcoal.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: AppColors.darkGreen),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    const sheetColor = Color(0xFFFAF9F6);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: sheetColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.charcoal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Choose Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: CategoryId.values.map((category) {
                        final isSelected = tempCategory == category;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                tempCategory = category;
                              });
                              Navigator.of(context).pop();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.darkGreen
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.darkGreen
                                              .withValues(alpha: 0.15),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [
                                        BoxShadow(
                                          color: AppColors.charcoal
                                              .withValues(alpha: 0.02),
                                          blurRadius: 5,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                              ),
                              child: Text(
                                HomeScreenHelpers.categoryLabel(category),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.charcoal
                                          .withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
