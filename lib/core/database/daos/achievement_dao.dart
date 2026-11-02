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
    final allAchievements = await db.select(db.achievements).get();
    if (allAchievements.isEmpty) return;

    // 1. Уникальные даты дневника питания
    final diaryEntries = await db.select(db.diaryEntries).get();
    final uniqueDiaryDates = diaryEntries
        .map((e) => DateTime(e.entryDate.year, e.entryDate.month, e.entryDate.day))
        .toSet()
        .toList()
      ..sort();

    // 2. Расчет мягкой серии (consecutive days)
    final streak = _calculateConsciousStreak(uniqueDiaryDates);
    final totalDiaryDays = uniqueDiaryDates.length;

    // 3. Водный баланс: дни с достижением нормы (дефолт 2000 мл или из профиля)
    final profile = await db.select(db.userProfiles).getSingleOrNull();
    final targetWater = profile?.targetWaterMl ?? 2000;

    final waterEntries = await db.select(db.waterEntries).get();
    final waterByDate = <DateTime, int>{};
    for (final w in waterEntries) {
      final d = DateTime(w.entryDate.year, w.entryDate.month, w.entryDate.day);
      waterByDate[d] = (waterByDate[d] ?? 0) + w.amountMl;
    }
    final waterGoalDays = waterByDate.values.where((ml) => ml >= targetWater).length;

    // 4. Количество записей веса
    final weightEntries = await db.select(db.weightEntries).get();
    final weightCount = weightEntries.length;

    // 5. Пользовательские продукты
    final userFoods = await (db.select(db.foodProducts)
          ..where((t) => t.sourceType.equals('user')))
        .get();
    final userFoodCount = userFoods.length;

    // 6. Обновление статуса для каждого достижения
    final now = DateTime.now();
    for (final ach in allAchievements) {
      int count = 0;
      switch (ach.key) {
        case 'first_entry':
          count = diaryEntries.isNotEmpty ? 1 : 0;
          break;
        case 'three_days_streak':
          count = streak;
          break;
        case 'week_streak':
          count = streak;
          break;
        case 'month_streak':
          count = totalDiaryDays; // Учитывает общее число осознанных дней без вины
          break;
        case 'water_balance':
          count = waterGoalDays;
          break;
        case 'weight_first':
          count = weightCount > 0 ? 1 : 0;
          break;
        case 'custom_food':
          count = userFoodCount;
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
