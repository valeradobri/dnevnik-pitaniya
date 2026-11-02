import 'package:flutter/material.dart';

/// Высококонтрастный современный переключатель фильтра / категории.
///
/// Разработан для максимальной читаемости без артефактов Material 3:
/// - Активный: фирменный изумрудный фон, белый полужирный текст, мягкая тень.
/// - Неактивный: плотный серо-стальной фон (никаких прозрачностей), глубокий тёмный
///   текст (#0F172A в светлой теме / #FFFFFF в тёмной), контрастная рамка.
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.selectedColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = selectedColor ?? const Color(0xFF059669);

    final bgColor = isSelected
        ? primary
        : (isDark ? const Color(0xFF262D38) : const Color(0xFFE2E8F0));

    final textColor = isSelected
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF0F172A));

    final borderColor = isSelected
        ? primary
        : (isDark ? const Color(0xFF3B4454) : const Color(0xFFCBD5E1));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: isSelected
                      ? Colors.white
                      : (icon == Icons.star_rounded
                          ? const Color(0xFFF59E0B)
                          : textColor),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: textColor,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
