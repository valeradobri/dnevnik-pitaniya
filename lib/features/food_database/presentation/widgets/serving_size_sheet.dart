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

  // Режим: сухой/сырой (false) или готовый (true)
  bool _isCooked = false;
  late double _coefficient;

  final _dryQuickChips = const [40.0, 60.0, 80.0, 100.0, 150.0, 200.0];
  final _cookedQuickChips = const [100.0, 150.0, 200.0, 250.0, 300.0, 400.0];

  final _mealTypes = const [
    ('breakfast', 'Завтрак', Icons.wb_sunny_outlined),
    ('lunch', 'Обед', Icons.wb_cloudy_outlined),
    ('dinner', 'Ужин', Icons.nights_stay_outlined),
    ('snack', 'Перекус', Icons.cookie_outlined),
  ];

  @override
  void initState() {
    super.initState();
    final defaultCoeff = NutritionCalculator.getCookingCoefficient(
      name: widget.product.name,
      category: widget.product.category,
    );
    _coefficient = defaultCoeff == 1.0 ? 2.5 : defaultCoeff;

    // Если в названии уже прямо написано «каша» или «вареный», то продукт уже готов
    final isAlreadyCooked = widget.product.name.toLowerCase().contains('каша') ||
        widget.product.name.toLowerCase().contains('варен');

    if (isAlreadyCooked) {
      _isCooked = true;
      _grams = widget.product.servingSizeG > 0 ? widget.product.servingSizeG : 200.0;
    } else {
      _grams = widget.product.servingSizeG > 0 ? widget.product.servingSizeG : 100.0;
    }

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

  void _toggleCookedMode(bool cooked) {
    if (cooked == _isCooked) return;
    setState(() {
      _isCooked = cooked;
      if (_isCooked) {
        // Переключение на готовый: увеличиваем граммовку по коэффициенту
        _grams = (_grams * _coefficient).roundToDouble().clamp(30.0, 1000.0);
      } else {
        // Переключение на сухой: уменьшаем граммовку до сухого эквивалента
        _grams = (_grams / _coefficient).roundToDouble().clamp(10.0, 500.0);
      }
      _gramsController.text = _grams.toInt().toString();
    });
  }

  Future<void> _showCustomCoefficientDialog() async {
    final controller = TextEditingController(text: _coefficient.toString());
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Коэффициент готовки'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Укажите, во сколько раз меняется вес продукта при варке или жарке.\n\n'
              '• Для круп и макарон: 2.0 – 3.0 (разваривание)\n'
              '• Для мяса и рыбы: 0.70 – 0.85 (ужарка)',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Коэффициент',
                hintText: '2.5',
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
              if (parsed != null && parsed > 0 && parsed <= 10.0) {
                Navigator.pop(ctx, parsed);
              }
            },
            child: const Text('Применить'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() => _coefficient = result);
    }
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
      final dryGrams = _isCooked
          ? NutritionCalculator.calculateDryEquivalent(
              cookedGrams: _grams,
              coefficient: _coefficient,
            )
          : _grams;

      final nutrient = NutritionCalculator.calculateForGrams(
        grams: dryGrams,
        caloriesPer100g: p.caloriesPer100g,
        proteinPer100g: p.proteinPer100g,
        fatPer100g: p.fatPer100g,
        carbsPer100g: p.carbsPer100g,
      );

      final isAlreadyMarkedCooked = p.name.toLowerCase().contains('готов') ||
          p.name.toLowerCase().contains('каша') ||
          p.name.toLowerCase().contains('варен');

      final displayName = _isCooked && !isAlreadyMarkedCooked
          ? '${p.name} (готовый)'
          : p.name;

      final notes = _isCooked
          ? 'В готовом виде: ${_grams.toInt()} г (сухой экв.: ${dryGrams.round()} г, ×${_coefficient.toStringAsFixed(1)})'
          : null;

      final entry = DiaryEntriesCompanion.insert(
        mealType: _selectedMealType,
        foodProductId: p.id,
        customName: displayName,
        grams: _grams,
        calculatedCalories: nutrient.calories,
        calculatedProtein: nutrient.protein,
        calculatedFat: nutrient.fat,
        calculatedCarbs: nutrient.carbs,
        entryDate: widget.date,
        timestamp: drift.Value(DateTime.now()),
        notes: drift.Value(notes),
      );

      final diaryDao = ref.read(diaryDaoProvider);
      await diaryDao.insertEntry(entry);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$displayName (${_grams.toInt()} г) добавлен в дневник! 🥗',
            ),
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

    // Рассчитываем сухой эквивалент и питательные вещества
    final dryGrams = _isCooked
        ? NutritionCalculator.calculateDryEquivalent(
            cookedGrams: _grams,
            coefficient: _coefficient,
          )
        : _grams;

    final expectedCookedGrams = NutritionCalculator.calculateCookedWeight(
      dryGrams: _grams,
      coefficient: _coefficient,
    );

    final nutrient = NutritionCalculator.calculateForGrams(
      grams: dryGrams,
      caloriesPer100g: p.caloriesPer100g,
      proteinPer100g: p.proteinPer100g,
      fatPer100g: p.fatPer100g,
      carbsPer100g: p.carbsPer100g,
    );

    final activeChips = _isCooked ? _cookedQuickChips : _dryQuickChips;

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
        child: SingleChildScrollView(
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

              // Заголовок продукта и рассчитанные калории
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
                  const SizedBox(width: 12),
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
                        _isCooked
                            ? 'за ${_grams.toInt()} г (готовый)'
                            : 'за ${_grams.toInt()} г (сухой)',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Переключатель: В сухом виде / В готовом виде ────────
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      icon: Icon(Icons.grain_rounded, size: 18),
                      label: Text('В сухом / сыром'),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      icon: Icon(Icons.soup_kitchen_rounded, size: 18),
                      label: Text('В готовом виде'),
                    ),
                  ],
                  selected: {_isCooked},
                  onSelectionChanged: (set) => _toggleCookedMode(set.first),
                ),
              ),
              const SizedBox(height: 10),

              // ── Информационная плашка пересчета ───────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _isCooked
                      ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                      : theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isCooked
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: _isCooked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded,
                                  size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'В тарелке: ${_grams.toInt()} г  ≈  ${dryGrams.round()} г сухого продукта',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              Text(
                                'Коэфф. ${_coefficient >= 1.0 ? "разваривания" : "ужарки"}: ×${_coefficient.toStringAsFixed(1)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Быстрый выбор популярных коэффициентов
                              if (_coefficient >= 1.0) ...[
                                _MiniCoeffChip(
                                  label: '2.0',
                                  isSelected: (_coefficient - 2.0).abs() < 0.05,
                                  onTap: () => setState(() => _coefficient = 2.0),
                                ),
                                _MiniCoeffChip(
                                  label: '2.5',
                                  isSelected: (_coefficient - 2.5).abs() < 0.05,
                                  onTap: () => setState(() => _coefficient = 2.5),
                                ),
                                _MiniCoeffChip(
                                  label: '2.8',
                                  isSelected: (_coefficient - 2.8).abs() < 0.05,
                                  onTap: () => setState(() => _coefficient = 2.8),
                                ),
                                _MiniCoeffChip(
                                  label: '3.0',
                                  isSelected: (_coefficient - 3.0).abs() < 0.05,
                                  onTap: () => setState(() => _coefficient = 3.0),
                                ),
                              ] else ...[
                                _MiniCoeffChip(
                                  label: '0.70',
                                  isSelected: (_coefficient - 0.70).abs() < 0.02,
                                  onTap: () => setState(() => _coefficient = 0.70),
                                ),
                                _MiniCoeffChip(
                                  label: '0.75',
                                  isSelected: (_coefficient - 0.75).abs() < 0.02,
                                  onTap: () => setState(() => _coefficient = 0.75),
                                ),
                                _MiniCoeffChip(
                                  label: '0.80',
                                  isSelected: (_coefficient - 0.80).abs() < 0.02,
                                  onTap: () => setState(() => _coefficient = 0.80),
                                ),
                              ],
                              InkWell(
                                onTap: _showCustomCoefficientDialog,
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  child: Icon(Icons.edit_outlined,
                                      size: 15, color: theme.colorScheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Сухой вес: ${_grams.toInt()} г  →  после готовки выйдет ~${expectedCookedGrams.round()} г',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 14),

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
              const SizedBox(height: 16),

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
              const SizedBox(height: 14),

              // Ввод граммов
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isCooked ? 'Вес готового блюда (в тарелке)' : 'Вес сухого продукта',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_isCooked)
                    Text(
                      '~${dryGrams.round()} г сухого',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _gramsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: _isCooked ? 'Вес в тарелке' : 'Сухой вес',
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
                  children: activeChips.map((g) {
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
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _isCooked
                              ? 'Добавить готовую порцию (${_grams.toInt()} г)'
                              : 'Добавить в дневник (${_grams.toInt()} г)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniCoeffChip extends StatelessWidget {
  const _MiniCoeffChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            ),
          ),
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
