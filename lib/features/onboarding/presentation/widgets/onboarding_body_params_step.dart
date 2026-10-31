import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';

class OnboardingBodyParamsStep extends ConsumerWidget {
  const OnboardingBodyParamsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final data = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    // Расчет категории ИМТ
    final bmi = data.bmi;
    final (bmiCategory, bmiColor) = _getBmiStatus(bmi);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Параметры тела',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Рост и вес определяют ваш объем метаболизма и норму гидратации',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Рост
          _ParameterSliderCard(
            title: 'Рост',
            value: data.heightCm,
            unit: 'см',
            min: 120,
            max: 220,
            divisions: 100,
            onChanged: (val) => notifier.updateHeight(val),
          ),
          const SizedBox(height: 16),

          // Текущий вес
          _ParameterSliderCard(
            title: 'Текущий вес',
            value: data.currentWeightKg,
            unit: 'кг',
            min: 35,
            max: 180,
            divisions: 290,
            onChanged: (val) => notifier.updateCurrentWeight(double.parse(val.toStringAsFixed(1))),
          ),
          const SizedBox(height: 16),

          // Желаемый целевой вес
          _ParameterSliderCard(
            title: 'Желаемый вес',
            value: data.targetWeightKg,
            unit: 'кг',
            min: 35,
            max: 180,
            divisions: 290,
            accentColor: theme.colorScheme.secondary,
            onChanged: (val) => notifier.updateTargetWeight(double.parse(val.toStringAsFixed(1))),
          ),
          const SizedBox(height: 20),

          // ИМТ Карточка
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: bmiColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ИМТ',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: bmiColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bmi.toStringAsFixed(1),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: bmiColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bmiCategory,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Норма: 18.5 – 24.9. Естественные колебания веса — это нормально.',
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  (String, Color) _getBmiStatus(double bmi) {
    if (bmi < 18.5) {
      return ('Дефицит массы тела', const Color(0xFF0EA5E9));
    } else if (bmi <= 24.9) {
      return ('Нормальный здоровый вес', const Color(0xFF10B981));
    } else if (bmi <= 29.9) {
      return ('Избыточная масса тела', const Color(0xFFF59E0B));
    } else {
      return ('Выше нормы', const Color(0xFFF97316));
    }
  }
}

class _ParameterSliderCard extends StatelessWidget {
  const _ParameterSliderCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.accentColor,
  });

  final String title;
  final double value;
  final String unit;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.15),
              inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
              trackHeight: 6,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
