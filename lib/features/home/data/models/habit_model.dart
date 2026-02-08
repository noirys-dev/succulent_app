import 'package:equatable/equatable.dart';
import 'package:succulent_app/core/classification/category.dart';

class HabitModel extends Equatable {
  final String id;
  final String title;
  final Duration plannedDuration;
  final CategoryId category;
  final bool isDone;

  const HabitModel({
    required this.id,
    required this.title,
    required this.plannedDuration,
    required this.category,
    this.isDone = false,
  });

  HabitModel copyWith({
    String? id,
    String? title,
    Duration? plannedDuration,
    CategoryId? category,
    bool? isDone,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'plannedDuration': plannedDuration.inMilliseconds,
        'category': category.name, // en güvenli saklama yöntemi
        'isDone': isDone,
      };

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      plannedDuration: Duration(milliseconds: json['plannedDuration'] as int),
      category: CategoryId.values.byName(json['category'] as String),
      isDone: json['isDone'] as bool,
    );
  }

  @override
  List<Object?> get props => [id, title, plannedDuration, category, isDone];
}
