import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Фирменная карточка «Дневника» с мягкой тенью и скруглением
///
/// Использовать вместо стандартного [Card] для единообразия UI.
/// [child] — содержимое карточки.
/// [padding] — внутренние отступы (по умолчанию 16px).
/// [color] — цвет фона (по умолчанию — surface из темы).
/// [onTap] — если передан, карточка становится кликабельной через [InkWell].
class NutriCard extends StatelessWidget {
  const NutriCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.onTap,
    this.radius,
    this.shadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final VoidCallback? onTap;
  final double? radius;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.surface;
    final isLight = theme.brightness == Brightness.light;
    final borderRadius = BorderRadius.circular(radius ?? AppColors.radiusCard);

    final defaultShadow = isLight
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    final container = Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: borderRadius,
        boxShadow: shadow ?? defaultShadow,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.04),
          child: container,
        ),
      );
    }

    return container;
  }
}
