import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../screens/recipe_detail_screen.dart';
import '../screens/create_recipe_screen.dart';
import '../screens/import_recipe_screen.dart';
import '../../../../core/widgets/filter_pill.dart';

class RecipesCatalogView extends ConsumerStatefulWidget {
  const RecipesCatalogView({super.key});

  @override
  ConsumerState<RecipesCatalogView> createState() => _RecipesCatalogViewState();
}

class _RecipesCatalogViewState extends ConsumerState<RecipesCatalogView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _query = '';

  final List<(String, String, IconData?)> _categories = const [
    ('all', 'Все', null),
    ('favorites', 'Избранное', Icons.star_rounded),
    ('breakfast', 'Завтраки', null),
    ('soup', 'Супы', null),
    ('lunch', 'Обеды', null),
    ('dinner', 'Ужины', null),
    ('salad', 'Салаты', null),
    ('snack', 'Перекусы', null),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipeDao = ref.watch(recipeDaoProvider);

    return Column(
      children: [
        // Поиск и кнопки импорта / создания
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Поиск рецептов...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
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
              const SizedBox(width: 8),
              Tooltip(
                message: 'Импортировать по ссылке',
                child: FilledButton.tonal(
                  onPressed: () => Navigator.push(context, ImportRecipeScreen.route()),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  child: const Icon(Icons.link_rounded, size: 22),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Создать рецепт',
                child: FilledButton.tonal(
                  onPressed: () => Navigator.push(context, CreateRecipeScreen.route()),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  child: const Icon(Icons.add_rounded, size: 22),
                ),
              ),
            ],
          ),
        ),

        // Плашки категорий
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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

        // Список карточек рецептов
        Expanded(
          child: StreamBuilder<List<Recipe>>(
            stream: recipeDao.watchAllRecipes(
              category: _selectedCategory == 'favorites' || _selectedCategory == 'all'
                  ? null
                  : _selectedCategory,
              onlyFavorites: _selectedCategory == 'favorites' ? true : null,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var list = snapshot.data!;
              if (_query.isNotEmpty) {
                list = list
                    .where((r) =>
                        r.name.toLowerCase().contains(_query) ||
                        (r.description?.toLowerCase().contains(_query) ?? false))
                    .toList();
              }

              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.restaurant_rounded,
                        size: 56,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text('Рецепты не найдены', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        'Попробуйте другой фильтр или создайте свой рецепт',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                itemCount: list.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final recipe = list[index];

                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      RecipeDetailScreen.route(recipe.id),
                    ),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.timer_outlined, size: 14, color: theme.colorScheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${recipe.prepTimeMinutes} мин',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${recipe.servings} ${_servingsWord(recipe.servings)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: Icon(
                                  recipe.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: recipe.isFavorite
                                      ? const Color(0xFFF59E0B)
                                      : theme.colorScheme.outlineVariant,
                                ),
                                onPressed: () => recipeDao.toggleFavorite(recipe.id, !recipe.isFavorite),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            recipe.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (recipe.description != null && recipe.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              recipe.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _servingsWord(int n) {
    if (n == 1) return 'порция';
    if (n >= 2 && n <= 4) return 'порции';
    return 'порций';
  }
}
