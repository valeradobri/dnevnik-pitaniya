import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // Создаем свежую in-memory базу данных для каждого теста
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase & DAOs — Integration Tests', () {
    test('База данных успешно сидируется начальными продуктами и достижениями', () async {
      final foods = await db.foodDao.getAllFoods();
      expect(foods.length, greaterThanOrEqualTo(50));

      final achievements = await db.select(db.achievements).get();
      expect(achievements.length, greaterThanOrEqualTo(5));
    });

    test('FoodDao — поиск и фильтрация продуктов', () async {
      final buckwheat = await db.foodDao.searchFoods('греч');
      expect(buckwheat, isNotEmpty);
      expect(buckwheat.first.name.toLowerCase(), contains('греч'));

      final chicken = await db.foodDao.searchFoods('куриное', category: 'meat');
      expect(chicken, isNotEmpty);
      expect(chicken.first.category, equals('meat'));
    });

    test('FoodDao — добавление в избранное', () async {
      final allFoods = await db.foodDao.getAllFoods();
      final first = allFoods.first;

      await db.foodDao.toggleFavorite(first.id, true);
      final favorites = await db.foodDao.watchFavorites().first;
      expect(favorites.any((f) => f.id == first.id), isTrue);

      await db.foodDao.toggleFavorite(first.id, false);
      final updatedFavorites = await db.foodDao.watchFavorites().first;
      expect(updatedFavorites.any((f) => f.id == first.id), isFalse);
    });

    test('DiaryDao — добавление, получение и подсчет КБЖУ за день', () async {
      final today = DateTime.now();

      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'breakfast',
          foodProductId: 1,
          customName: 'Овсяная каша',
          grams: 200,
          calculatedCalories: 176.0,
          calculatedProtein: 6.0,
          calculatedFat: 3.4,
          calculatedCarbs: 30.0,
          entryDate: today,
        ),
      );

      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'lunch',
          foodProductId: 2,
          customName: 'Куриное филе',
          grams: 150,
          calculatedCalories: 229.5,
          calculatedProtein: 45.6,
          calculatedFat: 5.25,
          calculatedCarbs: 0.0,
          entryDate: today,
        ),
      );

      final entries = await db.diaryDao.getEntriesForDate(today);
      expect(entries.length, equals(2));

      final totals = await db.diaryDao.watchTotalsForDate(today).first;
      expect(totals.calories, closeTo(405.5, 0.1));
      expect(totals.protein, closeTo(51.6, 0.1));
      expect(totals.fat, closeTo(8.65, 0.1));
      expect(totals.carbs, closeTo(30.0, 0.1));

      // Удаление записи
      await db.diaryDao.deleteEntry(entries.first.id);
      final remaining = await db.diaryDao.getEntriesForDate(today);
      expect(remaining.length, equals(1));
    });

    test('UserDao — сохранение профиля и обновление веса', () async {
      final profile = UserProfilesCompanion.insert(
        name: 'Валерий',
        birthDate: DateTime(1995, 5, 20),
        gender: 'male',
        heightCm: 180.0,
        currentWeightKg: 82.5,
        targetWeightKg: 75.0,
        activityLevel: 'moderate',
        goalType: 'lose_weight',
        targetCalories: 2100,
        targetProteinG: 160.0,
        targetFatG: 70.0,
        targetCarbsG: 210.0,
        targetWaterMl: 2700,
      );

      final id = await db.userDao.saveProfile(profile);
      expect(id, isPositive);

      final loaded = await db.userDao.getProfile();
      expect(loaded, isNotNull);
      expect(loaded!.name, equals('Валерий'));
      expect(loaded.currentWeightKg, equals(82.5));

      // Обновление текущего веса
      await db.userDao.updateWeight(81.8);
      final updated = await db.userDao.getProfile();
      expect(updated!.currentWeightKg, equals(81.8));
    });

    test('WaterDao — учет и сброс воды', () async {
      final today = DateTime.now();

      await db.waterDao.addWater(today, 250);
      await db.waterDao.addWater(today, 500);

      final total = await db.waterDao.watchTotalWaterMlForDate(today).first;
      expect(total, equals(750));

      await db.waterDao.resetWaterForDate(today);
      final afterReset = await db.waterDao.watchTotalWaterMlForDate(today).first;
      expect(afterReset, equals(0));
    });

    test('WeightDao — добавление взвешиваний и получение последнего', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();

      await db.weightDao.addWeight(weightKg: 83.0, date: yesterday);
      await db.weightDao.addWeight(weightKg: 82.3, date: today, notes: 'Утреннее натощак');

      final latest = await db.weightDao.getLatestWeight();
      expect(latest, isNotNull);
      expect(latest!.weightKg, equals(82.3));
      expect(latest.notes, equals('Утреннее натощак'));
    });

    test('RecipeDao — сидирование и проверка правильной привязки сыра (не куриное филе)', () async {
      await db.recipeDao.seedInitialRecipes();
      final recipes = await db.recipeDao.watchAllRecipes().first;
      expect(recipes.length, greaterThanOrEqualTo(5));

      final pancake = recipes.firstWhere((r) => r.name.contains('Овсяноблин'));
      final details = await db.recipeDao.getRecipeWithDetails(pancake.id);
      expect(details, isNotNull);

      final cheeseItem = details!.ingredients.firstWhere((i) => i.ingredient.notes == 'Сыр');
      expect(cheeseItem.product.name.toLowerCase(), contains('сыр'));
      expect(cheeseItem.product.name.toLowerCase(), isNot(contains('куриное')));
    });

    test('AchievementDao — синхронизация и разблокировка первого достижения', () async {
      await db.achievementDao.syncAchievements();
      var achievements = await db.achievementDao.getAchievementsWithStatus();
      expect(achievements.length, greaterThanOrEqualTo(6));

      // Изначально записей нет — ни одно не открыто
      final firstEntryAch = achievements.firstWhere((a) => a.achievement.key == 'first_entry');
      expect(firstEntryAch.isUnlocked, isFalse);

      // Добавляем запись в дневник
      final today = DateTime.now();
      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'lunch',
          foodProductId: 1,
          customName: 'Куриная грудка',
          grams: 150,
          calculatedCalories: 165.0,
          calculatedProtein: 35.0,
          calculatedFat: 2.0,
          calculatedCarbs: 0.0,
          entryDate: today,
        ),
      );

      // Синхронизируем
      await db.achievementDao.syncAchievements();
      achievements = await db.achievementDao.getAchievementsWithStatus();

      final updatedFirstAch = achievements.firstWhere((a) => a.achievement.key == 'first_entry');
      expect(updatedFirstAch.isUnlocked, isTrue);
      expect(updatedFirstAch.currentCount, equals(1));
      expect(updatedFirstAch.unlockedAt, isNotNull);

      // Проверяем HabitStats
      final stats = await db.achievementDao.getHabitStats();
      expect(stats.currentStreak, equals(1));
      expect(stats.totalActiveDays, equals(1));
      expect(stats.unlockedAchievementsCount, greaterThanOrEqualTo(1));
    });

    test('MealPlanDao — watchShoppingList реактивно обновляется при удалении и поддерживает фильтр onlyFromToday', () async {
      final now = DateTime.now();
      final monday = db.mealPlanDao.startOfWeek(now);
      final sunday = monday.add(const Duration(days: 6));

      // Создаем недельный план
      final plan = await db.mealPlanDao.getOrCreatePlanForWeek(monday);

      // Получаем рецепты
      final recipes = await db.recipeDao.watchAllRecipes().first;
      expect(recipes, isNotEmpty);
      final recipe1 = recipes[0];
      final recipe2 = recipes.length > 1 ? recipes[1] : recipes[0];

      // Добавляем рецепт на понедельник (прошлый день, если сегодня не пн)
      final pastDate = DateTime(monday.year, monday.month, monday.day);
      final item1Id = await db.mealPlanDao.addPlanItem(
        mealPlanId: plan.id,
        recipeId: recipe1.id,
        plannedDate: pastDate,
        mealType: 'breakfast',
      );

      // Добавляем рецепт на воскресенье (будущий день, если сегодня не вс)
      final futureDate = DateTime(sunday.year, sunday.month, sunday.day);
      await db.mealPlanDao.addPlanItem(
        mealPlanId: plan.id,
        recipeId: recipe2.id,
        plannedDate: futureDate,
        mealType: 'dinner',
      );

      // Проверяем, что в списке всей недели есть ингредиенты
      final fullWeekList = await db.mealPlanDao.watchShoppingList(monday).first;
      expect(fullWeekList, isNotEmpty);

      // Удаляем рецепт с понедельника
      await db.mealPlanDao.deletePlanItem(item1Id);

      // Проверяем, что список мгновенно и реактивно обновился
      final updatedList = await db.mealPlanDao.watchShoppingList(monday).first;
      // Если recipe1 и recipe2 разные, размер изменится
      if (recipe1.id != recipe2.id) {
        expect(updatedList.length, isNot(equals(fullWeekList.length)));
      }

      // Проверяем работу фильтра onlyFromToday
      final todayList = await db.mealPlanDao.watchShoppingList(monday, onlyFromToday: true).first;
      expect(todayList, isNotEmpty); // воскресный рецепт остается
    });
  });
}

