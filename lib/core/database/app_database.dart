import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tables/tables.dart';
import 'seed/food_seed.dart';
import 'seed/achievements_seed.dart';
import 'daos/food_dao.dart';
import 'daos/diary_dao.dart';
import 'daos/user_dao.dart';
import 'daos/water_dao.dart';
import 'daos/weight_dao.dart';
import 'daos/recipe_dao.dart';
import 'daos/meal_plan_dao.dart';
import 'daos/achievement_dao.dart';

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
        beforeOpen: (details) async {
          if (!details.wasCreated) {
            await _seedFoodProducts();
            await recipeDao.seedInitialRecipes();
          }
        },
      );

  // ─── Seed начальных данных ────────────────────────────────────────────
  Future<void> _seedInitialData() async {
    await _seedAchievements();
    await _seedFoodProducts();
    await recipeDao.seedInitialRecipes();
  }

  Future<void> seedFoodProducts() async {
    final existing = await select(foodProducts).get();
    final existingNames = existing.map((f) => f.name.toLowerCase()).toSet();
    final toInsert = initialFoodProducts
        .where((f) => !existingNames.contains(f.name.value.toLowerCase()))
        .toList();
    if (toInsert.isNotEmpty) {
      await batch((b) {
        b.insertAll(foodProducts, toInsert);
      });
    }
  }

  Future<void> _seedFoodProducts() => seedFoodProducts();

  Future<void> seedAchievements() async {
    final existing = await select(achievements).get();
    final existingKeys = existing.map((a) => a.key).toSet();
    final toInsert = initialAchievements
        .where((a) => !existingKeys.contains(a.key.value))
        .toList();
    if (toInsert.isNotEmpty) {
      await batch((b) {
        b.insertAll(achievements, toInsert);
      });
    }
  }

  Future<void> _seedAchievements() => seedAchievements();

  // ─── Доступ к DAOs ───────────────────────────────────────────────────
  late final foodDao = FoodDao(this);
  late final diaryDao = DiaryDao(this);
  late final userDao = UserDao(this);
  late final waterDao = WaterDao(this);
  late final weightDao = WeightDao(this);
  late final recipeDao = RecipeDao(this);
  late final mealPlanDao = MealPlanDao(this);
  late final achievementDao = AchievementDao(this);
}

/// Инициализация подключения к SQLite-файлу на устройстве (поддержка Android, iOS, Windows, Web)
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'dnevnik_db',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
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

final recipeDaoProvider = Provider<RecipeDao>((ref) {
  return ref.watch(databaseProvider).recipeDao;
});

final mealPlanDaoProvider = Provider<MealPlanDao>((ref) {
  return ref.watch(databaseProvider).mealPlanDao;
});

final achievementDaoProvider = Provider<AchievementDao>((ref) {
  return ref.watch(databaseProvider).achievementDao;
});

