import 'package:succulent_app/features/home/domain/entities/habit.dart';

abstract class HomeRepository {
  Future<List<Habit>> getHabits();
  Future<void> addHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> removeHabit(String id);
}
