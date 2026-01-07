// Priority enum - Görev öncelik seviyeleri
enum Priority {
  low,
  medium,
  high,
}

// Priority extension - Görüntüleme ve renk için
extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.low:
        return 'Düşük';
      case Priority.medium:
        return 'Orta';
      case Priority.high:
        return 'Yüksek';
    }
  }

  int get value {
    switch (this) {
      case Priority.low:
        return 1;
      case Priority.medium:
        return 2;
      case Priority.high:
        return 3;
    }
  }
}
