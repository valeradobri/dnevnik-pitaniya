import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';

class CreateFoodDialog extends ConsumerStatefulWidget {
  const CreateFoodDialog({super.key, this.initialBarcode});

  final String? initialBarcode;

  static Future<FoodProduct?> show(BuildContext context, {String? initialBarcode}) {
    return showDialog<FoodProduct>(
      context: context,
      builder: (ctx) => CreateFoodDialog(initialBarcode: initialBarcode),
    );
  }

  @override
  ConsumerState<CreateFoodDialog> createState() => _CreateFoodDialogState();
}

class _CreateFoodDialogState extends ConsumerState<CreateFoodDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  String _category = 'other';
  bool _isLoading = false;

  final _categories = const [
    ('grains', 'Крупы и злаки'),
    ('meat', 'Мясо и птица'),
    ('fish', 'Рыба и морепродукты'),
    ('dairy', 'Молочные продукты'),
    ('vegetables', 'Овощи и зелень'),
    ('fruits', 'Фрукты и ягоды'),
    ('sweets', 'Сладкое и десерты'),
    ('nuts', 'Орехи и семена'),
    ('bakery', 'Выпечка и хлеб'),
    ('drinks', 'Напитки'),
    ('other', 'Другое'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final brand = _brandController.text.trim().isEmpty ? null : _brandController.text.trim();
    final cals = double.parse(_caloriesController.text.replaceAll(',', '.'));
    final prot = double.parse(_proteinController.text.replaceAll(',', '.'));
    final fat = double.parse(_fatController.text.replaceAll(',', '.'));
    final carb = double.parse(_carbsController.text.replaceAll(',', '.'));

    setState(() => _isLoading = true);

    try {
      final foodDao = ref.read(foodDaoProvider);
      final id = await foodDao.insertFood(
        FoodProductsCompanion.insert(
          name: name,
          brand: drift.Value(brand),
          barcode: drift.Value(widget.initialBarcode),
          caloriesPer100g: cals,
          proteinPer100g: prot,
          fatPer100g: fat,
          carbsPer100g: carb,
          category: drift.Value(_category),
          sourceType: const drift.Value('user'),
        ),
      );

      final created = await foodDao.getFoodById(id);

      if (mounted) {
        Navigator.of(context).pop(created);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Продукт "$name" сохранен в вашу базу!'),
            behavior: SnackBarBehavior.floating,
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

    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.add_circle_outline_rounded, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Свой продукт')),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Укажите пищевую ценность на 100 граммов продукта:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.initialBarcode != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Штрих-код: ${widget.initialBarcode}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Название
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Название продукта *',
                hintText: 'Например, Домашний творог',
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                fillColor: theme.colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Введите название' : null,
            ),
            const SizedBox(height: 12),

            // Бренд
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: 'Бренд / Производитель (опционально)',
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                fillColor: theme.colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),

            // Категория
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              isDense: true,
              decoration: InputDecoration(
                labelText: 'Категория',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
                items: _categories
                    .map((c) => DropdownMenuItem(
                          value: c.$1,
                          child: Text(
                            c.$2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 16),

              // Калории
              TextFormField(
                controller: _caloriesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Калории на 100 г *',
                  suffixText: 'ккал',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerLowest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Введите калории';
                  final n = double.tryParse(val.replaceAll(',', '.'));
                  if (n == null || n < 0 || n > 1000) return 'Укажите число от 0 до 1000';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // БЖУ сетка
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Белки',
                        suffixText: 'г',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerLowest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (val) => _validateMacro(val, 'белки'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Жиры',
                        suffixText: 'г',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerLowest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (val) => _validateMacro(val, 'жиры'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Углеводы',
                        suffixText: 'г',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerLowest,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      validator: (val) => _validateMacro(val, 'углеводы'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Создать'),
        ),
      ],
    );
  }

  String? _validateMacro(String? val, String name) {
    if (val == null || val.trim().isEmpty) return '0';
    final n = double.tryParse(val.replaceAll(',', '.'));
    if (n == null || n < 0 || n > 100) return '0–100';
    return null;
  }
}
