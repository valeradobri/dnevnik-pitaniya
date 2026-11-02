import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../../recipes/domain/models/recipe_model.dart';

/// Расчет оставшегося бюджета КБЖУ с учетом коридора нормы (±10 г)
class RemainingBudget {
  const RemainingBudget({
    required this.targetCalories,
    required this.targetProtein,
    required this.targetFat,
    required this.targetCarbs,
    required this.consumedCalories,
    required this.consumedProtein,
    required this.consumedFat,
    required this.consumedCarbs,
  });

  final double targetCalories;
  final double targetProtein;
  final double targetFat;
  final double targetCarbs;

  final double consumedCalories;
  final double consumedProtein;
  final double consumedFat;
  final double consumedCarbs;

  double get remainingCalories => (targetCalories - consumedCalories).clamp(0.0, 9999.0);
  double get remainingProtein => (targetProtein - consumedProtein).clamp(0.0, 999.0);
  double get remainingFat => (targetFat - consumedFat).clamp(0.0, 999.0);
  double get remainingCarbs => (targetCarbs - consumedCarbs).clamp(0.0, 999.0);

  bool get hasRemainingCalories => remainingCalories > 50;

  /// Определяет, какого макронутриента пропорционально не хватает больше всего
  String get dominantNeed {
    if (remainingCalories <= 80) return 'low_cal';

    final protRatio = targetProtein > 0 ? (remainingProtein / targetProtein) : 0.0;
    final fatRatio = targetFat > 0 ? (remainingFat / targetFat) : 0.0;
    final carbsRatio = targetCarbs > 0 ? (remainingCarbs / targetCarbs) : 0.0;

    if (protRatio >= 0.35 && protRatio >= fatRatio && protRatio >= carbsRatio) {
      return 'protein';
    } else if (carbsRatio >= 0.4 && carbsRatio >= fatRatio) {
      return 'carbs';
    } else if (fatRatio >= 0.4 && fatRatio >= protRatio) {
      return 'fat';
    }
    return 'balanced';
  }

  /// Проверка, попадает ли предложение в коридор допуска (±10 единиц по БЖУ, ±150 ккал)
  bool fitsWithinCorridor({
    required double itemCalories,
    required double itemProtein,
    required double itemFat,
    required double itemCarbs,
    double toleranceGrams = 10.0,
    double toleranceCals = 150.0,
  }) {
    final calsFit = itemCalories <= (remainingCalories + toleranceCals);
    final protFit = itemProtein <= (remainingProtein + toleranceGrams);
    final fatFit = itemFat <= (remainingFat + toleranceGrams);
    final carbsFit = itemCarbs <= (remainingCarbs + toleranceGrams);
    return calsFit && protFit && fatFit && carbsFit;
  }
}

/// Интерактивное предложение блюда или продукта под остаток БЖУ
class MealSuggestion {
  const MealSuggestion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.categoryTag,
    required this.categoryLabel,
    required this.icon,
    required this.suggestedGrams,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.reason,
    required this.defaultMealType,
    this.product,
    this.recipe,
  });

  final String id;
  final String title;
  final String subtitle;
  final String categoryTag; // 'all', 'recipe', 'protein', 'balanced', 'light'
  final String categoryLabel;
  final IconData icon;
  final double suggestedGrams;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final String reason;
  final String defaultMealType; // 'dinner', 'snack', 'lunch'
  final FoodProduct? product;
  final RecipeWithDetails? recipe;

  bool get isRecipe => recipe != null;
}
