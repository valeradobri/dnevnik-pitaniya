import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';

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

  runApp(
    ProviderScope(
      child: DnevnikApp(prefs: prefs),
    ),
  );
}
