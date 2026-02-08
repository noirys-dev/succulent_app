import 'package:succulent_app/features/home/data/models/habit_model.dart';

abstract class HomeRepository {
  Future<List<HabitModel>> getHabits();
  Future<void> addHabit(HabitModel habit);
  Future<void> updateHabit(HabitModel habit);
  Future<void> removeHabit(String id);
}
