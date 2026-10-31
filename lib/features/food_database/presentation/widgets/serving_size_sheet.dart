import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/nutrition_calculator.dart';

class ServingSizeSheet extends ConsumerStatefulWidget {
  const ServingSizeSheet({
    super.key,
    required this.product,
    required this.initialMealType,
    required this.date,
  });

  final FoodProduct product;
  final String initialMealType;
  final DateTime date;

  static Future<bool?> show(
    BuildContext context, {
    required FoodProduct product,
    required String initialMealType,
    required DateTime date,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ServingSizeSheet(
        product: product,
        initialMealType: initialMealType,
        date: date,
      ),
    );
  }

  @override
  ConsumerState<ServingSizeSheet> createState() => _ServingSizeSheetState();
}

class _ServingSizeSheetState extends ConsumerState<ServingSizeSheet> {
  late final TextEditingController _gramsController;
  late String _selectedMealType;
  double _grams = 100.0;
  bool _isLoading = false;

  final _quickChips = const [50.0, 100.0, 150.0, 200.0, 250.0, 300.0];

  final _mealTypes = const [
    ('breakfast', 'Завтрак', Icons.wb_sunny_outlined),
    ('lunch', 'Обед', Icons.wb_cloudy_outlined),
    ('dinner', 'Ужин', Icons.nights_stay_outlined),
    ('snack', 'Перекус', Icons.cookie_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _grams = widget.product.servingSizeG > 0 ? widget.product.servingSizeG : 100.0;
    _gramsController = TextEditingController(text: _grams.toInt().toString());
    _selectedMealType = widget.initialMealType;
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _onGramsChanged(String val) {
    final parsed = double.tryParse(val.replaceAll(',', '.'));
    if (parsed != null && parsed >= 0) {
      setState(() => _grams = parsed);
    }
  }

  void _selectChipGrams(double grams) {
    setState(() {
      _grams = grams;
      _gramsController.text = grams.toInt().toString();
    });
  }

  Future<void> _submit() async {
    if (_grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите вес порции больше 0 грамм')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final p = widget.product;
      final nutrient = NutritionCalculator.calculateForGrams(
        grams: _grams,
        caloriesPer100g: p.caloriesPer100g,
        proteinPer100g: p.proteinPer100g,
        fatPer100g: p.fatPer100g,
        carbsPer100g: p.carbsPer100g,
      );

      final entry = DiaryEntriesCompanion.insert(
        mealType: _selectedMealType,
        foodProductId: p.id,
        customName: p.name,
        grams: _grams,
        calculatedCalories: nutrient.calories,
        calculatedProtein: nutrient.protein,
        calculatedFat: nutrient.fat,
        calculatedCarbs: nutrient.carbs,
        entryDate: widget.date,
        timestamp: drift.Value(DateTime.now()),
      );

      final diaryDao = ref.read(diaryDaoProvider);
      await diaryDao.insertEntry(entry);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${p.name} (${_grams.toInt()} г) добавлен в дневник! 🥗'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = widget.product;

    // Мгновенный расчет для указанных граммов
    final nutrient = NutritionCalculator.calculateForGrams(
      grams: _grams,
      caloriesPer100g: p.caloriesPer100g,
      proteinPer100g: p.proteinPer100g,
      fatPer100g: p.fatPer100g,
      carbsPer100g: p.carbsPer100g,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Заголовок продукта
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (p.brand != null && p.brand!.isNotEmpty)
                        Text(
                          p.brand!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                // Итоговые калории порции
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${nutrient.calories.round()} ккал',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      'за ${_grams.toInt()} г',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Карточка БЖУ для рассчитанной порции
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroStat(label: 'Белки', value: nutrient.protein, color: AppColors.protein),
                  Container(width: 1, height: 28, color: theme.colorScheme.outlineVariant),
                  _MacroStat(label: 'Жиры', value: nutrient.fat, color: AppColors.fat),
                  Container(width: 1, height: 28, color: theme.colorScheme.outlineVariant),
                  _MacroStat(label: 'Углеводы', value: nutrient.carbs, color: AppColors.carbs),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Прием пищи (чипы)
            Text(
              'Прием пищи',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _mealTypes.map((m) {
                  final isSelected = _selectedMealType == m.$1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(m.$2),
                      avatar: Icon(m.$3, size: 16),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedMealType = m.$1);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Ввод граммов
            Text(
              'Размер порции',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _gramsController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Граммы',
                      suffixText: 'г',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLowest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onChanged: _onGramsChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Быстрые чипы граммовки
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _quickChips.map((g) {
                  final isSelected = _grams == g;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text('${g.toInt()} г'),
                      backgroundColor: isSelected
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.surfaceContainerLowest,
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                      onPressed: () => _selectChipGrams(g),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

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
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Добавить в дневник',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          '${value.toStringAsFixed(1)} г',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
