import 'package:equatable/equatable.dart';
import 'package:succulent_app/core/classification/category.dart';
import 'package:succulent_app/features/home/data/models/habit_model.dart';

class HomeState extends Equatable {
  final List<HabitModel> habits; // Habit yerine HabitModel
  final CategoryId? suggestedCategory;
  final CategoryId? selectedCategory;

  const HomeState({
    this.habits = const [],
    this.suggestedCategory,
    this.selectedCategory,
  });

  HomeState copyWith({
    List<HabitModel>? habits,
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

  Map<String, dynamic> toJson() {
    return {
      'habits': habits.map((x) => x.toJson()).toList(), // toMap yerine toJson
      'suggestedCategory': suggestedCategory?.name, // index yerine name
      'selectedCategory': selectedCategory?.name,
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
    );
  }
}
