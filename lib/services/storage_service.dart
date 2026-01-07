import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// Storage Service - Hive ile yerel veri işlemleri (Single Responsibility)
class StorageService {
  static const String _taskBoxName = 'tasks';
  late Box<Task> _taskBox;

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Hive başlatma
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    _taskBox = await Hive.openBox<Task>(_taskBoxName);
  }

  /// Tüm görevleri getir
  List<Task> getAllTasks() {
    return _taskBox.values.toList();
  }

  /// ID ile görev getir
  Task? getTaskById(String id) {
    return _taskBox.values.firstWhere(
      (task) => task.id == id,
      orElse: () => throw Exception('Task not found: $id'),
    );
  }

  /// Görev ekle
  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  /// Görev güncelle
  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
  }

  /// Görev sil
  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  /// Predecessor görev durumunu kontrol et
  bool isPredecessorCompleted(String? predecessorId) {
    if (predecessorId == null || predecessorId.isEmpty) return true;
    
    try {
      final predecessor = getTaskById(predecessorId);
      return predecessor?.status.isCompleted ?? true;
    } catch (_) {
      return true; // Predecessor bulunamazsa, bağımlılık yok say
    }
  }

  /// Box dinleme (reactive updates için)
  Box<Task> get taskBox => _taskBox;
}
