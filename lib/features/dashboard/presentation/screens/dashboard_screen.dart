import 'package:flutter/material.dart';
import '../../../../core/widgets/nutri_card.dart';
import '../../../../core/widgets/calorie_ring.dart';
import '../../../../core/widgets/macro_bar.dart';
import '../../../../app/theme/app_colors.dart';

/// Главный экран (Дашборд)
/// Отображает суточный прогресс калорий, макронутриентов, воды.
/// Реализация с данными из Riverpod/Drift — в Фазе 2.
/// Текущая версия: статичная демонстрация дизайн-системы.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    'Доброе утро! 👋',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text('Дневник', style: theme.textTheme.titleLarge),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                  tooltip: 'Уведомления',
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Кольцо калорий ─────────────────────────────────
                  NutriCard(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Center(
                          child: CalorieRing(
                            consumed: 1240,
                            target: 2000,
                            size: 200,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // БЖУ строки
                        MacroBar(
                          label: 'Белки',
                          current: 68,
                          target: 120,
                          color: AppColors.protein,
                        ),
                        const SizedBox(height: 10),
                        MacroBar(
                          label: 'Жиры',
                          current: 42,
                          target: 65,
                          color: AppColors.fat,
                        ),
                        const SizedBox(height: 10),
                        MacroBar(
                          label: 'Углеводы',
                          current: 155,
                          target: 230,
                          color: AppColors.carbs,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Вода ───────────────────────────────────────────
                  NutriCard(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.waterLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.water_drop_rounded,
                            color: AppColors.water,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Вода', style: theme.textTheme.titleSmall),
                              const SizedBox(height: 4),
                              MacroBar(
                                label: '',
                                current: 1200,
                                target: 2400,
                                color: AppColors.water,
                                unit: 'мл',
                                showValues: false,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '1.2 / 2.4 л',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.water,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Мотивирующее сообщение ─────────────────────────
                  NutriCard(
                    color: AppColors.primaryContainer,
                    child: Row(
                      children: [
                        const Text('🌱', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Отличный прогресс!',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Вы на правильном пути. Последовательность — ключ к долгосрочным результатам.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onPrimaryContainer
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Приёмы пищи сегодня ────────────────────────────
                  Text(
                    'Сегодня',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  _MealSection(
                    title: 'Завтрак',
                    icon: Icons.wb_sunny_outlined,
                    calories: 420,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _MealSection(
                    title: 'Обед',
                    icon: Icons.restaurant_outlined,
                    calories: 580,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _MealSection(
                    title: 'Ужин',
                    icon: Icons.nights_stay_outlined,
                    calories: 240,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _MealSection(
                    title: 'Перекус',
                    icon: Icons.apple_outlined,
                    calories: 0,
                    isEmpty: true,
                    onTap: () {},
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.title,
    required this.icon,
    required this.calories,
    required this.onTap,
    this.isEmpty = false,
  });

  final String title;
  final IconData icon;
  final double calories;
  final VoidCallback onTap;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NutriCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isEmpty
                ? theme.colorScheme.onSurfaceVariant
                : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isEmpty
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (!isEmpty)
            Text(
              '${calories.round()} ккал',
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              'Добавить',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
