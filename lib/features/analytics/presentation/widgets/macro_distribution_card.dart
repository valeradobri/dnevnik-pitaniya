import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/nutri_card.dart';
import '../providers/analytics_providers.dart';

class MacroDistributionCard extends StatelessWidget {
  const MacroDistributionCard({
    super.key,
    required this.dailyData,
    required this.targetProtein,
    required this.targetFat,
    required this.targetCarbs,
  });

  final List<DailyNutritionData> dailyData;
  final double targetProtein;
  final double targetFat;
  final double targetCarbs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double totalProtG = 0;
    double totalFatG = 0;
    double totalCarbG = 0;

    for (final d in dailyData) {
      totalProtG += d.protein;
      totalFatG += d.fat;
      totalCarbG += d.carbs;
    }

    final protCals = totalProtG * 4;
    final fatCals = totalFatG * 9;
    final carbCals = totalCarbG * 4;
    final totalMacroCals = protCals + fatCals + carbCals;

    final hasData = totalMacroCals > 0;

    final protPct = hasData ? (protCals / totalMacroCals * 100).round() : 30;
    final fatPct = hasData ? (fatCals / totalMacroCals * 100).round() : 30;
    final carbPct = hasData ? (100 - protPct - fatPct).clamp(0, 100) : 40;

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
                  color: AppColors.proteinLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pie_chart_rounded, color: AppColors.protein, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Баланс БЖУ',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    hasData ? 'Доля калорий из белков, жиров и углеводов' : 'Целевое распределение',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              // Круговая диаграмма
              SizedBox(
                width: 130,
                height: 130,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 36,
                    sections: [
                      PieChartSectionData(
                        value: protPct.toDouble(),
                        color: AppColors.protein,
                        radius: 24,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: fatPct.toDouble(),
                        color: AppColors.fat,
                        radius: 24,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: carbPct.toDouble(),
                        color: AppColors.carbs,
                        radius: 24,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Легенда и граммы
              Expanded(
                child: Column(
                  children: [
                    _MacroRow(
                      color: AppColors.protein,
                      label: 'Белки',
                      percent: protPct,
                      grams: totalProtG,
                    ),
                    const SizedBox(height: 10),
                    _MacroRow(
                      color: AppColors.fat,
                      label: 'Жиры',
                      percent: fatPct,
                      grams: totalFatG,
                    ),
                    const SizedBox(height: 10),
                    _MacroRow(
                      color: AppColors.carbs,
                      label: 'Углеводы',
                      percent: carbPct,
                      grams: totalCarbG,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.color,
    required this.label,
    required this.percent,
    required this.grams,
  });

  final Color color;
  final String label;
  final int percent;
  final double grams;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          '$percent%',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(width: 8),
        if (grams > 0)
          Text(
            '(${grams.round()} г)',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
      ],
    );
  }
}
