import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';

/// Радиальное кольцо калорий — центральный виджет дашборда
///
/// Отображает три концентрические дуги:
/// 1. Фон — полное кольцо (цель).
/// 2. Прогресс — потреблённые калории (изумрудный).
/// 3. Опционально — превышение нормы (мягкий янтарный, без красного цвета).
///
/// Параметры:
/// - [consumed] — потреблено калорий.
/// - [target]   — суточная цель.
/// - [size]     — диаметр кольца (по умолчанию 180px).
/// - [strokeWidth] — толщина дуги (по умолчанию 14px).
class CalorieRing extends StatelessWidget {
  const CalorieRing({
    super.key,
    required this.consumed,
    required this.target,
    this.size = 180,
    this.strokeWidth = 14,
    this.showLabels = true,
  });

  final double consumed;
  final double target;
  final double size;
  final double strokeWidth;
  final bool showLabels;

  double get _progress => target > 0 ? (consumed / target).clamp(0.0, 1.5) : 0.0;
  bool get _isOverTarget => consumed > target;
  double get _remaining => (target - consumed).clamp(0, double.infinity);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Кольцо прогресса
          CustomPaint(
            size: Size(size, size),
            painter: _CalorieRingPainter(
              progress: _progress,
              isOver: _isOverTarget,
              trackColor: theme.colorScheme.surfaceContainerHighest,
              strokeWidth: strokeWidth,
            ),
          ),
          // Центральный текст
          if (showLabels)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Число калорий (большое)
                Text(
                  consumed.toStringAsFixed(0),
                  style: AppTypography.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'ккал',
                  style: AppTypography.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                // Остаток или превышение
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _isOverTarget
                        ? AppColors.warningContainer
                        : AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _isOverTarget
                        ? '+${(consumed - target).toStringAsFixed(0)}'
                        : '${_remaining.toStringAsFixed(0)} ост.',
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: _isOverTarget
                          ? AppColors.warning
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CalorieRingPainter extends CustomPainter {
  const _CalorieRingPainter({
    required this.progress,
    required this.isOver,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final bool isOver;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2; // Начинаем с 12 часов

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = isOver ? AppColors.warning : AppColors.primary
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // 1. Трек (фон кольца)
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Прогресс
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CalorieRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.isOver != isOver ||
      oldDelegate.trackColor != trackColor;
}
