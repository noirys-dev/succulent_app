import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const RoutinaApp());
}

class RoutinaApp extends StatefulWidget {
  const RoutinaApp({super.key});

  @override
  State<RoutinaApp> createState() => _RoutinaAppState();
}

class _RoutinaAppState extends State<RoutinaApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleThemeMode(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Routina',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
      ),
      themeMode: _themeMode,
      home: RoutineHomeScreen(onThemeChanged: _toggleThemeMode),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RoutineHomeScreen extends StatefulWidget {
  const RoutineHomeScreen({super.key, required this.onThemeChanged});

  final ValueChanged<bool> onThemeChanged;

  @override
  State<RoutineHomeScreen> createState() => _RoutineHomeScreenState();
}

class _RoutineHomeScreenState extends State<RoutineHomeScreen> {
  // Sample data for routines
  final List<Map<String, dynamic>> _routines = [
    {'title': 'Morning Meditation', 'completed': false, 'time': '07:00 AM'},
    {'title': 'Drink Water (500ml)', 'completed': false, 'time': '07:30 AM'},
    {'title': 'Read 10 Pages', 'completed': false, 'time': '08:00 AM'},
    {'title': 'Workout', 'completed': false, 'time': '06:00 PM'},
  ];
  bool _showCelebration = false;
  int _celebrationTick = 0;

  void _toggleRoutine(int index) {
    setState(() {
      _routines[index]['completed'] = !_routines[index]['completed'];
    });
    _updateCelebration();
  }

  double _completionRatio() {
    if (_routines.isEmpty) {
      return 0;
    }
    final completedCount = _routines
        .where((routine) => routine['completed'] == true)
        .length;
    return completedCount / _routines.length;
  }

  void _updateCelebration() {
    final allDone = _routines.isNotEmpty &&
        _routines.every((routine) => routine['completed'] == true);
    if (allDone) {
      _triggerCelebration();
    } else if (_showCelebration) {
      setState(() {
        _showCelebration = false;
      });
    }
  }

  void _triggerCelebration() {
    _celebrationTick++;
    final currentTick = _celebrationTick;
    setState(() {
      _showCelebration = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || currentTick != _celebrationTick) {
        return;
      }
      setState(() {
        _showCelebration = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completionRatio = _completionRatio();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routina'),
        actions: [
          IconButton(
            tooltip: 'Light mode',
            onPressed: () => widget.onThemeChanged(false),
            icon: Icon(
              Icons.light_mode,
              color: isDark
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton(
            tooltip: 'Dark mode',
            onPressed: () => widget.onThemeChanged(true),
            icon: Icon(
              Icons.dark_mode,
              color: isDark
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: completionRatio),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeIn,
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 10,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(completionRatio * 100).round()}%',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(_routines.length, (index) {
                final routine = _routines[index];
                return Card(
                  elevation: 0,
                  color: routine['completed']
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Checkbox(
                      value: routine['completed'],
                      onChanged: (_) => _toggleRoutine(index),
                      shape: const CircleBorder(),
                    ),
                    title: Text(
                      routine['title'],
                      style: TextStyle(
                        decoration: routine['completed']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(routine['time']),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              }),
            ],
          ),
          Positioned(
            top: 24,
            right: 24,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: _showCelebration
                  ? Container(
                      key: const ValueKey('celebration'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).colorScheme.shadow.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.celebration,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Well done!',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(key: ValueKey('celebration-empty')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add routine functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Routine feature coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
