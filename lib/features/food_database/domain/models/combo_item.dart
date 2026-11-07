import '../../../../core/database/app_database.dart';
import '../../../../core/utils/nutrition_calculator.dart';

/// Элемент ингредиента внутри собираемого комбо/блюда
class ComboIngredientItem {
  final FoodProduct product;
  double grams;
  final bool isCooked;
  final double coefficient;

  ComboIngredientItem({
    required this.product,
    required this.grams,
    this.isCooked = false,
    this.coefficient = 1.0,
  });

  /// Вес сухого/сырого эквивалента для подсчета КБЖУ
  double get effectiveGrams {
    if (isCooked && coefficient > 0) {
      return NutritionCalculator.calculateDryEquivalent(
        cookedGrams: grams,
        coefficient: coefficient,
      );
    }
    return grams;
  }

  /// Рассчитанные нутриенты для данного веса
  NutrientAmount get nutrients => NutritionCalculator.calculateForGrams(
        grams: effectiveGrams,
        caloriesPer100g: product.caloriesPer100g,
        proteinPer100g: product.proteinPer100g,
        fatPer100g: product.fatPer100g,
        carbsPer100g: product.carbsPer100g,
      );

  double get calories => nutrients.calories;
  double get protein => nutrients.protein;
  double get fat => nutrients.fat;
  double get carbs => nutrients.carbs;

  ComboIngredientItem copyWith({
    FoodProduct? product,
    double? grams,
    bool? isCooked,
    double? coefficient,
  }) {
    return ComboIngredientItem(
      product: product ?? this.product,
      grams: grams ?? this.grams,
      isCooked: isCooked ?? this.isCooked,
      coefficient: coefficient ?? this.coefficient,
    );
  }
}

/// Совокупные метрики собираемого комбо
class ComboSummary {
  final List<ComboIngredientItem> items;

  const ComboSummary(this.items);

  double get totalGrams => items.fold(0.0, (sum, i) => sum + i.grams);

  double get totalCalories =>
      items.fold(0.0, (sum, i) => sum + i.nutrients.calories);

  double get totalProtein =>
      items.fold(0.0, (sum, i) => sum + i.nutrients.protein);

  double get totalFat =>
      items.fold(0.0, (sum, i) => sum + i.nutrients.fat);

  double get totalCarbs =>
      items.fold(0.0, (sum, i) => sum + i.nutrients.carbs);

  /// Генерация автоназвания, если пользователь не указал свое
  String get defaultTitle {
    if (items.isEmpty) return 'Составное блюдо';
    if (items.length <= 3) {
      return items.map((i) => i.product.name).join(' + ');
    }
    return '${items.take(2).map((i) => i.product.name).join(' + ')} + ещё ${items.length - 2}';
  }

  /// Текстовый состав ингредиентов для поля notes в дневнике питания
  String get ingredientsNotes {
    return items
        .map((i) => '${i.product.name} ${i.grams.toInt()}г')
        .join(', ');
  }
}
