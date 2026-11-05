import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/backup/data/services/backup_service.dart';

void main() {
  late AppDatabase db;
  late BackupService service;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = BackupService(db);

    // Подготовка тестовых данных
    await db.userDao.saveProfile(
      UserProfilesCompanion(
        name: const drift.Value('Валерия'),
        gender: const drift.Value('female'),
        birthDate: drift.Value(DateTime(1996, 5, 20)),
        heightCm: const drift.Value(168.0),
        currentWeightKg: const drift.Value(64.5),
        targetWeightKg: const drift.Value(60.0),
        activityLevel: const drift.Value('moderate'),
        goalType: const drift.Value('lose_weight'),
        targetCalories: const drift.Value(1850),
        targetProteinG: const drift.Value(110.0),
        targetFatG: const drift.Value(60.0),
        targetCarbsG: const drift.Value(215.0),
        targetWaterMl: const drift.Value(2100),
      ),
    );

    await db.weightDao.addWeight(
      weightKg: 64.5,
      date: DateTime(2026, 11, 1),
      notes: 'Утреннее взвешивание',
    );

    await db.waterDao.addWater(
      DateTime(2026, 11, 1),
      500,
    );

    final foodId = await db.foodDao.insertFood(
      FoodProductsCompanion.insert(
        name: 'Смузи ягодный',
        caloriesPer100g: 85.0,
        proteinPer100g: 2.5,
        fatPer100g: 0.5,
        carbsPer100g: 18.0,
        category: drift.Value('beverages'),
        sourceType: drift.Value('user'),
      ),
    );

    await db.diaryDao.insertEntry(
      DiaryEntriesCompanion.insert(
        mealType: 'breakfast',
        foodProductId: foodId,
        customName: 'Смузи ягодный',
        grams: 250.0,
        calculatedCalories: 212.5,
        calculatedProtein: 6.25,
        calculatedFat: 1.25,
        calculatedCarbs: 45.0,
        entryDate: DateTime(2026, 11, 1),
        notes: const drift.Value('Очень вкусно'),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('BackupService Export Tests', () {
    test('exportToJson creates complete valid JSON with all tables', () async {
      final jsonStr = await service.exportToJson();
      expect(jsonStr.isNotEmpty, isTrue);

      final backup = service.parseBackupJson(jsonStr);
      expect(backup.appName, 'Dnevnik');
      expect(backup.version, 1);
      expect(backup.userProfile?['name'], 'Валерия');
      expect(backup.weightEntries.length, 1);
      expect(backup.waterEntries.length, 1);
      expect(backup.diaryEntries.length, 1);
      expect(backup.customFoods.length, 1);

      final summary = backup.summary;
      expect(summary.hasProfile, isTrue);
      expect(summary.profileName, 'Валерия');
      expect(summary.recipesCount, greaterThanOrEqualTo(5));
      expect(summary.totalRecords, greaterThanOrEqualTo(10));
    });

    test('exportDiaryToCsv outputs UTF-8 BOM, column headers and semicolon separators',
        () async {
      final csv = await service.exportDiaryToCsv();
      expect(csv.startsWith('\uFEFF'), isTrue);
      expect(csv.contains('Дата;Время;Приём пищи;Продукт;Граммы'), isTrue);
      expect(csv.contains('Завтрак;Смузи ягодный;250.0;212.5'), isTrue);
    });

    test('exportWeightToCsv outputs weight records with headers', () async {
      final csv = await service.exportWeightToCsv();
      expect(csv.startsWith('\uFEFF'), isTrue);
      expect(csv.contains('Дата;Время;Вес (кг);Заметка'), isTrue);
      expect(csv.contains('64.5;Утреннее взвешивание'), isTrue);
    });

    test('parseBackupJson throws FormatException for foreign or corrupted JSON', () {
      expect(
        () => service.parseBackupJson('{"appName": "OtherApp"}'),
        throwsFormatException,
      );
      expect(
        () => service.parseBackupJson('not a json'),
        throwsFormatException,
      );
    });
  });

  group('BackupService Restore Tests', () {
    test('restoreBackup successfully restores all data into new database', () async {
      // Экспорт данных из первой БД
      final backup = await service.createBackup();

      // Создаем чистую вторую БД
      final newDb = AppDatabase.forTesting(NativeDatabase.memory());
      final newService = BackupService(newDb);

      // Восстанавливаем данные
      await newService.restoreBackup(backup, clearExisting: true);

      // Проверяем восстановленный профиль
      final profile = await (newDb.select(newDb.userProfiles)..limit(1)).getSingleOrNull();
      expect(profile, isNotNull);
      expect(profile!.name, 'Валерия');
      expect(profile.currentWeightKg, 64.5);

      // Проверяем восстановленные записи
      final weights = await newDb.select(newDb.weightEntries).get();
      expect(weights.length, 1);
      expect(weights.first.weightKg, 64.5);

      final water = await newDb.select(newDb.waterEntries).get();
      expect(water.length, 1);
      expect(water.first.amountMl, 500);

      final diary = await newDb.select(newDb.diaryEntries).get();
      expect(diary.length, 1);
      expect(diary.first.customName, 'Смузи ягодный');
      expect(diary.first.grams, 250.0);

      final foods = await (newDb.select(newDb.foodProducts)
            ..where((t) => t.sourceType.equals('user')))
          .get();
      expect(foods.length, 1);
      expect(foods.first.name, 'Смузи ягодный');

      await newDb.close();
    });
  });
}
