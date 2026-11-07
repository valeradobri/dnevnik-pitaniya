import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';

/// Диалог копирования рациона всего дня
class CopyDayDialog extends ConsumerStatefulWidget {
  const CopyDayDialog({
    super.key,
    required this.sourceDate,
    required this.entriesCount,
    required this.totalCalories,
  });

  final DateTime sourceDate;
  final int entriesCount;
  final double totalCalories;

  static Future<bool?> show(
    BuildContext context, {
    required DateTime sourceDate,
    required int entriesCount,
    required double totalCalories,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => CopyDayDialog(
        sourceDate: sourceDate,
        entriesCount: entriesCount,
        totalCalories: totalCalories,
      ),
    );
  }

  @override
  ConsumerState<CopyDayDialog> createState() => _CopyDayDialogState();
}

class _CopyDayDialogState extends ConsumerState<CopyDayDialog> {
  late DateTime _targetDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _targetDate = widget.sourceDate.add(const Duration(days: 1));
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Сегодня';
    if (target == today.add(const Duration(days: 1))) return 'Завтра';
    if (target == today.subtract(const Duration(days: 1))) return 'Вчера';
    return DateFormat('d MMMM', 'ru_RU').format(date);
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final diaryDao = ref.read(diaryDaoProvider);
      final count = await diaryDao.copyDay(
        sourceDate: widget.sourceDate,
        targetDate: _targetDate,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        final dateStr = DateFormat('d MMMM', 'ru_RU').format(_targetDate);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Весь день скопирован на $dateStr ($count блюд)'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка копирования дня: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceDateStr = DateFormat('d MMMM', 'ru_RU').format(widget.sourceDate);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.date_range_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Скопировать весь день',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Рацион за $sourceDateStr (${widget.entriesCount} блюд · ${widget.totalCalories.round()} ккал)',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            Text('На какую дату продублировать:', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Завтра'),
                    selected: DateUtils.isSameDay(_targetDate, tomorrow),
                    onSelected: (_) => setState(() => _targetDate = tomorrow),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('Сегодня'),
                    selected: DateUtils.isSameDay(_targetDate, today),
                    onSelected: (_) => setState(() => _targetDate = today),
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('+2 дня'),
                    selected: DateUtils.isSameDay(_targetDate, dayAfterTomorrow),
                    onSelected: (_) => setState(() => _targetDate = dayAfterTomorrow),
                  ),
                  const SizedBox(width: 6),
                  ActionChip(
                    avatar: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text(_formatDateLabel(_targetDate)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _targetDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        setState(() => _targetDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Скопировать день'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
