import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../providers/analytics_providers.dart';
import '../widgets/calorie_chart_card.dart';
import '../widgets/macro_distribution_card.dart';
import '../widgets/weight_trend_chart_card.dart';
import '../widgets/water_chart_card.dart';
import '../widgets/guilt_free_insight_card.dart';

/// Экран глубокой аналитики и статистики (Вкладка 4 нижней навигации)
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final selectedPeriod = ref.watch(analyticsPeriodProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final dailyNutrition = ref.watch(dailyNutritionListProvider);
    final dailyWater = ref.watch(dailyWaterListProvider);
    final weightTrend = ref.watch(weightTrendListProvider);

    final profile = profileAsync.value;
    final targetCalories = profile?.targetCalories.toDouble() ?? 2000.0;
    final targetProtein = profile?.targetProteinG ?? 120.0;
    final targetFat = profile?.targetFatG ?? 65.0;
    final targetCarbs = profile?.targetCarbsG ?? 230.0;
    final targetWater = profile?.targetWaterMl ?? 2000;
    final targetWeight = profile?.targetWeightKg ?? 65.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Статистика'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'О методике',
            onPressed: () => _showMethodologyDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // Переключатель периода (7 / 30 / 90 дней)
            Center(
              child: SegmentedButton<AnalyticsPeriod>(
                segments: AnalyticsPeriod.values.map((p) {
                  return ButtonSegment(
                    value: p,
                    label: Text(p.label),
                  );
                }).toList(),
                selected: {selectedPeriod},
                onSelectionChanged: (set) {
                  ref.read(analyticsPeriodProvider.notifier).state = set.first;
                },
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Бережный поддерживающий инсайт
            GuiltFreeInsightCard(
              dailyData: dailyNutrition,
              period: selectedPeriod,
            ),
            const SizedBox(height: 14),

            // График калорий с нормой
            CalorieChartCard(
              dailyData: dailyNutrition,
              targetCalories: targetCalories,
            ),
            const SizedBox(height: 14),

            // Диаграмма соотношения БЖУ
            MacroDistributionCard(
              dailyData: dailyNutrition,
              targetProtein: targetProtein,
              targetFat: targetFat,
              targetCarbs: targetCarbs,
            ),
            const SizedBox(height: 14),

            // График веса со сглаженной линией тренда (MA)
            WeightTrendChartCard(
              weightPoints: weightTrend,
              targetWeight: targetWeight,
            ),
            const SizedBox(height: 14),

            // График гидратации
            WaterChartCard(
              waterData: dailyWater,
              targetWaterMl: targetWater,
            ),
          ],
        ),
      ),
    );
  }

  void _showMethodologyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('О методике аналитики'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '• Скользящее среднее веса (Moving Average): сглаживает ежедневные водные колебания (до ±1.5 кг) и отображает истинную динамику изменения массы тела.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 10),
              Text(
                '• Формула целевых калорий: базируется на Миффлине-Сан Жеоре с учетом вашей физической активности и бережного темпа изменений.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              SizedBox(height: 10),
              Text(
                '• Принцип устойчивости: прогресс измеряется регулярностью и самочувствием, а не абсолютным математическим совершенством.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}
