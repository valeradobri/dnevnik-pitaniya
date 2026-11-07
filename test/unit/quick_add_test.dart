import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('DiaryDao Quick Add Tests', () {
    test('insertQuickAddEntry creates placeholder product and logs diary entry', () async {
      final date = DateTime(2026, 11, 7);

      final entryId = await db.diaryDao.insertQuickAddEntry(
        mealType: 'lunch',
        customName: 'Бизнес-ланч в кафе',
        calories: 620,
        protein: 28,
        fat: 22,
        carbs: 75,
        date: date,
        notes: 'Суп + паста',
      );

      expect(entryId, isPositive);

      final entries = await db.diaryDao.getEntriesForDate(date);
      expect(entries.length, 1);

      final entry = entries.first;
      expect(entry.customName, 'Бизнес-ланч в кафе');
      expect(entry.calculatedCalories, 620);
      expect(entry.calculatedProtein, 28);
      expect(entry.calculatedFat, 22);
      expect(entry.calculatedCarbs, 75);
      expect(entry.mealType, 'lunch');
      expect(entry.notes, 'Суп + паста');

      // Check placeholder food was created
      final product = await db.foodDao.getFoodById(entry.foodProductId);
      expect(product, isNotNull);
      expect(product!.sourceType, 'quick_add');
    });

    test('insertQuickAddEntry reuses existing quick_add product without duplicating', () async {
      final date = DateTime(2026, 11, 7);

      await db.diaryDao.insertQuickAddEntry(
        mealType: 'breakfast',
        customName: 'Кофе и круассан',
        calories: 380,
        date: date,
      );

      await db.diaryDao.insertQuickAddEntry(
        mealType: 'dinner',
        customName: 'Ужин у друзей',
        calories: 750,
        date: date,
      );

      final entries = await db.diaryDao.getEntriesForDate(date);
      expect(entries.length, 2);

      // Both entries should reference the EXACT same foodProductId
      expect(entries[0].foodProductId, entries[1].foodProductId);

      // Count products with sourceType = 'quick_add'
      final allFoods = await (db.select(db.foodProducts)
            ..where((t) => t.sourceType.equals('quick_add')))
          .get();
      expect(allFoods.length, 1);
    });

    test('Quick add product is hidden from FoodDao catalog queries', () async {
      await db.diaryDao.insertQuickAddEntry(
        mealType: 'snack',
        customName: 'Шоколадка',
        calories: 250,
        date: DateTime(2026, 11, 7),
      );

      final allFoods = await db.foodDao.getAllFoods();
      expect(allFoods.any((f) => f.sourceType == 'quick_add'), isFalse);

      final searchResults = await db.foodDao.searchFoods('Быстрая');
      expect(searchResults.any((f) => f.sourceType == 'quick_add'), isFalse);
    });

    test('insertQuickAddEntry uses fallback name if customName is empty', () async {
      await db.diaryDao.insertQuickAddEntry(
        mealType: 'snack',
        customName: '   ',
        calories: 150,
        date: DateTime(2026, 11, 7),
      );

      final entries = await db.diaryDao.getEntriesForDate(DateTime(2026, 11, 7));
      expect(entries.first.customName, 'Быстрая запись');
    });
  });
}
