import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/task_provider.dart';
import '../widgets/task_form.dart';

/// Task Detail Screen - Görev detay/düzenleme ekranı (Stateless)
class TaskDetailScreen extends StatelessWidget {
  final String? taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  bool get isNewTask => taskId == null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNewTask ? 'Yeni Görev' : 'Görevi Düzenle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          Task? existingTask;
          if (!isNewTask) {
            existingTask = taskProvider.getTaskById(taskId!);
            if (existingTask == null) {
              return const Center(
                child: Text('Görev bulunamadı'),
              );
            }
          }

          return TaskForm(
            existingTask: existingTask,
            availablePredecessors: taskProvider.tasks,
            onSave: (task) => _saveTask(context, taskProvider, task),
          );
        },
      ),
    );
  }

  void _saveTask(BuildContext context, TaskProvider provider, Task task) async {
    if (isNewTask) {
      await provider.addTask(task);
    } else {
      await provider.updateTask(task);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNewTask ? 'Görev eklendi' : 'Görev güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }
}
