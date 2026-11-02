import 'package:flutter_test/flutter_test.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/nutrition_suggestions/domain/models/meal_suggestion.dart';
import 'package:dnevnik/features/nutrition_suggestions/data/meal_suggestions_service.dart';

void main() {
  group('RemainingBudget — расчет остатка и коридора нормы', () {
    test('Вычисляет остаток КБЖУ корректно', () {
      const budget = RemainingBudget(
        targetCalories: 2000,
        targetProtein: 140,
        targetFat: 65,
        targetCarbs: 210,
        consumedCalories: 1350,
        consumedProtein: 90,
        consumedFat: 45,
        consumedCarbs: 145,
      );

      expect(budget.remainingCalories, equals(650));
      expect(budget.remainingProtein, equals(50));
      expect(budget.remainingFat, equals(20));
      expect(budget.remainingCarbs, equals(65));
      expect(budget.hasRemainingCalories, isTrue);
    });

    test('Коридор нормы: отклонение до +-10г по БЖУ и +-150 ккал допустимо', () {
      const budget = RemainingBudget(
        targetCalories: 2000,
        targetProtein: 120,
        targetFat: 60,
        targetCarbs: 200,
        consumedCalories: 1600,
        consumedProtein: 90,
        consumedFat: 48,
        consumedCarbs: 160,
      );

      // Остаток: 400 ккал, 30г белка, 12г жиров, 40г углей
      // Проверяем блюдо на 440 ккал, 38г белка, 18г жиров, 42г углей (превышение в пределах 10г)
      final fits = budget.fitsWithinCorridor(
        itemCalories: 440,
        itemProtein: 38,
        itemFat: 18,
        itemCarbs: 42,
        toleranceGrams: 10.0,
        toleranceCals: 150.0,
      );

      expect(fits, isTrue, reason: 'Блюдо в пределах допустимого коридора +-10г должно подходить');
    });

    test('Блюдо с сильным перебором (>10г жиров/белка или >150 ккал) отсекается', () {
      const budget = RemainingBudget(
        targetCalories: 2000,
        targetProtein: 120,
        targetFat: 60,
        targetCarbs: 200,
        consumedCalories: 1800,
        consumedProtein: 110,
        consumedFat: 55,
        consumedCarbs: 190,
      );

      // Остаток: 200 ккал, 10г белка, 5г жиров, 10г углей
      // Проверяем жирную пиццу 600 ккал, 35г жиров
      final fits = budget.fitsWithinCorridor(
        itemCalories: 600,
        itemProtein: 25,
        itemFat: 35,
        itemCarbs: 55,
      );

      expect(fits, isFalse);
    });
  });

  group('MealSuggestionsService — умный подбор блюд', () {
    const service = MealSuggestionsService();

    final testFoods = [
      FoodProduct(
        id: 1,
        name: 'Творог 5%',
        category: 'dairy',
        caloriesPer100g: 121,
        proteinPer100g: 16,
        fatPer100g: 5,
        carbsPer100g: 3,
        servingSizeG: 100,
        sourceType: 'base',
        isFavorite: true,
        createdAt: DateTime(2026, 1, 1),
      ),
      FoodProduct(
        id: 2,
        name: 'Куриное филе',
        category: 'meat',
        caloriesPer100g: 110,
        proteinPer100g: 23,
        fatPer100g: 1.5,
        carbsPer100g: 0,
        servingSizeG: 100,
        sourceType: 'base',
        isFavorite: true,
        createdAt: DateTime(2026, 1, 1),
      ),
      FoodProduct(
        id: 3,
        name: 'Яблоко свежее',
        category: 'fruits',
        caloriesPer100g: 52,
        proteinPer100g: 0.3,
        fatPer100g: 0.2,
        carbsPer100g: 14,
        servingSizeG: 100,
        sourceType: 'base',
        isFavorite: false,
        createdAt: DateTime(2026, 1, 1),
      ),
      FoodProduct(
        id: 4,
        name: 'Огурцы свежие',
        category: 'vegetables',
        caloriesPer100g: 15,
        proteinPer100g: 0.8,
        fatPer100g: 0.1,
        carbsPer100g: 2.8,
        servingSizeG: 100,
        sourceType: 'base',
        isFavorite: false,
        createdAt: DateTime(2026, 1, 1),
      ),
    ];

    test('При дефиците белка рекомендует белковые варианты с рассчитанной порцией', () {
      const budget = RemainingBudget(
        targetCalories: 2000,
        targetProtein: 140,
        targetFat: 60,
        targetCarbs: 220,
        consumedCalories: 1400,
        consumedProtein: 95,
        consumedFat: 48,
        consumedCarbs: 170,
      );

      final suggestions = service.generateSuggestions(
        budget: budget,
        foods: testFoods,
        recipes: [],
        preferredMealType: 'dinner',
      );

      expect(suggestions, isNotEmpty);
      final chicken = suggestions.firstWhere((s) => s.title.contains('Куриное филе'));
      expect(chicken.categoryTag, equals('protein'));
      expect(chicken.protein, greaterThanOrEqualTo(20));
      expect(chicken.suggestedGrams, greaterThanOrEqualTo(90));
    });

    test('При минимальном остатке калорий (<60 ккал) предлагает травяной чай или огурцы', () {
      const budget = RemainingBudget(
        targetCalories: 2000,
        targetProtein: 120,
        targetFat: 60,
        targetCarbs: 200,
        consumedCalories: 1980,
        consumedProtein: 118,
        consumedFat: 59,
        consumedCarbs: 198,
      );

      final suggestions = service.generateSuggestions(
        budget: budget,
        foods: testFoods,
        recipes: [],
        preferredMealType: 'dinner',
      );

      expect(suggestions, isNotEmpty);
      expect(suggestions.any((s) => s.title.contains('чай') || s.title.contains('огур')), isTrue);
    });
  });
}
