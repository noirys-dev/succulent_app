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

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _habitController = TextEditingController();
  final FocusNode _habitFocusNode = FocusNode();
  String _submittedHabit = '';
  CategoryId? _suggestedCategory;
  CategoryId? _selectedCategory;
  final List<_HabitEntry> _habitEntries = [];
  String _selectedDuration = '1h 30m';

  @override
  void initState() {
    super.initState();
    _habitFocusNode.addListener(() {
      if (!_habitFocusNode.hasFocus) {
        _updateSuggestedCategoryFromInput();
      }
    });
  }

  @override
  void dispose() {
    _habitController.dispose();
    _habitFocusNode.dispose();
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
    final double progressValue =
        totalHabits == 0 ? 0.0 : completedHabits / totalHabits;
    final String completionPercentage =
        (progressValue * 100).toStringAsFixed(0);
    const double bottomPanelHeight = 220;

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
                      style: TextStyle(
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
                    if (totalHabits > 0) ...[
                      Text(
                        '$completedHabits / $totalHabits',
                        style: TextStyle(
                          fontSize: 12,
                          color: kCharcoal.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 5,
                              backgroundColor: kLightGreen.withOpacity(0.5),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                kDarkGreen,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$completionPercentage%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kCharcoal,
                          ),
                        ),
                      ],
                    ),
                    if (_habitEntries.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Column(
                        children: _habitEntries.asMap().entries.map(
                          (entryItem) {
                            final index = entryItem.key;
                            final entry = entryItem.value;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _habitEntries[index] = entry.copyWith(
                                    isDone: !entry.isDone,
                                  );
                                });
                                HapticFeedback.lightImpact();
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  color: kCharcoal
                                                      .withOpacity(0.8),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                entry.categoryLabel,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: kCharcoal
                                                      .withOpacity(0.8),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (entry.categoryLabel == 'Productivity')
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: GestureDetector(
                                            onTap: () async {
                                              final result =
                                                  await Navigator.of(context)
                                                      .push(
                                                MaterialPageRoute(
                                                  builder: (_) => FocusScreen(
                                                    taskTitle: entry.habitText,
                                                    plannedDuration:
                                                        _parseDuration(entry
                                                                .durationText) ??
                                                            entry
                                                                .plannedDuration,
                                                    category: 'Productivity',
                                                  ),
                                                ),
                                              );

                                              if (!mounted) return;

                                              if (result is Map &&
                                                  result['completed'] == true) {
                                                final updated =
                                                    result['updatedDuration'];

                                                if (updated is Duration) {
                                                  setState(() {
                                                    _habitEntries[index] =
                                                        entry.copyWith(
                                                      plannedDuration: updated,
                                                      durationText:
                                                          _formatDurationText(
                                                              updated),
                                                    );
                                                  });
                                                }
                                              }
                                            },
                                            child: Icon(
                                              Icons.play_circle_outline,
                                              size: 20,
                                              color:
                                                  kDarkGreen.withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ],
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
                      const SizedBox(height: 10),
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

                          setState(() {
                            _submittedHabit = habitText;
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

                            // Prepare for next entry
                            _suggestedCategory = null;
                            _selectedCategory = null;
                          });

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
    int tempHours = 0;
    int tempMinutes = 30;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Duration',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _NumberPicker(
                          value: tempHours,
                          max: 12,
                          label: 'h',
                          onChanged: (v) {
                            setModalState(() => tempHours = v);
                          },
                        ),
                        const SizedBox(width: 16),
                        _NumberPicker(
                          value: tempMinutes,
                          max: 59,
                          label: 'm',
                          onChanged: (v) {
                            setModalState(() => tempMinutes = v);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDuration = '${tempHours}h ${tempMinutes}m';
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
                      child: const Text('Set Duration'),
                    ),
                  ],
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
}

class _NumberPicker extends StatelessWidget {
  final int value;
  final int max;
  final String label;
  final ValueChanged<int> onChanged;

  const _NumberPicker({
    required this.value,
    required this.max,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
        Text(
          '$value$label',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
        ),
      ],
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
