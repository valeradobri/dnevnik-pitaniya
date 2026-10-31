import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/nutri_card.dart';
import '../providers/analytics_providers.dart';

class CalorieChartCard extends StatelessWidget {
  const CalorieChartCard({
    super.key,
    required this.dailyData,
    required this.targetCalories,
  });

  final List<DailyNutritionData> dailyData;
  final double targetCalories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (dailyData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Рассчитываем среднюю калорийность за дни с записями
    final daysWithData = dailyData.where((d) => d.calories > 0).toList();
    final avgCalories = daysWithData.isNotEmpty
        ? (daysWithData.fold<double>(0, (sum, d) => sum + d.calories) / daysWithData.length).round()
        : 0;

    // Максимум для оси Y
    double maxY = targetCalories * 1.25;
    for (final d in dailyData) {
      if (d.calories > maxY) maxY = d.calories * 1.15;
    }
    if (maxY <= 0) maxY = 2500;

    final spots = <FlSpot>[];
    for (int i = 0; i < dailyData.length; i++) {
      spots.add(FlSpot(i.toDouble(), dailyData[i].calories));
    }

    return NutriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.caloriesLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_fire_department_rounded, color: AppColors.calories, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Калории и норма',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Цель: ${targetCalories.round()} ккал',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Ср: $avgCalories ккал',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // График LineChart
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (dailyData.length - 1).toDouble().clamp(1.0, 90.0),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (val, meta) {
                        if (val == 0 || val >= maxY - 100) return const SizedBox.shrink();
                        return Text(
                          val.toInt().toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: dailyData.length > 14 ? (dailyData.length / 5).toDouble() : 1,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= dailyData.length) return const SizedBox.shrink();
                        final date = dailyData[idx].date;
                        final label = dailyData.length <= 7
                            ? DateFormat('E', 'ru_RU').format(date)
                            : DateFormat('d MMM', 'ru_RU').format(date);

                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: targetCalories,
                      color: AppColors.calories.withValues(alpha: 0.6),
                      strokeWidth: 2,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 6, bottom: 2),
                        style: const TextStyle(
                          color: AppColors.calories,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        labelResolver: (line) => 'Норма',
                      ),
                    ),
                  ],
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final d = idx >= 0 && idx < dailyData.length ? dailyData[idx] : null;
                        final dateLabel = d != null ? DateFormat('d MMMM', 'ru_RU').format(d.date) : '';
                        return LineTooltipItem(
                          '$dateLabel\n${spot.y.round()} ккал',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.calories,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: dailyData.length <= 14,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: AppColors.calories,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.calories.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
