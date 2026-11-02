import 'package:flutter/material.dart';

/// Бережный баннер о коридоре нормы (±10 единиц БЖУ не страшны)
class ToleranceCorridorBanner extends StatelessWidget {
  const ToleranceCorridorBanner({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF064E3B).withValues(alpha: 0.35)
        : const Color(0xFFECFDF5);
    final borderColor = isDark
        ? const Color(0xFF059669).withValues(alpha: 0.4)
        : const Color(0xFFA7F3D0);
    final textColor = isDark ? const Color(0xFFD1FAE5) : const Color(0xFF065F46);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.spa_rounded, color: Color(0xFF10B981), size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Коридор ±10 единиц по БЖУ — это физиологическая норма 🌿',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded, color: Color(0xFF059669), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Отклонения на ±10 г по БЖУ — это не страшно!',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Наш организм не считает граммы поминутно. Небольшой выход за границы безопасен и естественен. Главное — ваше самочувствие, сытость и комфорт без стресса.',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.35,
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
