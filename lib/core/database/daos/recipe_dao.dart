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

  /// Реактивный стрим всех сохраненных шаблонов комбо
  Stream<List<RecipeWithDetails>> watchCombosWithDetails() {
    return (db.select(db.recipes)
          ..where((t) => t.category.equals('combo'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .asyncMap((recipes) async {
      final list = <RecipeWithDetails>[];
      for (final r in recipes) {
        final d = await getRecipeWithDetails(r.id);
        if (d != null) list.add(d);
      }
      return list;
    });
  }

  /// Сохранить связку продуктов как шаблон комбо
  Future<int> saveComboTemplate({
    required String name,
    required List<({int foodProductId, double grams})> items,
  }) {
    return insertRecipe(
      recipe: RecipesCompanion.insert(
        name: name,
        category: const Value('combo'),
        servings: const Value(1),
        description: const Value('Пользовательское комбо'),
      ),
      ingredients: items
          .map(
            (i) => RecipeIngredientsCompanion.insert(
              recipeId: 0,
              foodProductId: i.foodProductId,
              grams: i.grams,
            ),
          )
          .toList(),
    );
  }

  /// Начальное и регулярное сидирование кураторской базы сбалансированных рецептов (26 блюд)
  Future<void> seedInitialRecipes() async {
    final existingRecipes = await db.select(db.recipes).get();

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
      final clean = namePart.toLowerCase().trim();
      final queryWords = clean
          .split(RegExp(r'[\s,\(\)\.\«\»\-]+'))
          .where((w) => w.length > 2)
          .toList();

      // 1. Точное совпадение
      final exact = allFoods.where((f) => f.name.toLowerCase().trim() == clean);
      if (exact.isNotEmpty) return exact.first.id;

      // 2. Имя начинается с запроса или содержит запрос целиком
      final fullSubstring = allFoods.where((f) {
        final n = f.name.toLowerCase();
        return n.startsWith(clean) || n.contains(clean);
      });
      if (fullSubstring.isNotEmpty) return fullSubstring.first.id;

      // 3. Совпадение всех значимых слов (например: "говядина", "нежирная" -> "Говядина нежирная (постная)")
      if (queryWords.isNotEmpty) {
        final allWordsMatch = allFoods.where((f) {
          final n = f.name.toLowerCase();
          return queryWords.every((w) => n.contains(w));
        });
        if (allWordsMatch.isNotEmpty) return allWordsMatch.first.id;

        // 4. Совпадение хотя бы первого ключевого слова среди проверенных продуктов
        final firstWord = queryWords.first;
        final firstWordMatch = allFoods.where((f) {
          if (f.sourceType != 'verified') return false;
          final n = f.name.toLowerCase();
          final words = n.split(RegExp(r'[\s,\(\)\.\«\»\-]+'));
          return words.any((w) => w.startsWith(firstWord) || firstWord.startsWith(w));
        });
        if (firstWordMatch.isNotEmpty) return firstWordMatch.first.id;
      }

      // 5. Безопасный фолбэк: строго проверенный продукт (verified), НИКОГДА не случайные онлайн-продукты
      final verified = allFoods.where((f) => f.sourceType == 'verified');
      if (verified.isNotEmpty) return verified.first.id;

      return allFoods.first.id;
    }

    // Добавляем или восстанавливаем рецепты из кураторской базы
    for (final seed in curatedSeedRecipes) {
      final existing = existingRecipes
          .where((r) => r.name.toLowerCase().trim() == seed.name.toLowerCase().trim())
          .firstOrNull;

      if (existing != null) {
        // Проверяем привязанные ингредиенты существующего рецепта
        final curIngredients = await (db.select(db.recipeIngredients)
              ..where((t) => t.recipeId.equals(existing.id)))
            .get();

        // Если есть ошибочные привязки (например к сторонним онлайн-продуктам) или не совпадает число ингредиентов
        bool needsResync = curIngredients.length != seed.ingredients.length;
        if (!needsResync) {
          for (final ing in curIngredients) {
            final p = allFoods.where((f) => f.id == ing.foodProductId).firstOrNull;
            if (p == null || p.sourceType != 'verified') {
              needsResync = true;
              break;
            }
          }
        }

        if (needsResync) {
          await (db.delete(db.recipeIngredients)
                ..where((t) => t.recipeId.equals(existing.id)))
              .go();

          for (final ing in seed.ingredients) {
            final foodId = findId(ing.foodQuery);
            await db.into(db.recipeIngredients).insert(
                  RecipeIngredientsCompanion(
                    recipeId: Value(existing.id),
                    foodProductId: Value(foodId),
                    grams: Value(ing.grams),
                    notes: Value(ing.notes),
                  ),
                );
          }
        }
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
