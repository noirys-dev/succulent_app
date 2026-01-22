import 'task_category.dart';

class Task {
  final String id;
  final String succulentId;
  final TaskCategory category;
  final String title;
  final String? description;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.succulentId,
    required this.category,
    required this.title,
    this.description,
    required this.scheduledDate,
    this.completedDate,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? succulentId,
    TaskCategory? category,
    String? title,
    String? description,
    DateTime? scheduledDate,
    DateTime? completedDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      succulentId: succulentId ?? this.succulentId,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'succulentId': succulentId,
      'category': category.toJson(),
      'title': title,
      'description': description,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      succulentId: json['succulentId'] as String,
      category: TaskCategory.fromJson(json['category'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Task(id: $id, title: $title, category: $category, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
