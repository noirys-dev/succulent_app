part of 'task_bloc.dart';

class TaskState {
  final List<Task> tasks;

  TaskState({required this.tasks});

  factory TaskState.initial() {
    return TaskState(tasks: []);
  }

  TaskState copyWith({List<Task>? tasks}) {
    return TaskState(
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskState &&
        other.tasks.length == tasks.length &&
        other.tasks.every((task) => tasks.contains(task));
  }

  @override
  int get hashCode => tasks.hashCode;
}
