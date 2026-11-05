import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../../food_database/presentation/widgets/serving_size_sheet.dart';
import '../providers/meal_suggestions_provider.dart';
import 'tolerance_corridor_banner.dart';

/// Интерактивный лист предложений блюд и продуктов под остаток БЖУ
class MealSuggestionsSheet extends ConsumerStatefulWidget {
  const MealSuggestionsSheet({
    super.key,
    required this.date,
    this.initialMealType = 'dinner',
  });

  final DateTime date;
  final String initialMealType;

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    String initialMealType = 'dinner',
  }) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MealSuggestionsSheet(
        date: date,
        initialMealType: initialMealType,
      ),
    );
  }

  @override
  ConsumerState<MealSuggestionsSheet> createState() => _MealSuggestionsSheetState();
}

class _MealSuggestionsSheetState extends ConsumerState<MealSuggestionsSheet> {
  late String _selectedMealType;
  String _categoryFilter = 'all'; // 'all', 'protein', 'recipe', 'light'

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType;
  }

  String _mealTypeName(String type) {
    switch (type) {
      case 'breakfast':
        return 'Завтрак';
      case 'lunch':
        return 'Обед';
      case 'dinner':
        return 'Ужин';
      case 'snack':
        return 'Перекус';
      default:
        return 'Ужин';
    }
  }

  Future<void> _addSuggestionToDiary(MealSuggestion suggestion) async {
    final diaryDao = ref.read(diaryDaoProvider);

    try {
      if (suggestion.isRecipe && suggestion.recipe != null) {
        final r = suggestion.recipe!;
        final perServing = r.nutrientsPerServing;
        // Добавляем как блюдо рецепта
        await diaryDao.insertEntry(
          DiaryEntriesCompanion.insert(
            mealType: _selectedMealType,
            foodProductId: r.ingredients.isNotEmpty ? r.ingredients.first.product.id : 1,
            customName: r.recipe.name,
            grams: r.gramsPerServing,
            calculatedCalories: perServing.calories,
            calculatedProtein: perServing.protein,
            calculatedFat: perServing.fat,
            calculatedCarbs: perServing.carbs,
            entryDate: widget.date,
          ),
        );
      } else if (suggestion.product != null) {
        final p = suggestion.product!;
        await diaryDao.insertEntry(
          DiaryEntriesCompanion.insert(
            mealType: _selectedMealType,
            foodProductId: p.id,
            customName: p.name,
            grams: suggestion.suggestedGrams,
            calculatedCalories: suggestion.calories,
            calculatedProtein: suggestion.protein,
            calculatedFat: suggestion.fat,
            calculatedCarbs: suggestion.carbs,
            entryDate: widget.date,
          ),
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('«${suggestion.title}» добавлено в ${_mealTypeName(_selectedMealType).toLowerCase()}!'),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка добавления: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _openServingSizeSheet(MealSuggestion suggestion) {
    if (suggestion.product != null) {
      Navigator.of(context).pop();
      ServingSizeSheet.show(
        context,
        product: suggestion.product!,
        initialMealType: _selectedMealType,
        date: widget.date,
      );
    } else {
      _addSuggestionToDiary(suggestion);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final budget = ref.watch(remainingBudgetProvider(widget.date));
    final suggestionsAsync =
        ref.watch(smartMealSuggestionsProvider((widget.date, _selectedMealType)));

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Верхняя ручка шторки ────────────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Заголовок и кнопка закрытия ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Что скушать в пределах нормы?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Умный подбор под оставшийся баланс дня',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // ── Карточка остатка КБЖУ ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _BudgetStatItem(
                      label: 'Калории',
                      value: '${budget.remainingCalories.round()} ккал',
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: _BudgetStatItem(
                      label: 'Белки',
                      value: '${budget.remainingProtein.round()} г',
                      color: AppColors.protein,
                    ),
                  ),
                  Expanded(
                    child: _BudgetStatItem(
                      label: 'Жиры',
                      value: '${budget.remainingFat.round()} г',
                      color: AppColors.fat,
                    ),
                  ),
                  Expanded(
                    child: _BudgetStatItem(
                      label: 'Углеводы',
                      value: '${budget.remainingCarbs.round()} г',
                      color: AppColors.carbs,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Выбор приёма пищи (таблетки) ────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                FilterPill(
                  label: 'Ужин 🌙',
                  isSelected: _selectedMealType == 'dinner',
                  onTap: () => setState(() => _selectedMealType = 'dinner'),
                ),
                const SizedBox(width: 8),
                FilterPill(
                  label: 'Перекус 🍎',
                  isSelected: _selectedMealType == 'snack',
                  onTap: () => setState(() => _selectedMealType = 'snack'),
                ),
                const SizedBox(width: 8),
                FilterPill(
                  label: 'Обед ☀️',
                  isSelected: _selectedMealType == 'lunch',
                  onTap: () => setState(() => _selectedMealType = 'lunch'),
                ),
                const SizedBox(width: 8),
                FilterPill(
                  label: 'Завтрак 🥞',
                  isSelected: _selectedMealType == 'breakfast',
                  onTap: () => setState(() => _selectedMealType = 'breakfast'),
                ),
              ],
            ),
          ),

          // ── Фильтр по направлениям ──────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                FilterPill(
                  label: 'Все варианты',
                  isSelected: _categoryFilter == 'all',
                  onTap: () => setState(() => _categoryFilter = 'all'),
                ),
                const SizedBox(width: 8),
                FilterPill(
                  label: 'Больше белка 🍗',
                  isSelected: _categoryFilter == 'protein',
                  onTap: () => setState(() => _categoryFilter = 'protein'),
                ),
                const SizedBox(width: 8),
                FilterPill(
                  label: 'Рецепты 👨‍🍳',
                  isSelected: _categoryFilter == 'recipe',
                  onTap: () => setState(() => _categoryFilter = 'recipe'),
                ),
                const SizedBox(width: 8),
                FilterPill(
                  label: 'Вкусняшки 🍬',
                  isSelected: _categoryFilter == 'sweets',
                  onTap: () => setState(() => _categoryFilter = 'sweets'),
                ),
                const SizedBox(width: 8),
                FilterPill(
                  label: 'Легкое 🥗',
                  isSelected: _categoryFilter == 'light',
                  onTap: () => setState(() => _categoryFilter = 'light'),
                ),
              ],
            ),
          ),

          // ── Бережный баннер Zero-Guilt о коридоре ±10 г ─────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: ToleranceCorridorBanner(),
          ),

          // ── Список предложений ──────────────────────────────────────
          Expanded(
            child: suggestionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Ошибка загрузки: $err')),
              data: (allSuggestions) {
                final filtered = _categoryFilter == 'all'
                    ? allSuggestions
                    : allSuggestions.where((s) {
                        if (_categoryFilter == 'recipe') return s.isRecipe;
                        return s.categoryTag == _categoryFilter;
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 56,
                            color: theme.colorScheme.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Норма на день почти закрыта!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Отклонения до 10 единиц по БЖУ абсолютно нормальны. Можно выпить травяной чай или съесть лёгкое яблоко.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, index) {
                    final item = filtered[index];
                    return _SuggestionCard(
                      item: item,
                      onAddInstant: () => _addSuggestionToDiary(item),
                      onOpenServing: () => _openServingSizeSheet(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetStatItem extends StatelessWidget {
  const _BudgetStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.item,
    required this.onAddInstant,
    required this.onOpenServing,
  });

  final MealSuggestion item;
  final VoidCallback onAddInstant;
  final VoidCallback onOpenServing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F766E).withValues(alpha: 0.3) : const Color(0xFFCCFBF1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.categoryLabel,
                            style: const TextStyle(
                              color: Color(0xFF0D9488),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Нутриенты КБЖУ бейджи ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${item.calories.round()} ккал',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Б: ${item.protein.toStringAsFixed(1)}г',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.protein,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Ж: ${item.fat.toStringAsFixed(1)}г',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.fat,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'У: ${item.carbs.toStringAsFixed(1)}г',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.carbs,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Почему это подходит (Reason) ─────────────────────────────
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 15, color: Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Кнопки действия ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenServing,
                  icon: const Icon(Icons.tune_rounded, size: 16),
                  label: const Text('Настроить порцию'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAddInstant,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('В дневник'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: const Color(0xFF059669),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
