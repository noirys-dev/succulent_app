import 'package:equatable/equatable.dart';
import 'package:succulent_app/core/classification/category.dart';

class Habit extends Equatable {
  final String id;
  final String title;
  final Duration plannedDuration;
  final CategoryId category;
  final bool isDone;

  const Habit({
    required this.id,
    required this.title,
    required this.plannedDuration,
    required this.category,
    this.isDone = false,
  });

  Habit copyWith({
    String? id,
    String? title,
    Duration? plannedDuration,
    CategoryId? category,
    bool? isDone,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
    );
  }

  @override
  List<Object?> get props => [id, title, plannedDuration, category, isDone];
}
