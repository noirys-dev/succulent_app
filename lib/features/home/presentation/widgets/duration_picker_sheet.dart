import 'package:flutter/material.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
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

    // Başlangıç kontrolü: Eğer 0h ve 0m geldiyse, dakikayı 10'a çek
    if (!_minutesList.contains(selectedMinutes)) {
      selectedMinutes = _minutesList.first;
    }

    hoursController = FixedExtentScrollController(
      initialItem: hoursList.indexOf(selectedHours),
    );
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: SizedBox(
          height: 350, // Biraz daha geniş alan
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Segmented Control
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.creme.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildSegmentButton('Custom', viewMode == 0,
                        () => setState(() => viewMode = 0)),
                    _buildSegmentButton('Presets', viewMode == 1,
                        () => setState(() => viewMode = 1)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: viewMode == 0
                      ? _buildCustomWheelView()
                      : _buildPresetsView(),
                ),
              ),

              if (viewMode == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () =>
                          _applyDuration(selectedHours, selectedMinutes),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Set Duration',
                          style: TextStyle(fontWeight: FontWeight.w600)),
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
                  // Saat 0'a çekilirse ve o an dakika 0'daysa (artık listede yok), 10'a zıplat
                  if (!_minutesList.contains(selectedMinutes)) {
                    selectedMinutes = _minutesList.first;
                    minutesController
                        .jumpToItem(_minutesList.indexOf(selectedMinutes));
                  }
                });
              },
            ),
            const SizedBox(width: 32),
            // Minutes Wheel
            _buildWheel(
              // KRİTİK NOKTA: ValueKey sayesinde saat değiştikçe dakika çarkı temizlenip yeniden kurulur.
              key: ValueKey('minutes_wheel_for_hour_$selectedHours'),
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

  Widget _buildSegmentButton(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive
                  ? AppColors.darkGreen
                  : AppColors.charcoal.withValues(alpha: 0.6),
            ),
          ),
        ),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          child: ListWheelScrollView.useDelegate(
            key: key,
            controller: controller,
            itemExtent: 40,
            perspective: 0.005,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) => onChanged(items[index]),
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
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: AppColors.charcoal)),
      ],
    );
  }
}
