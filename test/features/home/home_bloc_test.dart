import 'package:mocktail/mocktail.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_event.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_state.dart';
import 'package:succulent_app/features/home/data/home_repository_impl.dart';
import 'package:succulent_app/core/classification/category.dart';

class MockStorage extends Mock implements Storage {}

void main() {
  group('HomeBloc', () {
    late HomeRepositoryImpl repository;
    late HomeBloc bloc;
    late Storage storage;

    setUp(() {
      storage = MockStorage();
      when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
      when(() => storage.read(any())).thenReturn(null);
      HydratedBloc.storage = storage;

      repository = HomeRepositoryImpl();
      bloc = HomeBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is HomeState()', () {
      expect(bloc.state, equals(HomeState()));
    });

    blocTest<HomeBloc, HomeState>(
      'emits [with habits] when AddHabitEvent is added',
      build: () => bloc,
      act: (bloc) => bloc.add(const LoadHabits()),
      verify: (bloc) => expect(bloc.state.habits, isEmpty),
    );

    blocTest<HomeBloc, HomeState>(
      'adds a habit and updates state',
      build: () => bloc,
      act: (bloc) => bloc.add(const AddHabitEvent(
        title: 'New Task',
        duration: Duration(minutes: 30),
        category: CategoryId.productivity,
      )),
      wait: const Duration(milliseconds: 50),
      expect: () => [isA<HomeState>().having((s) => s.habits.length, 'len', 1)],
    );

    blocTest<HomeBloc, HomeState>(
      'toggles habit done',
      build: () => bloc,
      act: (bloc) async {
        bloc.add(const AddHabitEvent(
          title: 'Toggle Me',
          duration: Duration(minutes: 10),
          category: CategoryId.general,
        ));
        await Future.delayed(const Duration(milliseconds: 20));
        final id = bloc.state.habits.first.id;
        bloc.add(ToggleHabitDoneEvent(id));
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<HomeState>().having((s) => s.habits.length, 'len', 1),
        isA<HomeState>().having((s) => s.habits.first.isDone, 'done', true),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'suggests a category',
      build: () => bloc,
      act: (bloc) => bloc.add(const SuggestCategoryEvent(
          'run')), // classifier returns some category
      expect: () => [
        isA<HomeState>()
            .having((s) => s.suggestedCategory, 'suggested', isNotNull)
      ],
    );
  });
}
