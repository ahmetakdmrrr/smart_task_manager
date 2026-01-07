# AI Hata ve Eksiklik Raporu
## Smart Task Manager - Yapay Zeka Destekli Geliştirme

**Proje:** Smart Task Manager  
**Tarih:** 07 Ocak 2026  
**AI Aracı:** Gemini (Antigravity)

---

## 1. Özet

Bu rapor, Smart Task Manager projesinin geliştirilmesi sırasında AI (yapay zeka) tarafından üretilen kodlardaki **hatalı veya eksik çıktıları** belgelemektedir. Toplam **8 adet hata/eksiklik** tespit edilmiş ve düzeltilmiştir.

---

## 2. AI Hataları ve Düzeltmeleri

### 2.1 CardTheme vs CardThemeData API Hatası ⭐

| Özellik | Değer |
|---------|-------|
| **Dosya** | `lib/core/theme/app_theme.dart` |
| **Hata Türü** | Compile Error |
| **Şiddet** | Yüksek (Derleme engelliyor) |

**Yanlış Kod:**
```dart
cardTheme: CardTheme(
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
),
```

**Doğru Kod:**
```dart
cardTheme: const CardThemeData(
  elevation: 2,
),
```

**Neden:** Flutter 3.x ve Material 3 ile API değişikliği. AI eski Flutter bilgisine dayanarak kod üretti.

---

### 2.2 GoRouter Route Sıralama Hatası ⭐

| Özellik | Değer |
|---------|-------|
| **Dosya** | `lib/core/router/app_router.dart` |
| **Hata Türü** | Logic Error |
| **Şiddet** | Orta (Yanlış sayfa yönlendirmesi) |

**Yanlış Sıralama:**
```dart
routes: [
  GoRoute(path: '/task/:id', ...),  // "new" kelimesi ID olarak algılanıyor!
  GoRoute(path: '/task/new', ...),
]
```

**Doğru Sıralama:**
```dart
routes: [
  GoRoute(path: '/task/new', ...),  // Önce spesifik route
  GoRoute(path: '/task/:id', ...),  // Sonra parametreli route
]
```

**Neden:** GoRouter'da spesifik route'lar parametreli route'lardan önce gelmeli. AI bu kurala uymadı.

---

### 2.3 Import Path Hataları

| Özellik | Değer |
|---------|-------|
| **Dosya** | `lib/core/router/app_router.dart` |
| **Hata Türü** | Compile Error |
| **Şiddet** | Yüksek |

**Yanlış:** `import '../screens/dashboard_screen.dart';`  
**Doğru:** `import '../../screens/dashboard_screen.dart';`

**Neden:** Klasör yapısı derinliği yanlış hesaplandı.

---

### 2.4 .env Dosyası Exception Handling Eksikliği

| Özellik | Değer |
|---------|-------|
| **Dosya** | `lib/main.dart` |
| **Hata Türü** | Runtime Crash |
| **Şiddet** | Yüksek |

**Yanlış:**
```dart
await dotenv.load(fileName: '.env');  // Dosya yoksa crash!
```

**Doğru:**
```dart
try {
  await dotenv.load(fileName: '.env');
} catch (e) {
  debugPrint('⚠️ .env dosyası bulunamadı');
}
```

---

### 2.5 withOpacity Deprecation Uyarıları

| Özellik | Değer |
|---------|-------|
| **Dosya** | Birçok widget dosyası |
| **Hata Türü** | Deprecation Warning (11 adet) |
| **Şiddet** | Düşük |

**Kullanılan:** `Colors.amber.withOpacity(0.1)`  
**Önerilen:** `Colors.amber.withValues(alpha: 0.1)`

---

### 2.6 Test Dosyasında Yanlış Sınıf Adı

| Özellik | Değer |
|---------|-------|
| **Dosya** | `test/widget_test.dart` |
| **Hata Türü** | Compile Error |

**Yanlış:** `await tester.pumpWidget(const MyApp());`  
**Doğru:** `await tester.pumpWidget(const SmartTaskManagerApp());`

---

### 2.7 Geçersiz Flutter CLI Flag

| Özellik | Değer |
|---------|-------|
| **Komut** | Terminal |
| **Hata Türü** | CLI Error |

**Yanlış:** `flutter build web --web-renderer html`  
**Doğru:** `flutter build web`

---

### 2.8 Eksik Model Validasyonu (Edge Case)

| Özellik | Değer |
|---------|-------|
| **Dosya** | `lib/models/task_model.dart` |
| **Hata Türü** | Missing Validation |
| **Şiddet** | Orta |

**Sorun:** `estimatedHours` alanı negatif değer kabul ediyor.

```dart
// Bu geçersiz değer kabul ediliyor!
Task(
  id: '1',
  title: 'Test',
  dueDate: DateTime.now(),
  estimatedHours: -5,  // Geçersiz!
);
```

**Önerilen Düzeltme:**
```dart
Task({
  required this.estimatedHours,
}) : assert(estimatedHours > 0, 'estimatedHours must be positive');
```

---

## 3. Hata Özeti

| # | Hata | Tür | Şiddet | Durum |
|---|------|-----|--------|-------|
| 1 | CardTheme API | Compile | Yüksek | ✅ Düzeltildi |
| 2 | Route Sıralaması | Logic | Orta | ✅ Düzeltildi |
| 3 | Import Path | Compile | Yüksek | ✅ Düzeltildi |
| 4 | Dotenv Exception | Runtime | Yüksek | ✅ Düzeltildi |
| 5 | withOpacity | Warning | Düşük | ⚠️ Uyarı |
| 6 | Test Sınıf Adı | Compile | Yüksek | ✅ Düzeltildi |
| 7 | CLI Flag | CLI | Orta | ✅ Düzeltildi |
| 8 | Validasyon Eksik | Logic | Orta | ⚠️ Raporlandı |

---

## 4. Sonuç

AI destekli kod üretimi hızlı prototipleme sağlasa da, **manuel kod incelemesi ve test** kritik öneme sahiptir. Bu projede tespit edilen 8 hata, AI'ın güncel API değişikliklerini takip etmede ve edge-case senaryolarında eksik kalabileceğini göstermektedir.

**Öneriler:**
1. AI çıktılarını her zaman derleyici ve linter ile doğrulayın
2. Edge-case senaryoları için unit test yazın
3. API değişikliklerini resmi dokümantasyondan kontrol edin
