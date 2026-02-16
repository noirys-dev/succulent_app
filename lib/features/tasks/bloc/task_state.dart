part of 'task_bloc.dart';

class TaskState extends Equatable {
  final List<Task> tasks;

  const TaskState({required this.tasks});

  factory TaskState.initial() {
    return const TaskState(tasks: []);
  }

  TaskState copyWith({List<Task>? tasks}) {
    return TaskState(
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object> get props => [tasks];
}
