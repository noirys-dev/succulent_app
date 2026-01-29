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
  String _selectedDuration = '0m';

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
    int selectedHours = 0;
    int selectedMinutes = 0;

    final PageController pageController = PageController();

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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Controllers must be rebuilt with correct initialItem on show
            hoursController = FixedExtentScrollController(
                initialItem: hoursList.indexOf(selectedHours));
            minutesController = FixedExtentScrollController(
                initialItem: minutesList.indexOf(0));
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
                child: SizedBox(
                  height: 220,
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const Text(
                            'Duration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                applyDuration(selectedHours, selectedMinutes),
                            child: const Text('Done'),
                          ),
                        ],
                      ),

                      Expanded(
                        child: PageView(
                          controller: pageController,
                          children: [
                            // PAGE 1 — Custom Duration (Wheel pickers)
                            // --- WHEEL PICKER: NEW HORIZONTAL LAYOUT ---
                            Center(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                height: 118,
                                decoration: BoxDecoration(
                                  // Remove color for transparency
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        height: 40,
                                        width: 220,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withOpacity(0.85),
                                              Colors.white.withOpacity(0.65),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: kDarkGreen.withOpacity(0.18),
                                            width: 0.8,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.04),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // HOURS WHEEL
                                        SizedBox(
                                          width: 36,
                                          child:
                                              ListWheelScrollView.useDelegate(
                                            controller: hoursController,
                                            itemExtent: 40,
                                            physics:
                                                const FixedExtentScrollPhysics(),
                                            onSelectedItemChanged: (index) {
                                              setModalState(() {
                                                selectedHours =
                                                    hoursList[index];
                                              });
                                            },
                                            childDelegate:
                                                ListWheelChildBuilderDelegate(
                                              childCount: hoursList.length,
                                              builder: (context, index) {
                                                final h = hoursList[index];
                                                final isSelected =
                                                    selectedHours == h;
                                                return Center(
                                                  child: Text(
                                                    '$h',
                                                    style: TextStyle(
                                                      fontSize:
                                                          isSelected ? 20 : 14,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                      color: isSelected
                                                          ? kDarkGreen
                                                          : kCharcoal
                                                              .withOpacity(
                                                                  0.45),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        // CENTER 'hours' LABEL
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: const Center(
                                            child: Text(
                                              'hours',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: kCharcoal,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // MINUTES WHEEL
                                        SizedBox(
                                          width: 56,
                                          child:
                                              ListWheelScrollView.useDelegate(
                                            controller: minutesController,
                                            itemExtent: 40,
                                            physics:
                                                const FixedExtentScrollPhysics(),
                                            onSelectedItemChanged: (index) {
                                              setModalState(() {
                                                selectedMinutes =
                                                    minutesList[index];
                                              });
                                            },
                                            childDelegate:
                                                ListWheelChildBuilderDelegate(
                                              childCount: minutesList.length,
                                              builder: (context, index) {
                                                final m = minutesList[index];
                                                final isSelected =
                                                    selectedMinutes == m;
                                                return Center(
                                                  child: Text(
                                                    '$m',
                                                    style: TextStyle(
                                                      fontSize:
                                                          isSelected ? 20 : 14,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                      color: isSelected
                                                          ? kDarkGreen
                                                          : kCharcoal
                                                              .withOpacity(
                                                                  0.45),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        // 'mins' LABEL
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Text(
                                            'mins',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: kCharcoal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // PAGE 2 — Pomodoro Presets
                            SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pomodoro',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: kCharcoal,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _PomodoroTile(
                                    title: '25 / 5',
                                    subtitle: 'Classic focus',
                                    onTap: () => applyDuration(0, 25),
                                  ),
                                  _PomodoroTile(
                                    title: '50 / 10',
                                    subtitle: 'Deep focus',
                                    onTap: () => applyDuration(0, 50),
                                  ),
                                  _PomodoroTile(
                                    title: '90 / 15',
                                    subtitle: 'Extended session',
                                    onTap: () => applyDuration(1, 30),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Removed: Swipe for Pomodoro presets hint
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
  final String subtitle;
  final VoidCallback onTap;

  const _PomodoroTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: kLightGreen.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: kDarkGreen.withOpacity(0.8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right,
                color: kDarkGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
