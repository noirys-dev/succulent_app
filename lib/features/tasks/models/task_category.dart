enum TaskCategory {
  watering,
  fertilizing,
  repotting,
  pruning,
  monitoring,
  other;

  String get displayName {
    switch (this) {
      case TaskCategory.watering:
        return 'Watering';
      case TaskCategory.fertilizing:
        return 'Fertilizing';
      case TaskCategory.repotting:
        return 'Repotting';
      case TaskCategory.pruning:
        return 'Pruning';
      case TaskCategory.monitoring:
        return 'Monitoring';
      case TaskCategory.other:
        return 'Other';
    }
  }

  String toJson() => name;

  static TaskCategory fromJson(String json) {
    return TaskCategory.values.firstWhere(
      (category) => category.name == json,
      orElse: () => TaskCategory.other,
    );
  }
}
