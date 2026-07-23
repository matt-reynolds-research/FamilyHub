import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/data_providers.dart';
import '../../theme/app_colors.dart';
import '../../models/task.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tasks', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip('Today', true),
                    const SizedBox(width: 8),
                    _buildChip('Upcoming', false),
                    const SizedBox(width: 8),
                    _buildChip('Assigned to Me', false),
                    const SizedBox(width: 8),
                    _buildChip('Family Chores', false),
                    const SizedBox(width: 8),
                    _buildChip('Home Projects', false),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: tasksAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) =>
                      Center(child: Text('Error loading tasks: $err')),
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 64, color: AppColors.textSecondary),
                            const SizedBox(height: 16),
                            Text('No tasks yet',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('Add tasks from Supabase or tap + below',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildTaskRow(context, ref, task);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Positioned(
          bottom: 32,
          right: 32,
          child: FloatingActionButton(
            backgroundColor: AppColors.accentPurple,
            foregroundColor: Colors.white,
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        )
      ],
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {},
      selectedColor: AppColors.primaryIndigo.withValues(alpha: 0.1),
      checkmarkColor: AppColors.primaryIndigo,
      backgroundColor: AppColors.surface,
    );
  }

  Widget _buildTaskRow(BuildContext context, WidgetRef ref, Task task) {
    Color priorityColor = AppColors.priorityLow;
    if (task.priority == 'high') priorityColor = AppColors.priorityHigh;
    if (task.priority == 'medium') priorityColor = AppColors.priorityMedium;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: GestureDetector(
          onTap: () {
            ref
                .read(tasksProvider.notifier)
                .toggleTask(task.id, !task.isCompleted);
          },
          child: Icon(
            task.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: task.isCompleted
                ? AppColors.textSecondary
                : AppColors.primaryIndigo,
            size: 28,
          ),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? AppColors.textSecondary : null,
              ),
        ),
        subtitle: task.dueDate != null
            ? Text('Due: ${DateFormat('MMM d').format(task.dueDate!)}')
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration:
                  BoxDecoration(color: priorityColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              backgroundColor: AppColors.primaryIndigo.withValues(alpha: 0.2),
              radius: 16,
              child: Text(task.assignee[0],
                  style: const TextStyle(
                      color: AppColors.primaryIndigo,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}
