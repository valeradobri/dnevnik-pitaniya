import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:file_selector/file_selector.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/models/backup_data.dart';

/// Сервис резервного копирования, экспорта и восстановления данных
class BackupService {
  BackupService(this.db);

  final AppDatabase db;

  /// Сформировать объект резервной копии из текущего состояния БД
  Future<BackupData> createBackup() async {
    // 1. Профиль пользователя
    final profile = await (db.select(db.userProfiles)..limit(1)).getSingleOrNull();
    final profileJson = profile != null
        ? {
            'name': profile.name,
            'birthDate': profile.birthDate.toIso8601String(),
            'gender': profile.gender,
            'heightCm': profile.heightCm,
            'currentWeightKg': profile.currentWeightKg,
            'targetWeightKg': profile.targetWeightKg,
            'activityLevel': profile.activityLevel,
            'goalType': profile.goalType,
            'weeklyRateKg': profile.weeklyRateKg,
            'targetCalories': profile.targetCalories,
            'targetProteinG': profile.targetProteinG,
            'targetFatG': profile.targetFatG,
            'targetCarbsG': profile.targetCarbsG,
            'targetWaterMl': profile.targetWaterMl,
          }
        : null;

    // 2. Пользовательские продукты
    final customFoods = await (db.select(db.foodProducts)
          ..where((t) => t.sourceType.equals('user')))
        .get();
    final foodsJson = customFoods
        .map((f) => {
              'id': f.id,
              'name': f.name,
              'brand': f.brand,
              'caloriesPer100g': f.caloriesPer100g,
              'proteinPer100g': f.proteinPer100g,
              'fatPer100g': f.fatPer100g,
              'carbsPer100g': f.carbsPer100g,
              'fiberPer100g': f.fiberPer100g,
              'category': f.category,
              'barcode': f.barcode,
              'isFavorite': f.isFavorite,
              'servingSizeG': f.servingSizeG,
            })
        .toList();

    // 3. Записи дневника питания
    final diary = await (db.select(db.diaryEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
    final diaryJson = diary
        .map((d) => {
              'mealType': d.mealType,
              'foodProductId': d.foodProductId,
              'customName': d.customName,
              'grams': d.grams,
              'calculatedCalories': d.calculatedCalories,
              'calculatedProtein': d.calculatedProtein,
              'calculatedFat': d.calculatedFat,
              'calculatedCarbs': d.calculatedCarbs,
              'entryDate': d.entryDate.toIso8601String(),
              'timestamp': d.timestamp.toIso8601String(),
              'notes': d.notes,
            })
        .toList();

    // 4. Записи воды
    final water = await (db.select(db.waterEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
    final waterJson = water
        .map((w) => {
              'amountMl': w.amountMl,
              'entryDate': w.entryDate.toIso8601String(),
              'timestamp': w.timestamp.toIso8601String(),
            })
        .toList();

    // 5. Взвешивания
    final weights = await (db.select(db.weightEntries)
          ..orderBy([(t) => OrderingTerm.asc(t.entryDate)]))
        .get();
    final weightJson = weights
        .map((w) => {
              'weightKg': w.weightKg,
              'entryDate': w.entryDate.toIso8601String(),
              'notes': w.notes,
              'timestamp': w.timestamp.toIso8601String(),
            })
        .toList();

    // 6. Рецепты и их ингредиенты
    final recipes = await db.select(db.recipes).get();
    final List<Map<String, dynamic>> recipesJson = [];
    for (final r in recipes) {
      final ingredients = await (db.select(db.recipeIngredients)
            ..where((t) => t.recipeId.equals(r.id)))
          .get();

      final ingList = <Map<String, dynamic>>[];
      for (final ing in ingredients) {
        final product = await (db.select(db.foodProducts)
              ..where((t) => t.id.equals(ing.foodProductId)))
            .getSingleOrNull();

        ingList.add({
          'foodProductId': ing.foodProductId,
          'productName': product?.name ?? 'Продукт',
          'grams': ing.grams,
          'notes': ing.notes,
        });
      }

      recipesJson.add({
        'name': r.name,
        'description': r.description,
        'prepTimeMinutes': r.prepTimeMinutes,
        'servings': r.servings,
        'category': r.category,
        'isFavorite': r.isFavorite,
        'imageUrl': r.imageUrl,
        'ingredients': ingList,
      });
    }

    return BackupData(
      version: 1,
      appName: 'Dnevnik',
      exportedAt: DateTime.now(),
      userProfile: profileJson,
      customFoods: foodsJson,
      diaryEntries: diaryJson,
      waterEntries: waterJson,
      weightEntries: weightJson,
      recipes: recipesJson,
    );
  }

  /// Экспорт полной резервной копии в форматированную строку JSON
  Future<String> exportToJson() async {
    final backup = await createBackup();
    return const JsonEncoder.withIndent('  ').convert(backup.toJson());
  }

  /// Экспорт дневника питания в CSV с поддержкой русского языка (UTF-8 with BOM)
  Future<String> exportDiaryToCsv() async {
    final diary = await (db.select(db.diaryEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.entryDate)]))
        .get();

    final buffer = StringBuffer();
    // BOM для корректного открытия кириллицы в Excel
    buffer.write('\uFEFF');
    buffer.writeln(
        'Дата;Время;Приём пищи;Продукт;Граммы;Калории;Белки (г);Жиры (г);Углеводы (г);Заметка');

    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    for (final e in diary) {
      final mealName = switch (e.mealType) {
        'breakfast' => 'Завтрак',
        'lunch' => 'Обед',
        'dinner' => 'Ужин',
        'snack' => 'Перекус',
        _ => e.mealType,
      };

      final cleanName = e.customName.replaceAll(';', ',');
      final cleanNotes = (e.notes ?? '').replaceAll(';', ',').replaceAll('\n', ' ');

      buffer.writeln(
        '${dateFormat.format(e.entryDate)};'
        '${timeFormat.format(e.timestamp)};'
        '$mealName;'
        '$cleanName;'
        '${e.grams.toStringAsFixed(1)};'
        '${e.calculatedCalories.toStringAsFixed(1)};'
        '${e.calculatedProtein.toStringAsFixed(1)};'
        '${e.calculatedFat.toStringAsFixed(1)};'
        '${e.calculatedCarbs.toStringAsFixed(1)};'
        '$cleanNotes',
      );
    }

    return buffer.toString();
  }

  /// Экспорт истории взвешиваний в CSV
  Future<String> exportWeightToCsv() async {
    final weights = await (db.select(db.weightEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.entryDate)]))
        .get();

    final buffer = StringBuffer();
    buffer.write('\uFEFF');
    buffer.writeln('Дата;Время;Вес (кг);Заметка');

    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    for (final w in weights) {
      final cleanNotes = (w.notes ?? '').replaceAll(';', ',').replaceAll('\n', ' ');
      buffer.writeln(
        '${dateFormat.format(w.entryDate)};'
        '${timeFormat.format(w.timestamp)};'
        '${w.weightKg.toStringAsFixed(1)};'
        '$cleanNotes',
      );
    }

    return buffer.toString();
  }

  /// Парсинг и валидация строки JSON бэкапа
  BackupData parseBackupJson(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Некорректный формат файла резервной копии');
    }

    if (decoded['appName'] != 'Dnevnik') {
      throw const FormatException('Файл не является резервной копией приложения «Дневник»');
    }

    return BackupData.fromJson(decoded);
  }

  /// Восстановление базы данных из резервной копии
  Future<void> restoreBackup(BackupData backup, {bool clearExisting = false}) async {
    await db.transaction(() async {
      if (clearExisting) {
        await db.delete(db.diaryEntries).go();
        await db.delete(db.waterEntries).go();
        await db.delete(db.weightEntries).go();
        await db.delete(db.recipeIngredients).go();
        await db.delete(db.recipes).go();
        await (db.delete(db.foodProducts)..where((t) => t.sourceType.equals('user'))).go();
      }

      // 1. Восстановление профиля
      if (backup.userProfile != null) {
        final p = backup.userProfile!;
        final profileCompanion = UserProfilesCompanion(
          id: const Value(1),
          name: Value(p['name'] as String? ?? 'Пользователь'),
          birthDate: Value(DateTime.tryParse(p['birthDate'] as String? ?? '') ?? DateTime(1995)),
          gender: Value(p['gender'] as String? ?? 'female'),
          heightCm: Value((p['heightCm'] as num?)?.toDouble() ?? 170.0),
          currentWeightKg: Value((p['currentWeightKg'] as num?)?.toDouble() ?? 70.0),
          targetWeightKg: Value((p['targetWeightKg'] as num?)?.toDouble() ?? 65.0),
          activityLevel: Value(p['activityLevel'] as String? ?? 'moderate'),
          goalType: Value(p['goalType'] as String? ?? 'maintain'),
          weeklyRateKg: Value((p['weeklyRateKg'] as num?)?.toDouble() ?? 0.5),
          targetCalories: Value((p['targetCalories'] as num?)?.toInt() ?? 2000),
          targetProteinG: Value((p['targetProteinG'] as num?)?.toDouble() ?? 120.0),
          targetFatG: Value((p['targetFatG'] as num?)?.toDouble() ?? 65.0),
          targetCarbsG: Value((p['targetCarbsG'] as num?)?.toDouble() ?? 230.0),
          targetWaterMl: Value((p['targetWaterMl'] as num?)?.toInt() ?? 2000),
          updatedAt: Value(DateTime.now()),
        );

        await db.into(db.userProfiles).insertOnConflictUpdate(profileCompanion);
      }

      // 2. Восстановление пользовательских продуктов (с сопоставлением старых и новых ID)
      final foodIdMap = <int, int>{};
      for (final f in backup.customFoods) {
        final oldId = f['id'] as int?;
        final companion = FoodProductsCompanion.insert(
          name: f['name'] as String,
          brand: Value(f['brand'] as String?),
          caloriesPer100g: (f['caloriesPer100g'] as num).toDouble(),
          proteinPer100g: (f['proteinPer100g'] as num).toDouble(),
          fatPer100g: (f['fatPer100g'] as num).toDouble(),
          carbsPer100g: (f['carbsPer100g'] as num).toDouble(),
          fiberPer100g: Value((f['fiberPer100g'] as num?)?.toDouble()),
          category: Value(f['category'] as String? ?? 'other'),
          sourceType: const Value('user'),
          barcode: Value(f['barcode'] as String?),
          isFavorite: Value(f['isFavorite'] as bool? ?? false),
          servingSizeG: Value((f['servingSizeG'] as num?)?.toDouble() ?? 100.0),
        );

        final newId = await db.into(db.foodProducts).insert(companion);
        if (oldId != null) {
          foodIdMap[oldId] = newId;
        }
      }

      // 3. Восстановление рецептов
      for (final r in backup.recipes) {
        final recipeCompanion = RecipesCompanion.insert(
          name: r['name'] as String,
          description: Value(r['description'] as String?),
          prepTimeMinutes: Value(r['prepTimeMinutes'] as int? ?? 30),
          servings: Value(r['servings'] as int? ?? 1),
          category: Value(r['category'] as String? ?? 'other'),
          isFavorite: Value(r['isFavorite'] as bool? ?? false),
          imageUrl: Value(r['imageUrl'] as String?),
        );
        final newRecipeId = await db.into(db.recipes).insert(recipeCompanion);

        final ingredients = (r['ingredients'] as List<dynamic>?) ?? [];
        for (final ing in ingredients) {
          final ingMap = ing as Map<String, dynamic>;
          int? productId = ingMap['foodProductId'] as int?;

          // Если продукт был пользовательским, берем новый ID
          if (productId != null && foodIdMap.containsKey(productId)) {
            productId = foodIdMap[productId];
          } else if (ingMap['productName'] != null) {
            // Поиск по имени среди базовых продуктов
            final found = await (db.select(db.foodProducts)
                  ..where((t) => t.name.equals(ingMap['productName'] as String))
                  ..limit(1))
                .getSingleOrNull();
            productId = found?.id;
          }

          if (productId != null) {
            await db.into(db.recipeIngredients).insert(
                  RecipeIngredientsCompanion.insert(
                    recipeId: newRecipeId,
                    foodProductId: productId,
                    grams: (ingMap['grams'] as num).toDouble(),
                    notes: Value(ingMap['notes'] as String?),
                  ),
                );
          }
        }
      }

      // 4. Восстановление записей дневника
      for (final d in backup.diaryEntries) {
        int? productId = d['foodProductId'] as int?;
        if (productId != null && foodIdMap.containsKey(productId)) {
          productId = foodIdMap[productId];
        } else {
          // Ищем продукт по названию
          final found = await (db.select(db.foodProducts)
                ..where((t) => t.name.equals(d['customName'] as String))
                ..limit(1))
              .getSingleOrNull();
          productId = found?.id ?? 1; // Дефолтный fallback
        }

        final finalProductId = productId ?? 1;

        final entryDate = DateTime.tryParse(d['entryDate'] as String? ?? '') ?? DateTime.now();
        final timestamp = DateTime.tryParse(d['timestamp'] as String? ?? '') ?? DateTime.now();

        await db.into(db.diaryEntries).insert(
              DiaryEntriesCompanion.insert(
                mealType: d['mealType'] as String? ?? 'snack',
                foodProductId: finalProductId,
                customName: d['customName'] as String? ?? 'Блюдо',
                grams: (d['grams'] as num?)?.toDouble() ?? 100.0,
                calculatedCalories: (d['calculatedCalories'] as num?)?.toDouble() ?? 0.0,
                calculatedProtein: (d['calculatedProtein'] as num?)?.toDouble() ?? 0.0,
                calculatedFat: (d['calculatedFat'] as num?)?.toDouble() ?? 0.0,
                calculatedCarbs: (d['calculatedCarbs'] as num?)?.toDouble() ?? 0.0,
                entryDate: entryDate,
                timestamp: Value(timestamp),
                notes: Value(d['notes'] as String?),
              ),
            );
      }

      // 5. Восстановление записей воды
      for (final w in backup.waterEntries) {
        final entryDate = DateTime.tryParse(w['entryDate'] as String? ?? '') ?? DateTime.now();
        final timestamp = DateTime.tryParse(w['timestamp'] as String? ?? '') ?? DateTime.now();

        await db.into(db.waterEntries).insert(
              WaterEntriesCompanion.insert(
                amountMl: w['amountMl'] as int? ?? 250,
                entryDate: entryDate,
                timestamp: Value(timestamp),
              ),
            );
      }

      // 6. Восстановление взвешиваний (с сохранением уникальности дат)
      for (final w in backup.weightEntries) {
        final entryDate = DateTime.tryParse(w['entryDate'] as String? ?? '') ?? DateTime.now();
        final timestamp = DateTime.tryParse(w['timestamp'] as String? ?? '') ?? DateTime.now();

        await db.into(db.weightEntries).insertOnConflictUpdate(
              WeightEntriesCompanion.insert(
                weightKg: (w['weightKg'] as num?)?.toDouble() ?? 70.0,
                entryDate: entryDate,
                notes: Value(w['notes'] as String?),
                timestamp: Value(timestamp),
              ),
            );
      }
    });
  }

  /// Сохранение во временный файл и вызов системного окна «Поделиться»
  Future<void> shareContent({
    required String content,
    required String fileName,
    String? subject,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content, encoding: utf8);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: subject ?? fileName,
      ),
    );
  }

  /// Открытие системного диалога выбора файла бэкапа
  Future<String?> pickBackupFile() async {
    const typeGroup = XTypeGroup(
      label: 'JSON Резервная копия',
      extensions: ['json'],
    );

    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return null;
    return await file.readAsString();
  }
}
