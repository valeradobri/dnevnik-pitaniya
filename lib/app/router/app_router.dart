import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'route_names.dart';

// Экраны-заглушки (будут заменены в Фазе 2)
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/diary/presentation/screens/diary_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

// Полнофункциональные экраны Фазы 3
import '../../features/recipes/presentation/screens/nutrition_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';

// Диалоги быстрого добавления (FAB)
import '../../features/food_database/presentation/widgets/food_search_sheet.dart';
import '../../features/water/presentation/widgets/add_water_dialog.dart';
import '../../features/weight/presentation/widgets/add_weight_dialog.dart';

/// Главный навигационный маршрутизатор приложения.
///
/// Использует [StatefulShellRoute.indexedStack] для сохранения состояния
/// скролла и введённых данных при переключении между вкладками.
///
/// Логика навигации:
/// - Если онбординг не завершён → редирект на /onboarding
/// - Иначе → Shell с 5 вкладками, начиная с /home/dashboard
GoRouter createRouter(SharedPreferences prefs) {
  final bool onboardingDone = prefs.getBool('onboarding_complete') ?? false;

  return GoRouter(
    initialLocation: onboardingDone ? RouteNames.dashboard : RouteNames.onboarding,
    debugLogDiagnostics: false,
    routes: [
      // ── Онбординг ───────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Shell (нижняя навигация) ─────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          // Вкладка 1: Главная
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Вкладка 2: Дневник
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.diary,
                name: 'diary',
                builder: (context, state) => const DiaryScreen(),
              ),
            ],
          ),
          // Вкладка 3: Питание (Рецепты + Планировщик)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.nutrition,
                name: 'nutrition',
                builder: (context, state) => const NutritionScreen(),
              ),
            ],
          ),
          // Вкладка 4: Статистика
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.analytics,
                name: 'analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          // Вкладка 5: Профиль
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Scaffold с нижней навигационной панелью и центральным FAB
class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: 'main_fab',
        onPressed: () => _showQuickAddSheet(context),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            // При нажатии на уже активную вкладку — возвращаемся к корню
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Дневник',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Питание',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Статистика',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _QuickAddSheet(),
    );
  }
}

/// Нижний лист быстрого добавления (FAB)
class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Быстрое добавление',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _QuickAddItem(
            icon: Icons.add_circle_outline_rounded,
            color: const Color(0xFF059669),
            label: 'Добавить блюдо',
            subtitle: 'Найти продукт и указать граммовку',
            onTap: () {
              Navigator.pop(context);
              FoodSearchSheet.show(
                context,
                mealType: 'lunch',
                date: DateTime.now(),
              );
            },
          ),
          const SizedBox(height: 8),
          _QuickAddItem(
            icon: Icons.water_drop_outlined,
            color: const Color(0xFF0EA5E9),
            label: 'Записать воду',
            subtitle: 'Добавить +250 мл или другой объём',
            onTap: () {
              Navigator.pop(context);
              AddWaterDialog.show(context, date: DateTime.now());
            },
          ),
          const SizedBox(height: 8),
          _QuickAddItem(
            icon: Icons.monitor_weight_outlined,
            color: const Color(0xFF6366F1),
            label: 'Внести вес',
            subtitle: 'Записать утреннее взвешивание',
            onTap: () {
              Navigator.pop(context);
              AddWeightDialog.show(context);
            },
          ),
        ],
      ),
    );
  }
}

class _QuickAddItem extends StatelessWidget {
  const _QuickAddItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
