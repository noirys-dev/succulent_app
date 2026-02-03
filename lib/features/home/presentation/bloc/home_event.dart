import 'package:equatable/equatable.dart';
import 'package:succulent_app/core/classification/category.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

class LoadHabits extends HomeEvent {
  const LoadHabits();

  @override
  List<Object?> get props => [];
}

class AddHabitEvent extends HomeEvent {
  final String title;
  final Duration duration;
  final CategoryId category;

  const AddHabitEvent({required this.title, required this.duration, required this.category});

  @override
  List<Object?> get props => [title, duration, category];
}

class RemoveHabitEvent extends HomeEvent {
  final String id;
  const RemoveHabitEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleHabitDoneEvent extends HomeEvent {
  final String id;
  const ToggleHabitDoneEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SuggestCategoryEvent extends HomeEvent {
  final String text;
  const SuggestCategoryEvent(this.text);

  @override
  List<Object?> get props => [text];
}

class SelectCategoryEvent extends HomeEvent {
  final CategoryId category;
  const SelectCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateHabitEvent extends HomeEvent {
  final String id;
  final String? title;
  final Duration? plannedDuration;

  const UpdateHabitEvent({required this.id, this.title, this.plannedDuration});

  @override
  List<Object?> get props => [id, title, plannedDuration];
}
