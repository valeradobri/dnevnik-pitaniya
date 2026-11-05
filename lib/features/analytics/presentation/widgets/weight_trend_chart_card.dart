import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/nutri_card.dart';
import '../providers/analytics_providers.dart';

class WeightTrendChartCard extends StatelessWidget {
  const WeightTrendChartCard({
    super.key,
    required this.weightPoints,
    required this.targetWeight,
  });

  final List<WeightTrendPoint> weightPoints;
  final double targetWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (weightPoints.isEmpty) {
      return NutriCard(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.monitor_weight_rounded, color: Color(0xFF6366F1), size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Динамика веса',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Icon(Icons.scale_rounded, size: 48, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 10),
            Text(
              'Пока нет записей взвешиваний за этот период',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            Text(
              'Регулярное утреннее взвешивание поможет отслеживать плавный тренд',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Рассчитываем дельту
    final firstWeight = weightPoints.first.rawWeight;
    final lastWeight = weightPoints.last.rawWeight;
    final delta = lastWeight - firstWeight;
    final deltaStr = delta.abs() < 0.05
        ? 'Без изменений'
        : '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} кг';

    // Определение мин/макс оси Y с запасом
    double minY = targetWeight;
    double maxY = targetWeight;
    for (final p in weightPoints) {
      if (p.rawWeight < minY) minY = p.rawWeight;
      if (p.rawWeight > maxY) maxY = p.rawWeight;
      if (p.movingAverage < minY) minY = p.movingAverage;
      if (p.movingAverage > maxY) maxY = p.movingAverage;
    }
    minY = (minY - 2).floorToDouble();
    maxY = (maxY + 2).ceilToDouble();
    if (maxY - minY < 4) {
      minY -= 2;
      maxY += 2;
    }

    final rawSpots = <FlSpot>[];
    final maSpots = <FlSpot>[];

    for (int i = 0; i < weightPoints.length; i++) {
      rawSpots.add(FlSpot(i.toDouble(), weightPoints[i].rawWeight));
      maSpots.add(FlSpot(i.toDouble(), weightPoints[i].movingAverage));
    }

    return NutriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.monitor_weight_rounded, color: Color(0xFF6366F1), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Динамика веса',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Цель: ${targetWeight.toStringAsFixed(1)} кг',
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (delta < 0 ? AppColors.primary : const Color(0xFF6366F1)).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  deltaStr,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: delta < 0 ? AppColors.primary : const Color(0xFF6366F1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Пояснение про тренд и воду
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 14,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 3, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Сглаженный тренд (MA)',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: Color(0xFF818CF8), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Взвешивания',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // График
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (weightPoints.length - 1).toDouble().clamp(1.0, 90.0),
                minY: minY,
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
                      reservedSize: 36,
                      getTitlesWidget: (val, meta) {
                        return Text(
                          val.toStringAsFixed(0),
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
                      interval: weightPoints.length > 7 ? (weightPoints.length / 4).toDouble() : 1,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx < 0 || idx >= weightPoints.length) return const SizedBox.shrink();
                        final date = weightPoints[idx].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            DateFormat('d MMM', 'ru_RU').format(date),
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
                      y: targetWeight,
                      color: const Color(0xFF6366F1).withValues(alpha: 0.6),
                      strokeWidth: 1.5,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 6, bottom: 2),
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        labelResolver: (line) => 'Цель',
                      ),
                    ),
                  ],
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final p = idx >= 0 && idx < weightPoints.length ? weightPoints[idx] : null;
                        final dateLabel = p != null ? DateFormat('d MMMM', 'ru_RU').format(p.date) : '';
                        return LineTooltipItem(
                          '$dateLabel\n${spot.y.toStringAsFixed(1)} кг',
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
                  // Сырые точки взвешивания (точечная линия)
                  LineChartBarData(
                    spots: rawSpots,
                    isCurved: false,
                    color: const Color(0xFF818CF8).withValues(alpha: 0.4),
                    barWidth: 1.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3,
                        color: const Color(0xFF818CF8),
                        strokeWidth: 1,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                  // Сглаженный тренд Moving Average (акцентная плавная зеленая линия)
                  LineChartBarData(
                    spots: maSpots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppColors.primary,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.08),
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
