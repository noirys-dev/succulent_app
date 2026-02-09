import 'package:get_it/get_it.dart';
import 'package:succulent_app/features/home/data/home_repository_impl.dart';
import 'package:succulent_app/features/home/domain/repositories/home_repository.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_bloc.dart';

import 'package:succulent_app/features/tasks/bloc/task_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Repositories
  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());

  // Blocs
  getIt.registerFactory(() => HomeBloc(repository: getIt<HomeRepository>()));
  getIt.registerFactory(() => TaskBloc());
}
