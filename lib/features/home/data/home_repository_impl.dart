import 'dart:async';
import 'package:succulent_app/features/home/domain/entities/habit.dart';
import 'package:succulent_app/features/home/domain/repositories/home_repository.dart';
import 'package:uuid/uuid.dart';

class HomeRepositoryImpl implements HomeRepository {
  final List<Habit> _store = [];
  final _uuid = const Uuid();

  @override
  Future<void> addHabit(Habit habit) async {
    final toAdd = habit.copyWith(id: habit.id.isEmpty ? _uuid.v4() : habit.id);
    _store.insert(0, toAdd);
  }

  @override
  Future<void> removeHabit(String id) async {
    _store.removeWhere((h) => h.id == id);
  }

  @override
  Future<List<Habit>> getHabits() async {
    // For now, return current state
    return List.unmodifiable(_store);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final idx = _store.indexWhere((h) => h.id == habit.id);
    if (idx >= 0) {
      _store[idx] = habit;
    }
  }
}
