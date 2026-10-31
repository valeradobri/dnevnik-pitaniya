import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/nutri_card.dart';
import '../providers/analytics_providers.dart';

class GuiltFreeInsightCard extends StatelessWidget {
  const GuiltFreeInsightCard({
    super.key,
    required this.dailyData,
    required this.period,
  });

  final List<DailyNutritionData> dailyData;
  final AnalyticsPeriod period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trackedDays = dailyData.where((d) => d.calories > 0).length;
    final totalDays = dailyData.length;

    String headline;
    String message;
    IconData icon;

    if (trackedDays == 0) {
      headline = 'Начало вашего пути';
      message = 'Записывайте даже небольшие перекусы. Главное — не идеальность цифр, а бережное наблюдение за своими привычками.';
      icon = Icons.spa_rounded;
    } else if (trackedDays >= totalDays * 0.7) {
      headline = 'Замечательная регулярность!';
      message = 'Вы вели дневник $trackedDays из $totalDays дней. Осознанность в питании — это фундамент устойчивого самочувствия без строгих ограничений.';
      icon = Icons.favorite_rounded;
    } else {
      headline = 'Каждый шаг имеет значение';
      message = 'Зафиксировано $trackedDays дней. Пропуски — это абсолютно нормально. Продолжайте в комфортном ритме, без спешки и вины.';
      icon = Icons.eco_rounded;
    }

    return NutriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headline,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Бережный подход к прогрессу',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Помните: колебания на весах в 1–2 кг за сутки вызваны задержкой воды и гликогеном, а не жировой тканью.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
