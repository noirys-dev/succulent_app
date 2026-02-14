import 'package:flutter/material.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import 'package:succulent_app/core/optimization/app_performance.dart';
import 'package:succulent_app/features/home/presentation/widgets/pomodoro_tile.dart';

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

  // İstediğin mantık: Saat 0 ise 0 dakikayı gösterme
  List<int> get _minutesList {
    return selectedHours == 0 ? [10, 20, 30, 40, 50] : [0, 10, 20, 30, 40, 50];
  }

  late FixedExtentScrollController hoursController;
  late FixedExtentScrollController minutesController;

  @override
  void initState() {
    super.initState();
    selectedHours = widget.initialDuration.inHours;
    selectedMinutes = widget.initialDuration.inMinutes.remainder(60);

    // Başlangıç kontrolü:
    // 0h seçiliyken dakika minimum 10 olmalı.
    if (selectedHours == 0 && selectedMinutes < 10) {
      selectedMinutes = 10;
    }

    // Eğer dakika listede yoksa (örn: 15, 25 gibi ara değerler geldiyse), en yakın veya varsayılan değere çek.
    if (!_minutesList.contains(selectedMinutes)) {
      // Basitçe en yakını veya ilkini seçebiliriz. Şimdilik ilkini (varsayılan) seçiyoruz.
      selectedMinutes = _minutesList.first;
    }

    hoursController = FixedExtentScrollController(
      initialItem: hoursList.indexOf(selectedHours),
    );

    // Controller'ı DÜZELTİLMİŞ selectedMinutes'ın indeksine göre başlat
    minutesController = FixedExtentScrollController(
      initialItem: _minutesList.indexOf(selectedMinutes),
    );
  }

  @override
  void dispose() {
    hoursController.dispose();
    minutesController.dispose();
    super.dispose();
  }

  void _applyDuration(int h, int m) {
    widget.onDurationSelected(Duration(hours: h, minutes: m));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const sheetColor = Color(0xFFFAF9F6); // Consistent Off-White
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
                'Set Duration',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              // Custom Sliding Segmented Control
              Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.charcoal.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Stack(
                  children: [
                    // Sliding White Pill
                    AnimatedAlign(
                      alignment: viewMode == 0
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        heightFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(21),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.charcoal.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Clickable Text Labels
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => viewMode = 0),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: viewMode == 0
                                      ? AppColors.darkGreen
                                      : AppColors.charcoal
                                          .withValues(alpha: 0.6),
                                  fontFamily:
                                      'Outfit', // Ensure consistent font
                                ),
                                child: const Text('Custom'),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => viewMode = 1),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: viewMode == 1
                                      ? AppColors.darkGreen
                                      : AppColors.charcoal
                                          .withValues(alpha: 0.6),
                                  fontFamily: 'Outfit',
                                ),
                                child: const Text('Presets'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Compact fixed height container
              SizedBox(
                height: 250,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      // Swipe Right -> Custom
                      if (viewMode != 0) setState(() => viewMode = 0);
                    } else if (details.primaryVelocity! < 0) {
                      // Swipe Left -> Presets
                      if (viewMode != 1) setState(() => viewMode = 1);
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: viewMode == 0
                        ? Column(
                            key: const ValueKey('custom'),
                            children: [
                              SizedBox(
                                height: 160,
                                child: _buildCustomWheelView(),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () => _applyDuration(
                                      selectedHours, selectedMinutes),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Confirm Duration',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : KeyedSubtree(
                            key: const ValueKey('presets'),
                            child: _buildPresetsView(),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        // Selection Highlight
        Container(
          height: 46,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.lightGreen.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hours Wheel
            _buildWheel(
              controller: hoursController,
              items: hoursList,
              selectedItem: selectedHours,
              label: 'h',
              onChanged: (val) {
                setState(() {
                  selectedHours = val;
                  // Trigger default minute selection based on User Request:
                  // 0h -> defaults to 10m (index 0)
                  // 1h/2h -> defaults to 0m (index 0)
                  selectedMinutes = _minutesList.first;

                  // Crucial: Animate to index 0 to visually "reset" the wheel
                  if (minutesController.hasClients) {
                    minutesController.animateToItem(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutQuart,
                    );
                  }
                });
              },
            ),
            const SizedBox(width: 32),
            // Minutes Wheel
            _buildWheel(
              // Key removed to prevent controller detachment
              controller: minutesController,
              items: _minutesList,
              selectedItem: selectedMinutes,
              label: 'm',
              onChanged: (val) => setState(() => selectedMinutes = val),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetsView() {
    return SingleChildScrollView(
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

  Widget _buildWheel({
    Key? key,
    required FixedExtentScrollController controller,
    required List<int> items,
    required int selectedItem,
    required String label,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      width: 60,
      height: 150,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            child: ListWheelScrollView.useDelegate(
              key: key,
              controller: controller,
              itemExtent: 40,
              perspective: 0.005,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (index) {
                if (index >= 0 && index < items.length) {
                  onChanged(items[index]);
                }
              },
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: items.length,
                builder: (context, index) {
                  final val = items[index];
                  final isSelected = selectedItem == val;
                  return Center(
                    child: Text(
                      '$val',
                      style: TextStyle(
                        fontSize: isSelected ? 24 : 18,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? AppColors.darkGreen
                            : AppColors.charcoal.withValues(alpha: 0.3),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.charcoal,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
