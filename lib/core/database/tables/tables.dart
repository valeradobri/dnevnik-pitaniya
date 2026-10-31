import 'package:drift/drift.dart';

/// Таблица профиля пользователя
///
/// Хранит персональные данные и персональные нормы КБЖУ.
/// Рассчитана на одну строку (единственный профиль).
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get gender => text()(); // 'male' | 'female'
  RealColumn get heightCm => real()();
  RealColumn get currentWeightKg => real()();
  RealColumn get targetWeightKg => real()();
  TextColumn get activityLevel => text()(); // sedentary|light|moderate|active|very_active
  TextColumn get goalType => text()();      // lose_weight|maintain|gain_weight
  RealColumn get weeklyRateKg => real().withDefault(const Constant(0.5))();
  IntColumn get targetCalories => integer()();
  RealColumn get targetProteinG => real()();
  RealColumn get targetFatG => real()();
  RealColumn get targetCarbsG => real()();
  IntColumn get targetWaterMl => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Каталог продуктов питания
///
/// Хранит нутриционные данные на 100 г.
/// [sourceType]: 'verified' | 'user' | 'ai' | 'open_food_facts'
class FoodProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get brand => text().nullable()();
  RealColumn get caloriesPer100g => real()();
  RealColumn get proteinPer100g => real()();
  RealColumn get fatPer100g => real()();
  RealColumn get carbsPer100g => real()();
  RealColumn get fiberPer100g => real().nullable()();
  TextColumn get category => text().withDefault(const Constant('other'))();
  TextColumn get sourceType => text().withDefault(const Constant('verified'))();
  TextColumn get barcode => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  RealColumn get servingSizeG => real().withDefault(const Constant(100.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {barcode},
      ];
}

/// Записи дневника питания
///
/// Каждая запись — одна порция продукта в конкретный приём пищи.
/// [mealType]: 'breakfast' | 'lunch' | 'dinner' | 'snack'
/// [entryDate]: хранится как дата без времени (YYYY-MM-DD) для правильного
///              выбора записей за день без зависимости от часового пояса.
class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get mealType => text()();
  IntColumn get foodProductId =>
      integer().references(FoodProducts, #id, onDelete: KeyAction.cascade)();
  TextColumn get customName => text().withLength(min: 1, max: 200)();
  RealColumn get grams => real()();
  RealColumn get calculatedCalories => real()();
  RealColumn get calculatedProtein => real()();
  RealColumn get calculatedFat => real()();
  RealColumn get calculatedCarbs => real()();
  DateTimeColumn get entryDate => dateTime()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
}

/// Записи учёта воды
class WaterEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountMl => integer()();
  DateTimeColumn get entryDate => dateTime()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

/// История взвешиваний
class WeightEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get weightKg => real()();
  DateTimeColumn get entryDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

/// Рецепты
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  IntColumn get prepTimeMinutes => integer().withDefault(const Constant(30))();
  IntColumn get servings => integer().withDefault(const Constant(1))();
  TextColumn get category => text().withDefault(const Constant('other'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Ингредиенты рецептов
class RecipeIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  IntColumn get foodProductId =>
      integer().references(FoodProducts, #id, onDelete: KeyAction.restrict)();
  RealColumn get grams => real()();
  TextColumn get notes => text().nullable()();
}

/// Планы питания (недельный планировщик)
class MealPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get weekStartDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Позиции плана питания
class MealPlanItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mealPlanId =>
      integer().references(MealPlans, #id, onDelete: KeyAction.cascade)();
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade).nullable()();
  DateTimeColumn get plannedDate => dateTime()();
  TextColumn get mealType => text()();
  TextColumn get customNote => text().nullable()();
  RealColumn get servings => real().withDefault(const Constant(1.0))();
}

/// Система достижений (шаблоны)
class Achievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();    // Уникальный ключ достижения
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get iconName => text()();
  IntColumn get requiredCount => integer().withDefault(const Constant(1))();
}

/// Разблокированные достижения пользователя
class UserAchievements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get achievementId =>
      integer().references(Achievements, #id, onDelete: KeyAction.cascade)();
  IntColumn get currentCount => integer().withDefault(const Constant(0))();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();
}
