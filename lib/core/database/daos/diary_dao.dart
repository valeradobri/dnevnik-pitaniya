import 'package:drift/drift.dart';
import '../app_database.dart';

/// Модель сводки КБЖУ за день
class DayTotals {
  const DayTotals({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  static const zero = DayTotals(
    calories: 0.0,
    protein: 0.0,
    fat: 0.0,
    carbs: 0.0,
  );
}

/// DAO для работы с записями дневника питания
class DiaryDao {
  DiaryDao(this.db);

  final AppDatabase db;

  /// Диапазон начала и конца суток для точного среза даты
  (DateTime, DateTime) _dayRange(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return (start, end);
  }

  /// Реактивный стрим записей за указанную дату
  Stream<List<DiaryEntry>> watchEntriesForDate(DateTime date) {
    final (start, end) = _dayRange(date);
    return (db.select(db.diaryEntries)
          ..where((t) => t.entryDate.isBiggerOrEqualValue(start) & t.entryDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
        .watch();
  }

  /// Получить записи за дату
  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) {
    final (start, end) = _dayRange(date);
    return (db.select(db.diaryEntries)
          ..where((t) => t.entryDate.isBiggerOrEqualValue(start) & t.entryDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
        .get();
  }

  /// Добавить новую запись в дневник
  Future<int> insertEntry(DiaryEntriesCompanion entry) {
    return db.into(db.diaryEntries).insert(entry);
  }

  /// Удалить запись из дневника
  Future<int> deleteEntry(int id) {
    return (db.delete(db.diaryEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Обновить запись в дневнике
  Future<bool> updateEntry(DiaryEntry entry) {
    return db.update(db.diaryEntries).replace(entry);
  }

  /// Реактивный стрим суммарных КБЖУ за день
  Stream<DayTotals> watchTotalsForDate(DateTime date) {
    return watchEntriesForDate(date).map((entries) {
      double cals = 0;
      double prot = 0;
      double fats = 0;
      double carb = 0;

      for (final e in entries) {
        cals += e.calculatedCalories;
        prot += e.calculatedProtein;
        fats += e.calculatedFat;
        carb += e.calculatedCarbs;
      }

      return DayTotals(
        calories: cals,
        protein: prot,
        fat: fats,
        carbs: carb,
      );
    });
  }

  /// Реактивный стрим записей дневника в диапазоне дат (включительно)
  Stream<List<DiaryEntry>> watchEntriesForRange(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
    return (db.select(db.diaryEntries)
          ..where((t) => t.entryDate.isBiggerOrEqualValue(start) & t.entryDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.entryDate), (t) => OrderingTerm(expression: t.timestamp)]))
        .watch();
  }

  /// Получить записи конкретного приёма пищи за дату
  Future<List<DiaryEntry>> getMealEntriesForDate(DateTime date, String mealType) async {
    final (start, end) = _dayRange(date);
    return (db.select(db.diaryEntries)
          ..where((t) =>
              t.entryDate.isBiggerOrEqualValue(start) &
              t.entryDate.isSmallerOrEqualValue(end) &
              t.mealType.equals(mealType))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
        .get();
  }

  /// Скопировать список записей в целевую дату и приём пищи
  Future<int> copyEntries({
    required List<DiaryEntry> entries,
    required DateTime targetDate,
    required String targetMealType,
  }) async {
    if (entries.isEmpty) return 0;
    final now = DateTime.now();
    final companions = entries.map((e) {
      return DiaryEntriesCompanion.insert(
        mealType: targetMealType,
        foodProductId: e.foodProductId,
        customName: e.customName,
        grams: e.grams,
        calculatedCalories: e.calculatedCalories,
        calculatedProtein: e.calculatedProtein,
        calculatedFat: e.calculatedFat,
        calculatedCarbs: e.calculatedCarbs,
        entryDate: targetDate,
        notes: Value(e.notes),
        timestamp: Value(now),
      );
    }).toList();

    await db.batch((b) {
      b.insertAll(db.diaryEntries, companions);
    });

    return companions.length;
  }

  /// Скопировать приём пищи из одной даты/приёма в другую
  Future<int> copyMeal({
    required DateTime sourceDate,
    required String sourceMealType,
    required DateTime targetDate,
    required String targetMealType,
  }) async {
    final entries = await getMealEntriesForDate(sourceDate, sourceMealType);
    return copyEntries(
      entries: entries,
      targetDate: targetDate,
      targetMealType: targetMealType,
    );
  }

  /// Скопировать весь день целиком из sourceDate в targetDate
  Future<int> copyDay({
    required DateTime sourceDate,
    required DateTime targetDate,
  }) async {
    final entries = await getEntriesForDate(sourceDate);
    if (entries.isEmpty) return 0;

    final now = DateTime.now();
    final companions = entries.map((e) {
      return DiaryEntriesCompanion.insert(
        mealType: e.mealType,
        foodProductId: e.foodProductId,
        customName: e.customName,
        grams: e.grams,
        calculatedCalories: e.calculatedCalories,
        calculatedProtein: e.calculatedProtein,
        calculatedFat: e.calculatedFat,
        calculatedCarbs: e.calculatedCarbs,
        entryDate: targetDate,
        notes: Value(e.notes),
        timestamp: Value(now),
      );
    }).toList();

    await db.batch((b) {
      b.insertAll(db.diaryEntries, companions);
    });

    return companions.length;
  }

  /// Очистить приём пищи за дату
  Future<int> clearMealForDate(DateTime date, String mealType) async {
    final (start, end) = _dayRange(date);
    return (db.delete(db.diaryEntries)
          ..where((t) =>
              t.entryDate.isBiggerOrEqualValue(start) &
              t.entryDate.isSmallerOrEqualValue(end) &
              t.mealType.equals(mealType)))
        .go();
  }

  /// Очистить весь день за дату
  Future<int> clearDayForDate(DateTime date) async {
    final (start, end) = _dayRange(date);
    return (db.delete(db.diaryEntries)
          ..where((t) =>
              t.entryDate.isBiggerOrEqualValue(start) &
              t.entryDate.isSmallerOrEqualValue(end)))
        .go();
  }

  /// Вставить быструю запись напрямую без выбора продукта из каталога
  Future<int> insertQuickAddEntry({
    required String mealType,
    required String customName,
    required double calories,
    double protein = 0.0,
    double fat = 0.0,
    double carbs = 0.0,
    double grams = 100.0,
    required DateTime date,
    String? notes,
  }) async {
    final quickFood = await _getOrCreateQuickAddFood();
    final now = DateTime.now();

    return db.into(db.diaryEntries).insert(
      DiaryEntriesCompanion.insert(
        mealType: mealType,
        foodProductId: quickFood.id,
        customName: customName.trim().isNotEmpty ? customName.trim() : 'Быстрая запись',
        grams: grams,
        calculatedCalories: calories,
        calculatedProtein: protein,
        calculatedFat: fat,
        calculatedCarbs: carbs,
        entryDate: date,
        notes: Value(notes),
        timestamp: Value(now),
      ),
    );
  }

  Future<FoodProduct> _getOrCreateQuickAddFood() async {
    final existing = await (db.select(db.foodProducts)
          ..where((t) => t.sourceType.equals('quick_add'))
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) return existing;

    final id = await db.into(db.foodProducts).insert(
      FoodProductsCompanion.insert(
        name: 'Быстрая запись',
        caloriesPer100g: 0.0,
        proteinPer100g: 0.0,
        fatPer100g: 0.0,
        carbsPer100g: 0.0,
        category: const Value('other'),
        sourceType: const Value('quick_add'),
      ),
    );

    return (await (db.select(db.foodProducts)..where((t) => t.id.equals(id))).getSingle());
  }
}

