import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

class OnboardingSummaryStep extends ConsumerWidget {
  const OnboardingSummaryStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(onboardingProvider);

    final bmr = data.bmr.round();
    final tdee = data.tdee.round();
    final target = data.calorieTarget;
    final finalCals = data.finalCalories;
    final macros = data.macros;
    final water = data.targetWaterMl;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Ваш персональный план готов!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Расчет выполнен по стандарту клинической диетологии (Миффлин-Сан Жеор)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Главная карточка калорий
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Целевая суточная норма',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      finalCals.toString(),
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ккал / день',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // BMR и TDEE бейджи
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MiniStatBadge(
                      label: 'Базовый метаболизм (BMR)',
                      value: '$bmr ккал',
                      tooltip: 'Энергия на дыхание и работу органов в покое',
                    ),
                    Container(width: 1, height: 28, color: theme.colorScheme.outlineVariant),
                    _MiniStatBadge(
                      label: 'Расход с активностью (TDEE)',
                      value: '$tdee ккал',
                      tooltip: 'Полный расход энергии за сутки',
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (target.wasClamped) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: Color(0xFFD97706), size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Мы защитили вас от чрезмерного дефицита: норма зафиксирована на безопасном минимуме (${target.minSafe} ккал).',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFB45309),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          Text(
            'Баланс макронутриентов (БЖУ)',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          // Сетка макросов
          Row(
            children: [
              Expanded(
                child: _MacroCard(
                  name: 'Белки',
                  grams: macros.proteinG.toInt(),
                  color: AppColors.protein,
                  percent: '${((macros.proteinG * 4 / finalCals) * 100).round()}%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroCard(
                  name: 'Жиры',
                  grams: macros.fatG.toInt(),
                  color: AppColors.fat,
                  percent: '${((macros.fatG * 9 / finalCals) * 100).round()}%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroCard(
                  name: 'Углеводы',
                  grams: macros.carbsG.toInt(),
                  color: AppColors.carbs,
                  percent: '${((macros.carbsG * 4 / finalCals) * 100).round()}%',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Норма воды
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.waterLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.water_drop_rounded, color: AppColors.water, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Норма чистой воды',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$water мл в день (~${(water / 250).ceil()} стаканов)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.water,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MiniStatBadge extends StatelessWidget {
  const _MiniStatBadge({
    required this.label,
    required this.value,
    required this.tooltip,
  });

  final String label;
  final String value;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.name,
    required this.grams,
    required this.color,
    required this.percent,
  });

  final String name;
  final int grams;
  final Color color;
  final String percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$grams г',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            percent,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
