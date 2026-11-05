import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // Сидируем базовые продукты питания
    await db.seedFoodProducts();
  });

  tearDown(() async {
    await db.close();
  });

  test('curated recipes pack seeds 26 rich recipes with ingredients and steps', () async {
    // Выполняем сидирование кураторской базы
    await db.recipeDao.seedInitialRecipes();

    final allRecipes = await db.select(db.recipes).get();
    expect(allRecipes.length, greaterThanOrEqualTo(26));

    // Проверяем наличие ключевых категорий
    final categories = allRecipes.map((r) => r.category).toSet();
    expect(categories, contains('breakfast'));
    expect(categories, contains('soup'));
    expect(categories, contains('lunch'));
    expect(categories, contains('dinner'));
    expect(categories, contains('salad'));
    expect(categories, contains('snack'));

    // Проверяем детальный рецепт борща
    final borscht = allRecipes.firstWhere((r) => r.name.contains('борщ'));
    final borschtDetails = await db.recipeDao.getRecipeWithDetails(borscht.id);
    expect(borschtDetails, isNotNull);
    expect(borschtDetails!.ingredients.length, greaterThanOrEqualTo(4));
    expect(borschtDetails.recipe.description, contains('Шаги приготовления:'));
    expect(borschtDetails.nutrientsPerServing.calories, greaterThan(0));

    // Проверяем, что повторный вызов seedInitialRecipes идемпотентен (не дублирует рецепты)
    await db.recipeDao.seedInitialRecipes();
    final allRecipesAfterSecondSeed = await db.select(db.recipes).get();
    expect(allRecipesAfterSecondSeed.length, allRecipes.length);
  });
}
