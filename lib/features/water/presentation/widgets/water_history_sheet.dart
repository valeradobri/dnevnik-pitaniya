import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'add_water_dialog.dart';

/// Модальный лист с историей выпитой воды за выбранный день
class WaterHistorySheet extends ConsumerWidget {
  const WaterHistorySheet({super.key, required this.date});

  final DateTime date;

  static Future<void> show(BuildContext context, {required DateTime date}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WaterHistorySheet(date: date),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final targetDate = DateTime(date.year, date.month, date.day);
    final entriesAsync = ref.watch(dateWaterEntriesProvider(targetDate));
    final profileAsync = ref.watch(userProfileProvider);
    final targetWater = profileAsync.value?.targetWaterMl ?? 2000;

    final dateStr = DateFormat('d MMMM yyyy', 'ru_RU').format(date);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
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

          // Заголовок
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.waterLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.water_drop_rounded, color: AppColors.water, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Журнал гидратации',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Добавить воду',
                onPressed: () {
                  Navigator.pop(context);
                  AddWaterDialog.show(context, date: date);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Список записей
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Ошибка загрузки: $err')),
              data: (entries) {
                final totalMl = entries.fold<int>(0, (sum, e) => sum + e.amountMl);
                final progress = targetWater > 0 ? (totalMl / targetWater).clamp(0.0, 1.0) : 0.0;

                return Column(
                  children: [
                    // Сводный прогресс-бар
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Всего за день: $totalMl мл',
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Цель: $targetWater мл (${(progress * 100).toInt()}%)',
                                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.water),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.water),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Список
                    Expanded(
                      child: entries.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.water_drop_outlined, size: 48, color: theme.colorScheme.outlineVariant),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Пока нет записей о воде за этот день',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: entries.length,
                              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                final timeStr = DateFormat('HH:mm').format(entry.timestamp);

                                IconData drinkIcon;
                                if (entry.amountMl <= 150) {
                                  drinkIcon = Icons.coffee_rounded;
                                } else if (entry.amountMl <= 350) {
                                  drinkIcon = Icons.local_drink_rounded;
                                } else {
                                  drinkIcon = Icons.water_drop_rounded;
                                }

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(drinkIcon, color: AppColors.water, size: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '+${entry.amountMl} мл',
                                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Время: $timeStr',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                                        tooltip: 'Удалить запись',
                                        onPressed: () async {
                                          final waterDao = ref.read(waterDaoProvider);
                                          await waterDao.deleteWaterEntry(entry.id);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Запись ${entry.amountMl} мл удалена'),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Быстрые кнопки добавления
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final waterDao = ref.read(waterDaoProvider);
                    await waterDao.addWater(targetDate, 150);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+150 мл'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final waterDao = ref.read(waterDaoProvider);
                    await waterDao.addWater(targetDate, 250);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+250 мл'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final waterDao = ref.read(waterDaoProvider);
                    await waterDao.addWater(targetDate, 500);
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('+500 мл'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
