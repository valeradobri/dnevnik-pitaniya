import 'package:flutter/material.dart';
import '../../app/theme/app_typography.dart';

/// Горизонтальный прогресс-бар для отображения макронутриента
///
/// Показывает текущее значение относительно цели с цветовой маркировкой
/// по типу нутриента (белки, жиры, углеводы).
class MacroBar extends StatelessWidget {
  const MacroBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    this.unit = 'г',
    this.showValues = true,
  });

  final String label;
  final double current;
  final double target;
  final Color color;
  final String unit;
  final bool showValues;

  double get _progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTypography.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (showValues)
              Text(
                '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit',
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

/// Статичный индикатор с числовым значением и подписью (для дашборда)
class MacroTile extends StatelessWidget {
  const MacroTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.unit = 'г',
  });

  final String label;
  final double value;
  final Color color;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toStringAsFixed(0),
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$label, $unit',
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
