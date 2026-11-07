import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/food_database/domain/models/combo_item.dart';
import 'package:dnevnik/features/food_database/presentation/widgets/serving_size_sheet.dart';
import 'package:dnevnik/features/food_database/presentation/widgets/combo_builder_sheet.dart';
import 'package:dnevnik/features/food_database/presentation/widgets/saved_combo_sheet.dart';
import 'package:dnevnik/features/recipes/domain/models/recipe_model.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru_RU', null);
  });

  group('Combo Hybrid Flow Widget Tests', () {
    late AppDatabase testDb;
    final now = DateTime.now();

    final bread = FoodProduct(
      id: 1,
      name: 'Хлеб тостовый',
      brand: 'Коломенское',
      caloriesPer100g: 250.0,
      proteinPer100g: 8.0,
      fatPer100g: 3.0,
      carbsPer100g: 48.0,
      category: 'bakery',
      sourceType: 'standard',
      servingSizeG: 40.0,
      isFavorite: false,
      createdAt: now,
    );

    final cheese = FoodProduct(
      id: 2,
      name: 'Сыр Гауда',
      brand: 'Брест-Литовск',
      caloriesPer100g: 350.0,
      proteinPer100g: 25.0,
      fatPer100g: 27.0,
      carbsPer100g: 0.0,
      category: 'dairy',
      sourceType: 'standard',
      servingSizeG: 30.0,
      isFavorite: false,
      createdAt: now,
    );

    setUp(() {
      testDb = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await testDb.close();
    });

    testWidgets('ServingSizeSheet "+ В комбо" button pops with ComboIngredientItem',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      dynamic poppedResult;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            diaryDaoProvider.overrideWithValue(testDb.diaryDao),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    poppedResult = await showModalBottomSheet(
                      context: context,
                      builder: (_) => ServingSizeSheet(
                        product: bread,
                        initialMealType: 'breakfast',
                        date: now,
                      ),
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('+ В комбо'), findsOneWidget);

      await tester.tap(find.text('+ В комбо'));
      await tester.pumpAndSettle();

      expect(poppedResult, isNotNull);
      expect(poppedResult, isA<ComboIngredientItem>());
      final item = poppedResult as ComboIngredientItem;
      expect(item.product.name, equals('Хлеб тостовый'));
      expect(item.grams, equals(40.0));
    });

    testWidgets('ComboBuilderSheet logs combo to diary and saves template',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final items = [
        ComboIngredientItem(product: bread, grams: 40),
        ComboIngredientItem(product: cheese, grams: 30),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            diaryDaoProvider.overrideWithValue(testDb.diaryDao),
            recipeDaoProvider.overrideWithValue(testDb.recipeDao),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ComboBuilderSheet(
                initialItems: items,
                initialMealType: 'breakfast',
                date: now,
                onAddMore: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Проверяем отображение ингредиентов
      expect(find.text('Хлеб тостовый'), findsOneWidget);
      expect(find.text('Сыр Гауда'), findsOneWidget);

      // Проверяем суммарные калории (Хлеб 40г = 100 ккал, Сыр 30г = 105 ккал -> 205 ккал)
      expect(find.textContaining('205'), findsWidgets);

      // Включаем чекбокс сохранения в шаблоны
      final checkbox = find.textContaining('Мои комбо');
      expect(checkbox, findsOneWidget);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Нажимаем "Записать в завтрак"
      final submitButton = find.textContaining('Записать в завтрак');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Проверяем запись в DiaryDao
      final entries = await testDb.diaryDao.getEntriesForDate(now);
      expect(entries.length, equals(1));
      final entry = entries.first;
      expect(entry.customName, equals('Хлеб тостовый + Сыр Гауда'));
      expect(entry.notes, contains('Хлеб тостовый 40г'));
      expect(entry.notes, contains('Сыр Гауда 30г'));
      expect(entry.calculatedCalories, closeTo(205.0, 0.5));

      // Проверяем сохраненный шаблон в RecipeDao
      final combos = await testDb.recipeDao.watchCombosWithDetails().first;
      expect(combos.length, equals(1));
      expect(combos.first.recipe.name, equals('Хлеб тостовый + Сыр Гауда'));
      expect(combos.first.recipe.category, equals('combo'));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('SavedComboSheet scales portions and logs to diary',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final recipe = Recipe(
        id: 99,
        name: 'Любимый бутерброд',
        category: 'combo',
        servings: 1,
        prepTimeMinutes: 3,
        isFavorite: true,
        createdAt: now,
      );

      final ingredients = [
        RecipeIngredientWithFood(
          ingredient: const RecipeIngredient(
            id: 1,
            recipeId: 99,
            foodProductId: 1,
            grams: 40,
          ),
          product: bread,
        ),
        RecipeIngredientWithFood(
          ingredient: const RecipeIngredient(
            id: 2,
            recipeId: 99,
            foodProductId: 2,
            grams: 30,
          ),
          product: cheese,
        ),
      ];

      final comboWithDetails = RecipeWithDetails(
        recipe: recipe,
        ingredients: ingredients,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            diaryDaoProvider.overrideWithValue(testDb.diaryDao),
            recipeDaoProvider.overrideWithValue(testDb.recipeDao),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SavedComboSheet(
                combo: comboWithDetails,
                initialMealType: 'lunch',
                date: now,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Любимый бутерброд'), findsOneWidget);
      expect(find.text('Хлеб тостовый'), findsOneWidget);
      expect(find.text('Сыр Гауда'), findsOneWidget);

      // Переключаем на 1.5 порции
      final chip15x = find.text('1.5 порц.');
      expect(chip15x, findsOneWidget);
      await tester.tap(chip15x);
      await tester.pumpAndSettle();

      // Нажимаем Записать в обед
      final submitButton = find.textContaining('Записать в обед');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Проверяем запись в DiaryDao (должно быть 205 * 1.5 = 307.5 ккал)
      final entries = await testDb.diaryDao.getEntriesForDate(now);
      expect(entries.length, equals(1));
      final entry = entries.first;
      expect(entry.mealType, equals('lunch'));
      expect(entry.customName, equals('Любимый бутерброд (1.5 порц.)'));
      expect(entry.calculatedCalories, closeTo(307.5, 1.0));
      expect(entry.notes, contains('60г')); // 40г * 1.5
      expect(entry.notes, contains('45г')); // 30г * 1.5

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
