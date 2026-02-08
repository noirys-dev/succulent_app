import 'dart:async';
import 'package:succulent_app/features/home/data/models/habit_model.dart';
import 'package:succulent_app/features/home/domain/repositories/home_repository.dart';
import 'package:uuid/uuid.dart';

class HomeRepositoryImpl implements HomeRepository {
  // artık listemiz sadece habitmodel tipinde veri kabul ediyor.
  final List<HabitModel> _store = [];
  final _uuid = const Uuid();

  @override
  Future<void> addHabit(HabitModel habit) async {
    // yeni bir alışkanlık eklendiğinde id boşsa uuid ile benzersiz bir kimlik atıyoruz.
    final toAdd = habit.copyWith(id: habit.id.isEmpty ? _uuid.v4() : habit.id);
    _store.insert(0, toAdd);
  }

  @override
  Future<void> removeHabit(String id) async {
    _store.removeWhere((h) => h.id == id);
  }

  @override
  Future<List<HabitModel>> getHabits() async {
    // dışarıdan gelen müdahalelere karşı listeyi korunmuş (unmodifiable) şekilde dönüyoruz.
    return List.unmodifiable(_store);
  }

  @override
  Future<void> updateHabit(HabitModel habit) async {
    final idx = _store.indexWhere((h) => h.id == habit.id);
    if (idx >= 0) {
      _store[idx] = habit;
    }
  }
}
