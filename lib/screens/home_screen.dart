import 'package:flutter/material.dart';
import 'package:succulent_app/models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<String, bool> habitCompletionStatus;

  @override
  void initState() {
    super.initState();
    // Initialize habit completion status
    habitCompletionStatus = {
      '1': false,
      '2': false,
      '3': false,
      '4': false,
      '5': false,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Sample habits data - replace with actual data from your state management
    final sampleHabits = [
      Task(
        id: '1',
        succulentId: '1',
        category: TaskCategory.watering,
        title: 'Morning Exercise',
        description: '30 minutes workout',
        scheduledDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: habitCompletionStatus['1'] ?? false,
      ),
      Task(
        id: '2',
        succulentId: '1',
        category: TaskCategory.monitoring,
        title: 'Read',
        description: 'Read for 20 minutes',
        scheduledDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: habitCompletionStatus['2'] ?? false,
      ),
      Task(
        id: '3',
        succulentId: '1',
        category: TaskCategory.fertilizing,
        title: 'Meditate',
        description: '10 minutes meditation',
        scheduledDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: habitCompletionStatus['3'] ?? false,
      ),
      Task(
        id: '4',
        succulentId: '1',
        category: TaskCategory.pruning,
        title: 'Drink Water',
        description: '8 glasses of water',
        scheduledDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: habitCompletionStatus['4'] ?? false,
      ),
      Task(
        id: '5',
        succulentId: '1',
        category: TaskCategory.other,
        title: 'Journal',
        description: 'Write 5 minutes',
        scheduledDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCompleted: habitCompletionStatus['5'] ?? false,
      ),
    ];

    final completedCount = habitCompletionStatus.values.where((v) => v).length;
    final totalCount = habitCompletionStatus.length;
    final completionPercentage =
        (completedCount / totalCount * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header with date and stats
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Habits',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(DateTime.now()),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Progress card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green[600]!, Colors.green[400]!],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$completedCount / $totalCount',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$completionPercentage%',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Complete',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: completedCount / totalCount,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Habits List
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'My Habits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[900],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: sampleHabits.length,
                      itemBuilder: (context, index) {
                        final habit = sampleHabits[index];
                        final isCompleted =
                            habitCompletionStatus[habit.id] ?? false;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isCompleted
                                  ? Colors.green[200]!
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: GestureDetector(
                              onTap: () {
                                setState(() {
                                  habitCompletionStatus[habit.id] =
                                      !isCompleted;
                                });
                              },
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? Colors.green[100]
                                      : _getCategoryColor(habit.category)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCompleted
                                        ? Colors.green[400]!
                                        : _getCategoryColor(habit.category)
                                            .withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  isCompleted
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isCompleted
                                      ? Colors.green[600]
                                      : _getCategoryColor(habit.category),
                                  size: 28,
                                ),
                              ),
                            ),
                            title: Text(
                              habit.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[900],
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            subtitle: Text(
                              habit.description ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                habitCompletionStatus[habit.id] = !isCompleted;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Add Habit button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle add habit
                  },
                  icon: const Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: const Text(
                    'Add New Habit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.watering:
        return Colors.blue;
      case TaskCategory.fertilizing:
        return Colors.orange;
      case TaskCategory.repotting:
        return Colors.brown;
      case TaskCategory.pruning:
        return Colors.purple;
      case TaskCategory.monitoring:
        return Colors.teal;
      case TaskCategory.other:
        return Colors.grey;
    }
  }
}
