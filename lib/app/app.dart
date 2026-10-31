import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Корневой виджет приложения «Дневник»
///
/// Подключает:
/// - GoRouter (навигация с условным редиректом на онбординг)
/// - Светлую и тёмную Material 3 темы
/// - Русский язык интерфейса
class DnevnikApp extends StatelessWidget {
  const DnevnikApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final router = createRouter(prefs);

    return MaterialApp.router(
      title: 'Дневник питания',
      debugShowCheckedModeBanner: false,

      // Темы
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Навигация
      routerConfig: router,

      // Локализация
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [
        Locale('ru', 'RU'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
