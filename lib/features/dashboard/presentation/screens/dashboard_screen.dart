import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/nutri_card.dart';
import '../../../../core/widgets/calorie_ring.dart';
import '../../../../core/widgets/macro_bar.dart';
import '../../../water/presentation/widgets/add_water_dialog.dart';
import '../../../water/presentation/widgets/water_history_sheet.dart';
import '../../../weight/presentation/widgets/add_weight_dialog.dart';
import '../../../food_database/presentation/widgets/food_search_sheet.dart';
import '../../../gamification/presentation/widgets/habits_streak_card.dart';
import '../../../nutrition_suggestions/presentation/widgets/remaining_macros_card.dart';
import '../providers/dashboard_providers.dart';

/// Главный экран (Дашборд) с реактивным подключением к Drift SQLite и Riverpod
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final profileAsync = ref.watch(userProfileProvider);
    final totalsAsync = ref.watch(dateTotalsProvider(todayDate));
    final waterAsync = ref.watch(dateWaterProvider(todayDate));
    final entriesAsync = ref.watch(dateDiaryEntriesProvider(todayDate));
    final latestWeightAsync = ref.watch(latestWeightProvider);

    final profile = profileAsync.value;
    final totals = totalsAsync.value ?? DayTotals.zero;
    final waterMl = waterAsync.value ?? 0;
    final entries = entriesAsync.value ?? [];
    final latestWeight = latestWeightAsync.value;

    final targetCalories = profile?.targetCalories.toDouble() ?? 2000.0;
    final targetProtein = profile?.targetProteinG ?? 120.0;
    final targetFat = profile?.targetFatG ?? 65.0;
    final targetCarbs = profile?.targetCarbsG ?? 230.0;
    final targetWater = profile?.targetWaterMl ?? 2000;
    final currentWeight = latestWeight?.weightKg ?? profile?.currentWeightKg ?? 70.0;
    final targetWeight = profile?.targetWeightKg ?? 65.0;

    final userName = profile?.name.isNotEmpty == true ? profile!.name : 'Друг';
    final greeting = _getGreeting();
    final dateStr = DateFormat('EEEE, d MMMM', 'ru_RU').format(today);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── AppBar с приветствием ──────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: theme.colorScheme.surface,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, $userName! 👋',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Обновить',
                  onPressed: () {
                    ref.invalidate(dateTotalsProvider(todayDate));
                    ref.invalidate(dateWaterProvider(todayDate));
                    ref.invalidate(dateDiaryEntriesProvider(todayDate));
                  },
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Мотивирующий бережный совет дня ──────────────────
                  _SupportiveQuoteCard(),
                  const SizedBox(height: 14),

                  // ── Карточка привычек и серии без вины ───────────────
                  const HabitsStreakCard(),
                  const SizedBox(height: 14),

                  // ── Главная карточка калорий и БЖУ ───────────────────
                  NutriCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Center(
                          child: CalorieRing(
                            consumed: totals.calories,
                            target: targetCalories,
                            size: 190,
                          ),
                        ),
                        const SizedBox(height: 20),
                        MacroBar(
                          label: 'Белки',
                          current: totals.protein,
                          target: targetProtein,
                          color: AppColors.protein,
                        ),
                        const SizedBox(height: 10),
                        MacroBar(
                          label: 'Жиры',
                          current: totals.fat,
                          target: targetFat,
                          color: AppColors.fat,
                        ),
                        const SizedBox(height: 10),
                        MacroBar(
                          label: 'Углеводы',
                          current: totals.carbs,
                          target: targetCarbs,
                          color: AppColors.carbs,
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Карточка остатка БЖУ, коридора нормы и умных предложений ──
                  RemainingMacrosCard(date: todayDate),
                  const SizedBox(height: 14),

                  // ── Виджет трекинга воды ─────────────────────────────
                  _WaterDashboardCard(
                    consumedMl: waterMl,
                    targetMl: targetWater,
                    onAddWater: (amount) async {
                      final waterDao = ref.read(waterDaoProvider);
                      await waterDao.addWater(todayDate, amount);
                    },
                    onOpenDialog: () => AddWaterDialog.show(context, date: todayDate),
                    onOpenHistory: () => WaterHistorySheet.show(context, date: todayDate),
                  ),
                  const SizedBox(height: 14),

                  // ── Виджет веса ──────────────────────────────────────
                  _WeightDashboardCard(
                    currentWeight: currentWeight,
                    targetWeight: targetWeight,
                    onLogWeight: () => AddWeightDialog.show(context, initialWeight: currentWeight),
                  ),
                  const SizedBox(height: 20),

                  // ── Заголовок приемов пищи ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Приёмы пищи сегодня',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Всего: ${totals.calories.round()} ккал',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Карточки 4 приемов пищи
                  _MealSectionCard(
                    title: 'Завтрак',
                    icon: Icons.wb_sunny_rounded,
                    color: const Color(0xFFF59E0B),
                    entries: entries.where((e) => e.mealType == 'breakfast').toList(),
                    onAdd: () => FoodSearchSheet.show(
                      context,
                      mealType: 'breakfast',
                      date: todayDate,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MealSectionCard(
                    title: 'Обед',
                    icon: Icons.wb_cloudy_rounded,
                    color: const Color(0xFF0EA5E9),
                    entries: entries.where((e) => e.mealType == 'lunch').toList(),
                    onAdd: () => FoodSearchSheet.show(
                      context,
                      mealType: 'lunch',
                      date: todayDate,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MealSectionCard(
                    title: 'Ужин',
                    icon: Icons.nights_stay_rounded,
                    color: const Color(0xFF6366F1),
                    entries: entries.where((e) => e.mealType == 'dinner').toList(),
                    onAdd: () => FoodSearchSheet.show(
                      context,
                      mealType: 'dinner',
                      date: todayDate,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MealSectionCard(
                    title: 'Перекус',
                    icon: Icons.cookie_rounded,
                    color: const Color(0xFF10B981),
                    entries: entries.where((e) => e.mealType == 'snack').toList(),
                    onAdd: () => FoodSearchSheet.show(
                      context,
                      mealType: 'snack',
                      date: todayDate,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Доброй ночи';
    if (hour < 12) return 'Доброе утро';
    if (hour < 18) return 'Добрый день';
    return 'Добрый вечер';
  }
}

class _SupportiveQuoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.spa_rounded, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Фокусируйтесь на регулярности и самочувствии. Колебания веса изо дня в день — это естественный процесс.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterDashboardCard extends StatelessWidget {
  const _WaterDashboardCard({
    required this.consumedMl,
    required this.targetMl,
    required this.onAddWater,
    required this.onOpenDialog,
    required this.onOpenHistory,
  });

  final int consumedMl;
  final int targetMl;
  final ValueChanged<int> onAddWater;
  final VoidCallback onOpenDialog;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = targetMl > 0 ? (consumedMl / targetMl).clamp(0.0, 1.0) : 0.0;

    return NutriCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.waterLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.water_drop_rounded, color: AppColors.water, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: InkWell(
                  onTap: onOpenHistory,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Вода за сегодня', style: theme.textTheme.titleSmall),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$consumedMl из $targetMl мл (${(progress * 100).toInt()}%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history_rounded, color: AppColors.water),
                tooltip: 'История воды',
                onPressed: onOpenHistory,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.water),
                tooltip: 'Записать воду',
                onPressed: onOpenDialog,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.water),
            ),
          ),
          const SizedBox(height: 12),
          // Быстрые кнопки +250 и +500 мл
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onAddWater(250),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+250 мл'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onAddWater(500),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+500 мл'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeightDashboardCard extends StatelessWidget {
  const _WeightDashboardCard({
    required this.currentWeight,
    required this.targetWeight,
    required this.onLogWeight,
  });

  final double currentWeight;
  final double targetWeight;
  final VoidCallback onLogWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diff = currentWeight - targetWeight;

    return NutriCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.monitor_weight_rounded, color: Color(0xFF6366F1), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Текущий вес', style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    Text(
                      '${currentWeight.toStringAsFixed(1)} кг',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                    Text(
                      'Цель: ${targetWeight.toStringAsFixed(1)} кг (${diff > 0 ? "-${diff.toStringAsFixed(1)}" : "+${(-diff).toStringAsFixed(1)}"} кг)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onLogWeight,
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Внести'),
          ),
        ],
      ),
    );
  }
}

class _MealSectionCard extends StatelessWidget {
  const _MealSectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.entries,
    required this.onAdd,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<DiaryEntry> entries;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCalories = entries.fold<double>(0, (sum, e) => sum + e.calculatedCalories);

    return NutriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${totalCalories.round()} ккал',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: theme.colorScheme.primary,
                tooltip: 'Добавить в $title',
                onPressed: onAdd,
              ),
            ],
          ),
          if (entries.isNotEmpty) ...[
            const Divider(height: 16),
            ...entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.customName,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.grams.toInt()} г  ·  ${entry.calculatedCalories.round()} ккал',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
