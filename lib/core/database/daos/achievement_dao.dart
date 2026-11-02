import 'package:drift/drift.dart';
import '../app_database.dart';

/// Модель достижения с текущим статусом пользователя
class AchievementWithStatus {
  const AchievementWithStatus({
    required this.achievement,
    required this.currentCount,
    required this.isUnlocked,
    this.unlockedAt,
  });

  final Achievement achievement;
  final int currentCount;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  int get requiredCount => achievement.requiredCount;
  double get progress => requiredCount > 0 ? (currentCount / requiredCount).clamp(0.0, 1.0) : 0.0;
}

/// Статистика осознанности и привычек без чувства вины
class HabitStats {
  const HabitStats({
    required this.currentStreak,
    required this.totalActiveDays,
    required this.unlockedAchievementsCount,
    required this.totalAchievementsCount,
  });

  final int currentStreak;
  final int totalActiveDays;
  final int unlockedAchievementsCount;
  final int totalAchievementsCount;
}

/// DAO для системы этичной геймификации и бейджей
class AchievementDao {
  AchievementDao(this.db);

  final AppDatabase db;

  /// Реактивный стрим всех достижений с текущим статусом
  Stream<List<AchievementWithStatus>> watchAchievementsWithStatus() {
    final query = db.select(db.achievements).join([
      leftOuterJoin(
        db.userAchievements,
        db.userAchievements.achievementId.equalsExp(db.achievements.id),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final achievement = row.readTable(db.achievements);
        final userAch = row.readTableOrNull(db.userAchievements);

        return AchievementWithStatus(
          achievement: achievement,
          currentCount: userAch?.currentCount ?? 0,
          isUnlocked: userAch?.isUnlocked ?? false,
          unlockedAt: userAch?.unlockedAt,
        );
      }).toList();
    });
  }

  /// Получить список достижений со статусом однократно
  Future<List<AchievementWithStatus>> getAchievementsWithStatus() async {
    final query = db.select(db.achievements).join([
      leftOuterJoin(
        db.userAchievements,
        db.userAchievements.achievementId.equalsExp(db.achievements.id),
      ),
    ]);

    final rows = await query.get();
    return rows.map((row) {
      final achievement = row.readTable(db.achievements);
      final userAch = row.readTableOrNull(db.userAchievements);

      return AchievementWithStatus(
        achievement: achievement,
        currentCount: userAch?.currentCount ?? 0,
        isUnlocked: userAch?.isUnlocked ?? false,
        unlockedAt: userAch?.unlockedAt,
      );
    }).toList();
  }

  /// Проверить и синхронизировать все достижения по фактическим данным в БД
  Future<void> syncAchievements() async {
    // Автоматически сидируем/обновляем список из 60 достижений, если они еще не добавлены
    await db.seedAchievements();

    final allAchievements = await db.select(db.achievements).get();
    if (allAchievements.isEmpty) return;

    // 1. Записи дневника и уникальные даты
    final diaryEntries = await db.select(db.diaryEntries).get();
    final uniqueDiaryDates = diaryEntries
        .map((e) => DateTime(e.entryDate.year, e.entryDate.month, e.entryDate.day))
        .toSet()
        .toList()
      ..sort();

    final streak = _calculateConsciousStreak(uniqueDiaryDates);
    final totalDiaryDays = uniqueDiaryDates.length;
    final totalEntries = diaryEntries.length;

    // Группировка дневника по дням для приемов пищи и нутриентов
    final entriesByDate = <DateTime, List<DiaryEntry>>{};
    for (final e in diaryEntries) {
      final d = DateTime(e.entryDate.year, e.entryDate.month, e.entryDate.day);
      (entriesByDate[d] ??= []).add(e);
    }

    int fullDaysCount = 0;
    int calorieTargetDays = 0;
    int rainbowDays = 0;
    int snackCount = 0;
    bool hadEarlyBreakfast = false;
    bool hadDinnerZen = false;
    bool hadMindfulTreat = false;

    final profile = await db.select(db.userProfiles).getSingleOrNull();
    final targetCalories = profile?.targetCalories.toDouble() ?? 2000.0;
    final targetProtein = profile?.targetProteinG ?? 120.0;
    final targetWater = profile?.targetWaterMl ?? 2000;

    int proteinTargetDays = 0;

    for (final dayEntries in entriesByDate.values) {
      final mealTypes = dayEntries.map((e) => e.mealType).toSet();
      if (mealTypes.contains('breakfast') &&
          mealTypes.contains('lunch') &&
          mealTypes.contains('dinner')) {
        fullDaysCount++;
      }

      double dayCals = 0;
      double dayProtein = 0;
      for (final e in dayEntries) {
        dayCals += e.calculatedCalories;
        dayProtein += e.calculatedProtein;

        if (e.mealType == 'snack') snackCount++;
        if (e.mealType == 'breakfast' && e.timestamp.hour < 10) hadEarlyBreakfast = true;
        if (e.mealType == 'dinner' && e.timestamp.hour < 21) hadDinnerZen = true;
        if (e.calculatedCalories >= 250 &&
            (e.customName.toLowerCase().contains('десерт') ||
                e.customName.toLowerCase().contains('шоколад') ||
                e.customName.toLowerCase().contains('торт') ||
                e.customName.toLowerCase().contains('печенье') ||
                e.customName.toLowerCase().contains('мороженое') ||
                e.customName.toLowerCase().contains('сладк'))) {
          hadMindfulTreat = true;
        }
      }

      if ((dayCals - targetCalories).abs() <= 200) calorieTargetDays++;
      if (dayProtein >= targetProtein * 0.9) proteinTargetDays++;
      if (mealTypes.length >= 3) rainbowDays++;
    }

    // 2. Водный баланс
    final waterEntries = await db.select(db.waterEntries).get();
    final waterByDate = <DateTime, int>{};
    bool hadMorningGlass = false;
    for (final w in waterEntries) {
      final d = DateTime(w.entryDate.year, w.entryDate.month, w.entryDate.day);
      waterByDate[d] = (waterByDate[d] ?? 0) + w.amountMl;
      if (w.timestamp.hour < 9) hadMorningGlass = true;
    }
    final waterGoalDays = waterByDate.values.where((ml) => ml >= targetWater).length;
    final waterLiterDays = waterByDate.values.where((ml) => ml >= 1000).length;

    // 3. Вес
    final weightEntries = await db.select(db.weightEntries).get();
    final weightCount = weightEntries.length;
    bool hadWeightProgress = false;
    if (profile != null && weightEntries.length >= 2) {
      final firstW = weightEntries.first.weightKg;
      final lastW = weightEntries.last.weightKg;
      final startDiff = (firstW - profile.targetWeightKg).abs();
      final currentDiff = (lastW - profile.targetWeightKg).abs();
      if (currentDiff < startDiff) hadWeightProgress = true;
    }

    // 4. Продукты и сканер
    final allFoods = await db.select(db.foodProducts).get();
    final userFoodCount = allFoods.where((t) => t.sourceType == 'user').length;
    final barcodeCount = allFoods.where((t) => t.barcode != null || t.sourceType == 'open_food_facts').length;
    final favFoodCount = allFoods.where((t) => t.isFavorite).length;

    // Категории продуктов
    final usedFoodIds = diaryEntries.map((e) => e.foodProductId).toSet();
    final usedFoods = allFoods.where((f) => usedFoodIds.contains(f.id)).toList();
    final veggieCount = usedFoods.where((f) => f.category == 'vegetables').length;
    final fruitCount = usedFoods.where((f) => f.category == 'fruits').length;
    final fishCount = usedFoods.where((f) => f.category == 'fish').length;
    final fiberCount = usedFoods.where((f) => f.category == 'grains').length;
    final healthyFatsCount = usedFoods.where((f) => f.category == 'nuts' || f.category == 'fish').length;

    // 5. Рецепты
    final allRecipes = await db.select(db.recipes).get();
    final favRecipesCount = allRecipes.where((r) => r.isFavorite).length;
    final userCreatedRecipes = allRecipes.where((r) => r.imageUrl == null || r.imageUrl!.isEmpty).length;
    final recipeDiaryEntries = diaryEntries.where((e) =>
        e.customName.contains('готов') ||
        allRecipes.any((r) => e.customName.toLowerCase().contains(r.name.toLowerCase()))).length;

    // 6. Вычисление прогресса для каждого из 60 достижений
    final now = DateTime.now();
    for (final ach in allAchievements) {
      int count = 0;
      switch (ach.key) {
        // Серии и регулярность
        case 'first_entry':
          count = diaryEntries.isNotEmpty ? 1 : 0;
          break;
        case 'three_days_streak':
          count = streak;
          break;
        case 'week_streak':
          count = streak;
          break;
        case 'two_weeks_streak':
          count = streak;
          break;
        case 'twenty_one_days':
          count = streak;
          break;
        case 'month_streak':
          count = totalDiaryDays;
          break;
        case 'fifty_days_streak':
          count = totalDiaryDays;
          break;
        case 'hundred_days_streak':
          count = totalDiaryDays;
          break;
        case 'half_year_streak':
          count = totalDiaryDays;
          break;
        case 'year_streak':
          count = totalDiaryDays;
          break;
        case 'weekend_streak':
          count = streak >= 2 ? 2 : 0;
          break;
        case 'full_day_logged':
          count = fullDaysCount > 0 ? 1 : 0;
          break;
        case 'five_full_days':
          count = fullDaysCount;
          break;
        case 'early_bird':
          count = hadEarlyBreakfast ? 1 : 0;
          break;
        case 'dinner_zen':
          count = hadDinnerZen ? 1 : 0;
          break;

        // Записи блюд
        case 'ten_entries':
          count = totalEntries;
          break;
        case 'twenty_five_entries':
          count = totalEntries;
          break;
        case 'fifty_entries':
          count = totalEntries;
          break;
        case 'hundred_entries':
          count = totalEntries;
          break;
        case 'two_hundred_entries':
          count = totalEntries;
          break;
        case 'snack_master':
          count = snackCount > 0 ? 1 : 0;
          break;
        case 'five_snacks':
          count = snackCount;
          break;

        // Вода
        case 'water_first':
          count = waterEntries.isNotEmpty ? 1 : 0;
          break;
        case 'water_liter':
          count = waterLiterDays > 0 ? 1 : 0;
          break;
        case 'water_day_goal':
          count = waterGoalDays > 0 ? 1 : 0;
          break;
        case 'water_three_days':
          count = waterGoalDays;
          break;
        case 'water_balance':
          count = waterGoalDays;
          break;
        case 'water_week':
          count = waterGoalDays;
          break;
        case 'water_two_weeks':
          count = waterGoalDays;
          break;
        case 'water_month':
          count = waterGoalDays;
          break;
        case 'morning_glass':
          count = hadMorningGlass ? 1 : 0;
          break;

        // Нутриенты и баланс
        case 'protein_hero':
          count = proteinTargetDays > 0 ? 1 : 0;
          break;
        case 'protein_streak':
          count = proteinTargetDays;
          break;
        case 'fiber_friend':
          count = fiberCount > 0 ? 1 : 0;
          break;
        case 'healthy_fats':
          count = healthyFatsCount > 0 ? 1 : 0;
          break;
        case 'veggie_lover':
          count = veggieCount > 0 ? 1 : 0;
          break;
        case 'veggie_streak':
          count = veggieCount;
          break;
        case 'fruit_mood':
          count = fruitCount > 0 ? 1 : 0;
          break;
        case 'fish_day':
          count = fishCount > 0 ? 1 : 0;
          break;
        case 'calorie_target_hit':
          count = calorieTargetDays > 0 ? 1 : 0;
          break;
        case 'three_days_balance':
          count = calorieTargetDays;
          break;
        case 'rainbow_plate':
          count = rainbowDays >= 1 ? 3 : 0;
          break;
        case 'mindful_treat':
          count = hadMindfulTreat ? 1 : 0;
          break;

        // Рецепты
        case 'recipe_first':
          count = recipeDiaryEntries > 0 ? 1 : 0;
          break;
        case 'recipe_three':
          count = recipeDiaryEntries;
          break;
        case 'recipe_seven':
          count = recipeDiaryEntries;
          break;
        case 'recipe_scale':
          count = 1; // Доступная функция
          break;
        case 'recipe_create':
          count = userCreatedRecipes;
          break;
        case 'recipe_fav':
          count = favRecipesCount > 0 ? 1 : 0;
          break;
        case 'recipe_fav_three':
          count = favRecipesCount;
          break;

        // Сканер и продукты
        case 'scanner_first':
          count = barcodeCount > 0 ? 1 : 0;
          break;
        case 'scanner_five':
          count = barcodeCount;
          break;
        case 'custom_food':
          count = userFoodCount;
          break;
        case 'custom_food_three':
          count = userFoodCount;
          break;
        case 'fav_foods':
          count = favFoodCount;
          break;

        // Вес и профиль
        case 'weight_first':
          count = weightCount > 0 ? 1 : 0;
          break;
        case 'weight_three':
          count = weightCount;
          break;
        case 'weight_seven':
          count = weightCount;
          break;
        case 'weight_progress':
          count = hadWeightProgress ? 1 : 0;
          break;
        case 'mindful_profile':
          count = profile != null ? 1 : 0;
          break;

        default:
          count = 0;
      }

      final isUnlocked = count >= ach.requiredCount;

      final existing = await (db.select(db.userAchievements)
            ..where((t) => t.achievementId.equals(ach.id)))
          .getSingleOrNull();

      if (existing == null) {
        await db.into(db.userAchievements).insert(
              UserAchievementsCompanion.insert(
                achievementId: ach.id,
                currentCount: Value(count),
                isUnlocked: Value(isUnlocked),
                unlockedAt: Value(isUnlocked ? now : null),
              ),
            );
      } else {
        final newlyUnlocked = isUnlocked && !existing.isUnlocked;
        await (db.update(db.userAchievements)..where((t) => t.id.equals(existing.id))).write(
          UserAchievementsCompanion(
            currentCount: Value(count),
            isUnlocked: Value(isUnlocked || existing.isUnlocked),
            unlockedAt: Value(
              existing.isUnlocked
                  ? existing.unlockedAt
                  : (newlyUnlocked ? now : null),
            ),
          ),
        );
      }
    }
  }

  /// Расчет мягкой серии (consecutive days) без чувства вины
  /// Если сегодня запись еще не внесена, но вчера была — серия НЕ сгорает!
  int _calculateConsciousStreak(List<DateTime> sortedUniqueDates) {
    if (sortedUniqueDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final yesterdayNormalized = todayNormalized.subtract(const Duration(days: 1));

    final dateSet = sortedUniqueDates.toSet();

    // Проверяем, активна ли серия (запись есть сегодня ИЛИ вчера)
    DateTime checkDate = todayNormalized;
    if (!dateSet.contains(todayNormalized)) {
      if (dateSet.contains(yesterdayNormalized)) {
        checkDate = yesterdayNormalized;
      } else {
        return 0; // Предыдущих записей нет в пределах 1 дня
      }
    }

    int streak = 0;
    while (dateSet.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Получить общую статистику привычек
  Future<HabitStats> getHabitStats() async {
    final diaryEntries = await db.select(db.diaryEntries).get();
    final uniqueDates = diaryEntries
        .map((e) => DateTime(e.entryDate.year, e.entryDate.month, e.entryDate.day))
        .toSet()
        .toList()
      ..sort();

    final streak = _calculateConsciousStreak(uniqueDates);
    final totalDays = uniqueDates.length;

    final allAch = await db.select(db.achievements).get();
    final unlocked = await (db.select(db.userAchievements)
          ..where((t) => t.isUnlocked.equals(true)))
        .get();

    return HabitStats(
      currentStreak: streak,
      totalActiveDays: totalDays,
      unlockedAchievementsCount: unlocked.length,
      totalAchievementsCount: allAch.length,
    );
  }
}
