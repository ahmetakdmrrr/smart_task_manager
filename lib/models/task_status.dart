// TaskStatus enum - Görev durumları
enum TaskStatus {
  pending,
  inProgress,
  completed,
}

// TaskStatus extension - Görüntüleme için
extension TaskStatusExtension on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.pending:
        return 'Bekliyor';
      case TaskStatus.inProgress:
        return 'Devam Ediyor';
      case TaskStatus.completed:
        return 'Tamamlandı';
    }
  }

  bool get isCompleted => this == TaskStatus.completed;
  bool get canStart => this != TaskStatus.completed;
}
