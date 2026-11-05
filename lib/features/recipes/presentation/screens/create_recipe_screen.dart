import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';

class _DraftIngredient {
  _DraftIngredient({required this.food, required this.grams});
  final FoodProduct food;
  double grams;
  String? notes;
}

class CreateRecipeScreen extends ConsumerStatefulWidget {
  const CreateRecipeScreen({super.key});

  static Route<bool?> route() {
    return MaterialPageRoute(builder: (ctx) => const CreateRecipeScreen());
  }

  @override
  ConsumerState<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends ConsumerState<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _prepTimeController = TextEditingController(text: '30');
  final _servingsController = TextEditingController(text: '2');
  String _category = 'lunch';
  final List<_DraftIngredient> _ingredients = [];
  bool _isLoading = false;

  final _categories = const [
    ('breakfast', 'Завтрак'),
    ('lunch', 'Обед'),
    ('dinner', 'Ужин'),
    ('snack', 'Перекус'),
    ('dessert', 'Десерт'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _prepTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _addIngredient() async {
    final foodDao = ref.read(foodDaoProvider);
    final allFoods = await foodDao.getAllFoods();

    if (!mounted) return;

    final selected = await showModalBottomSheet<FoodProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Выберите ингредиент',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: allFoods.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final f = allFoods[i];
                  return ListTile(
                    title: Text(f.name),
                    subtitle: Text('${f.caloriesPer100g.round()} ккал на 100 г'),
                    onTap: () => Navigator.pop(ctx, f),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null && mounted) {
      final gramsController = TextEditingController(text: '100');
      final confirmedGrams = await showDialog<double>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Вес для "${selected.name}"'),
          content: TextField(
            controller: gramsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Граммы', suffixText: 'г'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
            FilledButton(
              onPressed: () {
                final g = double.tryParse(gramsController.text.replaceAll(',', '.'));
                Navigator.pop(ctx, g);
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      );

      if (confirmedGrams != null && confirmedGrams > 0) {
        setState(() {
          _ingredients.add(_DraftIngredient(food: selected, grams: confirmedGrams));
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте хотя бы один ингредиент')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prepTime = int.tryParse(_prepTimeController.text) ?? 30;
      final servings = int.tryParse(_servingsController.text) ?? 2;

      final recipeDao = ref.read(recipeDaoProvider);
      await recipeDao.insertRecipe(
        recipe: RecipesCompanion.insert(
          name: _nameController.text.trim(),
          description: drift.Value(_descController.text.trim().isEmpty ? null : _descController.text.trim()),
          prepTimeMinutes: drift.Value(prepTime),
          servings: drift.Value(servings),
          category: drift.Value(_category),
        ),
        ingredients: _ingredients
            .map((item) => RecipeIngredientsCompanion.insert(
                  recipeId: 0, // установится в транзакции DAO
                  foodProductId: item.food.id,
                  grams: item.grams,
                  notes: drift.Value(item.notes),
                ))
            .toList(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Рецепт успешно создан! 👨‍🍳'),
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

    // Подсчет КБЖУ черновика
    double totalCals = 0;
    for (final ing in _ingredients) {
      totalCals += (ing.food.caloriesPer100g * ing.grams) / 100.0;
    }
    final servings = int.tryParse(_servingsController.text) ?? 1;
    final calsPerServing = servings > 0 ? (totalCals / servings).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать рецепт'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _isLoading ? null : _submit,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Название блюда *',
                hintText: 'Например, Куриное филе с овощами',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Введите название' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Описание и процесс приготовления',
                hintText: 'Шаги, температура, особенности запекания...',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Время (мин)',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLowest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Порций',
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLowest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _category,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Категория',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(
                        value: c.$1,
                        child: Text(c.$2, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _category = val ?? 'lunch'),
            ),
            const SizedBox(height: 24),

            // Ингредиенты
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Ингредиенты (${_ingredients.length})',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addIngredient,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Добавить'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_ingredients.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: Text(
                    'Нажмите «Добавить», чтобы включить продукты в рецепт',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, index) {
                  final item = _ingredients[index];
                  final cals = (item.food.caloriesPer100g * item.grams) / 100.0;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.food.name),
                    subtitle: Text('${item.grams.toInt()} г · ${cals.round()} ккал'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      onPressed: () => setState(() => _ingredients.removeAt(index)),
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),
            // Итог КБЖУ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('Всего: ${totalCals.round()} ккал'),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '~ $calsPerServing ккал / порция',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Сохранить рецепт', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
