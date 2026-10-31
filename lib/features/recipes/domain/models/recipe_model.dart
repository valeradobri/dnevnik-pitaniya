import '../../../../core/database/app_database.dart';
import '../../../../core/utils/nutrition_calculator.dart';

/// Связка ингредиента рецепта с продуктом из каталога
class RecipeIngredientWithFood {
  const RecipeIngredientWithFood({
    required this.ingredient,
    required this.product,
  });

  final RecipeIngredient ingredient;
  final FoodProduct product;

  /// Нутриенты для базового веса этого ингредиента в рецепте
  NutrientAmount get nutrients => NutritionCalculator.calculateForGrams(
        grams: ingredient.grams,
        caloriesPer100g: product.caloriesPer100g,
        proteinPer100g: product.proteinPer100g,
        fatPer100g: product.fatPer100g,
        carbsPer100g: product.carbsPer100g,
      );

  /// Пересчет граммов под желаемое количество порций
  double getGramsForServings(int baseServings, int targetServings) {
    if (baseServings <= 0) return ingredient.grams;
    return (ingredient.grams / baseServings) * targetServings;
  }
}

/// Рецепт с полным списком ингредиентов и расчетом КБЖУ на порцию
class RecipeWithDetails {
  const RecipeWithDetails({
    required this.recipe,
    required this.ingredients,
  });

  final Recipe recipe;
  final List<RecipeIngredientWithFood> ingredients;

  /// Общий вес всех ингредиентов блюда (г)
  double get totalGrams =>
      ingredients.fold<double>(0, (sum, item) => sum + item.ingredient.grams);

  /// Суммарные нутриенты всего блюда
  NutrientAmount get totalNutrients {
    double cals = 0;
    double prot = 0;
    double fat = 0;
    double carbs = 0;

    for (final ing in ingredients) {
      final n = ing.nutrients;
      cals += n.calories;
      prot += n.protein;
      fat += n.fat;
      carbs += n.carbs;
    }

    return NutrientAmount(
      calories: cals,
      protein: prot,
      fat: fat,
      carbs: carbs,
    );
  }

  /// Нутриенты на 1 порцию
  NutrientAmount get nutrientsPerServing {
    final s = recipe.servings > 0 ? recipe.servings : 1;
    final total = totalNutrients;
    return NutrientAmount(
      calories: total.calories / s,
      protein: total.protein / s,
      fat: total.fat / s,
      carbs: total.carbs / s,
    );
  }

  /// Нутриенты на заданное число порций
  NutrientAmount nutrientsForServings(int targetServings) {
    final perServing = nutrientsPerServing;
    return NutrientAmount(
      calories: perServing.calories * targetServings,
      protein: perServing.protein * targetServings,
      fat: perServing.fat * targetServings,
      carbs: perServing.carbs * targetServings,
    );
  }

  /// Вес 1 порции в граммах
  double get gramsPerServing {
    final s = recipe.servings > 0 ? recipe.servings : 1;
    return totalGrams / s;
  }
}
