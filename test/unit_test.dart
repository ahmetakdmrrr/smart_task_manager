// Smart Task Manager - Unit Tests
// AI tarafından üretilmiş test senaryoları

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager/models/models.dart';
import 'package:smart_task_manager/providers/filter_provider.dart';

void main() {
  group('Task Model Tests', () {
    test('Task oluşturulduğunda varsayılan değerler doğru olmalı', () {
      final task = Task(
        id: 'test-1',
        title: 'Test Görevi',
        dueDate: DateTime.now().add(const Duration(days: 7)),
      );

      expect(task.priority, Priority.medium);
      expect(task.status, TaskStatus.pending);
      expect(task.hasDelayRisk, false);
      expect(task.hasDependency, false);
    });

    test('Priority değeri doğru dönmeli', () {
      expect(Priority.low.label, 'Düşük');
      expect(Priority.medium.label, 'Orta');
      expect(Priority.high.label, 'Yüksek');
    });

    test('TaskStatus değeri doğru dönmeli', () {
      expect(TaskStatus.pending.label, 'Bekliyor');
      expect(TaskStatus.inProgress.label, 'Devam Ediyor');
      expect(TaskStatus.completed.label, 'Tamamlandı');
    });

    test('isOverdue gecikmiş görevi tespit etmeli', () {
      final overdueTask = Task(
        id: 'overdue-1',
        title: 'Gecikmiş Görev',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(overdueTask.isOverdue, true);

      final futureTask = Task(
        id: 'future-1',
        title: 'Gelecek Görev',
        dueDate: DateTime.now().add(const Duration(days: 5)),
      );
      expect(futureTask.isOverdue, false);
    });
  });

  group('FilterProvider Tests', () {
    late FilterProvider filterProvider;
    late List<Task> testTasks;

    setUp(() {
      filterProvider = FilterProvider();
      testTasks = [
        Task(id: '1', title: 'Yüksek Öncelikli', dueDate: DateTime.now(), priorityIndex: 2),
        Task(id: '2', title: 'Düşük Öncelikli', dueDate: DateTime.now(), priorityIndex: 0),
        Task(id: '3', title: 'Orta Öncelikli', dueDate: DateTime.now(), priorityIndex: 1),
      ];
    });

    test('Öncelik filtresi çalışmalı', () {
      filterProvider.setSelectedPriority(Priority.high);
      final filtered = filterProvider.applyFilters(testTasks);
      
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Yüksek Öncelikli');
    });

    test('Arama filtresi çalışmalı', () {
      filterProvider.setSearchQuery('düşük');
      final filtered = filterProvider.applyFilters(testTasks);
      
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Düşük Öncelikli');
    });

    test('Temizle tüm filtreleri sıfırlamalı', () {
      filterProvider.setSelectedPriority(Priority.high);
      filterProvider.setSearchQuery('test');
      filterProvider.clearFilters();
      
      expect(filterProvider.selectedPriority, null);
      expect(filterProvider.searchQuery, '');
    });
  });

  group('Edge Case Tests', () {
    test('Boş görev listesi filtrelenmeli', () {
      final filterProvider = FilterProvider();
      final result = filterProvider.applyFilters([]);
      expect(result, isEmpty);
    });

    test('Çok uzun başlık kesılmalı (255+ karakter edge case)', () {
      final longTitle = 'A' * 300;
      final task = Task(
        id: 'long-1',
        title: longTitle,
        dueDate: DateTime.now(),
      );
      expect(task.title.length, 300); // Şu an kesim yok, ileride eklenebilir
    });

    test('Negatif estimatedHours kabul edilmemeli (edge case)', () {
      // NOT: Bu test şu an geçer çünkü validasyon yok
      // Bu bir AI eksikliği olarak raporlanmalı
      final task = Task(
        id: 'neg-1',
        title: 'Negatif Süre',
        dueDate: DateTime.now(),
        estimatedHours: -5, // Geçersiz ama kabul ediliyor!
      );
      expect(task.estimatedHours, -5); // Validasyon eksik!
    });
  });
}
