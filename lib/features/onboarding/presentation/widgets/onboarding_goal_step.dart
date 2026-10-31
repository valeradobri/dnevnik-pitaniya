import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';

class OnboardingGoalStep extends ConsumerWidget {
  const OnboardingGoalStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    final goals = [
      _GoalOption(
        key: 'lose_weight',
        title: 'Снижение веса',
        description: 'Комфортный дефицит калорий без голодания и жестких ограничений',
        icon: Icons.trending_down_rounded,
        color: const Color(0xFF10B981),
      ),
      _GoalOption(
        key: 'maintain',
        title: 'Поддержание формы',
        description: 'Энергетический баланс для сохранения текущего веса и самочувствия',
        icon: Icons.balance_rounded,
        color: const Color(0xFF6366F1),
      ),
      _GoalOption(
        key: 'gain_weight',
        title: 'Набор массы',
        description: 'Умеренный профицит калорий для роста мышц и набора здоровой массы',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFFF97316),
      ),
    ];

    final isChangeGoal = data.goalType != 'maintain';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Ваша цель',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Исходя из цели мы рассчитаем суточный дефицит или профицит',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Выбор цели
          ...goals.map((g) {
            final isSelected = data.goalType == g.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GoalCard(
                option: g,
                isSelected: isSelected,
                onTap: () => notifier.updateGoal(
                  goalType: g.key,
                  weeklyRateKg: data.weeklyRateKg,
                ),
              ),
            );
          }),

          // Темп изменения веса в неделю
          if (isChangeGoal) ...[
            const SizedBox(height: 16),
            Text(
              'Желаемый темп изменения веса',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Рекомендуемый безопасный темп — 0.5 кг в неделю',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _RateChip(
                  label: '0.25 кг/нед',
                  subtitle: 'Мягкий',
                  isSelected: data.weeklyRateKg == 0.25,
                  onTap: () => notifier.updateGoal(
                    goalType: data.goalType,
                    weeklyRateKg: 0.25,
                  ),
                ),
                const SizedBox(width: 8),
                _RateChip(
                  label: '0.5 кг/нед',
                  subtitle: 'Оптимальный',
                  isSelected: data.weeklyRateKg == 0.5,
                  isRecommended: true,
                  onTap: () => notifier.updateGoal(
                    goalType: data.goalType,
                    weeklyRateKg: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                _RateChip(
                  label: '0.75 кг/нед',
                  subtitle: 'Быстрый',
                  isSelected: data.weeklyRateKg == 0.75,
                  onTap: () => notifier.updateGoal(
                    goalType: data.goalType,
                    weeklyRateKg: 0.75,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _GoalOption {
  const _GoalOption({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String key;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _GoalOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? option.color.withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? option.color
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? option.color.withValues(alpha: 0.16)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  option.icon,
                  color: isSelected ? option.color : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? option.color : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateChip extends StatelessWidget {
  const _RateChip({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isRecommended = false,
  });

  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? primary.withValues(alpha: 0.12)
                : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? primary
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? primary : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: isRecommended ? const Color(0xFF10B981) : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isRecommended ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
