import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_event.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_state.dart';
import 'package:succulent_app/features/home/domain/repositories/home_repository.dart';
import 'package:succulent_app/features/home/data/models/habit_model.dart';
import 'package:succulent_app/core/classification/category.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

class MockStorage extends Mock implements Storage {}

void main() {
  late HomeRepository repository;
  late Storage storage;
  late HomeBloc bloc;

  setUp(() {
    repository = MockHomeRepository();
    storage = MockStorage();
    when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
    HydratedBloc.storage = storage;
    bloc = HomeBloc(repository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  final date = DateTime(2023, 10, 10);
  final h1 = HabitModel(
          id: '1',
          title: 'H1',
          plannedDuration: Duration.zero,
          category: CategoryId.productivity)
      .copyWith(createdAt: date);
  final h2 = HabitModel(
          id: '2',
          title: 'H2',
          plannedDuration: Duration.zero,
          category: CategoryId.productivity)
      .copyWith(createdAt: date);
  final h3 = HabitModel(
          id: '3',
          title: 'H3',
          plannedDuration: Duration.zero,
          category: CategoryId.productivity)
      .copyWith(createdAt: date);

  // Interspersed habit from another day
  final otherDate = DateTime(2023, 10, 11);
  final hOther = HabitModel(
          id: 'X',
          title: 'X',
          plannedDuration: Duration.zero,
          category: CategoryId.productivity)
      .copyWith(createdAt: otherDate);

  group('HomeBloc Reorder', () {
    blocTest<HomeBloc, HomeState>(
      'reorders habits correctly for the same day',
      build: () => bloc,
      seed: () => HomeState(habits: [h1, h2, h3], selectedDate: date),
      act: (bloc) => bloc.add(const ReorderHabitsEvent(0, 3)), // Move H1 to end
      expect: () => [
        isA<HomeState>().having((s) => s.habits, 'habits', [h2, h3, h1]),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'reorders habits correctly with interspersed items',
      build: () => bloc,
      seed: () => HomeState(habits: [h1, hOther, h2, h3], selectedDate: date),
      act: (bloc) => bloc.add(const ReorderHabitsEvent(
          0, 3)), // Move H1 to after H3 (index 2 in filtered, target index 3)
      // Filtered: [H1, H2, H3]. Move H1(0) to 3 -> [H2, H3, H1]
      // Original: [H1, Other, H2, H3]
      // Reconstructed:
      // Slot 0 (was H1): NewFiltered[0] -> H2
      // Slot 1 (was Other): Keep -> Other
      // Slot 2 (was H2): NewFiltered[1] -> H3
      // Slot 3 (was H3): NewFiltered[2] -> H1
      // Result: [H2, Other, H3, H1]
      expect: () => [
        isA<HomeState>()
            .having((s) => s.habits, 'habits', [h2, hOther, h3, h1]),
      ],
    );
  });
}
