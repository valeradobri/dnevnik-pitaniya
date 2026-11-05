import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/nutrition_calculator.dart';
import '../../data/services/recipe_parser_service.dart';
import 'create_recipe_screen.dart';
import 'recipe_detail_screen.dart';

final recipeParserServiceProvider = Provider<RecipeParserService>((ref) {
  return const RecipeParserService();
});

class ImportRecipeScreen extends ConsumerStatefulWidget {
  const ImportRecipeScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (ctx) => const ImportRecipeScreen());
  }

  @override
  ConsumerState<ImportRecipeScreen> createState() => _ImportRecipeScreenState();
}

class _ImportRecipeScreenState extends ConsumerState<ImportRecipeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;
  ParsedRecipe? _recipe;

  // Контроллеры для редактирования распарсенного рецепта
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _instructionsController;
  late TextEditingController _prepTimeController;
  late TextEditingController _servingsController;
  String _category = 'lunch';

  final _categories = const [
    ('breakfast', 'Завтрак'),
    ('soup', 'Суп'),
    ('lunch', 'Обед'),
    ('dinner', 'Ужин'),
    ('salad', 'Салат'),
    ('snack', 'Перекус'),
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _instructionsController = TextEditingController();
    _prepTimeController = TextEditingController(text: '30');
    _servingsController = TextEditingController(text: '2');
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _instructionsController.dispose();
    _prepTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && mounted) {
      _urlController.text = data!.text!.trim();
    }
  }

  Future<void> _loadRecipe() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _errorMessage = 'Пожалуйста, вставьте ссылку на рецепт');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final foodDao = ref.read(foodDaoProvider);
      final allFoods = await foodDao.getAllFoods();
      final parser = ref.read(recipeParserServiceProvider);

      final parsed = await parser.parseRecipeFromUrl(url, allFoods);

      if (mounted) {
        setState(() {
          _recipe = parsed;
          _titleController.text = parsed.title;
          _descController.text = parsed.description ?? '';
          _instructionsController.text = parsed.instructions;
          _prepTimeController.text = parsed.prepTimeMinutes.toString();
          _servingsController.text = parsed.servings.toString();
          _category = parsed.category;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _selectProductForIngredient(ParsedIngredient ing) async {
    final foodDao = ref.read(foodDaoProvider);
    final allFoods = await foodDao.getAllFoods();

    if (!mounted) return;

    final selected = await showModalBottomSheet<FoodProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductSelectorSheet(allFoods: allFoods, initialQuery: ing.cleanName),
    );

    if (selected != null && mounted) {
      setState(() {
        ing.matchedProduct = selected;
        ing.cleanName = selected.name;
      });
    }
  }

  Future<void> _editIngredientGrams(ParsedIngredient ing) async {
    final controller = TextEditingController(text: ing.grams.round().toString());
    final confirmed = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Вес для "${ing.cleanName}"'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Граммы',
            suffixText: 'г',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              final val = double.tryParse(controller.text.replaceAll(',', '.'));
              Navigator.pop(ctx, val);
            },
            child: const Text('Готово'),
          ),
        ],
      ),
    );

    if (confirmed != null && confirmed > 0 && mounted) {
      setState(() {
        ing.grams = confirmed;
      });
    }
  }

  Future<void> _addNewIngredient() async {
    final foodDao = ref.read(foodDaoProvider);
    final allFoods = await foodDao.getAllFoods();

    if (!mounted) return;

    final selected = await showModalBottomSheet<FoodProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ProductSelectorSheet(allFoods: allFoods, initialQuery: ''),
    );

    if (selected != null && mounted) {
      setState(() {
        _recipe?.ingredients.add(
          ParsedIngredient(
            rawText: selected.name,
            cleanName: selected.name,
            grams: 100,
            matchedProduct: selected,
            isIncluded: true,
          ),
        );
      });
    }
  }

  NutrientAmount _calculateTotalNutrients() {
    if (_recipe == null) {
      return const NutrientAmount(calories: 0, protein: 0, fat: 0, carbs: 0);
    }
    double cals = 0;
    double prot = 0;
    double fat = 0;
    double carbs = 0;

    for (final ing in _recipe!.ingredients) {
      if (!ing.isIncluded || ing.matchedProduct == null) continue;
      final n = NutritionCalculator.calculateForGrams(
        grams: ing.grams,
        caloriesPer100g: ing.matchedProduct!.caloriesPer100g,
        proteinPer100g: ing.matchedProduct!.proteinPer100g,
        fatPer100g: ing.matchedProduct!.fatPer100g,
        carbsPer100g: ing.matchedProduct!.carbsPer100g,
      );
      cals += n.calories;
      prot += n.protein;
      fat += n.fat;
      carbs += n.carbs;
    }

    return NutrientAmount(calories: cals, protein: prot, fat: fat, carbs: carbs);
  }

  Future<void> _saveRecipe() async {
    if (_recipe == null) return;
    if (!_formKey.currentState!.validate()) return;

    final included = _recipe!.ingredients.where((i) => i.isIncluded).toList();
    if (included.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Включите хотя бы один ингредиент в рецепт')),
      );
      return;
    }

    final missingProduct = included.any((i) => i.matchedProduct == null);
    if (missingProduct) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите продукт из каталога для всех включенных ингредиентов')),
      );
      return;
    }

    final prepTime = int.tryParse(_prepTimeController.text) ?? 30;
    final servings = int.tryParse(_servingsController.text) ?? 2;

    final recipeDao = ref.read(recipeDaoProvider);

    final recipeCompanion = RecipesCompanion(
      name: drift.Value(_titleController.text.trim()),
      description: drift.Value(_instructionsController.text.trim()),
      prepTimeMinutes: drift.Value(prepTime),
      servings: drift.Value(servings),
      category: drift.Value(_category),
      imageUrl: drift.Value(_recipe!.imageUrl),
    );

    final ingredientCompanions = included.map((i) {
      return RecipeIngredientsCompanion(
        foodProductId: drift.Value(i.matchedProduct!.id),
        grams: drift.Value(i.grams),
        notes: drift.Value(i.notes ?? i.rawText),
      );
    }).toList();

    try {
      final recipeId = await recipeDao.insertRecipe(
        recipe: recipeCompanion,
        ingredients: ingredientCompanions,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Рецепт «${_titleController.text.trim()}» сохранён в каталог! 🍳'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
        Navigator.push(context, RecipeDetailScreen.route(recipeId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Импорт рецепта по ссылке'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Поле ввода ссылки
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Вставьте ссылку на любой кулинарный сайт',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Поддерживаются eda.ru, iamcook, povarenok, gastronom, allrecipes и другие сайты с рецептами.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          keyboardType: TextInputType.url,
                          decoration: InputDecoration(
                            hintText: 'https://eda.ru/recepty/...',
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.paste_rounded, size: 20),
                              tooltip: 'Вставить из буфера',
                              onPressed: _pasteFromClipboard,
                            ),
                          ),
                          onSubmitted: (_) => _loadRecipe(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _isLoading ? null : _loadRecipe,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.download_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: theme.colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Text('Не удалось импортировать',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(_errorMessage!, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(context, CreateRecipeScreen.route());
                      },
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: const Text('Создать рецепт вручную'),
                    ),
                  ],
                ),
              ),
            ],

            if (_recipe != null) ...[
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Карточка превью рецепта
                    if (_recipe!.imageUrl != null && _recipe!.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          _recipe!.imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const SizedBox.shrink(),
                        ),
                      ),
                    if (_recipe!.imageUrl != null) const SizedBox(height: 16),

                    // Название блюда
                    TextFormField(
                      controller: _titleController,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        labelText: 'Название блюда',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        prefixIcon: const Icon(Icons.restaurant_menu_rounded),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Укажите название' : null,
                    ),
                    const SizedBox(height: 14),

                    // Категория
                    Text('Категория:', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: _categories.map((c) {
                        final isSel = _category == c.$1;
                        return ChoiceChip(
                          label: Text(c.$2),
                          selected: isSel,
                          onSelected: (selected) {
                            if (selected) setState(() => _category = c.$1);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Время готовки и порции
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _prepTimeController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Время (мин)',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              prefixIcon: const Icon(Icons.timer_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _servingsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Порций',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              prefixIcon: const Icon(Icons.people_outline_rounded),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Сводка КБЖУ
                    _buildNutrientsSummary(theme),
                    const SizedBox(height: 24),

                    // Секция ингредиентов
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ингредиенты (${_recipe!.ingredients.where((i) => i.isIncluded).length})',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: _addNewIngredient,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Добавить'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Список ингредиентов
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _recipe!.ingredients.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final ing = _recipe!.ingredients[index];
                        final isMatched = ing.matchedProduct != null;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: ing.isIncluded
                                ? theme.colorScheme.surfaceContainerLowest
                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: ing.isIncluded
                                  ? (isMatched
                                      ? theme.colorScheme.outlineVariant.withValues(alpha: 0.5)
                                      : Colors.amber.withValues(alpha: 0.7))
                                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: ing.isIncluded,
                                onChanged: (val) => setState(() => ing.isIncluded = val ?? false),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ing.cleanName,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        decoration: ing.isIncluded ? null : TextDecoration.lineThrough,
                                      ),
                                    ),
                                    if (ing.rawText != ing.cleanName)
                                      Text(
                                        ing.rawText,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 11,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    InkWell(
                                      onTap: () => _selectProductForIngredient(ing),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isMatched
                                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                              : Colors.amber.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isMatched ? Icons.check_circle_rounded : Icons.search_rounded,
                                              size: 13,
                                              color: isMatched ? theme.colorScheme.primary : Colors.amber.shade800,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                isMatched ? ing.matchedProduct!.name : 'Привязать к продукту...',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: isMatched ? theme.colorScheme.primary : Colors.amber.shade900,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => _editIngredientGrams(ing),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: theme.colorScheme.outlineVariant),
                                  ),
                                  child: Text(
                                    '${ing.grams.round()} г',
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  setState(() => _recipe!.ingredients.removeAt(index));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Инструкции / шаги
                    Text('Шаги приготовления',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        hintText: 'Шаги приготовления...',
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Кнопка сохранения
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _saveRecipe,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        icon: const Icon(Icons.bookmark_add_rounded),
                        label: const Text(
                          'Сохранить в мою книгу рецептов',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientsSummary(ThemeData theme) {
    final n = _calculateTotalNutrients();
    final servings = int.tryParse(_servingsController.text) ?? 1;
    final perServingCal = servings > 0 ? (n.calories / servings).round() : n.calories.round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Итого КБЖУ рецепта:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text(
                '~ $perServingCal ккал / порция',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NutrientBadge(label: 'Калории', value: '${n.calories.round()} ккал', color: AppColors.calories),
              _NutrientBadge(label: 'Белки', value: '${n.protein.toStringAsFixed(1)} г', color: AppColors.protein),
              _NutrientBadge(label: 'Жиры', value: '${n.fat.toStringAsFixed(1)} г', color: AppColors.fat),
              _NutrientBadge(label: 'Углеводы', value: '${n.carbs.toStringAsFixed(1)} г', color: AppColors.carbs),
            ],
          ),
        ],
      ),
    );
  }
}

class _NutrientBadge extends StatelessWidget {
  const _NutrientBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _ProductSelectorSheet extends StatefulWidget {
  const _ProductSelectorSheet({
    required this.allFoods,
    required this.initialQuery,
  });

  final List<FoodProduct> allFoods;
  final String initialQuery;

  @override
  State<_ProductSelectorSheet> createState() => _ProductSelectorSheetState();
}

class _ProductSelectorSheetState extends State<_ProductSelectorSheet> {
  late TextEditingController _searchController;
  late List<FoodProduct> _filtered;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _applyFilter(widget.initialQuery);
  }

  void _applyFilter(String q) {
    final query = q.toLowerCase().trim();
    if (query.isEmpty) {
      _filtered = widget.allFoods;
    } else {
      _filtered = widget.allFoods.where((f) => f.name.toLowerCase().contains(query)).toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Поиск продукта...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onChanged: (val) {
                setState(() => _applyFilter(val));
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final food = _filtered[i];
                return ListTile(
                  title: Text(food.name),
                  subtitle: Text(
                    '${food.caloriesPer100g.round()} ккал · Б: ${food.proteinPer100g.toStringAsFixed(1)} · Ж: ${food.fatPer100g.toStringAsFixed(1)} · У: ${food.carbsPer100g.toStringAsFixed(1)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  onTap: () => Navigator.pop(ctx, food),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
