import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:succulent_app/core/classification/category.dart';
import 'package:succulent_app/core/classification/classifier.dart';
import 'package:succulent_app/features/focus/presentation/pages/focus_screen.dart';

// Brand color palette
const Color kDarkBrown = Color(0xFFA76D5A);
const Color kLightBrown = Color(0xFFE4B69D);
const Color kDarkGreen = Color(0xFF76966B);
const Color kLightGreen = Color(0xFFC3CE98);
const Color kCreme = Color(0xFFF9EEDB);
const Color kCharcoal = Color(0xFF636262);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _habitController = TextEditingController();
  final FocusNode _habitFocusNode = FocusNode();
  String _submittedHabit = '';
  CategoryId? _suggestedCategory;
  CategoryId? _selectedCategory;
  final List<_HabitEntry> _habitEntries = [];
  bool _isProgressBarVisible = false;
  String _selectedDuration = '20m';

  // Removed: _progressController, _progressAnimation, _currentProgressValue

  // Premium iOS-like animation constants
  static const Duration _kMotionDuration = Duration(milliseconds: 650);
  static const Curve _kMotionCurve = Curves.easeOutQuart;

  @override
  void initState() {
    super.initState();
    _isProgressBarVisible = _habitEntries.isNotEmpty;
    _habitFocusNode.addListener(() {
      if (!_habitFocusNode.hasFocus) {
        _updateSuggestedCategoryFromInput();
      }
    });
    // Removed: _progressController/_progressAnimation init
  }

  @override
  void dispose() {
    _habitController.dispose();
    _habitFocusNode.dispose();
    // Removed: _progressController.dispose();
    super.dispose();
  }

  void _updateSuggestedCategoryFromInput() {
    final text = _habitController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _suggestedCategory = null;
        _selectedCategory = null;
      });
      return;
    }

    final category = Classifier.classifyEn(text).category;

    setState(() {
      _suggestedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalHabits = _habitEntries.length;
    final int completedHabits =
        _habitEntries.where((entry) => entry.isDone).length;
    final double targetProgressValue =
        totalHabits == 0 ? 0.0 : completedHabits / totalHabits;
    final String completionPercentage =
        ((totalHabits == 0 ? 0.0 : completedHabits / totalHabits) * 100)
            .toStringAsFixed(0);
    const double bottomPanelHeight = 220;

    // Progress bar animation handled by TweenAnimationBuilder below.

    return Scaffold(
      backgroundColor: Color.lerp(Colors.white, kCreme, 0.2)!,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20)
                        .copyWith(bottom: bottomPanelHeight + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today · ${_formatShortDate(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: kCharcoal,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: kLightGreen.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(80),
                          border: Border.all(
                            color: kDarkGreen.withOpacity(0.85),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '🌱',
                            style: TextStyle(fontSize: 64),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Progress Section with Premium Animation
                    AnimatedCrossFade(
                      duration: _kMotionDuration,
                      firstCurve: _kMotionCurve,
                      secondCurve: _kMotionCurve,
                      sizeCurve: _kMotionCurve,
                      alignment: Alignment.topCenter,
                      crossFadeState: _isProgressBarVisible
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$completedHabits / $totalHabits',
                            style: TextStyle(
                              fontSize: 12,
                              color: kCharcoal.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                        begin: 0, end: targetProgressValue),
                                    duration: _kMotionDuration,
                                    curve: _kMotionCurve,
                                    builder: (context, value, _) {
                                      return LinearProgressIndicator(
                                        value: value,
                                        minHeight: 5,
                                        backgroundColor:
                                            kLightGreen.withOpacity(0.45),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                kDarkGreen),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '$completionPercentage%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kCharcoal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      secondChild: const SizedBox(width: double.infinity),
                    ),
                    AnimatedList(
                      key: _listKey,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      initialItemCount: _habitEntries.length,
                      itemBuilder: (context, index, animation) {
                        final entry = _habitEntries[index];
                        final curvedAnimation = CurvedAnimation(
                          parent: animation,
                          curve: _kMotionCurve,
                        );
                        // Refined Premium Animation:
                        // Uses Scale instead of Slide to avoid clipping artifacts.
                        // Aligns from top (-1.0) for a natural "roll down" effect.
                        return SizeTransition(
                          sizeFactor: curvedAnimation,
                          axisAlignment: -1.0,
                          child: FadeTransition(
                            opacity: curvedAnimation,
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.95, end: 1.0)
                                  .animate(curvedAnimation),
                              child: _buildHabitCard(entry, index),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                decoration: BoxDecoration(
                  color: Color.lerp(Colors.white, kCreme, 0.2)!,
                  border: Border(
                    top: BorderSide(color: kLightGreen.withOpacity(0.35)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _habitController,
                            focusNode: _habitFocusNode,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: "What's your next move?",
                              hintStyle:
                                  TextStyle(color: kCharcoal.withOpacity(0.6)),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                    color: kLightGreen.withOpacity(0.6)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                    color: kLightGreen.withOpacity(0.6)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: kDarkGreen),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            _openDurationSheet();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kCharcoal,
                            side:
                                BorderSide(color: kLightGreen.withOpacity(0.6)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            _selectedDuration,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    if (_suggestedCategory != null) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: _openCategorySheet,
                          child: Chip(
                            label: Text(
                              _categoryLabel(
                                _selectedCategory ?? _suggestedCategory!,
                              ),
                            ),
                            backgroundColor: kLightGreen.withOpacity(0.4),
                            side: BorderSide(
                              color: kDarkGreen.withOpacity(0.8),
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: kDarkGreen.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
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
                          final habitText = _habitController.text.trim();
                          if (habitText.isEmpty) return;

                          final classifiedCategory =
                              Classifier.classifyEn(habitText).category;
                          final finalCategory = _selectedCategory ??
                              _suggestedCategory ??
                              classifiedCategory;

                          // Check if list is currently empty to stagger animation
                          final bool isFirstItem = _habitEntries.isEmpty;

                          setState(() {
                            _submittedHabit = habitText;
                            if (isFirstItem) _isProgressBarVisible = true;
                            _suggestedCategory = classifiedCategory;
                            _selectedCategory = null;

                            _habitEntries.insert(
                              0,
                              _HabitEntry(
                                habitText: habitText,
                                durationText: _selectedDuration,
                                categoryLabel: _categoryLabel(finalCategory),
                                plannedDuration:
                                    _parseDuration(_selectedDuration) ??
                                        const Duration(),
                              ),
                            );

                            // If not first item, insert immediately
                            if (!isFirstItem) {
                              _listKey.currentState?.insertItem(
                                0,
                                duration: _kMotionDuration,
                              );
                            }

                            // Prepare for next entry
                            _suggestedCategory = null;
                            _selectedCategory = null;
                          });

                          // If first item, delay slightly to let progress bar expand first
                          if (isFirstItem) {
                            Future.delayed(const Duration(milliseconds: 300),
                                () {
                              if (mounted) {
                                _listKey.currentState?.insertItem(
                                  0,
                                  duration: _kMotionDuration,
                                );
                              }
                            });
                          }

                          debugPrint('Submitted habit: $habitText');
                          _habitController.clear();
                          FocusScope.of(context).unfocus();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkGreen,
                          foregroundColor: kCreme,
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
            ),
          ],
        ),
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _categoryLabel(CategoryId id) {
    return kCategories.firstWhere((category) => category.id == id).label;
  }

  void _openCategorySheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 8),
              for (final category in kCategories)
                ListTile(
                  title: Text(
                    category.label,
                    style: const TextStyle(fontSize: 15),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.id;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _openDurationSheet() {
    final d = _parseDuration(_selectedDuration) ?? const Duration(minutes: 20);
    int selectedHours = d.inHours;
    int selectedMinutes = d.inMinutes.remainder(60);

    // For wheel scroll controllers
    final List<int> hoursList = [0, 1, 2];
    final List<int> minutesList = [0, 10, 20, 30, 40, 50];
    FixedExtentScrollController? hoursController;
    FixedExtentScrollController? minutesController;

    void applyDuration(int h, int m) {
      final d = Duration(hours: h, minutes: m);
      setState(() {
        _selectedDuration = _formatDurationText(d);
      });
      Navigator.of(context).pop();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        // 0 = Custom, 1 = Presets
        int viewMode = 1;

        return StatefulBuilder(
          builder: (context, setModalState) {
            // Initialize controllers if null (only once per modal session effectively)
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
                          color: kCreme.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _buildSegmentButton(
                              title: 'Custom',
                              isActive: viewMode == 0,
                              onTap: () => setModalState(() => viewMode = 0),
                            ),
                            _buildSegmentButton(
                              title: 'Presets',
                              isActive: viewMode == 1,
                              onTap: () => setModalState(() => viewMode = 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Content Area
                      Expanded(
                        child: GestureDetector(
                          onHorizontalDragEnd: (details) {
                            final velocity = details.primaryVelocity ?? 0;
                            if (velocity < 0) {
                              // Swipe Left (Custom -> Presets)
                              if (viewMode == 0)
                                setModalState(() => viewMode = 1);
                            } else if (velocity > 0) {
                              // Swipe Right (Presets -> Custom)
                              if (viewMode == 1)
                                setModalState(() => viewMode = 0);
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: viewMode == 0
                              // PAGE 1: Custom Wheel
                              ? Column(
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
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: kLightGreen.withOpacity(0.25),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Hours
                                          _buildWheel(
                                            controller: hoursController!,
                                            items: hoursList,
                                            selectedItem: selectedHours,
                                            label: 'h',
                                            onChanged: (val) => setModalState(
                                                () => selectedHours = val),
                                          ),
                                          const SizedBox(width: 24),
                                          // Minutes
                                          _buildWheel(
                                            controller: minutesController!,
                                            items: minutesList,
                                            selectedItem: selectedMinutes,
                                            label: 'm',
                                            onChanged: (val) => setModalState(
                                                () => selectedMinutes = val),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                              // PAGE 2: Presets
                              : SingleChildScrollView(
                              child: Column(
                                children: [
                                  _PomodoroTile(
                                    title: 'Classic Pomodoro',
                                    duration: '25m',
                                    breakTime: '5m break',
                                    icon: Icons.timer_outlined,
                                    onTap: () => applyDuration(0, 25),
                                  ),
                                  _PomodoroTile(
                                    title: 'Deep Work',
                                    duration: '50m',
                                    breakTime: '10m break',
                                    icon: Icons.psychology_outlined,
                                    onTap: () => applyDuration(0, 50),
                                  ),
                                  _PomodoroTile(
                                    title: 'Long Session',
                                    duration: '90m',
                                    breakTime: '15m break',
                                    icon: Icons.coffee_outlined,
                                    onTap: () => applyDuration(1, 30),
                                  ),
                                ],
                              ),
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
                                  applyDuration(selectedHours, selectedMinutes),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kDarkGreen,
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
          },
        );
      },
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
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
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? kDarkGreen : kCharcoal.withOpacity(0.6),
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
                      color:
                          isSelected ? kDarkGreen : kCharcoal.withOpacity(0.3),
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
            color: kCharcoal,
          ),
        ),
      ],
    );
  }

  Duration? _parseDuration(String text) {
    final hourMatch = RegExp(r'(\d+)\s*h').firstMatch(text);
    final minuteMatch = RegExp(r'(\d+)\s*m').firstMatch(text);

    final hours = hourMatch != null ? int.tryParse(hourMatch.group(1)!) : null;
    final minutes =
        minuteMatch != null ? int.tryParse(minuteMatch.group(1)!) : null;

    if (hours == null && minutes == null) {
      return null;
    }

    return Duration(hours: hours ?? 0, minutes: minutes ?? 0);
  }

  String _formatDurationText(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);

    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  Duration _clampDuration(Duration d) {
    const maxDuration = Duration(hours: 2);
    if (d > maxDuration) return maxDuration;
    return d;
  }

  void _openEditHabitSheet(int index) {
    final entry = _habitEntries[index];
    final TextEditingController textController =
        TextEditingController(text: entry.habitText);
    Duration tempDuration = _clampDuration(entry.plannedDuration);
    String formattedDuration = _formatDurationText(tempDuration);

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Habit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: kDarkBrown,
                          tooltip: 'Delete',
                          onPressed: () {
                            final removedEntry = _habitEntries[index];
                            final bool isLastItem = _habitEntries.length == 1;

                            // 1. Remove item visually with a "Swipe Left" style animation.
                            _listKey.currentState?.removeItem(
                              index,
                              (context, animation) {
                                // Phase 1: Slide out to left & Fade (First 60% of time)
                                final slideAnimation = Tween<Offset>(
                                  begin: const Offset(-1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: const Interval(0.4, 1.0,
                                      curve: Curves.easeOutCubic),
                                ));

                                final fadeAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: const Interval(0.4, 1.0,
                                      curve: Curves.easeOut),
                                );

                                // Phase 2: Collapse height (Last 40% of time)
                                final sizeAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: const Interval(0.0, 0.4,
                                      curve: Curves.easeOut),
                                );

                                return SizeTransition(
                                  sizeFactor: sizeAnimation,
                                  axisAlignment: -1.0, // Collapse upwards
                                  child: FadeTransition(
                                    opacity: fadeAnimation,
                                    child: SlideTransition(
                                      position: slideAnimation,
                                      child:
                                          _buildHabitCard(removedEntry, index),
                                    ),
                                  ),
                                );
                              },
                              duration: _kMotionDuration,
                            );

                            // 2. Update data immediately AFTER calling removeItem
                            setState(() {
                              _habitEntries.removeAt(index);
                            });

                            if (isLastItem) {
                              // Wait for the task removal animation to finish before hiding the progress bar.
                              Future.delayed(_kMotionDuration, () {
                                if (mounted && _habitEntries.isEmpty) {
                                  setState(() {
                                    _isProgressBarVisible = false;
                                  });
                                }
                              });
                            }

                            Navigator.of(context).pop();
                            HapticFeedback.lightImpact();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: textController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Edit habit",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: kLightGreen.withOpacity(0.6),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: kLightGreen.withOpacity(0.6),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: kDarkGreen),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 20, color: kDarkGreen),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            Duration tempEditDuration = tempDuration;
                            int tempEditHours =
                                tempEditDuration.inHours.clamp(0, 2);
                            int tempEditMinutes =
                                tempEditDuration.inMinutes.remainder(60);
                            await showCupertinoModalPopup<void>(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setPickerState) {
                                    return SafeArea(
                                        child: CupertinoPopupSurface(
                                      isSurfacePainted: true,
                                      child: Container(
                                        height: 320,
                                        color: CupertinoColors.systemBackground
                                            .resolveFrom(context),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  CupertinoButton(
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  const Text(
                                                    'Duration',
                                                    style: TextStyle(
                                                        color: kDarkGreen,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  CupertinoButton(
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () {
                                                      setModalState(() {
                                                        tempDuration =
                                                            _clampDuration(
                                                                tempEditDuration);
                                                        formattedDuration =
                                                            _formatDurationText(
                                                                tempDuration);
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Done'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 72,
                                                    child: CupertinoPicker(
                                                      itemExtent: 36,
                                                      scrollController:
                                                          FixedExtentScrollController(
                                                              initialItem:
                                                                  tempEditHours),
                                                      onSelectedItemChanged:
                                                          (value) {
                                                        setPickerState(() {
                                                          tempEditHours = value;
                                                          tempEditDuration = Duration(
                                                              hours:
                                                                  tempEditHours,
                                                              minutes:
                                                                  tempEditMinutes);
                                                        });
                                                      },
                                                      children: const [
                                                        Text('0'),
                                                        Text('1'),
                                                        Text('2'),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text('h'),
                                                  const SizedBox(width: 16),
                                                  SizedBox(
                                                    width: 84,
                                                    child: CupertinoPicker(
                                                      itemExtent: 36,
                                                      scrollController:
                                                          FixedExtentScrollController(
                                                              initialItem:
                                                                  tempEditMinutes),
                                                      onSelectedItemChanged:
                                                          (value) {
                                                        setPickerState(() {
                                                          tempEditMinutes =
                                                              value;
                                                          tempEditDuration = Duration(
                                                              hours:
                                                                  tempEditHours,
                                                              minutes:
                                                                  tempEditMinutes);
                                                        });
                                                      },
                                                      children: List.generate(
                                                        60,
                                                        (index) =>
                                                            Text('$index'),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text('mins'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ));
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: kLightGreen.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              formattedDuration,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kDarkGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final newText = textController.text.trim();
                          if (newText.isEmpty) return;
                          setState(() {
                            _habitEntries[index] = entry.copyWith(
                              habitText: newText,
                              plannedDuration: tempDuration,
                              durationText: formattedDuration,
                            );
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkGreen,
                          foregroundColor: kCreme,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHabitCard(_HabitEntry entry, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _habitEntries[index] = entry.copyWith(
            isDone: !entry.isDone,
          );
        });
        HapticFeedback.lightImpact();
      },
      onLongPress: () {
        if (entry.isDone) return;
        HapticFeedback.mediumImpact();
        _openEditHabitSheet(index);
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
            color: kLightGreen.withOpacity(0.45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: kDarkGreen.withOpacity(0.85),
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.habitText,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kCharcoal,
                      decoration: entry.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        entry.durationText,
                        style: TextStyle(
                          fontSize: 12,
                          color: kCharcoal.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.categoryLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: kCharcoal.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (entry.categoryLabel == 'Productivity' && !entry.isDone)
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
                                taskTitle: entry.habitText,
                                plannedDuration:
                                    _parseDuration(entry.durationText) ??
                                        entry.plannedDuration,
                                taskIndex: index,
                              ),
                            ),
                          );

                          if (result != null && result['completed'] == true) {
                            final int completedIndex =
                                result['taskIndex'] as int;

                            setState(() {
                              final existing = _habitEntries[completedIndex];
                              final Duration? updated =
                                  result['updatedDuration'] as Duration?;

                              _habitEntries[completedIndex] = existing.copyWith(
                                isDone: true,
                                plannedDuration:
                                    updated ?? existing.plannedDuration,
                                durationText: updated != null
                                    ? _formatDurationText(updated)
                                    : existing.durationText,
                              );
                            });
                          }
                        },
                        onLongPress: () {},
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: kLightGreen.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: kDarkGreen.withOpacity(0.9),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: 18,
                              color: kDarkGreen,
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

class _HabitEntry {
  final String habitText;
  final String durationText;
  final String categoryLabel;
  final Duration plannedDuration;
  final bool isDone;

  const _HabitEntry({
    required this.habitText,
    required this.durationText,
    required this.categoryLabel,
    required this.plannedDuration,
    this.isDone = false,
  });

  _HabitEntry copyWith({
    String? habitText,
    String? durationText,
    String? categoryLabel,
    Duration? plannedDuration,
    bool? isDone,
  }) {
    return _HabitEntry(
      habitText: habitText ?? this.habitText,
      durationText: durationText ?? this.durationText,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      isDone: isDone ?? this.isDone,
    );
  }
}

class _PomodoroTile extends StatelessWidget {
  final String title;
  final String duration;
  final String breakTime;
  final IconData icon;
  final VoidCallback onTap;

  const _PomodoroTile({
    required this.title,
    required this.duration,
    required this.breakTime,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: kLightGreen.withOpacity(0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: kDarkGreen.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kLightGreen.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: kDarkGreen, size: 20),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: kCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$duration focus · $breakTime',
                    style: TextStyle(
                      fontSize: 13,
                      color: kCharcoal.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                color: kLightGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
