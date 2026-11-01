import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../../data/open_food_facts_client.dart';
import 'serving_size_sheet.dart';
import 'create_food_dialog.dart';
import '../screens/barcode_scanner_screen.dart';

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

  final _categories = const [
    ('all', 'Все'),
    ('favorites', '★ Избранное'),
    ('grains', 'Крупы'),
    ('meat', 'Мясо и птица'),
    ('fish', 'Рыба'),
    ('dairy', 'Молочные'),
    ('vegetables', 'Овощи'),
    ('fruits', 'Фрукты'),
    ('nuts', 'Орехи'),
    ('drinks', 'Напитки'),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Выбор продукта',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
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

          // Горизонтальные чипы категорий
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
                return ChoiceChip(
                  label: Text(cat.$2),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat.$1);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Список продуктов
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
                                  Text(
                                    'Б: ${item.protein.toStringAsFixed(1)} · Ж: ${item.fat.toStringAsFixed(1)} · У: ${item.carbs.toStringAsFixed(1)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 11,
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
                          Text(
                            'Б: ${item.proteinPer100g.toStringAsFixed(1)} · Ж: ${item.fatPer100g.toStringAsFixed(1)} · У: ${item.carbsPer100g.toStringAsFixed(1)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
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
                        final added = await ServingSizeSheet.show(
                          context,
                          product: item,
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
        ],
      ),
    );
  }
}
