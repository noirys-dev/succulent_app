import 'package:flutter/material.dart';
import 'package:succulent_app/features/tasks/view/task_screen.dart';
import '../home/presentation/pages/home_screen.dart';
import '../../core/theme/app_colors.dart';

class RootNavigation extends StatefulWidget {
  const RootNavigation({super.key});

  @override
  State<RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<RootNavigation> {
  int _currentIndex = 0;

  // ekranlarımızı burada listeliyoruz
  final List<Widget> _pages = [
    const HomeScreen(),
    const TaskScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.creme,
        selectedItemColor: AppColors.darkBrown,
        unselectedItemColor: AppColors.darkBrown.withOpacity(0.4),
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'tasks'),
        ],
      ),
    );
  }
}
