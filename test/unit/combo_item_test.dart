import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/food_database/domain/models/combo_item.dart';

void main() {
  group('ComboItem & ComboSummary Tests', () {
    final now = DateTime.now();

    final breadProduct = FoodProduct(
      id: 1,
      name: 'Хлеб бородинский',
      category: 'bakery',
      caloriesPer100g: 210,
      proteinPer100g: 7,
      fatPer100g: 1.5,
      carbsPer100g: 42,
      servingSizeG: 40,
      isFavorite: false,
      sourceType: 'standard',
      createdAt: now,
    );

    final cheeseProduct = FoodProduct(
      id: 2,
      name: 'Сыр Российский',
      category: 'dairy',
      caloriesPer100g: 360,
      proteinPer100g: 23,
      fatPer100g: 29.5,
      carbsPer100g: 0,
      servingSizeG: 30,
      isFavorite: false,
      sourceType: 'standard',
      createdAt: now,
    );

    final sausageProduct = FoodProduct(
      id: 3,
      name: 'Колбаса Докторская',
      category: 'meat',
      caloriesPer100g: 260,
      proteinPer100g: 12,
      fatPer100g: 22,
      carbsPer100g: 1.5,
      servingSizeG: 50,
      isFavorite: false,
      sourceType: 'standard',
      createdAt: now,
    );

    test('ComboIngredientItem calculates nutrition for custom grams correctly', () {
      final item = ComboIngredientItem(
        product: breadProduct,
        grams: 50,
      );

      expect(item.calories, closeTo(105.0, 0.01)); // 210 * 50 / 100
      expect(item.protein, closeTo(3.5, 0.01));
      expect(item.fat, closeTo(0.75, 0.01));
      expect(item.carbs, closeTo(21.0, 0.01));
    });

    test('ComboSummary sums total nutrition, grams, and generates default title and notes', () {
      final items = [
        ComboIngredientItem(product: breadProduct, grams: 40), // 84 kcal, 2.8 P, 0.6 F, 16.8 C
        ComboIngredientItem(product: cheeseProduct, grams: 30), // 108 kcal, 6.9 P, 8.85 F, 0 C
        ComboIngredientItem(product: sausageProduct, grams: 40), // 104 kcal, 4.8 P, 8.8 F, 0.6 C
      ];

      final summary = ComboSummary(items);

      expect(summary.totalGrams, equals(110.0));
      expect(summary.totalCalories, closeTo(296.0, 0.1));
      expect(summary.totalProtein, closeTo(14.5, 0.1));
      expect(summary.totalFat, closeTo(18.25, 0.1));
      expect(summary.totalCarbs, closeTo(17.4, 0.1));

      expect(summary.defaultTitle, equals('Хлеб бородинский + Сыр Российский + Колбаса Докторская'));
      expect(summary.ingredientsNotes, equals('Хлеб бородинский 40г, Сыр Российский 30г, Колбаса Докторская 40г'));
    });

    test('ComboSummary handles empty items gracefully', () {
      final summary = ComboSummary(const []);
      expect(summary.totalGrams, equals(0.0));
      expect(summary.totalCalories, equals(0.0));
      expect(summary.defaultTitle, equals('Составное блюдо'));
      expect(summary.ingredientsNotes, isEmpty);
    });
  });

  group('RecipeDao Combo Template Integration Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('saveComboTemplate saves recipe with category "combo" and retrieves via watchCombosWithDetails', () async {
      final now = DateTime.now();
      final p1Id = await db.into(db.foodProducts).insert(
        FoodProductsCompanion.insert(
          name: 'Хлеб тостовый',
          category: const Value('bakery'),
          caloriesPer100g: 250,
          proteinPer100g: 8,
          fatPer100g: 3,
          carbsPer100g: 48,
          createdAt: Value(now),
        ),
      );

      final p2Id = await db.into(db.foodProducts).insert(
        FoodProductsCompanion.insert(
          name: 'Сыр Гауда',
          category: const Value('dairy'),
          caloriesPer100g: 350,
          proteinPer100g: 25,
          fatPer100g: 27,
          carbsPer100g: 0,
          createdAt: Value(now),
        ),
      );

      final p1 = await (db.select(db.foodProducts)..where((tbl) => tbl.id.equals(p1Id))).getSingle();
      final p2 = await (db.select(db.foodProducts)..where((tbl) => tbl.id.equals(p2Id))).getSingle();

      final items = [
        ComboIngredientItem(product: p1, grams: 50),
        ComboIngredientItem(product: p2, grams: 30),
      ];

      final savedId = await db.recipeDao.saveComboTemplate(
        name: 'Бутерброд с сыром',
        items: items.map((i) => (foodProductId: i.product.id, grams: i.grams)).toList(),
      );

      expect(savedId, isPositive);

      final combos = await db.recipeDao.watchCombosWithDetails().first;
      expect(combos.length, equals(1));
      final combo = combos.first;
      expect(combo.recipe.name, equals('Бутерброд с сыром'));
      expect(combo.recipe.category, equals('combo'));
      expect(combo.ingredients.length, equals(2));
      expect(combo.totalGrams, equals(80.0));

      // Delete combo
      await db.recipeDao.deleteRecipe(savedId);
      final afterDelete = await db.recipeDao.watchCombosWithDetails().first;
      expect(afterDelete, isEmpty);
    });
  });
}
