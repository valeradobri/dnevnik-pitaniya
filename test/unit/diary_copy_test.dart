import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/core/database/app_database.dart';

void main() {
  late AppDatabase db;
  late int eggId;
  late int breadId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());

    eggId = await db.foodDao.insertFood(
      FoodProductsCompanion.insert(
        name: 'Яйцо куриное',
        caloriesPer100g: 155.0,
        proteinPer100g: 13.0,
        fatPer100g: 11.0,
        carbsPer100g: 0.7,
      ),
    );

    breadId = await db.foodDao.insertFood(
      FoodProductsCompanion.insert(
        name: 'Хлеб цельнозерновой',
        caloriesPer100g: 220.0,
        proteinPer100g: 8.0,
        fatPer100g: 2.0,
        carbsPer100g: 42.0,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('DiaryDao Copy & Clear Operations', () {
    test('copyEntries copies specified entries to target date and mealType', () async {
      final date1 = DateTime(2026, 11, 7);
      final date2 = DateTime(2026, 11, 8);

      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'breakfast',
          foodProductId: eggId,
          customName: 'Яйцо куриное',
          grams: 100,
          calculatedCalories: 155,
          calculatedProtein: 13,
          calculatedFat: 11,
          calculatedCarbs: 0.7,
          entryDate: date1,
        ),
      );

      final sourceEntries = await db.diaryDao.getEntriesForDate(date1);
      expect(sourceEntries.length, 1);

      final count = await db.diaryDao.copyEntries(
        entries: sourceEntries,
        targetDate: date2,
        targetMealType: 'lunch',
      );

      expect(count, 1);

      final targetEntries = await db.diaryDao.getEntriesForDate(date2);
      expect(targetEntries.length, 1);
      expect(targetEntries.first.mealType, 'lunch');
      expect(targetEntries.first.customName, 'Яйцо куриное');
      expect(targetEntries.first.grams, 100);
      expect(targetEntries.first.calculatedCalories, 155);
      expect(targetEntries.first.entryDate.year, 2026);
      expect(targetEntries.first.entryDate.month, 11);
      expect(targetEntries.first.entryDate.day, 8);
    });

    test('copyEntries returns 0 for empty list', () async {
      final count = await db.diaryDao.copyEntries(
        entries: [],
        targetDate: DateTime(2026, 11, 8),
        targetMealType: 'breakfast',
      );
      expect(count, 0);
    });

    test('copyMeal copies only the specified mealType to target date and mealType', () async {
      final date1 = DateTime(2026, 11, 7);
      final date2 = DateTime(2026, 11, 8);

      // Завтрак (2 блюда)
      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'breakfast',
          foodProductId: eggId,
          customName: 'Яйцо куриное',
          grams: 100,
          calculatedCalories: 155,
          calculatedProtein: 13,
          calculatedFat: 11,
          calculatedCarbs: 0.7,
          entryDate: date1,
        ),
      );
      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'breakfast',
          foodProductId: breadId,
          customName: 'Хлеб цельнозерновой',
          grams: 50,
          calculatedCalories: 110,
          calculatedProtein: 4,
          calculatedFat: 1,
          calculatedCarbs: 21,
          entryDate: date1,
        ),
      );

      // Обед (1 блюдо)
      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'lunch',
          foodProductId: breadId,
          customName: 'Хлеб на обед',
          grams: 60,
          calculatedCalories: 132,
          calculatedProtein: 4.8,
          calculatedFat: 1.2,
          calculatedCarbs: 25.2,
          entryDate: date1,
        ),
      );

      // Копируем только завтрак в обед на date2
      final copied = await db.diaryDao.copyMeal(
        sourceDate: date1,
        sourceMealType: 'breakfast',
        targetDate: date2,
        targetMealType: 'lunch',
      );

      expect(copied, 2);

      final date2Entries = await db.diaryDao.getEntriesForDate(date2);
      expect(date2Entries.length, 2);
      expect(date2Entries.every((e) => e.mealType == 'lunch'), isTrue);
    });

    test('copyDay duplicates all meals of the entire day to target date', () async {
      final date1 = DateTime(2026, 11, 7);
      final date2 = DateTime(2026, 11, 8);

      // Завтрак
      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'breakfast',
          foodProductId: eggId,
          customName: 'Яйцо',
          grams: 100,
          calculatedCalories: 155,
          calculatedProtein: 13,
          calculatedFat: 11,
          calculatedCarbs: 0.7,
          entryDate: date1,
        ),
      );

      // Обед
      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'lunch',
          foodProductId: breadId,
          customName: 'Хлеб',
          grams: 50,
          calculatedCalories: 110,
          calculatedProtein: 4,
          calculatedFat: 1,
          calculatedCarbs: 21,
          entryDate: date1,
        ),
      );

      // Ужин
      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'dinner',
          foodProductId: eggId,
          customName: 'Яйцо на ужин',
          grams: 100,
          calculatedCalories: 155,
          calculatedProtein: 13,
          calculatedFat: 11,
          calculatedCarbs: 0.7,
          entryDate: date1,
        ),
      );

      final copiedCount = await db.diaryDao.copyDay(
        sourceDate: date1,
        targetDate: date2,
      );

      expect(copiedCount, 3);

      final date2Entries = await db.diaryDao.getEntriesForDate(date2);
      expect(date2Entries.length, 3);

      final breakfastEntries = date2Entries.where((e) => e.mealType == 'breakfast').toList();
      final lunchEntries = date2Entries.where((e) => e.mealType == 'lunch').toList();
      final dinnerEntries = date2Entries.where((e) => e.mealType == 'dinner').toList();

      expect(breakfastEntries.length, 1);
      expect(lunchEntries.length, 1);
      expect(dinnerEntries.length, 1);
    });

    test('clearMealForDate removes only specified meal on that date', () async {
      final date = DateTime(2026, 11, 7);

      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'breakfast',
          foodProductId: eggId,
          customName: 'Яйцо',
          grams: 100,
          calculatedCalories: 155,
          calculatedProtein: 13,
          calculatedFat: 11,
          calculatedCarbs: 0.7,
          entryDate: date,
        ),
      );

      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'lunch',
          foodProductId: breadId,
          customName: 'Хлеб',
          grams: 50,
          calculatedCalories: 110,
          calculatedProtein: 4,
          calculatedFat: 1,
          calculatedCarbs: 21,
          entryDate: date,
        ),
      );

      final deleted = await db.diaryDao.clearMealForDate(date, 'breakfast');
      expect(deleted, 1);

      final remaining = await db.diaryDao.getEntriesForDate(date);
      expect(remaining.length, 1);
      expect(remaining.first.mealType, 'lunch');
    });

    test('clearDayForDate removes all meals on that date but preserves other dates', () async {
      final date1 = DateTime(2026, 11, 7);
      final date2 = DateTime(2026, 11, 8);

      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'breakfast',
          foodProductId: eggId,
          customName: 'Яйцо день 1',
          grams: 100,
          calculatedCalories: 155,
          calculatedProtein: 13,
          calculatedFat: 11,
          calculatedCarbs: 0.7,
          entryDate: date1,
        ),
      );

      await db.diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: 'breakfast',
          foodProductId: eggId,
          customName: 'Яйцо день 2',
          grams: 100,
          calculatedCalories: 155,
          calculatedProtein: 13,
          calculatedFat: 11,
          calculatedCarbs: 0.7,
          entryDate: date2,
        ),
      );

      final deleted = await db.diaryDao.clearDayForDate(date1);
      expect(deleted, 1);

      final date1Entries = await db.diaryDao.getEntriesForDate(date1);
      expect(date1Entries.isEmpty, isTrue);

      final date2Entries = await db.diaryDao.getEntriesForDate(date2);
      expect(date2Entries.length, 1);
    });
  });
}
