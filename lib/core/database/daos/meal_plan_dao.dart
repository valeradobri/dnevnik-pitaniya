import 'package:drift/drift.dart';
import '../app_database.dart';
import '../../../../features/recipes/domain/models/recipe_model.dart';

/// Элемент умного списка покупок, агрегированный из плана питания
class ShoppingItem {
  const ShoppingItem({
    required this.foodId,
    required this.name,
    required this.category,
    required this.totalGrams,
    this.isBought = false,
  });

  final int foodId;
  final String name;
  final String category;
  final double totalGrams;
  final bool isBought;

  ShoppingItem copyWith({bool? isBought}) {
    return ShoppingItem(
      foodId: foodId,
      name: name,
      category: category,
      totalGrams: totalGrams,
      isBought: isBought ?? this.isBought,
    );
  }
}

/// Элемент плана питания с прикрепленным рецептом (если есть)
class MealPlanItemWithRecipe {
  const MealPlanItemWithRecipe({
    required this.item,
    this.recipeDetails,
  });

  final MealPlanItem item;
  final RecipeWithDetails? recipeDetails;
}

/// DAO для работы с недельным планировщиком питания и генерацией списка покупок
class MealPlanDao {
  MealPlanDao(this.db);

  final AppDatabase db;

  /// Начало недели (понедельник, 00:00:00)
  DateTime startOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Получить или создать план для указанной недели
  Future<MealPlan> getOrCreatePlanForWeek(DateTime weekStart) async {
    final monday = startOfWeek(weekStart);
    final existing = await (db.select(db.mealPlans)
          ..where((t) => t.weekStartDate.equals(monday)))
        .getSingleOrNull();

    if (existing != null) return existing;

    final id = await db.into(db.mealPlans).insert(
          MealPlansCompanion.insert(weekStartDate: monday),
        );
    return (db.select(db.mealPlans)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Реактивный стрим всех запланированных блюд на неделю
  Stream<List<MealPlanItemWithRecipe>> watchPlanItemsForWeek(DateTime date) {
    final monday = startOfWeek(date);
    final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    final query = db.select(db.mealPlanItems)
      ..where((t) =>
          t.plannedDate.isBiggerOrEqualValue(monday) &
          t.plannedDate.isSmallerOrEqualValue(sunday))
      ..orderBy([(t) => OrderingTerm(expression: t.plannedDate)]);

    return query.watch().asyncMap((items) async {
      final list = <MealPlanItemWithRecipe>[];
      for (final item in items) {
        RecipeWithDetails? recipe;
        if (item.recipeId != null) {
          recipe = await db.recipeDao.getRecipeWithDetails(item.recipeId!);
        }
        list.add(MealPlanItemWithRecipe(item: item, recipeDetails: recipe));
      }
      return list;
    });
  }

  /// Добавить блюдо в план
  Future<int> addPlanItem({
    required int mealPlanId,
    int? recipeId,
    required DateTime plannedDate,
    required String mealType,
    String? customNote,
    double servings = 1.0,
  }) {
    return db.into(db.mealPlanItems).insert(
          MealPlanItemsCompanion.insert(
            mealPlanId: mealPlanId,
            recipeId: Value(recipeId),
            plannedDate: plannedDate,
            mealType: mealType,
            customNote: Value(customNote),
            servings: Value(servings),
          ),
        );
  }

  /// Удалить элемент плана
  Future<int> deletePlanItem(int id) {
    return (db.delete(db.mealPlanItems)..where((t) => t.id.equals(id))).go();
  }

  /// Реактивный стрим списка покупок на неделю с возможностью фильтрации только предстоящих дней
  Stream<List<ShoppingItem>> watchShoppingList(DateTime date, {bool onlyFromToday = false}) {
    final monday = startOfWeek(date);
    final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    final query = db.select(db.mealPlanItems)
      ..where((t) =>
          t.plannedDate.isBiggerOrEqualValue(monday) &
          t.plannedDate.isSmallerOrEqualValue(sunday));

    return query.watch().asyncMap((items) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final filteredItems = onlyFromToday
          ? items.where((it) {
              final d = DateTime(it.plannedDate.year, it.plannedDate.month, it.plannedDate.day);
              return !d.isBefore(today);
            }).toList()
          : items;

      final gramsByFoodId = <int, double>{};

      for (final item in filteredItems) {
        if (item.recipeId != null) {
          final recipe = await db.recipeDao.getRecipeWithDetails(item.recipeId!);
          if (recipe != null) {
            final factor = item.servings / (recipe.recipe.servings > 0 ? recipe.recipe.servings : 1);
            for (final ing in recipe.ingredients) {
              final foodId = ing.product.id;
              final weight = ing.ingredient.grams * factor;
              gramsByFoodId[foodId] = (gramsByFoodId[foodId] ?? 0) + weight;
            }
          }
        }
      }

      final shoppingList = <ShoppingItem>[];
      for (final entry in gramsByFoodId.entries) {
        final food = await db.foodDao.getFoodById(entry.key);
        if (food != null) {
          shoppingList.add(
            ShoppingItem(
              foodId: food.id,
              name: food.name,
              category: food.category,
              totalGrams: entry.value,
            ),
          );
        }
      }

      shoppingList.sort((a, b) => a.category.compareTo(b.category));
      return shoppingList;
    });
  }

  /// Автоматическая генерация списка покупок на неделю из рецептов плана
  Future<List<ShoppingItem>> generateShoppingList(DateTime date, {bool onlyFromToday = false}) async {
    return watchShoppingList(date, onlyFromToday: onlyFromToday).first;
  }
}
