import 'package:equatable/equatable.dart';
import 'package:succulent_app/core/classification/category.dart';
import 'package:succulent_app/features/home/domain/entities/habit.dart';

class HomeState extends Equatable {
  final List<Habit> habits;
  final CategoryId? suggestedCategory;
  final CategoryId? selectedCategory;

  const HomeState({
    this.habits = const [],
    this.suggestedCategory,
    this.selectedCategory,
  });

  HomeState copyWith({
    List<Habit>? habits,
    CategoryId? suggestedCategory,
    CategoryId? selectedCategory,
  }) {
    return HomeState(
      habits: habits ?? this.habits,
      suggestedCategory: suggestedCategory ?? this.suggestedCategory,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [habits, suggestedCategory, selectedCategory];
}
