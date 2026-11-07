import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../../data/open_food_facts_client.dart';
import 'serving_size_sheet.dart';
import 'create_food_dialog.dart';
import '../screens/barcode_scanner_screen.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../../domain/models/combo_item.dart';
import 'combo_builder_sheet.dart';
import 'saved_combo_sheet.dart';
import '../../../recipes/domain/models/recipe_model.dart';

class FoodSearchSheet extends ConsumerStatefulWidget {
  const FoodSearchSheet({
    super.key,
    required this.mealType,
    required this.date,
  });

  final String mealType;
  final DateTime date;

  static Future<void> show(
    BuildContext context, {
    required String mealType,
    required DateTime date,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FoodSearchSheet(mealType: mealType, date: date),
    );
  }

  @override
  ConsumerState<FoodSearchSheet> createState() => _FoodSearchSheetState();
}

class _FoodSearchSheetState extends ConsumerState<FoodSearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _query = '';
  bool _isSearchingOnline = false;
  List<RemoteFoodProduct>? _onlineResults;
  final OpenFoodFactsClient _offClient = OpenFoodFactsClient();
  final List<ComboIngredientItem> _comboItems = [];

  final List<(String, String, IconData?)> _categories = const [
    ('all', 'Все', null),
    ('favorites', 'Избранное', Icons.star_rounded),
    ('combos', 'Мои комбо', Icons.lunch_dining_rounded),
    ('grains', 'Крупы', null),
    ('meat', 'Мясо и птица', null),
    ('fish', 'Рыба', null),
    ('dairy', 'Молочные', null),
    ('vegetables', 'Овощи', null),
    ('fruits', 'Фрукты', null),
    ('nuts', 'Орехи', null),
    ('drinks', 'Напитки', null),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchOnline() async {
    if (_query.isEmpty) return;
    setState(() {
      _isSearchingOnline = true;
      _onlineResults = null;
    });

    try {
      final results = await _offClient.searchProducts(_query);
      if (mounted) {
        setState(() {
          _onlineResults = results;
          _isSearchingOnline = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _onlineResults = [];
          _isSearchingOnline = false;
        });
      }
    }
  }

  Future<void> _importAndSelectOnline(RemoteFoodProduct item) async {
    final foodDao = ref.read(foodDaoProvider);
    final id = await foodDao.insertFood(
      FoodProductsCompanion.insert(
        name: item.name,
        brand: drift.Value(item.brand),
        barcode: drift.Value(item.barcode),
        category: drift.Value(item.category),
        caloriesPer100g: item.calories,
        proteinPer100g: item.protein,
        fatPer100g: item.fat,
        carbsPer100g: item.carbs,
        servingSizeG: const drift.Value(100.0),
        sourceType: const drift.Value('open_food_facts'),
      ),
    );
    final inserted = await foodDao.getFoodById(id);
    if (inserted != null && mounted) {
      final added = await ServingSizeSheet.show(
        context,
        product: inserted,
        initialMealType: widget.mealType,
        date: widget.date,
      );
      if (added == true && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foodDao = ref.watch(foodDaoProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
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
          const SizedBox(height: 12),

          // Заголовок и кнопка создания своего продукта
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Выбор продукта',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () async {
                    final created = await CreateFoodDialog.show(context);
                    if (created != null && context.mounted) {
                      ServingSizeSheet.show(
                        context,
                        product: created,
                        initialMealType: widget.mealType,
                        date: widget.date,
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Свой продукт'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Поле поиска
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск (гречка, курица, банан...)',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      tooltip: 'Сканировать штрих-код',
                      onPressed: () async {
                        final added = await BarcodeScannerScreen.show(
                          context,
                          mealType: widget.mealType,
                          date: widget.date,
                        );
                        if (added == true && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _query = val.trim().toLowerCase()),
            ),
          ),
          const SizedBox(height: 12),

          // Горизонтальные плашки категорий
          SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat.$1;
                return Center(
                  child: FilterPill(
                    label: cat.$2,
                    icon: cat.$3,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCategory = cat.$1),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Список продуктов или сохраненных комбо
          if (_selectedCategory == 'combos') ...[
            Expanded(
              child: StreamBuilder<List<RecipeWithDetails>>(
                stream: ref.watch(recipeDaoProvider).watchCombosWithDetails(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var combos = snapshot.data!;
                  if (_query.isNotEmpty) {
                    combos = combos
                        .where((c) => c.recipe.name.toLowerCase().contains(_query.toLowerCase()))
                        .toList();
                  }

                  if (combos.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lunch_dining_outlined,
                              size: 56,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text('Нет сохраненных комбо', style: theme.textTheme.titleMedium),
                            const SizedBox(height: 6),
                            Text(
                              'Соберите бутерброд или перекус из нескольких продуктов в поиске — и сохраните его галочкой «⭐ Сохранить в Мои комбо»!',
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.tonalIcon(
                              onPressed: () => setState(() => _selectedCategory = 'all'),
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('Собрать из продуктов'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: combos.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final combo = combos[index];
                      final cals = combo.nutrientsPerServing.calories.round();
                      final ingredientsText = combo.ingredients
                          .map((i) => '${i.product.name} ${i.ingredient.grams.toInt()}г')
                          .join(' + ');

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.lunch_dining_rounded, size: 22),
                        ),
                        title: Text(
                          combo.recipe.name,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              ingredientsText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$cals ккал · ${combo.totalGrams.toInt()} г · Б: ${combo.nutrientsPerServing.protein.toStringAsFixed(1)} · Ж: ${combo.nutrientsPerServing.fat.toStringAsFixed(1)} · У: ${combo.nutrientsPerServing.carbs.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        onTap: () async {
                          final added = await SavedComboSheet.show(
                            context,
                            combo: combo,
                            initialMealType: widget.mealType,
                            date: widget.date,
                          );
                          if (added == true && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: StreamBuilder<List<FoodProduct>>(
                stream: foodDao.watchAllFoods(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                var list = snapshot.data!;

                // Фильтрация по категории
                if (_selectedCategory == 'favorites') {
                  list = list.where((p) => p.isFavorite).toList();
                } else if (_selectedCategory != 'all') {
                  list = list.where((p) => p.category == _selectedCategory).toList();
                }

                // Фильтрация по поисковой строке
                if (_query.isNotEmpty) {
                  list = list.where((p) {
                    final nameMatch = p.name.toLowerCase().contains(_query);
                    final brandMatch = p.brand?.toLowerCase().contains(_query) ?? false;
                    return nameMatch || brandMatch;
                  }).toList();
                }

                if (list.isEmpty) {
                  if (_isSearchingOnline) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Поиск в базе Open Food Facts...'),
                        ],
                      ),
                    );
                  }

                  if (_onlineResults != null && _onlineResults!.isNotEmpty) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _onlineResults!.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _onlineResults![index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'онлайн',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.brand != null && item.brand!.isNotEmpty)
                                Text(
                                  item.brand!,
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              Row(
                                children: [
                                  Text(
                                    '${item.calories.round()} ккал',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'Б: ${item.protein.toStringAsFixed(1)} · Ж: ${item.fat.toStringAsFixed(1)} · У: ${item.carbs.toStringAsFixed(1)}',
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.add_circle_outline_rounded, size: 24),
                          onTap: () => _importAndSelectOnline(item),
                        );
                      },
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 56,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Локально ничего не найдено',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          if (_query.isNotEmpty) ...[
                            Text(
                              'Попробуйте поискать во всемирной базе продуктов Open Food Facts',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.tonalIcon(
                              onPressed: _searchOnline,
                              icon: const Icon(Icons.travel_explore_rounded, size: 20),
                              label: Text('Искать «$_query» онлайн'),
                            ),
                          ] else ...[
                            Text(
                              'Попробуйте изменить категорию или фильтр',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = list[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      title: Text(
                        item.name,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            '${item.caloriesPer100g.round()} ккал',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Б: ${item.proteinPer100g.toStringAsFixed(1)} · Ж: ${item.fatPer100g.toStringAsFixed(1)} · У: ${item.carbsPer100g.toStringAsFixed(1)}',
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              item.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                              color: item.isFavorite ? const Color(0xFFF59E0B) : theme.colorScheme.outlineVariant,
                            ),
                            onPressed: () => foodDao.toggleFavorite(item.id, !item.isFavorite),
                          ),
                          const Icon(Icons.add_circle_outline_rounded, size: 24),
                        ],
                      ),
                      onTap: () async {
                        final result = await ServingSizeSheet.show(
                          context,
                          product: item,
                          initialMealType: widget.mealType,
                          date: widget.date,
                        );
                        if (result is bool && result == true && context.mounted) {
                          Navigator.pop(context);
                        } else if (result is ComboIngredientItem && context.mounted) {
                          setState(() => _comboItems.add(result));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('«${result.product.name}» (${result.grams.toInt()} г) добавлен в комбо! 🥪'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'Открыть',
                                onPressed: _openComboBuilder,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],

        // Плашка собранного комбо (корзина внизу экрана)
        if (_comboItems.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lunch_dining_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Комбо: ${_comboItems.length} ${_itemWord(_comboItems.length)} (${ComboSummary(_comboItems).totalGrams.toInt()} г)',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${ComboSummary(_comboItems).totalCalories.round()} ккал · Б: ${ComboSummary(_comboItems).totalProtein.toStringAsFixed(1)} · Ж: ${ComboSummary(_comboItems).totalFat.toStringAsFixed(1)} · У: ${ComboSummary(_comboItems).totalCarbs.toStringAsFixed(1)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: _openComboBuilder,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Готово', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

  Future<void> _openComboBuilder() async {
    final saved = await ComboBuilderSheet.show(
      context,
      items: _comboItems,
      initialMealType: widget.mealType,
      date: widget.date,
      onAddMore: () {},
    );
    if (saved == true && mounted) {
      Navigator.pop(context);
    }
  }

  String _itemWord(int n) {
    if (n % 10 == 1 && n % 100 != 11) return 'продукт';
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)) return 'продукта';
    return 'продуктов';
  }
}
