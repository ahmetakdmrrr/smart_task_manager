import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

/// Task Provider - Görev state yönetimi (ChangeNotifier)
class TaskProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  // Getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Görevleri yükle
  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _tasks = _storageService.getAllTasks();
      _error = null;
    } catch (e) {
      _error = 'Görevler yüklenirken hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Görev ekle
  Future<void> addTask(Task task) async {
    try {
      await _storageService.addTask(task);
      _tasks.add(task);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Görev eklenirken hata oluştu: $e';
      notifyListeners();
    }
  }

  /// Görev güncelle
  Future<void> updateTask(Task task) async {
    try {
      await _storageService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Görev güncellenirken hata oluştu: $e';
      notifyListeners();
    }
  }

  /// Görev sil
  Future<void> deleteTask(String id) async {
    try {
      await _storageService.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Görev silinirken hata oluştu: $e';
      notifyListeners();
    }
  }

  /// Görev durumunu değiştir
  Future<void> updateTaskStatus(String id, TaskStatus newStatus) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    
    // Bağımlılık kontrolü
    if (newStatus == TaskStatus.inProgress) {
      if (!canStartTask(id)) {
        _error = 'Öncül görev henüz tamamlanmadı!';
        notifyListeners();
        return;
      }
    }

    final updatedTask = task.copyWith(statusIndex: newStatus.index);
    await updateTask(updatedTask);
  }

  /// Görev başlatılabilir mi? (Bağımlılık kontrolü)
  bool canStartTask(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    return _storageService.isPredecessorCompleted(task.predecessorId);
  }

  /// ID ile görev getir
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
