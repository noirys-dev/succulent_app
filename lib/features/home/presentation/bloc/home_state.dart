import 'package:equatable/equatable.dart';
import 'package:succulent_app/core/classification/category.dart';
import 'package:succulent_app/features/home/data/models/habit_model.dart';

class HomeState extends Equatable {
  final List<HabitModel> habits; // Habit yerine HabitModel
  final CategoryId? suggestedCategory;
  final CategoryId? selectedCategory;
  final DateTime selectedDate;

  HomeState({
    this.habits = const [],
    this.suggestedCategory,
    this.selectedCategory,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  HomeState copyWith({
    List<HabitModel>? habits,
    CategoryId? suggestedCategory,
    CategoryId? selectedCategory,
    DateTime? selectedDate,
  }) {
    return HomeState(
      habits: habits ?? this.habits,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  int get streakCount {
    if (habits.isEmpty) return 0;

    // Group dates that have at least one completed habit
    final completedDates = habits
        .where((h) => h.isDone)
        .map((h) =>
            DateTime(h.createdAt.year, h.createdAt.month, h.createdAt.day))
        .toSet()
        .toList();

    if (completedDates.isEmpty) return 0;

    // Sort dates descending
    completedDates.sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    // Check if the streak is still alive (completed today or yesterday)
    final latestDate = completedDates.first;
    if (latestDate.isBefore(yesterdayDate)) {
      return 0;
    }

    int streak = 0;
    DateTime nextDateExpected = latestDate;

    for (final date in completedDates) {
      if (date == nextDateExpected) {
        streak++;
        nextDateExpected = date.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Duration get totalFocusedTime {
    final completedToday = habits.where((h) =>
        h.isDone &&
        h.createdAt.year == selectedDate.year &&
        h.createdAt.month == selectedDate.month &&
        h.createdAt.day == selectedDate.day);

    return completedToday.fold(
        Duration.zero, (total, h) => total + h.plannedDuration);
  }

  @override
  List<Object?> get props =>
      [habits, suggestedCategory, selectedCategory, selectedDate];

  Map<String, dynamic> toJson() {
    return {
      'habits': habits.map((x) => x.toJson()).toList(), // toMap yerine toJson
      'suggestedCategory': suggestedCategory?.name, // index yerine name
      'selectedCategory': selectedCategory?.name,
      'selectedDate': selectedDate.toIso8601String(),
    };
  }

  factory HomeState.fromJson(Map<String, dynamic> json) {
    final habitsList = (json['habits'] as List<dynamic>?)
            ?.map(
              (x) => HabitModel.fromJson(x as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return HomeState(
      habits: habitsList,
      suggestedCategory: json['suggestedCategory'] != null
          ? CategoryId.values.byName(json['suggestedCategory'])
          : null,
      selectedCategory: json['selectedCategory'] != null
          ? CategoryId.values.byName(json['selectedCategory'])
          : null,
      selectedDate: json['selectedDate'] != null
          ? DateTime.parse(json['selectedDate'] as String)
          : DateTime.now(),
    );
  }
}
