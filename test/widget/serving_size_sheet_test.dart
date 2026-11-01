import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/food_database/presentation/widgets/serving_size_sheet.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru_RU', null);
  });

  group('ServingSizeSheet — Dry vs Cooked Mode Widget Tests', () {
    late AppDatabase testDb;

    setUp(() {
      testDb = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await testDb.close();
    });

    final testProduct = FoodProduct(
      id: 1,
      name: 'Гречневая крупа (ядрица, сухая)',
      brand: 'Агро-Альянс',
      caloriesPer100g: 313.0,
      proteinPer100g: 12.6,
      fatPer100g: 3.3,
      carbsPer100g: 62.1,
      category: 'cereals',
      sourceType: 'verified',
      servingSizeG: 100.0,
      isFavorite: false,
      createdAt: DateTime.now(),
    );

    testWidgets('ServingSizeSheet renders segmented toggle and switches between dry and cooked modes',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            diaryDaoProvider.overrideWithValue(testDb.diaryDao),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ServingSizeSheet(
                product: testProduct,
                initialMealType: 'lunch',
                date: DateTime.now(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Проверяем отображение заголовка и бренда
      expect(find.text('Гречневая крупа (ядрица, сухая)'), findsOneWidget);
      expect(find.text('Агро-Альянс'), findsOneWidget);

      // Проверяем наличие сегментированного переключателя
      expect(find.text('В сухом / сыром'), findsOneWidget);
      expect(find.text('В готовом виде'), findsOneWidget);

      // По умолчанию режим сухого продукта
      expect(find.textContaining('после готовки выйдет'), findsOneWidget);

      // Переключаемся в режим «В готовом виде»
      await tester.tap(find.text('В готовом виде'));
      await tester.pumpAndSettle();

      // Проверяем появление плашки разваривания и коэффициента готовки
      expect(find.textContaining('В тарелке:'), findsOneWidget);
      expect(find.textContaining('Коэфф. разваривания'), findsOneWidget);
      expect(find.text('2.5'), findsOneWidget);

      // Нажимаем кнопку добавления в дневник
      final submitButton = find.textContaining('Добавить готовую порцию');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Проверяем, что в БД дневника появилась запись
      final entries = await testDb.diaryDao.getEntriesForDate(DateTime.now());
      expect(entries.length, equals(1));
      final entry = entries.first;
      expect(entry.customName, contains('Гречневая крупа'));
      expect(entry.notes, contains('В готовом виде'));

      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('ServingSizeSheet does NOT show cooking toggle for ready-to-eat foods like Avocado',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final avocado = FoodProduct(
        id: 2,
        name: 'Авокадо свежее',
        brand: null,
        caloriesPer100g: 160.0,
        proteinPer100g: 2.0,
        fatPer100g: 14.7,
        carbsPer100g: 1.8,
        category: 'fruits',
        sourceType: 'verified',
        servingSizeG: 100.0,
        isFavorite: false,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            diaryDaoProvider.overrideWithValue(testDb.diaryDao),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ServingSizeSheet(
                product: avocado,
                initialMealType: 'breakfast',
                date: DateTime.now(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Проверяем название
      expect(find.text('Авокадо свежее'), findsOneWidget);

      // Проверяем, что НЕТ тумблера «В сухом / сыром» и «В готовом виде»
      expect(find.text('В сухом / сыром'), findsNothing);
      expect(find.text('В готовом виде'), findsNothing);
      expect(find.textContaining('Коэфф.'), findsNothing);

      // Проверяем обычный лаконичный интерфейс
      expect(find.text('Размер порции'), findsOneWidget);
      expect(find.textContaining('Добавить в дневник'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}

