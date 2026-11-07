import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/models/combo_item.dart';

/// Модальный экран сборки составного блюда / комбо
class ComboBuilderSheet extends ConsumerStatefulWidget {
  const ComboBuilderSheet({
    super.key,
    required this.initialItems,
    required this.initialMealType,
    required this.date,
    required this.onAddMore,
  });

  final List<ComboIngredientItem> initialItems;
  final String initialMealType;
  final DateTime date;
  final VoidCallback onAddMore;

  static Future<bool?> show(
    BuildContext context, {
    required List<ComboIngredientItem> items,
    required String initialMealType,
    required DateTime date,
    required VoidCallback onAddMore,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ComboBuilderSheet(
        initialItems: items,
        initialMealType: initialMealType,
        date: date,
        onAddMore: onAddMore,
      ),
    );
  }

  @override
  ConsumerState<ComboBuilderSheet> createState() => _ComboBuilderSheetState();
}

class _ComboBuilderSheetState extends ConsumerState<ComboBuilderSheet> {
  late final List<ComboIngredientItem> _items;
  late final TextEditingController _titleController;
  late String _selectedMealType;
  bool _saveAsTemplate = false;
  bool _isLoading = false;

  final _mealTypes = const [
    ('breakfast', 'Завтрак', Icons.wb_sunny_outlined),
    ('lunch', 'Обед', Icons.wb_cloudy_outlined),
    ('dinner', 'Ужин', Icons.nights_stay_outlined),
    ('snack', 'Перекус', Icons.cookie_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
    final summary = ComboSummary(_items);
    _titleController = TextEditingController(text: summary.defaultTitle);
    _selectedMealType = widget.initialMealType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      if (_items.isNotEmpty && _titleController.text.trim().isEmpty) {
        _titleController.text = ComboSummary(_items).defaultTitle;
      }
    });
  }

  Future<void> _editGrams(int index) async {
    final item = _items[index];
    final controller = TextEditingController(text: item.grams.toInt().toString());

    final newGrams = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Укажите вес ингредиента:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                suffixText: 'г',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.replaceAll(',', '.'));
              if (parsed != null && parsed > 0) {
                Navigator.pop(ctx, parsed);
              }
            },
            child: const Text('Готово'),
          ),
        ],
      ),
    );

    if (newGrams != null && mounted) {
      setState(() {
        _items[index] = item.copyWith(grams: newGrams);
      });
    }
  }

  Future<void> _submit() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('В блюде должен быть хотя бы один ингредиент')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final diaryDao = ref.read(diaryDaoProvider);
      final recipeDao = ref.read(recipeDaoProvider);
      final summary = ComboSummary(_items);

      final title = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : summary.defaultTitle;

      // 1. Записываем в дневник как единое составное блюдо
      final firstProductId = _items.first.product.id;
      await diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: _selectedMealType,
          foodProductId: firstProductId,
          customName: title,
          grams: summary.totalGrams,
          calculatedCalories: summary.totalCalories,
          calculatedProtein: summary.totalProtein,
          calculatedFat: summary.totalFat,
          calculatedCarbs: summary.totalCarbs,
          entryDate: widget.date,
          timestamp: drift.Value(DateTime.now()),
          notes: drift.Value(summary.ingredientsNotes),
        ),
      );

      // 2. Если отмечено, сохраняем как шаблон в Мои комбо
      if (_saveAsTemplate) {
        await recipeDao.saveComboTemplate(
          name: title,
          items: _items.map((i) => (foodProductId: i.product.id, grams: i.grams)).toList(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('«$title» записан в ${_formatMealName(_selectedMealType)}! 🥪'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    final summary = ComboSummary(_items);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Хэндл
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

            // Заголовок
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
                    child: Text(
                      'Конструктор комбо / блюда',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_items.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() => _items.clear()),
                      child: const Text('Очистить'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.set_meal_outlined, size: 64, color: theme.colorScheme.outlineVariant),
                            const SizedBox(height: 12),
                            Text('В комбо пока нет продуктов', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text(
                              'Добавьте хлеб, колбасу, сыр, овощи или любые другие продукты из поиска!',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            FilledButton.tonalIcon(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onAddMore();
                              },
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Добавить ингредиенты'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        // Поле названия
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Название блюда',
                            hintText: 'Например, Бутерброд с ветчиной и сыром',
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerLowest,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            prefixIcon: const Icon(Icons.edit_note_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Карточка с суммарными КБЖУ
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
                                        'Итого КБЖУ',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${summary.totalCalories.round()} ккал',
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
                                      'Вес: ${summary.totalGrams.round()} г',
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _MiniNutrientStat(
                                    label: 'Белки',
                                    value: '${summary.totalProtein.toStringAsFixed(1)} г',
                                    color: AppColors.protein,
                                  ),
                                  _MiniNutrientStat(
                                    label: 'Жиры',
                                    value: '${summary.totalFat.toStringAsFixed(1)} г',
                                    color: AppColors.fat,
                                  ),
                                  _MiniNutrientStat(
                                    label: 'Углеводы',
                                    value: '${summary.totalCarbs.toStringAsFixed(1)} г',
                                    color: AppColors.carbs,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Список ингредиентов
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ингредиенты (${_items.length}):',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onAddMore();
                              },
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Добавить ещё'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        ...List.generate(_items.length, (index) {
                          final item = _items[index];
                          final cals = item.nutrients.calories.round();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$cals ккал · Б: ${item.nutrients.protein.toStringAsFixed(1)} · Ж: ${item.nutrients.fat.toStringAsFixed(1)} · У: ${item.nutrients.carbs.toStringAsFixed(1)}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _editGrams(index),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${item.grams.toInt()} г',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.edit_rounded, size: 14, color: theme.colorScheme.primary),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  color: theme.colorScheme.onSurfaceVariant,
                                  onPressed: () => _removeItem(index),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 14),

                        // Приём пищи
                        Text(
                          'Записать в приём пищи:',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
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
                        const SizedBox(height: 14),

                        // Чекбокс: сохранить как шаблон
                        Material(
                          type: MaterialType.transparency,
                          child: CheckboxListTile(
                            value: _saveAsTemplate,
                            onChanged: (val) => setState(() => _saveAsTemplate = val ?? false),
                            contentPadding: EdgeInsets.zero,
                            title: const Text('⭐ Сохранить в «Мои комбо»', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Чтобы в следующий раз добавлять этот бутерброд в один клик'),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Кнопка сохранения
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
                                    'Записать в ${_formatMealName(_selectedMealType)} (${summary.totalCalories.round()} ккал)',
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

class _MiniNutrientStat extends StatelessWidget {
  const _MiniNutrientStat({
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
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
