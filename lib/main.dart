import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/task_provider.dart';
import 'providers/filter_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // .env dosyasını yükle (opsiyonel - AI özelliği için)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ .env dosyası bulunamadı, AI özellikleri devre dışı.');
  }

  
  // Türkçe tarih formatı için
  await initializeDateFormatting('tr_TR', null);
  
  // Hive başlat
  await StorageService().init();
  
  runApp(const SmartTaskManagerApp());
}

class SmartTaskManagerApp extends StatelessWidget {
  const SmartTaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider()..loadTasks(),
        ),
        ChangeNotifierProvider(
          create: (_) => FilterProvider(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Smart Task Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        // Dark theme'i default yap
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),
    );
  }
}
