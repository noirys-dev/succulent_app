import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; // BackdropFilter için gerekli
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
  // Placeholder for user name (Authentication to be added later)
  final String _userName = 'Anita';
  CategoryId? _suggestedCategory;
  CategoryId? _selectedCategory;
  final List<_HabitEntry> _habitEntries = [];
  bool _isProgressBarVisible = false;
  String _selectedDuration = '20m';
  bool _isInputOpen = false;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

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
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _habitController.dispose();
    _habitFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final isScrolled = _scrollController.offset > 20;
      if (isScrolled != _isScrolled) {
        setState(() {
          _isScrolled = isScrolled;
        });
      }
    }
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
    final Color backgroundColor = Color.lerp(Colors.white, kCreme, 0.2)!;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onTap: () {
          if (_isInputOpen) {
            setState(() => _isInputOpen = false);
            FocusScope.of(context).unfocus();
          }
        },
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20)
                        .copyWith(bottom: bottomPanelHeight + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hello, $_userName!',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: kDarkGreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Today · ${_formatShortDate(DateTime.now())}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: kCharcoal,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
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
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutQuart,
                padding: EdgeInsets.only(
                    bottom:
                        _isInputOpen || !_isScrolled ? 30 + bottomPadding : 0),
                child: RepaintBoundary(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve:
                        _isInputOpen ? Curves.easeOutBack : Curves.easeOutQuart,
                    width: _isInputOpen
                        ? MediaQuery.of(context).size.width - 32
                        : (_isScrolled
                            ? MediaQuery.of(context).size.width
                            : 220),
                    height: _isInputOpen
                        ? (_suggestedCategory != null ? 220 : 180)
                        : (_isScrolled ? 40 + bottomPadding : 60),
                    decoration: BoxDecoration(
                      color: _isInputOpen
                          ? Color.lerp(Colors.white,
                              const Color.fromARGB(0, 249, 238, 219), 0.2)!
                          : kDarkGreen,
                      borderRadius: _isInputOpen
                          ? BorderRadius.circular(28)
                          : (_isScrolled
                              ? const BorderRadius.vertical(
                                  top: Radius.circular(24))
                              : BorderRadius.circular(40)),
                      boxShadow: [
                        BoxShadow(
                          color: kDarkGreen.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        // Navigator ikonları
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isInputOpen ? 0.0 : 1.0,
                          curve: _isInputOpen
                              ? const Interval(0.0, 0.2, curve: Curves.easeOut)
                              : const Interval(0.7, 1.0, curve: Curves.easeIn),
                          child: IgnorePointer(
                            ignoring: _isInputOpen,
                            child: _buildNavBarIcons(),
                          ),
                        ),
                        // Input panel
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: _isInputOpen ? 1.0 : 0.0,
                          curve: _isInputOpen
                              ? const Interval(0.6, 1.0, curve: Curves.easeIn)
                              : const Interval(0.0, 0.2, curve: Curves.easeOut),
                          child: IgnorePointer(
                            ignoring: !_isInputOpen,
                            child: _buildInputPanel(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBarIcons() {
    final double otherIconSize = _isScrolled ? 34 : 28;

    return Container(
      width: double.infinity,
      height: double.infinity,
      // Arka plan rengini kaldırdık çünkü artık ana container rengi var
      color: Colors.transparent,
      alignment: Alignment.center,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon:
                  Icon(Icons.home_rounded, color: kCreme, size: otherIconSize),
              tooltip: 'Home',
            ),
            GestureDetector(
              onTap: () {
                setState(() => _isInputOpen = true);
                // Container açılması bitince focus iste
                Future.delayed(const Duration(milliseconds: 550), () {
                  if (mounted && _isInputOpen) {
                    _habitFocusNode.requestFocus();
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kCreme,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: const Icon(Icons.add, color: kDarkGreen, size: 28),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.person_outline_rounded,
                  color: kCreme, size: otherIconSize),
              tooltip: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPanel() {
    return Container(
      // Arka plan rengini kaldırdık çünkü artık ana container rengi var
      color: Colors.transparent,
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
                        hintStyle: TextStyle(color: kCharcoal.withOpacity(0.6)),
                        filled: true,
                        fillColor: kCreme.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: kLightGreen.withOpacity(0.6)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: kLightGreen.withOpacity(0.6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: kDarkGreen),
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
                      side: BorderSide(color: kLightGreen.withOpacity(0.6)),
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
                const SizedBox(height: 8),
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
                    final habitText = _habitController.text.trim();
                    if (habitText.isEmpty) return;

                    final classifiedCategory =
                        Classifier.classifyEn(habitText).category;
                    final finalCategory = _selectedCategory ??
                        _suggestedCategory ??
                        classifiedCategory;

                    final bool isFirstItem = _habitEntries.isEmpty;

                    setState(() {
                      _submittedHabit = habitText;
                      if (isFirstItem) _isProgressBarVisible = true;
                      _suggestedCategory = classifiedCategory;
                      _selectedCategory = null;
                      _isInputOpen = false;

                      _habitEntries.insert(
                        0,
                        _HabitEntry(
                          habitText: habitText,
                          durationText: _selectedDuration,
                          categoryLabel: _categoryLabel(finalCategory),
                          plannedDuration: _parseDuration(_selectedDuration) ??
                              const Duration(),
                        ),
                      );

                      if (!isFirstItem) {
                        _listKey.currentState?.insertItem(
                          0,
                          duration: _kMotionDuration,
                        );
                      }

                      _suggestedCategory = null;
                      _selectedCategory = null;
                    });

                    if (isFirstItem) {
                      Future.delayed(const Duration(milliseconds: 300), () {
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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kCharcoal,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kCategories.map((category) {
                  final isSelected =
                      (_selectedCategory ?? _suggestedCategory) == category.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategory = category.id);
                      Navigator.pop(context);
                    },
                    child: Chip(
                      label: Text(category.label),
                      backgroundColor: isSelected
                          ? kDarkGreen
                          : kLightGreen.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: isSelected ? kCreme : kCharcoal,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? kDarkGreen
                            : kLightGreen.withOpacity(0.6),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _openDurationSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Duration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kCharcoal,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  '5m',
                  '10m',
                  '15m',
                  '20m',
                  '25m',
                  '30m',
                  '45m',
                  '1h',
                  '2h'
                ].map((duration) {
                  final isSelected = _selectedDuration == duration;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedDuration = duration);
                      Navigator.pop(context);
                    },
                    child: Chip(
                      label: Text(duration),
                      backgroundColor: isSelected
                          ? kDarkGreen
                          : kLightGreen.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: isSelected ? kCreme : kCharcoal,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? kDarkGreen
                            : kLightGreen.withOpacity(0.6),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Duration? _parseDuration(String durationText) {
    final trimmed = durationText.trim().toLowerCase();
    if (trimmed.endsWith('m')) {
      final minutes = int.tryParse(trimmed.substring(0, trimmed.length - 1));
      if (minutes != null) return Duration(minutes: minutes);
    } else if (trimmed.endsWith('h')) {
      final hours = int.tryParse(trimmed.substring(0, trimmed.length - 1));
      if (hours != null) return Duration(hours: hours);
    }
    return null;
  }

  String _formatDurationText(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  Widget _buildHabitCard(_HabitEntry entry, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              final existing = _habitEntries[index];
              _habitEntries[index] =
                  existing.copyWith(isDone: !existing.isDone);
            });
            HapticFeedback.mediumImpact();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color:
                  entry.isDone ? kLightGreen.withOpacity(0.15) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: entry.isDone
                    ? kDarkGreen.withOpacity(0.4)
                    : kLightGreen.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: entry.isDone
                  ? []
                  : [
                      BoxShadow(
                        color: kDarkGreen.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Column(
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

                                _habitEntries[completedIndex] =
                                    existing.copyWith(
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
