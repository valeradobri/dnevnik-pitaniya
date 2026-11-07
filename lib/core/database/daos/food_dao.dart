import 'package:drift/drift.dart';
import '../app_database.dart';

/// DAO для работы с каталогом продуктов питания
class FoodDao {
  FoodDao(this.db);

  final AppDatabase db;

  /// Получить все продукты
  Future<List<FoodProduct>> getAllFoods() {
    return (db.select(db.foodProducts)
          ..where((t) => t.sourceType.equals('quick_add').not())
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  /// Реактивный стрим всех продуктов
  Stream<List<FoodProduct>> watchAllFoods() {
    return (db.select(db.foodProducts)
          ..where((t) => t.sourceType.equals('quick_add').not())
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Поиск продуктов по имени или категории с поддержкой кириллицы
  Future<List<FoodProduct>> searchFoods(String query, {String? category}) async {
    final clean = query.trim().toLowerCase();
    var q = db.select(db.foodProducts)..where((t) => t.sourceType.equals('quick_add').not());

    if (category != null && category.isNotEmpty) {
      q = q..where((t) => t.category.equals(category));
    }

    final list = await (q..orderBy([(t) => OrderingTerm(expression: t.name)])).get();

    if (clean.isEmpty) {
      return list;
    }

    return list
        .where((item) => item.name.toLowerCase().contains(clean))
        .toList();
  }

  /// Получить продукт по ID
  Future<FoodProduct?> getFoodById(int id) {
    return (db.select(db.foodProducts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Добавить новый продукт
  Future<int> insertFood(FoodProductsCompanion food) {
    return db.into(db.foodProducts).insert(food);
  }

  /// Обновить продукт
  Future<bool> updateFood(FoodProduct food) {
    return db.update(db.foodProducts).replace(food);
  }

  /// Переключить флаг «Избранное»
  Future<void> toggleFavorite(int id, bool isFavorite) {
    return (db.update(db.foodProducts)..where((t) => t.id.equals(id))).write(
      FoodProductsCompanion(isFavorite: Value(isFavorite)),
    );
  }

  /// Реактивный стрим избранных продуктов
  Stream<List<FoodProduct>> watchFavorites() {
    return (db.select(db.foodProducts)
          ..where((t) => t.isFavorite.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch();
  }

  /// Поиск продукта по штрихкоду
  Future<FoodProduct?> getFoodByBarcode(String barcode) {
    final clean = barcode.trim();
    if (clean.isEmpty) return Future.value(null);
    return (db.select(db.foodProducts)..where((t) => t.barcode.equals(clean)))
        .getSingleOrNull();
  }
}
