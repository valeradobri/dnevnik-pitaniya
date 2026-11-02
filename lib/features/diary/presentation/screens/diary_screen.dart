import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/nutri_card.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../food_database/presentation/widgets/food_search_sheet.dart';
import '../../../nutrition_suggestions/presentation/widgets/meal_suggestions_sheet.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
    });
  }

  void _goToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  String _formatDateTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return 'Сегодня, ${DateFormat('d MMMM', 'ru_RU').format(date)}';
    } else if (target == yesterday) {
      return 'Вчера, ${DateFormat('d MMMM', 'ru_RU').format(date)}';
    } else if (target == tomorrow) {
      return 'Завтра, ${DateFormat('d MMMM', 'ru_RU').format(date)}';
    }
    return DateFormat('EEEE, d MMMM', 'ru_RU').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(dateDiaryEntriesProvider(_selectedDate));
    final totalsAsync = ref.watch(dateTotalsProvider(_selectedDate));
    final profileAsync = ref.watch(userProfileProvider);

    final entries = entriesAsync.value ?? [];
    final totals = totalsAsync.value ?? DayTotals.zero;
    final profile = profileAsync.value;
    final targetCals = profile?.targetCalories ?? 2000;

    final now = DateTime.now();
    final isToday = DateTime(now.year, now.month, now.day) == _selectedDate;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Дневник питания'),
        centerTitle: false,
        actions: [
          if (!isToday)
            TextButton.icon(
              onPressed: _goToday,
              icon: const Icon(Icons.today_rounded, size: 18),
              label: const Text('Сегодня'),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Выбрать дату',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                locale: const Locale('ru', 'RU'),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Панель переключения дат ──────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 28),
                    onPressed: _previousDay,
                    tooltip: 'Предыдущий день',
                  ),
                  Expanded(
                    child: Text(
                      _formatDateTitle(_selectedDate),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 28),
                    onPressed: _nextDay,
                    tooltip: 'Следующий день',
                  ),
                ],
              ),
            ),

            // ── Сводка за день ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: theme.colorScheme.surfaceContainerLowest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${totals.calories.round()} / $targetCals ккал',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Съедено за день',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _MacroPill(label: 'Б', value: totals.protein, color: AppColors.protein),
                      const SizedBox(width: 8),
                      _MacroPill(label: 'Ж', value: totals.fat, color: AppColors.fat),
                      const SizedBox(width: 8),
                      _MacroPill(label: 'У', value: totals.carbs, color: AppColors.carbs),
                    ],
                  ),
                ],
              ),
            ),

            // ── Список секций приемов пищи ────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                children: [
                  // ── Кнопка «Что скушать в пределах нормы?» ──────────
                  InkWell(
                    onTap: () => MealSuggestionsSheet.show(context, date: _selectedDate),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF059669).withValues(alpha: 0.3) : const Color(0xFFA7F3D0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF059669), size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Не знаете, что съесть? Подобрать под остаток БЖУ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFD1FAE5) : const Color(0xFF065F46),
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF059669), size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _DiaryMealSection(
                    title: 'Завтрак',
                    icon: Icons.wb_sunny_rounded,
                    color: const Color(0xFFF59E0B),
                    mealType: 'breakfast',
                    date: _selectedDate,
                    entries: entries.where((e) => e.mealType == 'breakfast').toList(),
                  ),
                  const SizedBox(height: 12),
                  _DiaryMealSection(
                    title: 'Обед',
                    icon: Icons.wb_cloudy_rounded,
                    color: const Color(0xFF0EA5E9),
                    mealType: 'lunch',
                    date: _selectedDate,
                    entries: entries.where((e) => e.mealType == 'lunch').toList(),
                  ),
                  const SizedBox(height: 12),
                  _DiaryMealSection(
                    title: 'Ужин',
                    icon: Icons.nights_stay_rounded,
                    color: const Color(0xFF6366F1),
                    mealType: 'dinner',
                    date: _selectedDate,
                    entries: entries.where((e) => e.mealType == 'dinner').toList(),
                  ),
                  const SizedBox(height: 12),
                  _DiaryMealSection(
                    title: 'Перекус',
                    icon: Icons.cookie_rounded,
                    color: const Color(0xFF10B981),
                    mealType: 'snack',
                    date: _selectedDate,
                    entries: entries.where((e) => e.mealType == 'snack').toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${value.round()}г',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DiaryMealSection extends ConsumerWidget {
  const _DiaryMealSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.mealType,
    required this.date,
    required this.entries,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String mealType;
  final DateTime date;
  final List<DiaryEntry> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final totalCalories = entries.fold<double>(0, (sum, e) => sum + e.calculatedCalories);
    final diaryDao = ref.read(diaryDaoProvider);

    return NutriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${totalCalories.round()} ккал',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: () => FoodSearchSheet.show(
                  context,
                  mealType: mealType,
                  date: date,
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Добавить'),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          if (entries.isNotEmpty) ...[
            const Divider(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (ctx, i) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final entry = entries[index];

                return Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                  ),
                  onDismissed: (_) async {
                    await diaryDao.deleteEntry(entry.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${entry.customName} удален'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.customName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${entry.grams.toInt()} г  ·  Б: ${entry.calculatedProtein.toStringAsFixed(1)} · Ж: ${entry.calculatedFat.toStringAsFixed(1)} · У: ${entry.calculatedCarbs.toStringAsFixed(1)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                entry.notes!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        '${entry.calculatedCalories.round()} ккал',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: theme.colorScheme.onSurfaceVariant,
                        tooltip: 'Удалить',
                        onPressed: () async {
                          await diaryDao.deleteEntry(entry.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else ...[
            const SizedBox(height: 10),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Ничего не добавлено',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
