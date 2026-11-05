import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'features/notifications/data/repositories/notification_preferences_repository.dart';
import 'features/notifications/data/services/notification_service.dart';
import 'features/notifications/presentation/providers/notification_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация русской локализации для форматирования дат
  await initializeDateFormatting('ru_RU', null);

  // Фиксируем портретную ориентацию
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Загружаем SharedPreferences до запуска приложения
  final prefs = await SharedPreferences.getInstance();

  // Инициализация сервиса локальных ненавязчивых напоминаний
  final notificationService = NotificationService();
  await notificationService.initialize();
  final notificationRepo = NotificationPreferencesRepository(prefs);
  if (notificationRepo.isMasterEnabled()) {
    final settings = notificationRepo.loadSettings();
    for (final s in settings) {
      if (s.isEnabled) {
        await notificationService.scheduleDailyReminder(s);
      }
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationPreferencesRepoProvider.overrideWithValue(notificationRepo),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: DnevnikApp(prefs: prefs),
    ),
  );
}
