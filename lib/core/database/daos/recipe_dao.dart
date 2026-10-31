import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../../../features/recipes/domain/models/recipe_model.dart';

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

  /// Начальное сидирование классических сбалансированных рецептов
  Future<void> seedInitialRecipes() async {
    final count = await (db.selectOnly(db.recipes)..addColumns([db.recipes.id.count()]))
        .map((r) => r.read(db.recipes.id.count()) ?? 0)
        .getSingle();

    // Если рецепты уже есть, проверяем, нужно ли дополнить их шагами приготовления
    if (count > 0) {
      final allExisting = await db.select(db.recipes).get();
      for (final r in allExisting) {
        if (r.description != null && !r.description!.contains('Шаги приготовления:')) {
          final updated = _getUpdatedDescription(r.name);
          if (updated != null) {
            await (db.update(db.recipes)..where((t) => t.id.equals(r.id)))
                .write(RecipesCompanion(description: Value(updated)));
          }
        }
      }

      // Исправляем ошибочную привязку сыра к куриному филе (из-за подстроки «сырое»)
      final cheeseProduct = await (db.select(db.foodProducts)
            ..where((t) => t.name.like('Сыр Российский%') | t.name.equals('Сыр Российский')))
          .getSingleOrNull();

      if (cheeseProduct != null) {
        final wrongCheeseIngredients = await (db.select(db.recipeIngredients).join([
          innerJoin(
            db.foodProducts,
            db.foodProducts.id.equalsExp(db.recipeIngredients.foodProductId),
          ),
        ])..where(
            db.recipeIngredients.notes.equals('Сыр') &
            db.foodProducts.name.like('%Куриное филе%'),
          )).get();

        for (final row in wrongCheeseIngredients) {
          final item = row.readTable(db.recipeIngredients);
          await (db.update(db.recipeIngredients)..where((t) => t.id.equals(item.id))).write(
            RecipeIngredientsCompanion(foodProductId: Value(cheeseProduct.id)),
          );
        }
      }
      return;
    }

    // Ищем ID базовых продуктов в каталоге
    final allFoods = await db.foodDao.getAllFoods();
    int findId(String namePart) {
      final query = namePart.toLowerCase().trim();
      // Сначала точное совпадение или отдельное слово / начинается со слова
      final exactOrWord = allFoods.where((f) {
        final name = f.name.toLowerCase();
        final words = name.split(RegExp(r'[\s,\(\)\.\«\»\-]+'));
        return words.contains(query) || name.startsWith(query);
      });
      if (exactOrWord.isNotEmpty) return exactOrWord.first.id;

      final found = allFoods.where(
        (f) => f.name.toLowerCase().contains(query),
      );
      return found.isNotEmpty ? found.first.id : 1;
    }

    final cottageCheeseId = findId('творог 5%');
    final eggId = findId('яйцо куриное');
    final oatsId = findId('овсяные хлопья');
    final chickenId = findId('куриное филе');
    final buckwheatId = findId('гречневая крупа');
    final milkId = findId('молоко');
    final cheeseId = findId('сыр российский');
    final beefId = findId('говядина');
    final potatoId = findId('картофель');
    final carrotId = findId('морковь');
    final salmonId = findId('лосось');
    final oliveOilId = findId('масло оливковое');

    // 1. Нежные сырники из творога (2 порции)
    await insertRecipe(
      recipe: const RecipesCompanion(
        name: Value('Нежные домашние сырники'),
        description: Value(
          'Классические творожные сырники с хрустящей корочкой и нежной текстурой внутри. Идеальный белковый завтрак.\n\nШаги приготовления:\n1. Выложите творог в глубокую миску и тщательно разомните вилкой, чтобы не было крупных комочков.\n2. Разбейте яйцо, добавьте овсяную муку, щепотку соли и ванилин по вкусу. Вымесите массу до однородности.\n3. Влажными руками сформируйте круглые плотные сырники толщиной около 1.5–2 см.\n4. Разогрейте антипригарную сковороду на среднем огне. Обжаривайте сырники по 3–4 минуты с каждой стороны под крышкой до золотистой корочки.',
        ),
        prepTimeMinutes: Value(20),
        servings: Value(2),
        category: Value('breakfast'),
      ),
      ingredients: [
        RecipeIngredientsCompanion(
          foodProductId: Value(cottageCheeseId),
          grams: const Value(300.0),
          notes: const Value('Творог 5%'),
        ),
        RecipeIngredientsCompanion(
          foodProductId: Value(eggId),
          grams: const Value(55.0),
          notes: const Value('1 яйцо'),
        ),
        RecipeIngredientsCompanion(
          foodProductId: Value(oatsId),
          grams: const Value(40.0),
          notes: const Value('Перемолотые хлопья или рисовая мука'),
        ),
      ],
    );

    // 2. Овсяноблин с сыром (1 порция)
    await insertRecipe(
      recipe: const RecipesCompanion(
        name: Value('Овсяноблин с сыром'),
        description: Value(
          'Быстрый, сбалансированный завтрак из цельных злаков и качественного белка. Готовится на сковороде за 7 минут.\n\nШаги приготовления:\n1. В миске или чаше блендера соедините овсяные хлопья, яйцо, молоко и щепотку соли.\n2. Взбейте вилкой или блендером до получения однородной смеси.\n3. Вылейте смесь на сухую разогретую антипригарную сковороду и распределите лопаткой в ровный блин.\n4. Жарьте на среднем огне 3–4 минуты под крышкой, затем аккуратно переверните.\n5. На одну половину блина выложите тонко нарезанный сыр, сложите пополам и прогрейте 1–2 минуты до расплавления сыра.',
        ),
        prepTimeMinutes: Value(10),
        servings: Value(1),
        category: Value('breakfast'),
      ),
      ingredients: [
        RecipeIngredientsCompanion(
          foodProductId: Value(oatsId),
          grams: const Value(45.0),
          notes: const Value('Овсяные хлопья'),
        ),
        RecipeIngredientsCompanion(
          foodProductId: Value(eggId),
          grams: const Value(55.0),
          notes: const Value('1 яйцо'),
        ),
        RecipeIngredientsCompanion(
          foodProductId: Value(milkId),
          grams: const Value(40.0),
          notes: const Value('Молоко'),
        ),
        RecipeIngredientsCompanion(
          foodProductId: Value(cheeseId),
          grams: const Value(30.0),
          notes: const Value('Сыр'),
        ),
      ],
    );

    // 3. Гречка с куриным филе (2 порции)
    await insertRecipe(
      recipe: const RecipesCompanion(
        name: Value('Гречка с запеченным куриным филе'),
        description: Value(
          'Золотой стандарт здорового питания: сложные медленные углеводы и нежирный чистый белок для восстановления мышц.\n\nШаги приготовления:\n1. Промойте гречневую крупу под холодной проточной водой.\n2. Залейте водой в пропорции 1:2 (на 150 г крупы — 300 мл воды), посолите и варите на медленном огне 15–20 минут до впитывания жидкости.\n3. Куриное филе промойте, обсушите салфеткой, натрите солью, перцем, паприкой и сбрызните оливковым маслом.\n4. Запекайте куриное филе в разогретой до 180°C духовке 20–25 минут в рукаве или на пергаменте до сочности.\n5. Нарежьте филе поперек волокон и подавайте на подушке из горячей рассыпчатой гречки со свежей зеленью.',
        ),
        prepTimeMinutes: Value(35),
        servings: Value(2),
        category: Value('lunch'),
      ),
      ingredients: [
        RecipeIngredientsCompanion(
          foodProductId: Value(buckwheatId),
          grams: const Value(150.0),
          notes: const Value('Гречневая крупа сухая'),
        ),
        RecipeIngredientsCompanion(
          foodProductId: Value(chickenId),
          grams: const Value(300.0),
          notes: const Value('Филе грудки'),
        ),
        RecipeIngredientsCompanion(
          foodProductId: Value(oliveOilId),
          grams: const Value(10.0),
          notes: const Value('Оливковое масло для запекания'),
        ),
      ],
    );

    // 4. Домашний борщ с говядиной (4 порции)
    await insertRecipe(
      recipe: const RecipesCompanion(
        name: Value('Домашний борщ с нежирной говядиной'),
        description: Value(
          'Ароматный традиционный суп, богатый клетчаткой, минералами и белком. Идеален для семейного обеда.\n\nШаги приготовления:\n1. Нежирную говядину промойте, залейте 1.5 л холодной воды, доведите до кипения, снимите пену и варите бульон на медленном огне 45–60 минут.\n2. Картофель очистите, нарежьте средними брусочками и опустите в кипящий бульон.\n3. Морковь и свеклу натрите на крупной терке. Слегка припустите на сковороде с ложкой бульона и каплей лимонного сока до мягкости, затем отправьте в суп.\n4. Добавьте тонко нашинкованную белокочанную капусту и варите суп еще 10–12 минут до готовности овощей.\n5. Добавьте лавровый лист, черный перец, чеснок и зелень. Снимите с огня и дайте борщу настояться под крышкой 15 минут перед подачей.',
        ),
        prepTimeMinutes: Value(60),
        servings: Value(4),
        category: Value('lunch'),
      ),
      ingredients: [
        RecipeIngredientsCompanion(
          foodProductId: Value(beefId),
          grams: const Value(350.0),
          notes: const Value('Говядина постная'),
        ),
        RecipeIngredientsCompanion(
          foodProductId: Value(potatoId),
          grams: const Value(200.0),
          notes: const Value('Картофель'),
        ),
        RecipeIngredientsCompanion(
          foodProductId: Value(carrotId),
          grams: const Value(100.0),
          notes: const Value('Морковь'),
        ),
      ],
    );

    // 5. Запеченный лосось с овощами (2 порции)
    await insertRecipe(
      recipe: const RecipesCompanion(
        name: Value('Запеченный лосось с брокколи'),
        description: Value(
          'Источник омега-3 жирных кислот и легкоусвояемого белка. Идеальный легкий и сытный ужин.\n\nШаги приготовления:\n1. Стейки лосося промойте, аккуратно промокните салфеткой, посолите, поперчите и сбрызните лимонным соком.\n2. Брокколи разберите на соцветия и слегка сбрызните оливковым маслом.\n3. Выложите лосось и брокколи в форму для запекания, застеленную пергаментной бумагой.\n4. Запекайте в разогретой до 180°C духовке 18–20 минут (или готовьте в пароварке 15 минут), чтобы рыба осталась нежной и сочной.',
        ),
        prepTimeMinutes: Value(25),
        servings: Value(2),
        category: Value('dinner'),
      ),
      ingredients: [
        RecipeIngredientsCompanion(
          foodProductId: Value(salmonId),
          grams: const Value(260.0),
          notes: const Value('Стейк лосося'),
        ),
        RecipeIngredientsCompanion(
          foodProductId: Value(oliveOilId),
          grams: const Value(10.0),
          notes: const Value('Масло оливковое'),
        ),
      ],
    );
  }

  String? _getUpdatedDescription(String title) {
    if (title.contains('сырники')) {
      return 'Классические творожные сырники с хрустящей корочкой и нежной текстурой внутри. Идеальный белковый завтрак.\n\nШаги приготовления:\n1. Выложите творог в глубокую миску и тщательно разомните вилкой, чтобы не было крупных комочков.\n2. Разбейте яйцо, добавьте овсяную муку, щепотку соли и ванилин по вкусу. Вымесите массу до однородности.\n3. Влажными руками сформируйте круглые плотные сырники толщиной около 1.5–2 см.\n4. Разогрейте антипригарную сковороду на среднем огне. Обжаривайте сырники по 3–4 минуты с каждой стороны под крышкой до золотистой корочки.';
    }
    if (title.contains('Овсяноблин')) {
      return 'Быстрый, сбалансированный завтрак из цельных злаков и качественного белка. Готовится на сковороде за 7 минут.\n\nШаги приготовления:\n1. В миске или чаше блендера соедините овсяные хлопья, яйцо, молоко и щепотку соли.\n2. Взбейте вилкой или блендером до получения однородной смеси.\n3. Вылейте смесь на сухую разогретую антипригарную сковороду и распределите лопаткой в ровный блин.\n4. Жарьте на среднем огне 3–4 минуты под крышкой, затем аккуратно переверните.\n5. На одну половину блина выложите тонко нарезанный сыр, сложите пополам и прогрейте 1–2 минуты до расплавления сыра.';
    }
    if (title.contains('Гречка')) {
      return 'Золотой стандарт здорового питания: сложные медленные углеводы и нежирный чистый белок для восстановления мышц.\n\nШаги приготовления:\n1. Промойте гречневую крупу под холодной проточной водой.\n2. Залейте водой в пропорции 1:2 (на 150 г крупы — 300 мл воды), посолите и варите на медленном огне 15–20 минут до впитывания жидкости.\n3. Куриное филе промойте, обсушите салфеткой, натрите солью, перцем, паприкой и сбрызните оливковым маслом.\n4. Запекайте куриное филе в разогретой до 180°C духовке 20–25 минут в рукаве или на пергаменте до сочности.\n5. Нарежьте филе поперек волокон и подавайте на подушке из горячей рассыпчатой гречки со свежей зеленью.';
    }
    if (title.contains('борщ')) {
      return 'Ароматный традиционный суп, богатый клетчаткой, минералами и белком. Идеален для семейного обеда.\n\nШаги приготовления:\n1. Нежирную говядину промойте, залейте 1.5 л холодной воды, доведите до кипения, снимите пену и варите бульон на медленном огне 45–60 минут.\n2. Картофель очистите, нарежьте средними брусочками и опустите в кипящий бульон.\n3. Морковь и свеклу натрите на крупной терке. Слегка припустите на сковороде с ложкой бульона и каплей лимонного сока до мягкости, затем отправьте в суп.\n4. Добавьте тонко нашинкованную белокочанную капусту и варите суп еще 10–12 минут до готовности овощей.\n5. Добавьте лавровый лист, черный перец, чеснок и зелень. Снимите с огня и дайте борщу настояться под крышкой 15 минут перед подачей.';
    }
    if (title.contains('лосось')) {
      return 'Источник омега-3 жирных кислот и легкоусвояемого белка. Идеальный легкий и сытный ужин.\n\nШаги приготовления:\n1. Стейки лосося промойте, аккуратно промокните салфеткой, посолите, поперчите и сбрызните лимонным соком.\n2. Брокколи разберите на соцветия и слегка сбрызните оливковым маслом.\n3. Выложите лосось и брокколи в форму для запекания, застеленную пергаментной бумагой.\n4. Запекайте в разогретой до 180°C духовке 18–20 минут (или готовьте в пароварке 15 минут), чтобы рыба осталась нежной и сочной.';
    }
    return null;
  }
}
