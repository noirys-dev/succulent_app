import 'package:succulent_app/core/classification/category.dart';
import 'package:succulent_app/features/home/domain/entities/habit.dart';

class HabitModel extends Habit {
  const HabitModel({
    required String id,
    required String title,
    required Duration plannedDuration,
    required CategoryId category,
    bool isDone = false,
  }) : super(
          id: id,
          title: title,
          plannedDuration: plannedDuration,
          category: category,
          isDone: isDone,
        );

  factory HabitModel.fromEntity(Habit h) {
    return HabitModel(
      id: h.id,
      title: h.title,
      plannedDuration: h.plannedDuration,
      category: h.category,
      isDone: h.isDone,
    );
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      plannedDuration: Duration(milliseconds: json['plannedDuration'] as int),
      category: CategoryId.values.firstWhere(
          (e) => e.toString() == json['category'].toString()),
      isDone: json['isDone'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'plannedDuration': plannedDuration.inMilliseconds,
        'category': category.toString(),
        'isDone': isDone,
      };
}
