import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/recipes/presentation/screens/nutrition_screen.dart';
import 'package:dnevnik/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:dnevnik/features/water/presentation/widgets/water_history_sheet.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru_RU', null);
  });

  group('Phase 3 Screens Widget Tests', () {
    late AppDatabase testDb;

    setUp(() {
      testDb = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await testDb.close();
    });

    testWidgets('NutritionScreen renders tabs and switches between Recipes and Meal Planner',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
          ],
          child: const MaterialApp(
            home: NutritionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Питание и меню'), findsOneWidget);
      expect(find.text('Книга рецептов'), findsOneWidget);
      expect(find.text('План & Покупки'), findsOneWidget);

      // Проверяем наличие поиска в рецептах
      expect(find.byType(TextField), findsOneWidget);

      // Переключаемся на вкладку "План & Покупки"
      await tester.tap(find.text('План & Покупки'));
      await tester.pumpAndSettle();

      // Проверяем элементы планировщика (Пн, Вт, Ср...)
      expect(find.text('Пн'), findsOneWidget);
      expect(find.text('Вт'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('AnalyticsScreen renders period selector and charts',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
          ],
          child: const MaterialApp(
            home: AnalyticsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Статистика'), findsOneWidget);
      expect(find.text('7 дней'), findsOneWidget);
      expect(find.text('30 дней'), findsOneWidget);
      expect(find.text('90 дней'), findsOneWidget);

      expect(find.text('Калории и норма'), findsOneWidget);
      expect(find.text('Баланс БЖУ'), findsOneWidget);
      expect(find.text('Динамика веса'), findsOneWidget);
      expect(find.text('Водный баланс'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('WaterHistorySheet displays daily water progress and controls',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final today = DateTime.now();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WaterHistorySheet(date: today),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Журнал гидратации'), findsOneWidget);
      expect(find.text('+150 мл'), findsOneWidget);
      expect(find.text('+250 мл'), findsOneWidget);
      expect(find.text('+500 мл'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
