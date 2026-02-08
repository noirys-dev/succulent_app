import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:succulent_app/core/classification/classifier.dart';
import 'package:succulent_app/features/home/data/models/habit_model.dart';
import 'package:succulent_app/features/home/domain/repositories/home_repository.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_event.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_state.dart';
import 'package:uuid/uuid.dart';

class HomeBloc extends HydratedBloc<HomeEvent, HomeState> {
  final HomeRepository repository;
  final _uuid = const Uuid();

  HomeBloc({required this.repository}) : super(const HomeState()) {
    on<LoadHabits>(_onLoad);
    on<AddHabitEvent>(_onAdd);
    on<RemoveHabitEvent>(_onRemove);
    on<ToggleHabitDoneEvent>(_onToggleDone);
    on<SuggestCategoryEvent>(_onSuggest);
    on<ClearCategoryEvent>(_onClearCategory);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<UpdateHabitEvent>(_onUpdate);
  }

  @override
  void onChange(Change<HomeState> change) {
    super.onChange(change);
  }

  Future<void> _onLoad(LoadHabits event, Emitter<HomeState> emit) async {
    final items = await repository.getHabits();
    // Avoid overwriting hydrated state with an empty in-memory repository.
    if (items.isEmpty) {
      return;
    }
    emit(state.copyWith(habits: items));
  }

  Future<void> _onAdd(AddHabitEvent event, Emitter<HomeState> emit) async {
    final id = _uuid.v4();
    final habit = HabitModel(
      id: id,
      title: event.title,
      plannedDuration: event.duration,
      category: event.category,
    );

    await repository.addHabit(habit);
    final updatedHabits = [...state.habits, habit];
    emit(state.copyWith(habits: updatedHabits));
  }

  Future<void> _onRemove(
      RemoveHabitEvent event, Emitter<HomeState> emit) async {
    await repository.removeHabit(event.id);
    final updatedHabits = state.habits.where((h) => h.id != event.id).toList();
    emit(state.copyWith(habits: updatedHabits));
  }

  Future<void> _onToggleDone(
      ToggleHabitDoneEvent event, Emitter<HomeState> emit) async {
    final current = state.habits;
    final idx = current.indexWhere((h) => h.id == event.id);
    if (idx >= 0) {
      final updatedHabit = current[idx].copyWith(isDone: !current[idx].isDone);
      await repository.updateHabit(updatedHabit);
      final updatedList =
          current.map((h) => h.id == event.id ? updatedHabit : h).toList();
      emit(state.copyWith(habits: updatedList));
    }
  }

  Future<void> _onSuggest(
      SuggestCategoryEvent event, Emitter<HomeState> emit) async {
    final result = Classifier.classifyEn(event.text).category;
    emit(state.copyWith(suggestedCategory: result));
  }

  void _onClearCategory(ClearCategoryEvent event, Emitter<HomeState> emit) {
    emit(HomeState(
      habits: state.habits,
      suggestedCategory: null,
      selectedCategory: null,
    ));
  }

  Future<void> _onSelectCategory(
      SelectCategoryEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(selectedCategory: event.category));
  }

  Future<void> _onUpdate(
      UpdateHabitEvent event, Emitter<HomeState> emit) async {
    final current = state.habits;
    final idx = current.indexWhere((h) => h.id == event.id);
    if (idx >= 0) {
      final existing = current[idx];
      final updated = existing.copyWith(
        title: event.title ?? existing.title,
        plannedDuration: event.plannedDuration ?? existing.plannedDuration,
      );
      await repository.updateHabit(updated);
      final updatedList =
          current.map((h) => h.id == event.id ? updated : h).toList();
      emit(state.copyWith(habits: updatedList));
    }
  }

  @override
  Map<String, dynamic>? toJson(HomeState state) {
    try {
      return state.toJson();
    } catch (e) {
      return null;
    }
  }

  @override
  HomeState? fromJson(Map<String, dynamic> json) {
    try {
      return HomeState.fromJson(json);
    } catch (e) {
      return null;
    }
  }
}
