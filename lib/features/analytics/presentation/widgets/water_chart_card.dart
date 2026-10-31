import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/nutri_card.dart';
import '../providers/analytics_providers.dart';

class WaterChartCard extends StatelessWidget {
  const WaterChartCard({
    super.key,
    required this.waterData,
    required this.targetWaterMl,
  });

  final List<DailyWaterData> waterData;
  final int targetWaterMl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (waterData.isEmpty) {
      return const SizedBox.shrink();
    }

    final daysWithData = waterData.where((d) => d.amountMl > 0).toList();
    final avgWater = daysWithData.isNotEmpty
        ? (daysWithData.fold<int>(0, (sum, d) => sum + d.amountMl) / daysWithData.length).round()
        : 0;

    double maxY = targetWaterMl * 1.3;
    for (final d in waterData) {
      if (d.amountMl > maxY) maxY = d.amountMl * 1.15;
    }
    if (maxY <= 0) maxY = 2500;

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < waterData.length; i++) {
      final item = waterData[i];
      final isMet = item.amountMl >= targetWaterMl && targetWaterMl > 0;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: item.amountMl.toDouble(),
              color: isMet ? AppColors.water : AppColors.water.withValues(alpha: 0.6),
              width: waterData.length <= 7 ? 18 : (waterData.length <= 14 ? 10 : 5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
      );
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
                      color: AppColors.waterLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.water_drop_rounded, color: AppColors.water, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Водный баланс',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Цель: $targetWaterMl мл/день',
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
                  color: AppColors.water.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Ср: $avgWater мл',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.water,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Столбчатая диаграмма
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
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
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= waterData.length) return const SizedBox.shrink();
                        final date = waterData[idx].date;

                        if (waterData.length > 7 && idx % (waterData.length ~/ 5) != 0) {
                          return const SizedBox.shrink();
                        }

                        final label = waterData.length <= 7
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
                      y: targetWaterMl.toDouble(),
                      color: AppColors.water.withValues(alpha: 0.6),
                      strokeWidth: 1.5,
                      dashArray: [5, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 6, bottom: 2),
                        style: const TextStyle(
                          color: AppColors.water,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        labelResolver: (line) => 'Норма',
                      ),
                    ),
                  ],
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = waterData[groupIndex];
                      final dateLabel = DateFormat('d MMMM', 'ru_RU').format(item.date);
                      return BarTooltipItem(
                        '$dateLabel\n${rod.toY.toInt()} мл',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
