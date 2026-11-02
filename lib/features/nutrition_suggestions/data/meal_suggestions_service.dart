import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/nutrition_calculator.dart';
import '../../recipes/domain/models/recipe_model.dart';
import '../domain/models/meal_suggestion.dart';

/// Интеллектуальный сервис подбора блюд и продуктов под оставшийся бюджет БЖУ
class MealSuggestionsService {
  const MealSuggestionsService();

  /// Подобрать рекомендации под текущий остаток БЖУ и приём пищи
  List<MealSuggestion> generateSuggestions({
    required RemainingBudget budget,
    required List<FoodProduct> foods,
    required List<RecipeWithDetails> recipes,
    String preferredMealType = 'dinner',
  }) {
    final suggestions = <MealSuggestion>[];

    // Если калорий осталось совсем мало (<60 ккал), предлагаем легкие бережные перекусы
    if (budget.remainingCalories < 60) {
      _addUltraLightOptions(suggestions, foods, preferredMealType);
      return suggestions;
    }

    // ── 1. Подбор из книги рецептов ─────────────────────────────────────
    for (final recipeWithDetails in recipes) {
      final serving = recipeWithDetails.nutrientsPerServing;
      final recipe = recipeWithDetails.recipe;

      // Проверяем, укладывается ли порция в остаток с учетом коридора нормы (±10г БЖУ, ±150 ккал)
      final fits = budget.fitsWithinCorridor(
        itemCalories: serving.calories,
        itemProtein: serving.protein,
        itemFat: serving.fat,
        itemCarbs: serving.carbs,
        toleranceGrams: 10.0,
        toleranceCals: 150.0,
      );

      if (fits && serving.calories >= 100) {
        String categoryTag = 'balanced';
        String categoryLabel = 'Сбалансировано';
        String reason = 'Готовое блюдо по рецепту в рамках коридора нормы';

        if (serving.protein >= 20) {
          categoryTag = 'protein';
          categoryLabel = 'Много белка';
          reason = 'Отлично насытит и восполнит ${(serving.protein / (budget.remainingProtein > 0 ? budget.remainingProtein : 1) * 100).clamp(10, 100).round()}% остатка белка';
        } else if (serving.calories <= 250) {
          categoryTag = 'light';
          categoryLabel = 'Легкий ужин';
          reason = 'Низкокалорийное легкое блюдо для комфортного вечера';
        }

        suggestions.add(
          MealSuggestion(
            id: 'recipe_${recipe.id}',
            title: recipe.name,
            subtitle: '1 порция (${recipeWithDetails.gramsPerServing.round()} г)',
            categoryTag: categoryTag,
            categoryLabel: categoryLabel,
            icon: Icons.restaurant_menu_rounded,
            suggestedGrams: recipeWithDetails.gramsPerServing,
            calories: serving.calories,
            protein: serving.protein,
            fat: serving.fat,
            carbs: serving.carbs,
            reason: reason,
            defaultMealType: preferredMealType,
            recipe: recipeWithDetails,
          ),
        );
      }
    }

    // ── 2. Подбор из каталога продуктов (с умным расчетом порции) ───────
    final proteinRichFoods = foods.where((f) =>
        f.proteinPer100g >= 12.0 &&
        !f.name.toLowerCase().contains('масло') &&
        !f.name.toLowerCase().contains('чипсы')).toList();

    for (final food in proteinRichFoods) {
      // Рассчитываем граммы, чтобы закрыть остаток белка (в пределах разумной порции 90-250г)
      double targetGrams = 120.0;
      if (budget.remainingProtein > 5 && food.proteinPer100g > 0) {
        targetGrams = ((budget.remainingProtein / food.proteinPer100g) * 100).clamp(90.0, 250.0);
      }

      final nut = NutritionCalculator.calculateForGrams(
        grams: targetGrams,
        caloriesPer100g: food.caloriesPer100g,
        proteinPer100g: food.proteinPer100g,
        fatPer100g: food.fatPer100g,
        carbsPer100g: food.carbsPer100g,
      );

      if (budget.fitsWithinCorridor(
        itemCalories: nut.calories,
        itemProtein: nut.protein,
        itemFat: nut.fat,
        itemCarbs: nut.carbs,
        toleranceGrams: 10.0,
        toleranceCals: 150.0,
      )) {
        final percentOfProtein = budget.remainingProtein > 0
            ? ((nut.protein / budget.remainingProtein) * 100).clamp(10, 100).round()
            : 100;

        suggestions.add(
          MealSuggestion(
            id: 'food_protein_${food.id}',
            title: food.name,
            subtitle: 'Порция ${targetGrams.round()} г',
            categoryTag: 'protein',
            categoryLabel: 'Белковый заряд',
            icon: Icons.fitness_center_rounded,
            suggestedGrams: targetGrams,
            calories: nut.calories,
            protein: nut.protein,
            fat: nut.fat,
            carbs: nut.carbs,
            reason: 'Закрывает ~$percentOfProtein% суточного белка без избытка жиров',
            defaultMealType: preferredMealType,
            product: food,
          ),
        );
      }
    }

    // ── 3. Легкие и сбалансированные перекусы (йогурты, творог, салаты) ─
    final snackAndDairy = foods.where((f) {
      final name = f.name.toLowerCase();
      return name.contains('йогурт') ||
          name.contains('творог') ||
          name.contains('кефир') ||
          name.contains('яйцо') ||
          name.contains('яблок') ||
          name.contains('салат');
    }).toList();

    for (final food in snackAndDairy) {
      final double defaultGrams = food.name.toLowerCase().contains('яйцо') ? 110.0 : 150.0;
      final nut = NutritionCalculator.calculateForGrams(
        grams: defaultGrams,
        caloriesPer100g: food.caloriesPer100g,
        proteinPer100g: food.proteinPer100g,
        fatPer100g: food.fatPer100g,
        carbsPer100g: food.carbsPer100g,
      );

      if (budget.fitsWithinCorridor(
        itemCalories: nut.calories,
        itemProtein: nut.protein,
        itemFat: nut.fat,
        itemCarbs: nut.carbs,
        toleranceGrams: 10.0,
        toleranceCals: 150.0,
      )) {
        // Избегаем дубликатов по ID
        if (!suggestions.any((s) => s.id == 'food_protein_${food.id}')) {
          suggestions.add(
            MealSuggestion(
              id: 'food_light_${food.id}',
              title: food.name,
              subtitle: 'Порция ${defaultGrams.round()} г',
              categoryTag: 'light',
              categoryLabel: 'Легкий перекус',
              icon: Icons.spa_rounded,
              suggestedGrams: defaultGrams,
              calories: nut.calories,
              protein: nut.protein,
              fat: nut.fat,
              carbs: nut.carbs,
              reason: 'Мягко насытит перед сном и не вызовет тяжести',
              defaultMealType: preferredMealType == 'dinner' ? 'snack' : preferredMealType,
              product: food,
            ),
          );
        }
      }
    }

    // Сортировка: приоритет отдается тем вариантам, которые лучше всего закрывают ведущий дефицит
    final dominant = budget.dominantNeed;
    suggestions.sort((a, b) {
      if (dominant == 'protein') {
        // Чем больше белка укладывается в остаток, тем выше
        return b.protein.compareTo(a.protein);
      } else if (dominant == 'low_cal') {
        return a.calories.compareTo(b.calories);
      } else {
        // Ближе всего к оставшимся калориям (без превышения)
        final diffA = (budget.remainingCalories - a.calories).abs();
        final diffB = (budget.remainingCalories - b.calories).abs();
        return diffA.compareTo(diffB);
      }
    });

    return suggestions;
  }

  void _addUltraLightOptions(
    List<MealSuggestion> list,
    List<FoodProduct> foods,
    String mealType,
  ) {
    list.add(
      MealSuggestion(
        id: 'light_tea',
        title: 'Травяной или зеленый чай с мятой',
        subtitle: '1 чашка (250 мл)',
        categoryTag: 'light',
        categoryLabel: 'Релакс',
        icon: Icons.emoji_food_beverage_rounded,
        suggestedGrams: 250,
        calories: 5,
        protein: 0,
        fat: 0,
        carbs: 1,
        reason: 'Вы уже выполнили норму на сегодня! Травяной чай расслабит перед сном',
        defaultMealType: mealType,
      ),
    );

    final cucumber = foods.firstWhere(
      (f) => f.name.toLowerCase().contains('огур'),
      orElse: () => foods.first,
    );

    list.add(
      MealSuggestion(
        id: 'light_cuke',
        title: 'Свежие хрустящие огурчики с зеленью',
        subtitle: '150 г',
        categoryTag: 'light',
        categoryLabel: 'Хрустящий перекус',
        icon: Icons.eco_rounded,
        suggestedGrams: 150,
        calories: 22,
        protein: 1.2,
        fat: 0.1,
        carbs: 4.2,
        reason: 'Минимум калорий, сочность и клетчатка без выхода за границы дня',
        defaultMealType: mealType,
        product: cucumber,
      ),
    );
  }
}
