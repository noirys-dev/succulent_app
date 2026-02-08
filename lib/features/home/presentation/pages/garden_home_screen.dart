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

class GardenHomeScreen extends StatefulWidget {
  const GardenHomeScreen({super.key});

  @override
  State<GardenHomeScreen> createState() => _GardenHomeScreenState();
}

class _GardenHomeScreenState extends State<GardenHomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final TextEditingController _habitController = TextEditingController();
  final FocusNode _habitFocusNode = FocusNode();

  // State variables
  final String _submittedHabit = '';
  final String _userName = 'Anita';
  CategoryId? _suggestedCategory;
  CategoryId? _selectedCategory;
  final List<_HabitEntry> _habitEntries = [];
  final String _selectedDuration = '20m';
  bool _isInputOpen = false;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Animation constants
  static const Duration _kMotionDuration = Duration(milliseconds: 650);
  static const Curve _kMotionCurve = Curves.easeOutQuart;

  @override
  void initState() {
    super.initState();
    _habitFocusNode.addListener(() {
      if (!_habitFocusNode.hasFocus) {
        _updateSuggestedCategoryFromInput();
      }
    });
    _scrollController.addListener(_onScroll);

    // Demo data for visualization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addDemoData();
    });
  }

  double get _plantGrowth {
    if (_habitEntries.isEmpty) return 0.0;
    final completed = _habitEntries.where((e) => e.isDone).length;
    return completed / _habitEntries.length;
  }

  String get _plantStatus {
    final growth = _plantGrowth;
    if (_habitEntries.isEmpty) return "Ready to grow";
    if (growth == 0) return "Needs water";
    if (growth < 0.5) return "Growing";
    if (growth < 1.0) return "Thriving";
    return "In full bloom!";
  }

  Duration get _totalFocusTime {
    return _habitEntries
        .where((e) => e.isDone)
        .fold(Duration.zero, (prev, e) => prev + e.plannedDuration);
  }

  String _formatFocusTime(Duration duration) {
    if (duration.inMinutes == 0) return "0m";
    if (duration.inHours > 0) {
      final minutes = duration.inMinutes % 60;
      if (minutes == 0) return '${duration.inHours}h';
      return '${duration.inHours}h ${minutes}m';
    }
    return '${duration.inMinutes}m';
  }

  void _addDemoData() {
    final demoTasks = [
      const _HabitEntry(
        habitText: "Read 10 pages of Stoicism",
        durationText: "20m",
        categoryLabel: "Self Care",
        plannedDuration: Duration(minutes: 20),
        isDone: true,
      ),
      const _HabitEntry(
        habitText: "Deep work on Flutter project",
        durationText: "45m",
        categoryLabel: "Productivity",
        plannedDuration: Duration(minutes: 45),
        isDone: false,
      ),
    ];

    for (var task in demoTasks) {
      _habitEntries.add(task);
      _listKey.currentState?.insertItem(_habitEntries.length - 1);
    }
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
    const double bottomPanelHeight = 220;
    final Color backgroundColor = Color.lerp(Colors.white, kCreme, 0.2)!;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double plantScale = 0.8 + (_plantGrowth * 0.4); // Range 0.8 to 1.2

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
                    // --- HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatShortDate(DateTime.now()),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kCharcoal.withOpacity(0.6),
                                letterSpacing: 0.5,
                                textBaseline: TextBaseline.alphabetic,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'My Garden',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: kDarkGreen,
                                letterSpacing: -0.5,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: kLightGreen.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: kDarkGreen.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(Icons.person, color: kDarkGreen),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- HERO SECTION (The Plant) ---
                    Container(
                      width: double.infinity,
                      height: 250,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            kLightGreen.withOpacity(0.2),
                            kLightGreen.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 40,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Progress Ring
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                      begin: 0, end: _plantGrowth),
                                  duration: _kMotionDuration,
                                  curve: _kMotionCurve,
                                  builder: (context, value, _) {
                                    return SizedBox(
                                      width: 160,
                                      height: 160,
                                      child: CircularProgressIndicator(
                                        value: value,
                                        strokeWidth: 8,
                                        backgroundColor:
                                            kLightGreen.withOpacity(0.2),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                kDarkGreen),
                                        strokeCap: StrokeCap.round,
                                      ),
                                    );
                                  },
                                ),
                                // Glow effect
                                AnimatedContainer(
                                  duration: _kMotionDuration,
                                  curve: _kMotionCurve,
                                  width: 100 + (_plantGrowth * 50),
                                  height: 100 + (_plantGrowth * 50),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kLightGreen.withOpacity(0.3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kLightGreen.withOpacity(
                                            0.3 + (_plantGrowth * 0.2)),
                                        blurRadius: 40 + (_plantGrowth * 30),
                                        spreadRadius: 10 + (_plantGrowth * 10),
                                      ),
                                    ],
                                  ),
                                ),
                                // The Plant
                                AnimatedScale(
                                  scale: plantScale,
                                  duration: _kMotionDuration,
                                  curve: Curves.elasticOut,
                                  child: const Text(
                                    '🪴',
                                    style: TextStyle(fontSize: 80),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Status Text
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                      opacity: animation, child: child),
                              child: Text(
                                _plantStatus,
                                key: ValueKey<String>(_plantStatus),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: kDarkGreen.withOpacity(0.9),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- BENTO GRID (Stats) ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildBentoCard(
                            title: "Focus Time",
                            value: _formatFocusTime(_totalFocusTime),
                            icon: Icons.timer_outlined,
                            color: kDarkBrown,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildBentoCard(
                            title: "Streak",
                            value: "5 Days",
                            icon: Icons.local_fire_department_outlined,
                            color: const Color(0xFFD97D54), // Burnt orange
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // --- TASK LIST HEADER ---
                    Text(
                      "Today's Growth",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kCharcoal.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- TASK LIST ---
                    AnimatedList(
                      key: _listKey,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      initialItemCount: _habitEntries.length,
                      itemBuilder: (context, index, animation) {
                        // Sort logic visual only: In a real app, sort the list data structure.
                        // Here we just render what we have.
                        final entry = _habitEntries[index];
                        return _buildAnimatedHabitItem(entry, index, animation);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // --- DYNAMIC NAVIGATOR ---
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
                        : (_isScrolled ? 60 + bottomPadding : 60),
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
                        // Navigator Icons
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
                        // Input Panel
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

  Widget _buildBentoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.withOpacity(0.8), size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kCharcoal,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: kCharcoal.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHabitItem(
      _HabitEntry entry, int index, Animation<double> animation) {
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
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
          child: _buildHabitCard(entry, index),
        ),
      ),
    );
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
            child: Row(
              children: [
                // Checkbox / Status Indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.isDone ? kDarkGreen : Colors.transparent,
                    border: Border.all(
                      color: entry.isDone ? kDarkGreen : kLightGreen,
                      width: 2,
                    ),
                  ),
                  child: entry.isDone
                      ? const Icon(Icons.check, size: 16, color: kCreme)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.habitText,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: entry.isDone
                              ? kCharcoal.withOpacity(0.5)
                              : kCharcoal,
                          decoration: entry.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (!entry.isDone) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 12, color: kCharcoal.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text(
                              entry.durationText,
                              style: TextStyle(
                                fontSize: 12,
                                color: kCharcoal.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (!entry.isDone)
                  IconButton(
                    icon: const Icon(Icons.play_circle_fill_rounded),
                    color: kDarkGreen,
                    iconSize: 32,
                    onPressed: () {
                      // Navigate to Focus Screen
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarIcons() {
    final double otherIconSize = _isScrolled ? 34 : 28;
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.grid_view_rounded,
                  color: kCreme, size: otherIconSize),
              tooltip: 'Garden',
            ),
            GestureDetector(
              onTap: () {
                setState(() => _isInputOpen = true);
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
              icon: Icon(Icons.bar_chart_rounded,
                  color: kCreme, size: otherIconSize),
              tooltip: 'Stats',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPanel() {
    // Reusing the exact same input panel logic from HomeScreen
    // For brevity in this test file, I'll implement a simplified version
    // that allows adding tasks to the list.
    return Container(
      color: Colors.transparent,
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _habitController,
              focusNode: _habitFocusNode,
              decoration: InputDecoration(
                hintText: "Plant a new seed...",
                filled: true,
                fillColor: kCreme.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final text = _habitController.text.trim();
                if (text.isNotEmpty) {
                  final newEntry = _HabitEntry(
                    habitText: text,
                    durationText: "20m", // Default for test
                    categoryLabel: "General",
                    plannedDuration: const Duration(minutes: 20),
                  );
                  setState(() {
                    _habitEntries.insert(0, newEntry);
                    _listKey.currentState?.insertItem(0);
                    _habitController.clear();
                    _isInputOpen = false;
                    FocusScope.of(context).unfocus();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkGreen,
                foregroundColor: kCreme,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text("Plant Task"),
            )
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
}

// Helper class reused locally for this test file
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
