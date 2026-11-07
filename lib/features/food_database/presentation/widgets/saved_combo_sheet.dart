import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../recipes/domain/models/recipe_model.dart';

/// Модальный экран быстрого добавления сохраненного шаблона комбо
class SavedComboSheet extends ConsumerStatefulWidget {
  const SavedComboSheet({
    super.key,
    required this.combo,
    required this.initialMealType,
    required this.date,
  });

  final RecipeWithDetails combo;
  final String initialMealType;
  final DateTime date;

  static Future<bool?> show(
    BuildContext context, {
    required RecipeWithDetails combo,
    required String initialMealType,
    required DateTime date,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SavedComboSheet(
        combo: combo,
        initialMealType: initialMealType,
        date: date,
      ),
    );
  }

  @override
  ConsumerState<SavedComboSheet> createState() => _SavedComboSheetState();
}

class _SavedComboSheetState extends ConsumerState<SavedComboSheet> {
  late String _selectedMealType;
  double _portions = 1.0;
  bool _isLoading = false;

  final _mealTypes = const [
    ('breakfast', 'Завтрак', Icons.wb_sunny_outlined),
    ('lunch', 'Обед', Icons.wb_cloudy_outlined),
    ('dinner', 'Ужин', Icons.nights_stay_outlined),
    ('snack', 'Перекус', Icons.cookie_outlined),
  ];

  final _quickPortions = const [0.5, 1.0, 1.5, 2.0, 3.0];

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType;
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final diaryDao = ref.read(diaryDaoProvider);
      final c = widget.combo;
      // Поскольку базовое количество порций = 1:
      final factor = _portions;
      final scaledCalories = c.nutrientsPerServing.calories * factor;
      final scaledProtein = c.nutrientsPerServing.protein * factor;
      final scaledFat = c.nutrientsPerServing.fat * factor;
      final scaledCarbs = c.nutrientsPerServing.carbs * factor;
      final scaledGrams = c.totalGrams * factor;

      final notes = c.ingredients
          .map((i) => '${i.product.name} ${(i.ingredient.grams * factor).round()}г')
          .join(', ');

      final displayName = _portions == 1.0
          ? c.recipe.name
          : '${c.recipe.name} ($_portions порц.)';

      final firstFoodId = c.ingredients.isNotEmpty ? c.ingredients.first.product.id : 1;

      await diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: _selectedMealType,
          foodProductId: firstFoodId,
          customName: displayName,
          grams: scaledGrams,
          calculatedCalories: scaledCalories,
          calculatedProtein: scaledProtein,
          calculatedFat: scaledFat,
          calculatedCarbs: scaledCarbs,
          entryDate: widget.date,
          timestamp: drift.Value(DateTime.now()),
          notes: drift.Value(notes),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('«$displayName» добавлен в ${_formatMealName(_selectedMealType)}! 🥪'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTemplate() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить комбо?'),
        content: Text('Шаблон «${widget.combo.recipe.name}» будет удален из сохраненных.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final recipeDao = ref.read(recipeDaoProvider);
      await recipeDao.deleteRecipe(widget.combo.recipe.id);
      if (mounted) {
        Navigator.pop(context, false);
      }
    }
  }

  String _formatMealName(String type) {
    switch (type) {
      case 'breakfast':
        return 'завтрак';
      case 'lunch':
        return 'обед';
      case 'dinner':
        return 'ужин';
      case 'snack':
        return 'перекус';
      default:
        return 'дневник';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.combo;

    final factor = _portions;
    final totalCals = c.nutrientsPerServing.calories * factor;
    final totalProt = c.nutrientsPerServing.protein * factor;
    final totalFat = c.nutrientsPerServing.fat * factor;
    final totalCarbs = c.nutrientsPerServing.carbs * factor;
    final totalWeight = c.totalGrams * factor;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lunch_dining_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.recipe.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Шаблон комбо · ${c.ingredients.length} ингр.',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: theme.colorScheme.error,
                    tooltip: 'Удалить шаблон',
                    onPressed: _deleteTemplate,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  // Сводка КБЖУ с учетом множителя порций
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Энергетическая ценность',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${totalCals.round()} ккал',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                '${totalWeight.round()} г',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _MacroItem(label: 'Белки', value: '${totalProt.toStringAsFixed(1)} г', color: AppColors.protein),
                            _MacroItem(label: 'Жиры', value: '${totalFat.toStringAsFixed(1)} г', color: AppColors.fat),
                            _MacroItem(label: 'Углеводы', value: '${totalCarbs.toStringAsFixed(1)} г', color: AppColors.carbs),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Выбор размера порции
                  Text('Сколько порций съедено:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _quickPortions.map((p) {
                        final isSelected = _portions == p;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: isSelected,
                            label: Text(p == 1.0 ? '1 порция' : '$p порц.'),
                            onSelected: (val) {
                              if (val) setState(() => _portions = p);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Состав
                  Text('Ингредиенты:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: c.ingredients.map((ing) {
                        final g = (ing.ingredient.grams * factor).round();
                        final cals = (ing.nutrients.calories * factor).round();

                        return ListTile(
                          dense: true,
                          title: Text(ing.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            'Б: ${(ing.nutrients.protein * factor).toStringAsFixed(1)} · Ж: ${(ing.nutrients.fat * factor).toStringAsFixed(1)} · У: ${(ing.nutrients.carbs * factor).toStringAsFixed(1)}',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
                          ),
                          trailing: Text(
                            '$g г  ($cals ккал)',
                            style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Приём пищи
                  Text('Записать в приём пищи:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _mealTypes.map((mt) {
                        final isSelected = _selectedMealType == mt.$1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: isSelected,
                            label: Text(mt.$2),
                            avatar: Icon(mt.$3, size: 16),
                            onSelected: (val) {
                              if (val) setState(() => _selectedMealType = mt.$1);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Кнопка добавления
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Записать в ${_formatMealName(_selectedMealType)} (${totalCals.round()} ккал)',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  const _MacroItem({
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
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
      ],
    );
  }
}
