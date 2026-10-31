import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';

class OnboardingActivityStep extends ConsumerWidget {
  const OnboardingActivityStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    final activities = [
      _ActivityOption(
        key: 'sedentary',
        title: 'Сидячий образ жизни',
        description: 'Офисная работа или учеба, минимум прогулок и физической активности',
        multiplier: 'x1.2',
        icon: Icons.chair_alt_rounded,
      ),
      _ActivityOption(
        key: 'light',
        title: 'Легкая активность',
        description: 'Пешие прогулки каждый день, легкие тренировки или йога 1-3 раза в неделю',
        multiplier: 'x1.375',
        icon: Icons.directions_walk_rounded,
      ),
      _ActivityOption(
        key: 'moderate',
        title: 'Умеренная активность',
        description: 'Фитнес, бег, плавание или силовые тренировки 3-5 раз в неделю',
        multiplier: 'x1.55',
        icon: Icons.fitness_center_rounded,
      ),
      _ActivityOption(
        key: 'active',
        title: 'Высокая активность',
        description: 'Интенсивные регулярные тренировки 6-7 дней в неделю или физическая работа',
        multiplier: 'x1.725',
        icon: Icons.directions_run_rounded,
      ),
      _ActivityOption(
        key: 'very_active',
        title: 'Очень высокая активность',
        description: 'Тяжелый физический труд или ежедневные двойные спортивные тренировки',
        multiplier: 'x1.9',
        icon: Icons.bolt_rounded,
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Уровень активности',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Показывает, сколько энергии расходует организм в обычный день (TDEE)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ...activities.map((activity) {
            final isSelected = data.activityLevel == activity.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ActivityCard(
                option: activity,
                isSelected: isSelected,
                onTap: () => notifier.updateActivityLevel(activity.key),
              ),
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ActivityOption {
  const _ActivityOption({
    required this.key,
    required this.title,
    required this.description,
    required this.multiplier,
    required this.icon,
  });

  final String key;
  final String title;
  final String description;
  final String multiplier;
  final IconData icon;
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _ActivityOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

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
                ? primary.withValues(alpha: 0.08)
                : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? primary
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.16)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  option.icon,
                  color: isSelected ? primary : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? primary : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withValues(alpha: 0.15)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            option.multiplier,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? primary : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
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
