import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Filter Provider - Filtreleme state yönetimi
class FilterProvider extends ChangeNotifier {
  Priority? _selectedPriority;
  TaskStatus? _selectedStatus;
  String _searchQuery = '';
  SortOption _sortOption = SortOption.dueDate;
  bool _sortAscending = true;

  // Getters
  Priority? get selectedPriority => _selectedPriority;
  TaskStatus? get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  SortOption get sortOption => _sortOption;
  bool get sortAscending => _sortAscending;

  /// Öncelik filtresi ayarla
  void setSelectedPriority(Priority? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  /// Durum filtresi ayarla
  void setSelectedStatus(TaskStatus? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  /// Arama sorgusu ayarla
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  /// Sıralama seçeneği ayarla
  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  /// Sıralama yönü değiştir
  void toggleSortDirection() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }

  /// Tüm filtreleri temizle
  void clearFilters() {
    _selectedPriority = null;
    _selectedStatus = null;
    _searchQuery = '';
    notifyListeners();
  }

  /// Görev listesini filtrele ve sırala
  List<Task> applyFilters(List<Task> tasks) {
    var filtered = tasks.where((task) {
      // Öncelik filtresi
      if (_selectedPriority != null && task.priority != _selectedPriority) {
        return false;
      }

      // Durum filtresi
      if (_selectedStatus != null && task.status != _selectedStatus) {
        return false;
      }

      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final titleMatch = task.title.toLowerCase().contains(_searchQuery);
        final descMatch = task.description.toLowerCase().contains(_searchQuery);
        if (!titleMatch && !descMatch) return false;
      }

      return true;
    }).toList();

    // Sıralama
    filtered.sort((a, b) {
      int comparison;
      switch (_sortOption) {
        case SortOption.dueDate:
          comparison = a.dueDate.compareTo(b.dueDate);
          break;
        case SortOption.priority:
          comparison = b.priority.value.compareTo(a.priority.value);
          break;
        case SortOption.title:
          comparison = a.title.compareTo(b.title);
          break;
        case SortOption.status:
          comparison = a.statusIndex.compareTo(b.statusIndex);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }
}

/// Sıralama seçenekleri
enum SortOption {
  dueDate,
  priority,
  title,
  status,
}

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.dueDate:
        return 'Teslim Tarihi';
      case SortOption.priority:
        return 'Öncelik';
      case SortOption.title:
        return 'Başlık';
      case SortOption.status:
        return 'Durum';
    }
  }
}
