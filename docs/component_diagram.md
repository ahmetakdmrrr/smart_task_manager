# Smart Task Manager - Component Diagram

## Sistem Bileşen Diyagramı

```mermaid
flowchart TB
    subgraph UI["🖥️ Presentation Layer (UI)"]
        direction TB
        DS[Dashboard Screen]
        TDS[Task Detail Screen]
        
        subgraph Widgets["Widgets"]
            TC[Task Card]
            TF[Task Form]
            FB[Filter Bar]
            DepS[Dependency Selector]
            RI[Risk Indicator]
            APD[AI Planner Dialog]
        end
    end

    subgraph State["⚡ State Management Layer"]
        TP[Task Provider]
        FP[Filter Provider]
    end

    subgraph Services["🔧 Services Layer"]
        SS[Storage Service]
        AIS[AI Service]
    end

    subgraph Models["📦 Data Models"]
        TM[Task Model]
        DM[Dependency Model]
    end

    subgraph Storage["💾 Local Storage"]
        Hive[(Hive Database)]
    end

    subgraph External["🤖 External API"]
        Gemini[Gemini AI API]
    end

    %% UI to State connections
    DS --> TP
    DS --> FP
    TDS --> TP
    TC --> TP
    TF --> TP
    FB --> FP
    DepS --> TP
    RI --> AIS
    APD --> AIS

    %% State to Services connections
    TP --> SS
    TP --> AIS
    FP --> SS

    %% Services to Models
    SS --> TM
    SS --> DM
    AIS --> TM

    %% Services to External
    SS --> Hive
    AIS --> Gemini
```

## Bileşen Açıklamaları

### 🖥️ Presentation Layer (UI)

| Bileşen | Dosya | Açıklama |
|---------|-------|----------|
| Dashboard Screen | `screens/dashboard_screen.dart` | Ana görev listesi ve filtreleme ekranı |
| Task Detail Screen | `screens/task_detail_screen.dart` | Görev detay ve düzenleme ekranı |
| Task Card | `widgets/task_card.dart` | Görev kartı (liste görünümü) |
| Task Form | `widgets/task_form.dart` | Görev ekleme/düzenleme formu |
| Filter Bar | `widgets/filter_bar.dart` | Öncelik ve tarih filtreleme |
| Dependency Selector | `widgets/dependency_selector.dart` | Öncül görev seçici |
| Risk Indicator | `widgets/risk_indicator.dart` | Gecikme riski göstergesi (🔴) |
| AI Planner Dialog | `widgets/ai_planner_dialog.dart` | AI yeniden planlama önerisi |

### ⚡ State Management Layer

| Bileşen | Dosya | Açıklama |
|---------|-------|----------|
| Task Provider | `providers/task_provider.dart` | Görev CRUD ve state yönetimi |
| Filter Provider | `providers/filter_provider.dart` | Filtreleme state yönetimi |

### 🔧 Services Layer

| Bileşen | Dosya | Açıklama |
|---------|-------|----------|
| Storage Service | `services/storage_service.dart` | Hive ile yerel veri saklama |
| AI Service | `services/ai_service.dart` | Gecikme riski analizi ve planlama |

### 📦 Data Models

| Bileşen | Dosya | Açıklama |
|---------|-------|----------|
| Task Model | `models/task_model.dart` | Görev veri yapısı |
| Dependency Model | `models/dependency_model.dart` | Bağımlılık ilişki yapısı |

---

## Veri Akışı

```mermaid
sequenceDiagram
    participant U as Kullanıcı
    participant UI as Dashboard
    participant TP as TaskProvider
    participant SS as StorageService
    participant AIS as AIService
    participant H as Hive DB

    U->>UI: Görev Ekle
    UI->>TP: addTask(task)
    TP->>SS: save(task)
    SS->>H: put(task)
    H-->>SS: success
    SS-->>TP: Task saved
    TP-->>UI: State güncelle
    UI-->>U: Liste yenilendi

    U->>UI: AI Planla butonu
    UI->>AIS: analyzeAndReplan(tasks)
    AIS->>AIS: Risk hesapla
    AIS-->>UI: Öneri listesi
    UI-->>U: Öneri dialogu göster
```
