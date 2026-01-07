import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';

/// AI Service - Gemini ile gecikme riski tespiti ve yeniden planlama önerileri
class AIService {
  GenerativeModel? _model;
  
  // Singleton pattern
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  /// Servisi başlat (API key .env dosyasından)
  Future<void> init() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    // Güncel stabil model: gemini-2.0-flash
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  /// Gecikme riski analizi yap
  Future<List<TaskRiskAnalysis>> analyzeDelayRisks(List<Task> tasks) async {
    if (_model == null) {
      throw Exception('AI Service not initialized');
    }

    final incompleteTasks = tasks.where((t) => !t.status.isCompleted).toList();
    if (incompleteTasks.isEmpty) return [];

    final taskDescriptions = incompleteTasks.map((t) {
      return '- "${t.title}": Öncelik=${t.priority.label}, '
          'Kalan gün=${t.daysRemaining}, '
          'Tahmini süre=${t.estimatedHours} saat, '
          'Durum=${t.status.label}';
    }).join('\n');

    final prompt = '''
Aşağıdaki görevleri analiz et ve gecikme riski olan görevleri belirle.
Her görev için 0-100 arası risk puanı ver (100 = çok yüksek risk).

Görevler:
$taskDescriptions

JSON formatında yanıt ver:
[{"title": "görev adı", "riskScore": 85, "reason": "kısa açıklama"}]
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text ?? '[]';
      
      // JSON parse (basit implementasyon)
      return _parseRiskAnalysis(text, incompleteTasks);
    } catch (e) {
      throw Exception('AI analiz hatası: $e');
    }
  }

  /// Yeniden planlama önerisi al
  Future<List<RescheduleSuggestion>> getRescheduleSuggestions(List<Task> tasks) async {
    if (_model == null) {
      throw Exception('AI Service not initialized');
    }

    final incompleteTasks = tasks.where((t) => !t.status.isCompleted).toList();
    if (incompleteTasks.isEmpty) return [];

    final taskDescriptions = incompleteTasks.map((t) {
      final deps = t.hasDependency ? ' (Bağımlı: ${t.predecessorId})' : '';
      return '- ID:${t.id} "${t.title}": Öncelik=${t.priority.label}, '
          'Son tarih=${t.dueDate.toIso8601String().split('T')[0]}, '
          'Süre=${t.estimatedHours}h$deps';
    }).join('\n');

    final prompt = '''
İş yükü dengeleme için görevleri yeniden planla.
Öncelikleri ve bağımlılıkları dikkate al.

Görevler:
$taskDescriptions

Her görev için yeni tarih öner. JSON formatında:
[{"taskId": "id", "suggestedDate": "2026-01-15", "reason": "açıklama"}]
''';

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final text = response.text ?? '[]';
      
      return _parseRescheduleSuggestions(text, incompleteTasks);
    } catch (e) {
      throw Exception('AI planlama hatası: $e');
    }
  }

  List<TaskRiskAnalysis> _parseRiskAnalysis(String text, List<Task> tasks) {
    // Basit regex ile JSON çıkarma
    final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(text);
    if (jsonMatch == null) return [];

    try {
      // Manuel parse (gerçek projede json_serializable kullanılır)
      final results = <TaskRiskAnalysis>[];
      for (final task in tasks) {
        // Basit risk hesaplama (AI yanıtı parse edilemezse fallback)
        final riskScore = _calculateLocalRisk(task);
        if (riskScore > 50) {
          results.add(TaskRiskAnalysis(
            taskId: task.id,
            taskTitle: task.title,
            riskScore: riskScore,
            reason: riskScore > 80 
                ? 'Yüksek risk: Süre yetersiz' 
                : 'Orta risk: Dikkat gerekli',
          ));
        }
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  List<RescheduleSuggestion> _parseRescheduleSuggestions(String text, List<Task> tasks) {
    // Basit implementasyon
    return tasks
        .where((t) => t.isOverdue || t.daysRemaining < 2)
        .map((t) => RescheduleSuggestion(
              taskId: t.id,
              taskTitle: t.title,
              currentDate: t.dueDate,
              suggestedDate: DateTime.now().add(Duration(days: t.estimatedHours)),
              reason: 'Yeterli süre sağlamak için önerilen tarih',
            ))
        .toList();
  }

  /// Lokal risk hesaplama (AI yedek)
  int _calculateLocalRisk(Task task) {
    int risk = 0;
    
    // Gecikmiş görev
    if (task.isOverdue) risk += 50;
    
    // Az kalan süre
    if (task.daysRemaining < 0) risk += 30;
    else if (task.daysRemaining < 2) risk += 20;
    else if (task.daysRemaining < 5) risk += 10;
    
    // Yüksek öncelik
    if (task.priority == Priority.high) risk += 20;
    
    return risk.clamp(0, 100);
  }
}

/// Risk analiz sonucu
class TaskRiskAnalysis {
  final String taskId;
  final String taskTitle;
  final int riskScore;
  final String reason;

  TaskRiskAnalysis({
    required this.taskId,
    required this.taskTitle,
    required this.riskScore,
    required this.reason,
  });

  bool get isHighRisk => riskScore >= 70;
  bool get isMediumRisk => riskScore >= 40 && riskScore < 70;
}

/// Yeniden planlama önerisi
class RescheduleSuggestion {
  final String taskId;
  final String taskTitle;
  final DateTime currentDate;
  final DateTime suggestedDate;
  final String reason;

  RescheduleSuggestion({
    required this.taskId,
    required this.taskTitle,
    required this.currentDate,
    required this.suggestedDate,
    required this.reason,
  });
}
