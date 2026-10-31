import 'package:flutter_test/flutter_test.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/recipes/domain/models/recipe_model.dart';

void main() {
  group('RecipeModel & Scaling Tests', () {
    final now = DateTime.now();

    final baseRecipe = Recipe(
      id: 1,
      name: 'Сырники из творога',
      description: 'Нежные домашние сырники',
      servings: 2,
      prepTimeMinutes: 20,
      isFavorite: false,
      category: 'breakfast',
      createdAt: now,
    );

    final eggProduct = FoodProduct(
      id: 10,
      name: 'Яйцо куриное',
      category: 'dairy',
      caloriesPer100g: 155,
      proteinPer100g: 13,
      fatPer100g: 11,
      carbsPer100g: 1,
      servingSizeG: 55,
      isFavorite: false,
      sourceType: 'standard',
      createdAt: now,
    );

    final ingredients = [
      RecipeIngredientWithFood(
        ingredient: const RecipeIngredient(
          id: 1,
          recipeId: 1,
          foodProductId: 10,
          grams: 100, // 100г яйца на 2 порции (50г на 1 порцию)
        ),
        product: eggProduct,
      ),
    ];

    final recipeWithDetails = RecipeWithDetails(
      recipe: baseRecipe,
      ingredients: ingredients,
    );

    test('RecipeWithDetails calculates total and per-serving nutrition correctly', () {
      // 100г яйца (155 ккал, 13г Б, 11г Ж, 1г У)
      expect(recipeWithDetails.totalNutrients.calories, closeTo(155.0, 0.1));
      expect(recipeWithDetails.totalNutrients.protein, closeTo(13.0, 0.1));
      expect(recipeWithDetails.totalNutrients.fat, closeTo(11.0, 0.1));
      expect(recipeWithDetails.totalNutrients.carbs, closeTo(1.0, 0.1));

      // На 1 порцию (из 2 порций)
      expect(recipeWithDetails.nutrientsPerServing.calories, closeTo(77.5, 0.1));
      expect(recipeWithDetails.nutrientsPerServing.protein, closeTo(6.5, 0.1));
      expect(recipeWithDetails.nutrientsPerServing.fat, closeTo(5.5, 0.1));
      expect(recipeWithDetails.nutrientsPerServing.carbs, closeTo(0.5, 0.1));
    });

    test('nutrientsForServings scales correctly for 4 servings', () {
      final for4 = recipeWithDetails.nutrientsForServings(4);
      expect(for4.calories, closeTo(310.0, 0.1)); // 77.5 * 4
      expect(for4.protein, closeTo(26.0, 0.1));
      expect(for4.fat, closeTo(22.0, 0.1));
      expect(for4.carbs, closeTo(2.0, 0.1));
    });

    test('getGramsForServings accurately scales ingredient weight', () {
      final ing = recipeWithDetails.ingredients.first;
      // 100г базово на 2 порции -> для 4 порций должно быть 200г
      expect(ing.getGramsForServings(2, 4), 200.0);
      // для 1 порции -> 50г
      expect(ing.getGramsForServings(2, 1), 50.0);
    });
  });
}
