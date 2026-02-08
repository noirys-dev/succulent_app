import 'package:flutter_test/flutter_test.dart';
import 'package:succulent_app/features/home/data/home_repository_impl.dart';
import 'package:succulent_app/features/home/data/models/habit_model.dart';
import 'package:succulent_app/core/classification/category.dart';

void main() {
  group('HomeRepositoryImpl', () {
    late HomeRepositoryImpl repository;

    setUp(() {
      repository = HomeRepositoryImpl();
    });

    test('getHabits returns empty initially', () async {
      final items = await repository.getHabits();
      expect(items, isEmpty);
    });

    test('addHabit adds an item and assigns an id when empty', () async {
      final habit = HabitModel(
        id: '',
        title: 'Test Habit',
        plannedDuration: const Duration(minutes: 20),
        category: CategoryId.general,
      );

      await repository.addHabit(habit);
      final items = await repository.getHabits();
      expect(items, hasLength(1));
      expect(items.first.title, equals('Test Habit'));
      expect(items.first.id, isNotEmpty);
    });

    test('updateHabit updates existing item', () async {
      final habit = HabitModel(
        id: '',
        title: 'To Update',
        plannedDuration: const Duration(minutes: 15),
        category: CategoryId.general,
      );

      await repository.addHabit(habit);
      var items = await repository.getHabits();
      final added = items.first;

      final updated = added.copyWith(
          title: 'Updated', plannedDuration: const Duration(minutes: 25));
      await repository.updateHabit(updated);

      items = await repository.getHabits();
      expect(items.first.title, equals('Updated'));
      expect(items.first.plannedDuration, equals(const Duration(minutes: 25)));
    });

    test('removeHabit removes an item', () async {
      final habit = HabitModel(
        id: '',
        title: 'To Remove',
        plannedDuration: const Duration(minutes: 10),
        category: CategoryId.general,
      );

      await repository.addHabit(habit);
      var items = await repository.getHabits();
      final added = items.first;

      await repository.removeHabit(added.id);
      items = await repository.getHabits();
      expect(items, isEmpty);
    });
  });
}
