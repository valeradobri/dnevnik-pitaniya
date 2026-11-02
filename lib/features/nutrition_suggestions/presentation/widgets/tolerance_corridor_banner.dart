import 'package:flutter/material.dart';

/// Компактный и раскрывающийся бережный баннер о коридоре нормы (±10 единиц БЖУ не страшны)
class ToleranceCorridorBanner extends StatefulWidget {
  const ToleranceCorridorBanner({
    super.key,
    this.compact = false,
    this.initiallyExpanded = false,
  });

  final bool compact;
  final bool initiallyExpanded;

  @override
  State<ToleranceCorridorBanner> createState() => _ToleranceCorridorBannerState();
}

class _ToleranceCorridorBannerState extends State<ToleranceCorridorBanner> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

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

    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.spa_rounded, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Коридор нормы: отклонения ±10 г по БЖУ безопасны',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: textColor.withValues(alpha: 0.7),
                  size: 20,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 4, bottom: 2),
                child: Text(
                  'Наш организм не считает граммы поминутно. Небольшой выход за границы на ±10 г по белкам, жирам или углеводам (и ±150 ккал) — это естественная норма. Слушайте тело, ориентируйтесь на чувство сытости и комфорт без стресса.',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.9),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
