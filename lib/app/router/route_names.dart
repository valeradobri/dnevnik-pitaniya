/// Именованные маршруты приложения «Дневник»
///
/// Используем строковые константы для безопасного type-safe именования
/// и единого реестра всех маршрутов приложения.
abstract final class RouteNames {
  // ── Онбординг ──────────────────────────────────────────────────────
  static const String onboarding = '/onboarding';
  static const String onboardingBasic = '/onboarding/basic';
  static const String onboardingGoal = '/onboarding/goal';
  static const String onboardingActivity = '/onboarding/activity';
  static const String onboardingResult = '/onboarding/result';

  // ── Shell (нижняя навигация) ────────────────────────────────────────
  static const String home = '/home';
  static const String dashboard = '/home/dashboard';
  static const String diary = '/home/diary';
  static const String nutrition = '/home/nutrition';
  static const String analytics = '/home/analytics';
  static const String profile = '/home/profile';

  // ── Дневник ─────────────────────────────────────────────────────────
  static const String addFood = '/home/diary/add-food';
  static const String portionEditor = '/home/diary/portion-editor';
  static const String customFood = '/home/diary/custom-food';

  // ── Рецепты ─────────────────────────────────────────────────────────
  static const String recipe = '/home/nutrition/recipe';
  static const String recipeDetail = '/home/nutrition/recipe/:id';
  static const String shoppingList = '/home/nutrition/shopping-list';

  // ── Вес ─────────────────────────────────────────────────────────────
  static const String weightHistory = '/home/analytics/weight';

  // ── Геймификация и привычки ─────────────────────────────────────────
  static const String achievements = '/achievements';

  // ── Модальные экраны ────────────────────────────────────────────────
  static const String quickAddModal = '/quick-add';
}
