import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/meal_plan_dao.dart';
import '../../../recipes/presentation/screens/recipe_detail_screen.dart';

class MealPlannerView extends ConsumerStatefulWidget {
  const MealPlannerView({super.key});

  @override
  ConsumerState<MealPlannerView> createState() => _MealPlannerViewState();
}

class _MealPlannerViewState extends ConsumerState<MealPlannerView> {
  int _tabIndex = 0; // 0 = Календарь, 1 = Список покупок
  late DateTime _weekStart;
  int _selectedDayOffset = 0; // 0 = Пн, 6 = Вс
  bool _onlyFromToday = false; // Фильтр: false = вся неделя, true = только с сегодняшнего дня
  final Set<int> _boughtFoodIds = {};

  final _days = const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  final _mealTypes = const [
    ('breakfast', 'Завтрак', Icons.wb_sunny_rounded, Color(0xFFF59E0B)),
    ('lunch', 'Обед', Icons.wb_cloudy_rounded, Color(0xFF0EA5E9)),
    ('dinner', 'Ужин', Icons.nights_stay_rounded, Color(0xFF6366F1)),
    ('snack', 'Перекус', Icons.cookie_rounded, Color(0xFF10B981)),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day);
    _weekStart = d.subtract(Duration(days: d.weekday - 1));
    _selectedDayOffset = now.weekday - 1;
  }

  void _prevWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  Future<void> _addMealDialog(String mealType, DateTime plannedDate) async {
    final recipeDao = ref.read(recipeDaoProvider);
    final mealPlanDao = ref.read(mealPlanDaoProvider);
    final allRecipes = await recipeDao.watchAllRecipes().first;

    if (!mounted) return;

    final noteController = TextEditingController();
    Recipe? chosenRecipe;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Запланировать на ${_formatMealTypeName(mealType)}',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Заметка или выбор рецепта
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'Своё блюдо или заметка',
                    hintText: 'Например, Ресторан / Пицца с друзьями',
                    filled: true,
                    fillColor: Theme.of(ctx).colorScheme.surfaceContainerLowest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Или выберите рецепт из книги:', style: Theme.of(ctx).textTheme.titleSmall),
                const SizedBox(height: 8),

                Expanded(
                  child: ListView.separated(
                    itemCount: allRecipes.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final r = allRecipes[i];
                      final isSelected = chosenRecipe?.id == r.id;
                      return ListTile(
                        selected: isSelected,
                        title: Text(r.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        subtitle: Text('${r.prepTimeMinutes} мин · ${r.servings} порц.'),
                        trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)) : null,
                        onTap: () {
                          setSheetState(() => chosenRecipe = r);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () async {
                      final plan = await mealPlanDao.getOrCreatePlanForWeek(_weekStart);
                      await mealPlanDao.addPlanItem(
                        mealPlanId: plan.id,
                        recipeId: chosenRecipe?.id,
                        plannedDate: plannedDate,
                        mealType: mealType,
                        customNote: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Запланировать', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatMealTypeName(String m) {
    switch (m) {
      case 'breakfast':
        return 'Завтрак';
      case 'lunch':
        return 'Обед';
      case 'dinner':
        return 'Ужин';
      case 'snack':
        return 'Перекус';
      default:
        return 'Приём пищи';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealPlanDao = ref.watch(mealPlanDaoProvider);

    final weekEnd = _weekStart.add(const Duration(days: 6));
    final weekTitle = '${DateFormat('d MMM', 'ru_RU').format(_weekStart)} — ${DateFormat('d MMM', 'ru_RU').format(weekEnd)}';

    return Column(
      children: [
        // Переключатель «План на неделю» / «Список покупок»
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                icon: Icon(Icons.calendar_view_week_rounded),
                label: Text('План недели'),
              ),
              ButtonSegment(
                value: 1,
                icon: Icon(Icons.shopping_cart_outlined),
                label: Text('Список покупок'),
              ),
            ],
            selected: {_tabIndex},
            onSelectionChanged: (val) => setState(() => _tabIndex = val.first),
          ),
        ),

        // Навигатор по неделям
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left_rounded), onPressed: _prevWeek),
              Text(
                weekTitle,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(icon: const Icon(Icons.chevron_right_rounded), onPressed: _nextWeek),
            ],
          ),
        ),

        if (_tabIndex == 0) ...[
          // Дни недели (Пн-Вс чипы)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(7, (index) {
                final isSelected = _selectedDayOffset == index;
                final dayDate = _weekStart.add(Duration(days: index));
                final isToday = DateTime.now().day == dayDate.day &&
                    DateTime.now().month == dayDate.month &&
                    DateTime.now().year == dayDate.year;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDayOffset = index),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : isToday
                                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                                  : theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _days[index],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${dayDate.day}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          // Сетка приемов пищи выбранного дня
          Expanded(
            child: StreamBuilder<List<MealPlanItemWithRecipe>>(
              stream: mealPlanDao.watchPlanItemsForWeek(_weekStart),
              builder: (context, snapshot) {
                final allItems = snapshot.data ?? [];
                final activeDate = _weekStart.add(Duration(days: _selectedDayOffset));

                final dayItems = allItems.where((i) {
                  final p = i.item.plannedDate;
                  return p.year == activeDate.year && p.month == activeDate.month && p.day == activeDate.day;
                }).toList();

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  children: _mealTypes.map((mt) {
                    final slotItems = dayItems.where((i) => i.item.mealType == mt.$1).toList();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: mt.$4.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(mt.$3, color: mt.$4, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  mt.$2,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_rounded),
                                color: theme.colorScheme.primary,
                                onPressed: () => _addMealDialog(mt.$1, activeDate),
                              ),
                            ],
                          ),
                          if (slotItems.isNotEmpty) ...[
                            const Divider(height: 16),
                            ...slotItems.map((item) {
                              final recipe = item.recipeDetails;
                              final title = recipe?.recipe.name ?? item.item.customNote ?? 'Блюдо';

                              return Dismissible(
                                key: ValueKey('meal_plan_${item.item.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    color: theme.colorScheme.onErrorContainer,
                                  ),
                                ),
                                onDismissed: (_) => mealPlanDao.deletePlanItem(item.item.id),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: recipe != null
                                              ? () => Navigator.push(
                                                    context,
                                                    RecipeDetailScreen.route(recipe.recipe.id),
                                                  )
                                              : null,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                              ),
                                              if (recipe != null)
                                                Text(
                                                  '${recipe.nutrientsPerServing.calories.round()} ккал на порцию',
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded, size: 18),
                                        color: theme.colorScheme.onSurfaceVariant,
                                        onPressed: () => mealPlanDao.deletePlanItem(item.item.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ] else ...[
                            const SizedBox(height: 6),
                            Text(
                              'Ничего не запланировано',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ] else ...[
          // Вкладка «Список покупок»
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Center(
              child: SegmentedButton<bool>(
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: const [
                  ButtonSegment<bool>(
                    value: false,
                    icon: Icon(Icons.date_range_rounded, size: 16),
                    label: Text('Вся неделя', style: TextStyle(fontSize: 13)),
                  ),
                  ButtonSegment<bool>(
                    value: true,
                    icon: Icon(Icons.today_rounded, size: 16),
                    label: Text('С сегодняшнего дня', style: TextStyle(fontSize: 13)),
                  ),
                ],
                selected: {_onlyFromToday},
                onSelectionChanged: (val) => setState(() => _onlyFromToday = val.first),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ShoppingItem>>(
              stream: mealPlanDao.watchShoppingList(_weekStart, onlyFromToday: _onlyFromToday),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final shoppingList = snapshot.data!;

                if (shoppingList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text('Список покупок пуст', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(
                            _onlyFromToday
                                ? 'Начиная с сегодняшнего дня рецептов в плане нет. Переключите на «Вся неделя» или добавьте блюда в календаре!'
                                : 'Запланируйте рецепты в календаре недели — и список необходимых продуктов с точным весом сформируется автоматически!',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: shoppingList.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = shoppingList[index];
                    final isChecked = _boughtFoodIds.contains(item.foodId);

                    return CheckboxListTile(
                      value: isChecked,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _boughtFoodIds.add(item.foodId);
                          } else {
                            _boughtFoodIds.remove(item.foodId);
                          }
                        });
                      },
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked ? theme.colorScheme.onSurfaceVariant : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text('Категория: ${item.category}'),
                      secondary: Text(
                        '${item.totalGrams.round()} г',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isChecked ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.primary,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
