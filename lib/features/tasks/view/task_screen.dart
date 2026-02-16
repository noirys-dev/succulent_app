import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:succulent_app/features/tasks/bloc/task_bloc.dart';
import 'package:succulent_app/features/tasks/models/task.dart';
import 'package:succulent_app/features/tasks/models/task_category.dart';
import 'package:succulent_app/core/theme/app_colors.dart';
import 'package:succulent_app/features/focus/presentation/pages/focus_screen.dart';
import 'package:succulent_app/features/tasks/view/widgets/task_card.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final TextEditingController taskController;

  @override
  void initState() {
    super.initState();
    taskController = TextEditingController();
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creme,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'succulent tasks',
          style: TextStyle(
            color: AppColors.darkBrown,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Görev Ekleme Alanı (Home Screen'deki TextField stiliyle)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBrown.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: taskController,
                style: const TextStyle(color: AppColors.charcoal),
                decoration: InputDecoration(
                  hintText: 'what did you do today?',
                  hintStyle: TextStyle(
                      color: AppColors.charcoal.withValues(alpha: 0.4)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppColors.darkGreen, size: 30),
                    onPressed: () {
                      if (taskController.text.isNotEmpty) {
                        final now = DateTime.now();
                        final task = Task(
                          id: now.microsecondsSinceEpoch.toString(),
                          succulentId: '',
                          category: TaskCategory.other,
                          title: taskController.text,
                          scheduledDate: now,
                          createdAt: now,
                          updatedAt: now,
                        );
                        context.read<TaskBloc>().add(AddTaskEvent(task));
                        taskController.clear();
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    final now = DateTime.now();
                    final task = Task(
                      id: now.microsecondsSinceEpoch.toString(),
                      succulentId: '',
                      category: TaskCategory.other,
                      title: value,
                      scheduledDate: now,
                      createdAt: now,
                      updatedAt: now,
                    );
                    context.read<TaskBloc>().add(AddTaskEvent(task));
                    taskController.clear();
                  }
                },
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'daily reflections',
              style: TextStyle(
                color: AppColors.charcoal,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Görev Listesi
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state.tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.psychology_outlined,
                            size: 60,
                            color: AppColors.lightBrown.withValues(alpha: 0.5)),
                        const SizedBox(height: 10),
                        Text(
                          'no tasks yet. keep growing.',
                          style: TextStyle(
                              color: AppColors.charcoal.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  );
                }

                return ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.tasks.length,
                  onReorder: (oldIndex, newIndex) {
                    context
                        .read<TaskBloc>()
                        .add(ReorderTaskEvent(oldIndex, newIndex));
                  },
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      color: Colors.transparent,
                      elevation: 0,
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final task = state.tasks[index];
                    return TaskCard(
                      key: ValueKey(task.id),
                      task: task,
                      onToggle: () {
                        final updated = task.copyWith(
                            isCompleted: !task.isCompleted,
                            updatedAt: DateTime.now());
                        context.read<TaskBloc>().add(UpdateTaskEvent(updated));
                      },
                      onEdit: () => _showEditTaskDialog(context, task),
                      onDelete: () {
                        context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
                      },
                      onPlayFocus: (task.durationMinutes != null &&
                              task.durationMinutes! > 0)
                          ? () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FocusScreen(
                                    taskTitle: task.title,
                                    plannedDuration: Duration(
                                        minutes: task.durationMinutes!),
                                    taskIndex: index,
                                  ),
                                ),
                              );

                              if (result != null &&
                                  result['completed'] == true) {
                                // Task completed via focus session
                                final updated = task.copyWith(
                                    isCompleted: true,
                                    updatedAt: DateTime.now());
                                if (context.mounted) {
                                  context
                                      .read<TaskBloc>()
                                      .add(UpdateTaskEvent(updated));
                                }
                              }
                            }
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Enter task title',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  final updatedTask = task.copyWith(
                    title: newTitle,
                    updatedAt: DateTime.now(),
                  );
                  context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
