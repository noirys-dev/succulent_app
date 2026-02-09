import 'package:equatable/equatable.dart';
import 'package:succulent_app/core/classification/category.dart';

class HabitModel extends Equatable {
  final String id;
  final String title;
  final Duration plannedDuration;
  final CategoryId category;
  final bool isDone;
  final DateTime createdAt;

  HabitModel({
    required this.id,
    required this.title,
    required this.plannedDuration,
    required this.category,
    this.isDone = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  HabitModel copyWith({
    String? id,
    String? title,
    Duration? plannedDuration,
    CategoryId? category,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      plannedDuration: plannedDuration ?? this.plannedDuration,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'plannedDuration': plannedDuration.inMilliseconds,
        'category': category.name, // en güvenli saklama yöntemi
        'isDone': isDone,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      plannedDuration: Duration(milliseconds: json['plannedDuration'] as int),
      category: CategoryId.values.byName(json['category'] as String),
      isDone: json['isDone'] as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, title, plannedDuration, category, isDone, createdAt];
}
