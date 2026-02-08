import 'package:equatable/equatable.dart';
// import yollarını kendi klasör yapına göre kontrol etmelisin
import '../../../core/classification/category.dart';
import '../../../core/classification/classifier.dart';
import 'task_category.dart';

class TaskModel extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;
  final CategoryId category; // gerçek hayat (productivity, health vb.)
  final TaskCategory effect; // bitki etkisi (watering, pruning vb.)

  const TaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.category,
    required this.effect,
  });

  /// kullanıcı sadece metin girdiğinde çalışan akıllı yapı
  factory TaskModel.fromUserInput({required String id, required String title}) {
    // classifier.dart içindeki classifyEn metodunu kullanıyoruz
    final result = Classifier.classifyEn(title);
    final detectedCategory = result.category;

    // gerçek hayat kategorisini bitki etkisine eşleyelim (mapping)
    TaskCategory plantForce;
    switch (detectedCategory) {
      case CategoryId.productivity:
        plantForce = TaskCategory.watering;
        break;
      case CategoryId.physicalActivity:
        plantForce = TaskCategory.fertilizing;
        break;
      case CategoryId.chores:
        plantForce = TaskCategory.pruning;
        break;
      case CategoryId.health:
      case CategoryId.social:
        plantForce = TaskCategory.monitoring;
        break;
      default:
        plantForce = TaskCategory.other;
    }

    return TaskModel(
      id: id,
      title: title,
      category: detectedCategory,
      effect: plantForce,
    );
  }

  /// mevcut bir objeyi değiştirmek yerine kopyasını oluşturur
  TaskModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    CategoryId? category,
    TaskCategory? effect,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      effect: effect ?? this.effect,
    );
  }

  /// telefona kaydetmek için json formatına çevirir
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
        'category': category.name,
        'effect': effect.name,
      };

  /// telefondan okunan json'ı tekrar objeye çevirir
  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'],
        title: json['title'],
        isCompleted: json['isCompleted'],
        category: CategoryId.values.byName(json['category']),
        effect: TaskCategory.values.byName(json['effect']),
      );

  @override
  List<Object?> get props => [id, title, isCompleted, category, effect];
}
