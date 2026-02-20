import 'package:flutter/material.dart';
import 'package:succulent_app/core/di/injection.dart' as di;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:succulent_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:succulent_app/features/tasks/bloc/task_bloc.dart';

import 'package:succulent_app/debug/succulent_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  HydratedBloc.storage = storage;
  await di.init();
  runApp(const SucculentApp());
}

bool kShowClassificationTest = false;

class SucculentApp extends StatelessWidget {
  const SucculentApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Toggle this flag to open the classification test screen

    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.getIt<HomeBloc>()),
          BlocProvider(create: (_) => di.getIt<TaskBloc>()),
        ],
        child: MaterialApp(
          title: 'Succulent',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
            fontFamily: 'Brawler',
          ),
          home: const SucculentTestScreen(),
        ));
  }
}
