import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tables/tables.dart';
import 'seed/food_seed.dart';
import 'daos/food_dao.dart';
import 'daos/diary_dao.dart';
import 'daos/user_dao.dart';
import 'daos/water_dao.dart';
import 'daos/weight_dao.dart';

part 'app_database.g.dart';

/// Главная база данных приложения «Дневник» на Drift / SQLite
///
/// Все таблицы объявлены в [tables.dart]. Миграции управляются через [MigrationStrategy].
/// Реактивные стримы ([watchX]) автоматически обновляют UI при любом изменении данных.
@DriftDatabase(
  tables: [
    UserProfiles,
    FoodProducts,
    DiaryEntries,
    WaterEntries,
    WeightEntries,
    Recipes,
    RecipeIngredients,
    MealPlans,
    MealPlanItems,
    Achievements,
    UserAchievements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.e);

  // Версия схемы — увеличивать при каждой структурной миграции
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedInitialData();
        },
        onUpgrade: (m, from, to) async {
          // Место для будущих миграций
        },
      );

  // ─── Seed начальных данных ────────────────────────────────────────────
  Future<void> _seedInitialData() async {
    await _seedAchievements();
    await _seedFoodProducts();
  }

  Future<void> _seedFoodProducts() async {
    await batch((b) {
      b.insertAll(foodProducts, initialFoodProducts);
    });
  }

  Future<void> _seedAchievements() async {
    final achievementsList = [
      AchievementsCompanion.insert(
        key: 'first_entry',
        title: 'Первый шаг',
        description: 'Добавьте первую запись в дневник питания',
        iconName: 'star_outline',
        requiredCount: const Value(1),
      ),
      AchievementsCompanion.insert(
        key: 'three_days_streak',
        title: '3 дня подряд',
        description: 'Ведите дневник 3 дня подряд',
        iconName: 'local_fire_department',
        requiredCount: const Value(3),
      ),
      AchievementsCompanion.insert(
        key: 'week_streak',
        title: 'Неделя осознанности',
        description: 'Ведите дневник 7 дней подряд',
        iconName: 'emoji_events',
        requiredCount: const Value(7),
      ),
      AchievementsCompanion.insert(
        key: 'water_balance',
        title: 'Водный баланс',
        description: 'Выполните норму воды 5 дней',
        iconName: 'water_drop',
        requiredCount: const Value(5),
      ),
      AchievementsCompanion.insert(
        key: 'weight_first',
        title: 'На весах',
        description: 'Добавьте первое взвешивание',
        iconName: 'monitor_weight',
        requiredCount: const Value(1),
      ),
      AchievementsCompanion.insert(
        key: 'month_streak',
        title: 'Месяц привычки',
        description: 'Ведите дневник 30 дней подряд',
        iconName: 'workspace_premium',
        requiredCount: const Value(30),
      ),
    ];

    await batch((b) {
      b.insertAllOnConflictUpdate(achievements, achievementsList);
    });
  }

  // ─── Доступ к DAOs ───────────────────────────────────────────────────
  late final foodDao = FoodDao(this);
  late final diaryDao = DiaryDao(this);
  late final userDao = UserDao(this);
  late final waterDao = WaterDao(this);
  late final weightDao = WeightDao(this);
}

/// Инициализация подключения к SQLite-файлу на устройстве
QueryExecutor _openConnection() {
  return driftDatabase(name: 'dnevnik_db');
}

// ─── Riverpod Провайдеры ───────────────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final foodDaoProvider = Provider<FoodDao>((ref) {
  return ref.watch(databaseProvider).foodDao;
});

final diaryDaoProvider = Provider<DiaryDao>((ref) {
  return ref.watch(databaseProvider).diaryDao;
});

final userDaoProvider = Provider<UserDao>((ref) {
  return ref.watch(databaseProvider).userDao;
});

final waterDaoProvider = Provider<WaterDao>((ref) {
  return ref.watch(databaseProvider).waterDao;
});

final weightDaoProvider = Provider<WeightDao>((ref) {
  return ref.watch(databaseProvider).weightDao;
});

