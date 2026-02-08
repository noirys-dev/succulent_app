import 'package:flutter/material.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import 'package:succulent_app/features/home/presentation/pages/pomodoro_tile.dart';

class DurationPickerSheet extends StatefulWidget {
  final Duration initialDuration;
  final ValueChanged<Duration> onDurationSelected;

  const DurationPickerSheet({
    super.key,
    required this.initialDuration,
    required this.onDurationSelected,
  });

  @override
  State<DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<DurationPickerSheet> {
  late int selectedHours;
  late int selectedMinutes;

  // 0 = Custom, 1 = Presets
  int viewMode = 1;

  final List<int> hoursList = [0, 1, 2];
  // 0 dakikayı kaldırdık, 10'dan başlıyor.
  final List<int> minutesList = [10, 20, 30, 40, 50];

  FixedExtentScrollController? hoursController;
  FixedExtentScrollController? minutesController;

  @override
  void initState() {
    super.initState();
    selectedHours = widget.initialDuration.inHours;
    selectedMinutes = widget.initialDuration.inMinutes.remainder(60);

    // Eğer seçili dakika listede yoksa (örn: 0 ise), listenin ilk elemanına (10) çek.
    if (!minutesList.contains(selectedMinutes)) {
      selectedMinutes = minutesList.first;
    }
  }

  void _applyDuration(int h, int m) {
    final d = Duration(hours: h, minutes: m);
    widget.onDurationSelected(d);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Controller'ları build anında initialize ediyoruz ki state korunsun
    hoursController ??= FixedExtentScrollController(
        initialItem: hoursList.indexOf(selectedHours));
    minutesController ??= FixedExtentScrollController(
        initialItem: minutesList.contains(selectedMinutes)
            ? minutesList.indexOf(selectedMinutes)
            : 0);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: SizedBox(
          height: 320,
          child: Column(
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Custom Segmented Control
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.creme.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildSegmentButton(
                      title: 'Custom',
                      isActive: viewMode == 0,
                      onTap: () => setState(() => viewMode = 0),
                    ),
                    _buildSegmentButton(
                      title: 'Presets',
                      isActive: viewMode == 1,
                      onTap: () => setState(() => viewMode = 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Content Area with Animation
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    final velocity = details.primaryVelocity ?? 0;
                    if (velocity < 0) {
                      // Swipe Left (Custom -> Presets)
                      if (viewMode == 0) setState(() => viewMode = 1);
                    } else if (velocity > 0) {
                      // Swipe Right (Presets -> Custom)
                      if (viewMode == 1) setState(() => viewMode = 0);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.05),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: viewMode == 0
                        ? _buildCustomWheelView()
                        : _buildPresetsView(),
                  ),
                ),
              ),

              // Bottom Action Button (Only for Custom mode)
              if (viewMode == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () =>
                          _applyDuration(selectedHours, selectedMinutes),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Set Duration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

  Widget _buildCustomWheelView() {
    return Column(
      key: const ValueKey('custom'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Selection Highlight
              Container(
                height: 46,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWheel(
                    controller: hoursController!,
                    items: hoursList,
                    selectedItem: selectedHours,
                    label: 'h',
                    onChanged: (val) => setState(() => selectedHours = val),
                  ),
                  const SizedBox(width: 24),
                  _buildWheel(
                    controller: minutesController!,
                    items: minutesList,
                    selectedItem: selectedMinutes,
                    label: 'm',
                    onChanged: (val) => setState(() => selectedMinutes = val),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetsView() {
    return SingleChildScrollView(
      key: const ValueKey('presets'),
      child: Column(
        children: [
          PomodoroTile(
            title: 'Classic Pomodoro',
            duration: '25m',
            breakTime: '5m break',
            icon: Icons.timer_outlined,
            onTap: () => _applyDuration(0, 25),
          ),
          PomodoroTile(
            title: 'Deep Work',
            duration: '50m',
            breakTime: '10m break',
            icon: Icons.psychology_outlined,
            onTap: () => _applyDuration(0, 50),
          ),
          PomodoroTile(
            title: 'Long Session',
            duration: '90m',
            breakTime: '15m break',
            icon: Icons.coffee_outlined,
            onTap: () => _applyDuration(1, 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
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
                      color: Colors.black.withOpacity(0.05),
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
                  : AppColors.charcoal.withOpacity(0.6),
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

  Widget _buildWheel({
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
                          : AppColors.charcoal.withOpacity(0.3),
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
}
