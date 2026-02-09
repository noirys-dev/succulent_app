import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../models/task.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends HydratedBloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskState.initial()) {
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  void _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) {
    final updatedTasks = List<Task>.from(state.tasks)..add(event.task);
    emit(state.copyWith(tasks: updatedTasks));
  }

  void _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) {
    final updatedTasks = state.tasks.map((task) {
      return task.id == event.task.id ? event.task : task;
    }).toList();
    emit(state.copyWith(tasks: updatedTasks));
  }

  void _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) {
    final updatedTasks =
        state.tasks.where((task) => task.id != event.taskId).toList();
    emit(state.copyWith(tasks: updatedTasks));
  }

  @override
  TaskState? fromJson(Map<String, dynamic> json) {
    try {
      final tasks = (json['tasks'] as List)
          .map((taskJson) => Task.fromJson(taskJson as Map<String, dynamic>))
          .toList();
      return TaskState(tasks: tasks);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(TaskState state) {
    try {
      return {
        'tasks': state.tasks.map((task) => task.toJson()).toList(),
      };
    } catch (_) {
      return null;
    }
  }
}
