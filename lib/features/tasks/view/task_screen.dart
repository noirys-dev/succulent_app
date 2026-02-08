import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:succulent_app/features/tasks/bloc/task_bloc.dart';
import 'package:succulent_app/features/tasks/models/task.dart';
import 'package:succulent_app/features/tasks/models/task_category.dart';
import 'package:succulent_app/core/theme/app_colors.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _taskController = TextEditingController();

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
                    color: AppColors.darkBrown.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _taskController,
                style: const TextStyle(color: AppColors.charcoal),
                decoration: InputDecoration(
                  hintText: 'what did you do today?',
                  hintStyle:
                      TextStyle(color: AppColors.charcoal.withOpacity(0.4)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle,
                        color: AppColors.darkGreen, size: 30),
                    onPressed: () {
                      if (_taskController.text.isNotEmpty) {
                        final now = DateTime.now();
                        final task = Task(
                          id: now.microsecondsSinceEpoch.toString(),
                          succulentId: '',
                          category: TaskCategory.other,
                          title: _taskController.text,
                          scheduledDate: now,
                          createdAt: now,
                          updatedAt: now,
                        );
                        context.read<TaskBloc>().add(AddTaskEvent(task));
                        _taskController.clear();
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
                    _taskController.clear();
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
                            color: AppColors.lightBrown.withOpacity(0.5)),
                        const SizedBox(height: 10),
                        Text(
                          'no tasks yet. keep growing.',
                          style: TextStyle(
                              color: AppColors.charcoal.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: state.tasks.length,
                  itemBuilder: (context, index) {
                    final task = state.tasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: task.isCompleted
                              ? AppColors.lightGreen
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          final updated = task.copyWith(
                              isCompleted: !task.isCompleted,
                              updatedAt: DateTime.now());
                          context
                              .read<TaskBloc>()
                              .add(UpdateTaskEvent(updated));
                        },
                        leading: Icon(
                          task.isCompleted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: task.isCompleted
                              ? AppColors.darkGreen
                              : AppColors.lightBrown,
                        ),
                        title: Text(
                          task.title.toLowerCase(),
                          style: TextStyle(
                            color: task.isCompleted
                                ? AppColors.charcoal.withOpacity(0.4)
                                : AppColors.charcoal,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          task.category.displayName.toLowerCase(),
                          style: TextStyle(
                            color: AppColors.darkBrown.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.lightBrown, size: 20),
                          onPressed: () {
                            // Silme eventi eklenebilir
                          },
                        ),
                      ),
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
}
