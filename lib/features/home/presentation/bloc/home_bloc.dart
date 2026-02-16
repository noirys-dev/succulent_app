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

  HomeBloc({required this.repository}) : super(HomeState()) {
    on<LoadHabits>(_onLoad);
    on<AddHabitEvent>(_onAdd);
    on<RemoveHabitEvent>(_onRemove);
    on<ToggleHabitDoneEvent>(_onToggleDone);
    on<SuggestCategoryEvent>(_onSuggest);
    on<ClearCategoryEvent>(_onClearCategory);
    on<SelectCategoryEvent>(_onSelectCategory);
    on<UpdateHabitEvent>(_onUpdate);
    on<ChangeDateEvent>(_onChangeDate);
    on<ToggleCalendarEvent>(_onToggleCalendar);
    on<ChangeDisplayedMonthEvent>(_onChangeDisplayedMonth);
    on<ReorderHabitsEvent>(_onReorderHabits);
  }

  void _onReorderHabits(ReorderHabitsEvent event, Emitter<HomeState> emit) {
    // 1. Get currently filtered habits (same logic as UI)
    final filteredHabits = state.habits.where((h) {
      final date = state.selectedDate;
      return h.createdAt.year == date.year &&
          h.createdAt.month == date.month &&
          h.createdAt.day == date.day;
    }).toList();

    if (event.oldIndex >= filteredHabits.length) return;

    var newIndex = event.newIndex;
    if (event.oldIndex < newIndex) {
      newIndex -= 1;
    }

    if (newIndex > filteredHabits.length) newIndex = filteredHabits.length;

    // 2. Create the new order for filtered habits
    final movedItem = filteredHabits.removeAt(event.oldIndex);
    filteredHabits.insert(newIndex, movedItem);

    // 3. Reconstruct the global list
    // We iterate through the global list. If an item belongs to the current date,
    // we pick the next item from our newly reordered 'filteredHabits'.
    // If it belongs to another date, we keep it as is.
    final List<HabitModel> newGlobalList = [];
    int filteredIndex = 0;

    for (final habit in state.habits) {
      final date = state.selectedDate;
      final isSameDay = habit.createdAt.year == date.year &&
          habit.createdAt.month == date.month &&
          habit.createdAt.day == date.day;

      if (isSameDay) {
        if (filteredIndex < filteredHabits.length) {
          newGlobalList.add(filteredHabits[filteredIndex]);
          filteredIndex++;
        }
      } else {
        newGlobalList.add(habit);
      }
    }

    // 4. Update repository and state
    // Note: If you have a backend/DB that persists order, you need to update it here.
    // Since we are just updating the list in HydratedBloc, this persists locally.
    emit(state.copyWith(habits: newGlobalList));
  }

  void _onChangeDate(ChangeDateEvent event, Emitter<HomeState> emit) {
    // Sadece tarihi güncelle, takvim durumunu değiştirme (açıksa açık kalsın)
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onToggleCalendar(ToggleCalendarEvent event, Emitter<HomeState> emit) {
    final newIsOpen = !state.isCalendarOpen;
    if (newIsOpen) {
      final now = DateTime.now();
      // Takvim açıldığında, gösterilen ayı ve seçili günü bugüne sıfırla
      final completionData = _computeMonthCompletionData(now);
      emit(state.copyWith(
        isCalendarOpen: true,
        monthCompletionData: completionData,
        selectedDate: now,
        displayedMonth: now,
      ));
    } else {
      emit(state.copyWith(isCalendarOpen: false));
    }
  }

  void _onChangeDisplayedMonth(
      ChangeDisplayedMonthEvent event, Emitter<HomeState> emit) {
    final completionData = _computeMonthCompletionData(event.month);
    emit(state.copyWith(
      displayedMonth: event.month,
      monthCompletionData: completionData,
    ));
  }

  Map<DateTime, double> _computeMonthCompletionData(DateTime month) {
    final Map<DateTime, double> result = {};
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    for (var day = firstDay;
        !day.isAfter(lastDay);
        day = day.add(const Duration(days: 1))) {
      final normalizedDay = DateTime(day.year, day.month, day.day);
      final habitsOnDay = state.habits.where((h) =>
          h.createdAt.year == day.year &&
          h.createdAt.month == day.month &&
          h.createdAt.day == day.day);

      if (habitsOnDay.isNotEmpty) {
        final completed = habitsOnDay.where((h) => h.isDone).length;
        result[normalizedDay] = completed / habitsOnDay.length;
      }
    }
    return result;
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
        category: event.category ?? existing.category,
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
