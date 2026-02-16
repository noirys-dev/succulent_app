import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:succulent_app/features/tasks/bloc/task_bloc.dart';
import 'package:succulent_app/features/tasks/models/task.dart';
import 'package:succulent_app/features/tasks/models/task_category.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  late Storage storage;

  setUp(() {
    storage = MockStorage();
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
  });

  group('TaskBloc', () {
    late TaskBloc taskBloc;

    setUp(() {
      taskBloc = TaskBloc();
    });

    tearDown(() {
      taskBloc.close();
    });

    test('initial state is correct', () {
      expect(taskBloc.state, TaskState.initial());
    });

    final task1 = Task(
      id: '1',
      succulentId: 's1',
      category: TaskCategory.watering,
      title: 'Task 1',
      scheduledDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final task2 = Task(
      id: '2',
      succulentId: 's1',
      category: TaskCategory.fertilizing,
      title: 'Task 2',
      scheduledDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final task3 = Task(
      id: '3',
      succulentId: 's1',
      category: TaskCategory.other,
      title: 'Task 3',
      scheduledDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    blocTest<TaskBloc, TaskState>(
      'emits updated task list when ReorderTaskEvent is added (move down)',
      build: () => taskBloc,
      act: (bloc) {
        bloc.add(AddTaskEvent(task1));
        bloc.add(AddTaskEvent(task2));
        bloc.add(AddTaskEvent(task3));
        // Move Task 1 (index 0) to after Task 3 (index 3 because list grew, effectively index 2)
        // In ReorderableListView, dragging item at index 0 to index 3 results in:
        bloc.add(ReorderTaskEvent(0, 3));
      },
      expect: () => [
        isA<TaskState>().having((state) => state.tasks, 'tasks', [task1]),
        isA<TaskState>()
            .having((state) => state.tasks, 'tasks', [task1, task2]),
        isA<TaskState>()
            .having((state) => state.tasks, 'tasks', [task1, task2, task3]),
        // After reorder: Task 2, Task 3, Task 1
        isA<TaskState>()
            .having((state) => state.tasks, 'tasks', [task2, task3, task1]),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits updated task list when ReorderTaskEvent is added (move up)',
      build: () => taskBloc,
      act: (bloc) {
        bloc.add(AddTaskEvent(task1));
        bloc.add(AddTaskEvent(task2));
        bloc.add(AddTaskEvent(task3));
        // Move Task 3 (index 2) to before Task 1 (index 0)
        bloc.add(ReorderTaskEvent(2, 0));
      },
      expect: () => [
        isA<TaskState>().having((state) => state.tasks, 'tasks', [task1]),
        isA<TaskState>()
            .having((state) => state.tasks, 'tasks', [task1, task2]),
        isA<TaskState>()
            .having((state) => state.tasks, 'tasks', [task1, task2, task3]),
        // After reorder: Task 3, Task 1, Task 2
        isA<TaskState>()
            .having((state) => state.tasks, 'tasks', [task3, task1, task2]),
      ],
    );
  });
}
