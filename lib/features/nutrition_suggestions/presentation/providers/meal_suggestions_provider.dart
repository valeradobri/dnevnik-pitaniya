import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../recipes/domain/models/recipe_model.dart';
import '../../data/meal_suggestions_service.dart';
import '../../domain/models/meal_suggestion.dart';

export '../../domain/models/meal_suggestion.dart';
export '../../data/meal_suggestions_service.dart';

final mealSuggestionsServiceProvider = Provider<MealSuggestionsService>((ref) {
  return const MealSuggestionsService();
});

/// Провайдер расчета оставшегося бюджета КБЖУ на выбранную дату
final remainingBudgetProvider = Provider.family<RemainingBudget, DateTime>((ref, date) {
  final totalsAsync = ref.watch(dateTotalsProvider(date));
  final profileAsync = ref.watch(userProfileProvider);

  final totals = totalsAsync.value ?? DayTotals.zero;
  final profile = profileAsync.value;

  final targetCals = profile?.targetCalories.toDouble() ?? 2000.0;
  final targetProt = profile?.targetProteinG ?? 120.0;
  final targetFat = profile?.targetFatG ?? 65.0;
  final targetCarbs = profile?.targetCarbsG ?? 220.0;

  return RemainingBudget(
    targetCalories: targetCals,
    targetProtein: targetProt,
    targetFat: targetFat,
    targetCarbs: targetCarbs,
    consumedCalories: totals.calories,
    consumedProtein: totals.protein,
    consumedFat: totals.fat,
    consumedCarbs: totals.carbs,
  );
});

/// Провайдер умных предложений блюд под выбранную дату и приём пищи
final smartMealSuggestionsProvider =
    FutureProvider.family<List<MealSuggestion>, (DateTime, String)>((ref, args) async {
  final (date, mealType) = args;
  final budget = ref.watch(remainingBudgetProvider(date));
  final service = ref.watch(mealSuggestionsServiceProvider);
  final foodDao = ref.watch(foodDaoProvider);
  final recipeDao = ref.watch(recipeDaoProvider);

  // Получаем продукты и детальные рецепты
  final allFoods = await foodDao.getAllFoods();
  final allRecipes = await recipeDao.watchAllRecipes().first;

  final detailedRecipes = <RecipeWithDetails>[];
  for (final r in allRecipes) {
    final details = await recipeDao.getRecipeWithDetails(r.id);
    if (details != null) {
      detailedRecipes.add(details);
    }
  }

  return service.generateSuggestions(
    budget: budget,
    foods: allFoods,
    recipes: detailedRecipes,
    preferredMealType: mealType,
  );
});
