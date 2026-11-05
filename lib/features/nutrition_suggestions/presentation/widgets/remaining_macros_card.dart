import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/meal_suggestions_provider.dart';
import 'meal_suggestions_sheet.dart';
import 'tolerance_corridor_banner.dart';

/// Интерактивная карточка на Дашборде с остатком БЖУ, коридором нормы и кнопкой подбора блюд
class RemainingMacrosCard extends ConsumerWidget {
  const RemainingMacrosCard({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final budget = ref.watch(remainingBudgetProvider(date));
    final suggestionsAsync = ref.watch(smartMealSuggestionsProvider((date, 'dinner')));
    final topSuggestions = suggestionsAsync.value ?? [];

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Верхняя строка: Заголовок и остаток калорий ────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lightbulb_rounded,
                        color: Color(0xFF059669),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Остаток на сегодня',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '~${budget.remainingCalories.round()} ккал',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Оставшиеся БЖУ в виде понятных плашек ──────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _MacroRemainingBadge(
                    label: 'Белки',
                    grams: budget.remainingProtein,
                    color: AppColors.protein,
                  ),
                ),
                Container(width: 1, height: 24, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                Expanded(
                  child: _MacroRemainingBadge(
                    label: 'Жиры',
                    grams: budget.remainingFat,
                    color: AppColors.fat,
                  ),
                ),
                Container(width: 1, height: 24, color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                Expanded(
                  child: _MacroRemainingBadge(
                    label: 'Углеводы',
                    grams: budget.remainingCarbs,
                    color: AppColors.carbs,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Компактное напоминание Zero-Guilt о коридоре нормы ─────
          const ToleranceCorridorBanner(compact: true),
          const SizedBox(height: 12),

          // ── Быстрые чипы предложений (если есть) ────────────────────
          if (topSuggestions.isNotEmpty) ...[
            Text(
              'Подходящие варианты на ужин:',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: topSuggestions.take(2).map((s) {
                return ActionChip(
                  avatar: Icon(s.icon, size: 16, color: const Color(0xFF059669)),
                  label: Text('${s.title} (~${s.calories.round()} ккал)'),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  onPressed: () => MealSuggestionsSheet.show(context, date: date),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

          // ── Главная кнопка интерактивного подбора ──────────────────
          FilledButton.icon(
            onPressed: () => MealSuggestionsSheet.show(context, date: date),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text('Что скушать в пределах нормы?'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroRemainingBadge extends StatelessWidget {
  const _MacroRemainingBadge({
    required this.label,
    required this.grams,
    required this.color,
  });

  final String label;
  final double grams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${grams.round()} г',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
