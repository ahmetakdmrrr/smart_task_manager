import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/task_provider.dart';
import '../providers/filter_provider.dart';
import '../services/ai_service.dart';
import '../widgets/task_card.dart';
import '../widgets/filter_bar.dart';

/// Dashboard Screen - Ana görev listesi ekranı (Stateless - Provider ile)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Consumer<FilterProvider>(
            builder: (context, filterProvider, _) => FilterBar(
              filterProvider: filterProvider,
            ),
          ),
          Expanded(
            child: _buildTaskList(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('newTask'),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Görev'),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Smart Task Manager'),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.auto_awesome),
          tooltip: 'AI Planla',
          onPressed: () => _showAIPlannerDialog(context),
        ),
      ],
    );
  }

  Widget _buildTaskList(BuildContext context) {
    return Consumer2<TaskProvider, FilterProvider>(
      builder: (context, taskProvider, filterProvider, _) {
        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (taskProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(taskProvider.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => taskProvider.loadTasks(),
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        final filteredTasks = filterProvider.applyFilters(taskProvider.tasks);

        if (filteredTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  taskProvider.tasks.isEmpty
                      ? 'Henüz görev yok'
                      : 'Filtreye uygun görev bulunamadı',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            final canStart = taskProvider.canStartTask(task.id);
            
            return TaskCard(
              task: task,
              showDependencyWarning: !canStart && task.hasDependency,
              onTap: () => context.pushNamed('taskDetail', pathParameters: {'id': task.id}),
              onDelete: () => _confirmDelete(context, taskProvider, task),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, TaskProvider provider, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: Text('"${task.title}" görevini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTask(task.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _showAIPlannerDialog(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple),
            SizedBox(width: 8),
            Text('AI Planlama'),
          ],
        ),
        content: const Text(
          'Yapay zeka görevlerinizi analiz edecek ve gecikme riski tespiti yapacak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _runAIAnalysis(context, taskProvider.tasks);
            },
            child: const Text('Analiz Et'),
          ),
        ],
      ),
    );
  }

  void _runAIAnalysis(BuildContext context, List<Task> tasks) async {
    // Loading göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 16),
            Text('Gemini AI analiz yapıyor...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Analiz için görev bulunamadı!')),
      );
      return;
    }

    try {
      // AI Service'i başlat ve Gemini API'yi çağır
      final aiService = AIService();
      await aiService.init();
      
      final riskResults = await aiService.analyzeDelayRisks(tasks);
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Sonuçları göster
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.purple),
                SizedBox(width: 8),
                Text('Gemini AI Sonuçları'),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📊 Analiz edilen görev: ${tasks.where((t) => !t.status.isCompleted).length}'),
                  const SizedBox(height: 8),
                  Text(
                    '⚠️ Riskli Görev: ${riskResults.length}',
                    style: TextStyle(
                      color: riskResults.isNotEmpty ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (riskResults.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Gecikme riski tespit edilenler:',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    ...riskResults.take(5).map((r) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                r.isHighRisk ? Icons.error : Icons.warning,
                                color: r.isHighRisk ? Colors.red : Colors.orange,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${r.taskTitle} (Risk: ${r.riskScore}%)',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      r.reason,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('✅ Tüm görevler yolunda!',
                          style: TextStyle(color: Colors.green)),
                    ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tamam'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI Hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

