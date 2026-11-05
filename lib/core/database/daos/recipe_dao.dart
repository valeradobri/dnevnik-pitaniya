import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../../../features/recipes/domain/models/recipe_model.dart';
import '../seed/recipes_seed.dart';

/// DAO для работы с рецептами и их ингредиентами
class RecipeDao {
  RecipeDao(this.db);

  final AppDatabase db;

  /// Реактивный стрим всех рецептов
  Stream<List<Recipe>> watchAllRecipes({String? category, bool? onlyFavorites}) {
    var q = db.select(db.recipes);
    if (category != null && category.isNotEmpty && category != 'all') {
      q = q..where((t) => t.category.equals(category));
    }
    if (onlyFavorites == true) {
      q = q..where((t) => t.isFavorite.equals(true));
    }
    return (q..orderBy([(t) => OrderingTerm(expression: t.name)])).watch();
  }

  /// Получить рецепт по ID с полным списком ингредиентов и продуктов
  Future<RecipeWithDetails?> getRecipeWithDetails(int recipeId) async {
    final recipe = await (db.select(db.recipes)..where((t) => t.id.equals(recipeId)))
        .getSingleOrNull();
    if (recipe == null) return null;

    final rows = await (db.select(db.recipeIngredients).join([
      innerJoin(
        db.foodProducts,
        db.foodProducts.id.equalsExp(db.recipeIngredients.foodProductId),
      ),
    ])..where(db.recipeIngredients.recipeId.equals(recipeId))).get();

    final ingredients = rows.map((row) {
      final ing = row.readTable(db.recipeIngredients);
      final food = row.readTable(db.foodProducts);
      return RecipeIngredientWithFood(ingredient: ing, product: food);
    }).toList();

    return RecipeWithDetails(recipe: recipe, ingredients: ingredients);
  }

  /// Реактивный стрим деталей рецепта с ингредиентами
  Stream<RecipeWithDetails?> watchRecipeWithDetails(int recipeId) {
    return (db.select(db.recipes)..where((t) => t.id.equals(recipeId)))
        .watchSingleOrNull()
        .asyncMap((recipe) async {
      if (recipe == null) return null;
      return getRecipeWithDetails(recipeId);
    });
  }

  /// Добавить рецепт со списком ингредиентов
  Future<int> insertRecipe({
    required RecipesCompanion recipe,
    required List<RecipeIngredientsCompanion> ingredients,
  }) {
    return db.transaction(() async {
      final recipeId = await db.into(db.recipes).insert(recipe);
      for (final ing in ingredients) {
        await db.into(db.recipeIngredients).insert(
              ing.copyWith(recipeId: Value(recipeId)),
            );
      }
      return recipeId;
    });
  }

  /// Удалить рецепт (ингредиенты удалятся каскадно)
  Future<int> deleteRecipe(int id) {
    return (db.delete(db.recipes)..where((t) => t.id.equals(id))).go();
  }

  /// Переключить флаг «Избранное»
  Future<void> toggleFavorite(int id, bool isFavorite) {
    return (db.update(db.recipes)..where((t) => t.id.equals(id))).write(
      RecipesCompanion(isFavorite: Value(isFavorite)),
    );
  }

  /// Начальное и регулярное сидирование кураторской базы сбалансированных рецептов (26 блюд)
  Future<void> seedInitialRecipes() async {
    final existingRecipes = await db.select(db.recipes).get();
    final existingNames = existingRecipes.map((r) => r.name.toLowerCase().trim()).toSet();

    // Обновляем шаги приготовления для старых записей, если у них нет подробной инструкции
    for (final r in existingRecipes) {
      if (r.description != null && !r.description!.contains('Шаги приготовления:')) {
        final matches = curatedSeedRecipes
            .where((c) => c.name.toLowerCase().trim() == r.name.toLowerCase().trim());
        if (matches.isNotEmpty) {
          await (db.update(db.recipes)..where((t) => t.id.equals(r.id)))
              .write(RecipesCompanion(description: Value(matches.first.description)));
        }
      }
    }

    // Ищем ID базовых продуктов в каталоге
    final allFoods = await db.foodDao.getAllFoods();
    if (allFoods.isEmpty) return;

    int findId(String namePart) {
      final query = namePart.toLowerCase().trim();
      final exactOrWord = allFoods.where((f) {
        final name = f.name.toLowerCase();
        final words = name.split(RegExp(r'[\s,\(\)\.\«\»\-]+'));
        return words.contains(query) || name.startsWith(query);
      });
      if (exactOrWord.isNotEmpty) return exactOrWord.first.id;

      final found = allFoods.where(
        (f) => f.name.toLowerCase().contains(query),
      );
      return found.isNotEmpty ? found.first.id : allFoods.first.id;
    }

    // Добавляем новые рецепты из кураторской базы, которых ещё нет в локальной базе
    for (final seed in curatedSeedRecipes) {
      if (existingNames.contains(seed.name.toLowerCase().trim())) {
        continue;
      }

      final ingCompanions = seed.ingredients.map((ing) {
        final foodId = findId(ing.foodQuery);
        return RecipeIngredientsCompanion(
          foodProductId: Value(foodId),
          grams: Value(ing.grams),
          notes: Value(ing.notes),
        );
      }).toList();

      await insertRecipe(
        recipe: RecipesCompanion(
          name: Value(seed.name),
          category: Value(seed.category),
          prepTimeMinutes: Value(seed.prepTimeMinutes),
          servings: Value(seed.servings),
          description: Value(seed.description),
          imageUrl: Value(seed.imageUrl),
        ),
        ingredients: ingCompanions,
      );
    }
  }
}
