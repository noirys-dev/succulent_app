import 'package:flutter/material.dart';
import 'package:succulent_app/core/optimization/app_performance.dart';
import 'package:succulent_app/core/classification/category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_event.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_state.dart';
import 'package:succulent_app/features/home/presentation/widgets/habit_card.dart';
import 'package:succulent_app/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:succulent_app/features/home/presentation/widgets/home_screen_input_section.dart';
import 'package:succulent_app/features/home/presentation/widgets/home_empty_state.dart';
import 'package:succulent_app/features/home/presentation/widgets/home_sliver_header_delegate.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import 'package:succulent_app/features/home/presentation/widgets/edit_habit_sheet.dart';
import 'home_screen_helpers.dart';
import 'package:succulent_app/features/home/presentation/widgets/duration_picker_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _habitController = TextEditingController();
  final FocusNode _habitFocusNode = FocusNode();
  final String _userName = 'Anita';

  String _selectedDuration = '20m';
  bool _isInputOpen = false;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _habitFocusNode.addListener(() {
      if (!_habitFocusNode.hasFocus) {
        _updateSuggestedCategoryFromInput();
      }
    });
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(const LoadHabits());
    });
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
      context.read<HomeBloc>().add(const ClearCategoryEvent());
      return;
    }
    context.read<HomeBloc>().add(SuggestCategoryEvent(text));
  }

  @override
  Widget build(BuildContext context) {
    const double bottomPanelHeight = 220;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final perf = AppPerformance.of(context);
        final filteredHabits = state.habits
            .where((h) =>
                HomeScreenHelpers.isSameDay(h.createdAt, state.selectedDate))
            .toList();
        final int totalHabits = filteredHabits.length;
        final int completedHabits =
            filteredHabits.where((entry) => entry.isDone).length;

        return Scaffold(
          backgroundColor: Color.lerp(Colors.white, AppColors.creme, 0.2)!,
          body: GestureDetector(
            onTap: () {
              if (_isInputOpen) {
                setState(() => _isInputOpen = false);
                FocusScope.of(context).unfocus();
              }
            },
            child: Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: HomeSliverHeaderDelegate(
                        userName: _userName,
                        completedHabits: completedHabits,
                        totalHabits: totalHabits,
                        streakCount: state.streakCount,
                        focusedTime: state.totalFocusedTime,
                        selectedDate: state.selectedDate,
                        onDateSelected: (date) {
                          context.read<HomeBloc>().add(ChangeDateEvent(date));
                        },
                        topPadding: MediaQuery.of(context).padding.top,
                        isCalendarOpen: state.isCalendarOpen,
                        displayedMonth: state.displayedMonth,
                        completionData: state.monthCompletionData,
                        onToggleCalendar: () {
                          context
                              .read<HomeBloc>()
                              .add(const ToggleCalendarEvent());
                        },
                        onChangeMonth: (month) {
                          context
                              .read<HomeBloc>()
                              .add(ChangeDisplayedMonthEvent(month));
                        },
                      ),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24).copyWith(
                        top: 16,
                        bottom: bottomPanelHeight + 40,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (filteredHabits.isEmpty) {
                              return const HomeEmptyState();
                            }
                            final habit = filteredHabits[index];
                            return HabitCard(
                              key: ValueKey(habit.id),
                              entry: habit,
                              index: state.habits.indexOf(habit),
                              onEdit: () => _openEditHabitSheet(
                                  state.habits.indexOf(habit)),
                            );
                          },
                          childCount: filteredHabits.isEmpty
                              ? 1
                              : filteredHabits.length,
                        ),
                      ),
                    ),
                  ],
                ),
                // Top Blur Area (Only when scrolled)
                if (_isScrolled)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: MediaQuery.of(context).padding.top,
                    child: ClipRect(
                      child: perf.adaptiveBlur(
                        sigmaX: perf.glassSigma,
                        sigmaY: perf.glassSigma,
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                // Bottom Bar with Glassmorphism
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedPadding(
                    duration: perf.mediumDuration,
                    curve: Curves.easeOutQuart,
                    padding: EdgeInsets.only(
                        bottom: _isInputOpen || !_isScrolled
                            ? 30 + bottomPadding
                            : 0),
                    child: ClipRRect(
                      borderRadius: _isInputOpen
                          ? BorderRadius.circular(28)
                          : (_isScrolled
                              ? const BorderRadius.vertical(
                                  top: Radius.circular(24))
                              : BorderRadius.circular(40)),
                      child: perf.adaptiveBlur(
                        sigmaX: perf.glassSigmaLight,
                        sigmaY: perf.glassSigmaLight,
                        child: AnimatedContainer(
                          duration: perf.mediumDuration,
                          curve: _isInputOpen
                              ? Curves.easeOutBack
                              : Curves.easeOutQuart,
                          width: _isInputOpen
                              ? MediaQuery.of(context).size.width - 32
                              : (_isScrolled
                                  ? MediaQuery.of(context).size.width
                                  : 220),
                          height: _isInputOpen
                              ? ((state.suggestedCategory != null ||
                                      state.selectedCategory != null)
                                  ? 220
                                  : 180)
                              : (_isScrolled ? 60 + bottomPadding : 60),
                          decoration: BoxDecoration(
                            color: _isInputOpen
                                ? Color.lerp(
                                        Colors.white, AppColors.creme, 0.4)!
                                    .withValues(alpha: 0.85)
                                : AppColors.darkGreen.withValues(alpha: 0.9),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.darkGreen.withValues(alpha: 0.15),
                                blurRadius: perf.shadowBlurRadius,
                                offset: Offset(0, perf.shadowOffsetY),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            children: [
                              AnimatedOpacity(
                                duration: perf.microDuration,
                                opacity: _isInputOpen ? 0.0 : 1.0,
                                curve: _isInputOpen
                                    ? const Interval(0.0, 0.2,
                                        curve: Curves.easeOut)
                                    : const Interval(0.7, 1.0,
                                        curve: Curves.easeIn),
                                child: IgnorePointer(
                                  ignoring: _isInputOpen,
                                  child: HomeNavBar(
                                    isScrolled: _isScrolled,
                                    onAddTap: () {
                                      context
                                          .read<HomeBloc>()
                                          .add(const ClearCategoryEvent());
                                      setState(() => _isInputOpen = true);
                                      Future.delayed(perf.mediumDuration, () {
                                        if (mounted && _isInputOpen) {
                                          _habitFocusNode.requestFocus();
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ),
                              AnimatedOpacity(
                                duration: perf.mediumDuration,
                                opacity: _isInputOpen ? 1.0 : 0.0,
                                curve: _isInputOpen
                                    ? const Interval(0.6, 1.0,
                                        curve: Curves.easeIn)
                                    : const Interval(0.0, 0.2,
                                        curve: Curves.easeOut),
                                child: IgnorePointer(
                                  ignoring: !_isInputOpen,
                                  child: HomeScreenInputSection(
                                    habitController: _habitController,
                                    habitFocusNode: _habitFocusNode,
                                    selectedDuration: _selectedDuration,
                                    isInputOpen: _isInputOpen,
                                    onToggleInput: () =>
                                        setState(() => _isInputOpen = false),
                                    onDurationChanged: (val) =>
                                        setState(() => _selectedDuration = val),
                                    onOpenDurationPicker: () {
                                      FocusScope.of(context).unfocus();
                                      final d = HomeScreenHelpers.parseDuration(
                                              _selectedDuration) ??
                                          const Duration(minutes: 20);
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (_) => DurationPickerSheet(
                                          initialDuration: d,
                                          onDurationSelected: (val) {
                                            setState(() => _selectedDuration =
                                                HomeScreenHelpers
                                                    .formatDurationText(val));
                                          },
                                        ),
                                      );
                                    },
                                    onOpenCategorySheet: _openCategorySheet,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                    // Update selection via bloc
                    context
                        .read<HomeBloc>()
                        .add(SelectCategoryEvent(category.id));
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

  void _openEditHabitSheet(int index) {
    final entry = context.read<HomeBloc>().state.habits[index];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditHabitSheet(entry: entry, index: index),
    );
  }
}
