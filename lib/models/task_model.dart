import 'package:hive/hive.dart';
import 'priority.dart';
import 'task_status.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int priorityIndex; // Priority enum index

  @HiveField(4)
  DateTime dueDate;

  @HiveField(5)
  int estimatedHours;

  @HiveField(6)
  int statusIndex; // TaskStatus enum index

  @HiveField(7)
  String? predecessorId; // Bağımlı olunan görev ID

  @HiveField(8)
  bool hasDelayRisk;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.priorityIndex = 1, // default: medium
    required this.dueDate,
    this.estimatedHours = 1,
    this.statusIndex = 0, // default: pending
    this.predecessorId,
    this.hasDelayRisk = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Priority getter/setter
  Priority get priority => Priority.values[priorityIndex];
  set priority(Priority value) => priorityIndex = value.index;

  // Status getter/setter
  TaskStatus get status => TaskStatus.values[statusIndex];
  set status(TaskStatus value) => statusIndex = value.index;

  // Bağımlılık kontrolü
  bool get hasDependency => predecessorId != null && predecessorId!.isNotEmpty;

  // Kalan gün hesaplama
  int get daysRemaining => dueDate.difference(DateTime.now()).inDays;

  // Gecikmiş mi?
  bool get isOverdue => dueDate.isBefore(DateTime.now()) && !status.isCompleted;

  // Kopyalama (immutable güncelleme için)
  Task copyWith({
    String? title,
    String? description,
    int? priorityIndex,
    DateTime? dueDate,
    int? estimatedHours,
    int? statusIndex,
    String? predecessorId,
    bool? hasDelayRisk,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priorityIndex: priorityIndex ?? this.priorityIndex,
      dueDate: dueDate ?? this.dueDate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      statusIndex: statusIndex ?? this.statusIndex,
      predecessorId: predecessorId ?? this.predecessorId,
      hasDelayRisk: hasDelayRisk ?? this.hasDelayRisk,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() => 'Task(id: $id, title: $title, status: ${status.label})';
}
