import 'package:bloc/bloc.dart';
import 'package:succulent_app/core/classification/classifier.dart';
import 'package:succulent_app/features/home/domain/entities/habit.dart';
import 'package:succulent_app/features/home/domain/repositories/home_repository.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_event.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_state.dart';
import 'package:uuid/uuid.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;
  final _uuid = const Uuid();

  HomeBloc({required this.repository}) : super(const HomeState()) {
    on<LoadHabits>(_onLoad);
    on<AddHabitEvent>(_onAdd);
    on<RemoveHabitEvent>(_onRemove);
    on<ToggleHabitDoneEvent>(_onToggleDone);
    on<SuggestCategoryEvent>(_onSuggest);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<UpdateHabitEvent>(_onUpdate);
  }

  Future<void> _onLoad(LoadHabits event, Emitter<HomeState> emit) async {
    final items = await repository.getHabits();
    emit(state.copyWith(habits: items));
  }

  Future<void> _onAdd(AddHabitEvent event, Emitter<HomeState> emit) async {
    final id = _uuid.v4();
    final habit = Habit(
      id: id,
      title: event.title,
      plannedDuration: event.duration,
      category: event.category,
    );

    await repository.addHabit(habit);
    final updated = await repository.getHabits();
    emit(state.copyWith(habits: updated));
  }

  Future<void> _onRemove(RemoveHabitEvent event, Emitter<HomeState> emit) async {
    await repository.removeHabit(event.id);
    final updated = await repository.getHabits();
    emit(state.copyWith(habits: updated));
  }

  Future<void> _onToggleDone(ToggleHabitDoneEvent event, Emitter<HomeState> emit) async {
    final current = state.habits;
    final idx = current.indexWhere((h) => h.id == event.id);
    if (idx >= 0) {
      final updatedHabit = current[idx].copyWith(isDone: !current[idx].isDone);
      await repository.updateHabit(updatedHabit);
      final updated = await repository.getHabits();
      emit(state.copyWith(habits: updated));
    }
  }

  Future<void> _onSuggest(SuggestCategoryEvent event, Emitter<HomeState> emit) async {
    final result = Classifier.classifyEn(event.text).category;
    emit(state.copyWith(suggestedCategory: result));
  }

  Future<void> _onSelectCategory(SelectCategoryEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(selectedCategory: event.category));
  }

  Future<void> _onUpdate(UpdateHabitEvent event, Emitter<HomeState> emit) async {
    final current = state.habits;
    final idx = current.indexWhere((h) => h.id == event.id);
    if (idx >= 0) {
      final existing = current[idx];
      final updated = existing.copyWith(
        title: event.title ?? existing.title,
        plannedDuration: event.plannedDuration ?? existing.plannedDuration,
      );
      await repository.updateHabit(updated);
      final updatedList = await repository.getHabits();
      emit(state.copyWith(habits: updatedList));
    }
  }
}
