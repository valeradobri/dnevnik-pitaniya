import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/models/recipe_model.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final int recipeId;

  static Route<void> route(int recipeId) {
    return MaterialPageRoute(
      builder: (ctx) => RecipeDetailScreen(recipeId: recipeId),
    );
  }

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  int _currentServings = 1;
  bool _initializedServings = false;
  String _selectedMealType = 'lunch';

  final _mealTypes = const [
    ('breakfast', 'Завтрак', Icons.wb_sunny_outlined),
    ('lunch', 'Обед', Icons.wb_cloudy_outlined),
    ('dinner', 'Ужин', Icons.nights_stay_outlined),
    ('snack', 'Перекус', Icons.cookie_outlined),
  ];

  Future<void> _addPortionToDiary(RecipeWithDetails details) async {
    final theme = Theme.of(context);
    final diaryDao = ref.read(diaryDaoProvider);
    final nutrients = details.nutrientsForServings(_currentServings);
    final scaledGrams = details.gramsPerServing * _currentServings;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
              const SizedBox(height: 16),
              Text(
                'Добавить в дневник',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '${details.recipe.name} · $_currentServings ${_servingWord(_currentServings)} (${nutrients.calories.round()} ккал)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              Text('Выберите приём пищи:', style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _mealTypes.map((m) {
                    final isSelected = _selectedMealType == m.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: isSelected,
                        label: Text(m.$2),
                        avatar: Icon(m.$3, size: 16),
                        onSelected: (selected) {
                          if (selected) {
                            setSheetState(() => _selectedMealType = m.$1);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Записать в дневник', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);

      // В качестве foodProductId берем первый ингредиент или 1
      final foodId = details.ingredients.isNotEmpty ? details.ingredients.first.product.id : 1;

      await diaryDao.insertEntry(
        DiaryEntriesCompanion.insert(
          mealType: _selectedMealType,
          foodProductId: foodId,
          customName: '${details.recipe.name} ($_currentServings порц.)',
          grams: scaledGrams,
          calculatedCalories: nutrients.calories,
          calculatedProtein: nutrients.protein,
          calculatedFat: nutrients.fat,
          calculatedCarbs: nutrients.carbs,
          entryDate: dateOnly,
          timestamp: drift.Value(DateTime.now()),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${details.recipe.name} добавлен в $_selectedMealType! 🍲'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _servingWord(int n) {
    if (n == 1) return 'порция';
    if (n >= 2 && n <= 4) return 'порции';
    return 'порций';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipeDao = ref.watch(recipeDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Рецепт'),
        actions: [
          StreamBuilder<RecipeWithDetails?>(
            stream: recipeDao.watchRecipeWithDetails(widget.recipeId),
            builder: (context, snapshot) {
              final r = snapshot.data?.recipe;
              if (r == null) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  r.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: r.isFavorite ? const Color(0xFFF59E0B) : theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => recipeDao.toggleFavorite(r.id, !r.isFavorite),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<RecipeWithDetails?>(
        stream: recipeDao.watchRecipeWithDetails(widget.recipeId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final details = snapshot.data;
          if (details == null) {
            return const Center(child: Text('Рецепт не найден'));
          }

          if (!_initializedServings) {
            _currentServings = details.recipe.servings > 0 ? details.recipe.servings : 1;
            _initializedServings = true;
          }

          final nutrients = details.nutrientsForServings(_currentServings);
          final r = details.recipe;

          final (intro, steps) = _parseDescription(r.description);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Шапка рецепта
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                        theme.colorScheme.surfaceContainerLowest,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                  '${r.prepTimeMinutes} мин',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _categoryName(r.category),
                              style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        r.name,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (intro.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          intro,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Интерактивный переключатель порций
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Количество порций',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded),
                            onPressed: _currentServings > 1
                                ? () => setState(() => _currentServings--)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '$_currentServings',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded),
                            onPressed: _currentServings < 12
                                ? () => setState(() => _currentServings++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // КБЖУ для выбранных порций
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Пищевая ценность (на $_currentServings ${_servingWord(_currentServings)}):'),
                          Text(
                            '${nutrients.calories.round()} ккал',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MacroStat(label: 'Белки', grams: nutrients.protein, color: AppColors.protein),
                          _MacroStat(label: 'Жиры', grams: nutrients.fat, color: AppColors.fat),
                          _MacroStat(label: 'Углеводы', grams: nutrients.carbs, color: AppColors.carbs),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Список ингредиентов
                Text(
                  'Ингредиенты',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: details.ingredients.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = details.ingredients[index];
                    final scaledGrams = item.getGramsForServings(
                      details.recipe.servings,
                      _currentServings,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (item.ingredient.notes != null && item.ingredient.notes!.isNotEmpty)
                                  Text(
                                    item.ingredient.notes!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '${scaledGrams.round()} г',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (steps.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Text(
                    'Шаги приготовления',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: steps.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final stepText = steps[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                stepText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 32),

                // Кнопка добавления в дневник
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => _addPortionToDiary(details),
                    icon: const Icon(Icons.add_task_rounded),
                    label: Text(
                      'Добавить в дневник ($_currentServings ${_servingWord(_currentServings)})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  (String, List<String>) _parseDescription(String? text) {
    if (text == null || text.trim().isEmpty) return ('', const []);

    const marker = 'Шаги приготовления:';
    if (text.contains(marker)) {
      final parts = text.split(marker);
      final intro = parts[0].trim();
      final stepsPart = parts.length > 1 ? parts[1].trim() : '';

      final steps = stepsPart
          .split(RegExp(r'\n+'))
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .map((line) => line.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), ''))
          .toList();
      return (intro, steps);
    }

    final lines = text.split('\n');
    final hasNumberedSteps = lines.any((l) => RegExp(r'^\d+[\.\)]\s+').hasMatch(l.trim()));
    if (hasNumberedSteps) {
      final introList = <String>[];
      final stepsList = <String>[];
      for (final line in lines) {
        final trimmed = line.trim();
        if (RegExp(r'^\d+[\.\)]\s+').hasMatch(trimmed)) {
          stepsList.add(trimmed.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), ''));
        } else if (stepsList.isEmpty && trimmed.isNotEmpty) {
          introList.add(trimmed);
        }
      }
      return (introList.join('\n'), stepsList);
    }

    return (text.trim(), const []);
  }

  String _categoryName(String cat) {
    switch (cat) {
      case 'breakfast':
        return 'Завтрак';
      case 'lunch':
        return 'Обед';
      case 'dinner':
        return 'Ужин';
      case 'snack':
        return 'Перекус';
      default:
        return 'Блюдо';
    }
  }
}

class _MacroStat extends StatelessWidget {
  const _MacroStat({
    required this.label,
    required this.grams,
    required this.color,
  });

  final String label;
  final double grams;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          '${grams.toStringAsFixed(1)} г',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
