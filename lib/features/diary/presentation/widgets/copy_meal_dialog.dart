import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';

/// Модальный диалог копирования приёма пищи в другую дату или приём
class CopyMealDialog extends ConsumerStatefulWidget {
  const CopyMealDialog({
    super.key,
    required this.sourceDate,
    required this.sourceMealType,
    required this.entries,
  });

  final DateTime sourceDate;
  final String sourceMealType;
  final List<DiaryEntry> entries;

  static Future<bool?> show(
    BuildContext context, {
    required DateTime sourceDate,
    required String sourceMealType,
    required List<DiaryEntry> entries,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => CopyMealDialog(
        sourceDate: sourceDate,
        sourceMealType: sourceMealType,
        entries: entries,
      ),
    );
  }

  @override
  ConsumerState<CopyMealDialog> createState() => _CopyMealDialogState();
}

class _CopyMealDialogState extends ConsumerState<CopyMealDialog> {
  late DateTime _targetDate;
  late String _targetMealType;
  bool _isLoading = false;

  final _mealTypes = const [
    ('breakfast', 'Завтрак', Icons.wb_sunny_rounded, Color(0xFFF59E0B)),
    ('lunch', 'Обед', Icons.wb_cloudy_rounded, Color(0xFF0EA5E9)),
    ('dinner', 'Ужин', Icons.nights_stay_rounded, Color(0xFF6366F1)),
    ('snack', 'Перекус', Icons.cookie_rounded, Color(0xFF10B981)),
  ];

  @override
  void initState() {
    super.initState();
    // По умолчанию предлагаем завтрашний день в тот же приём пищи
    _targetDate = widget.sourceDate.add(const Duration(days: 1));
    _targetMealType = widget.sourceMealType;
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Сегодня';
    if (target == today.add(const Duration(days: 1))) return 'Завтра';
    if (target == today.subtract(const Duration(days: 1))) return 'Вчера';
    return DateFormat('d MMM', 'ru_RU').format(date);
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);

    try {
      final diaryDao = ref.read(diaryDaoProvider);
      final count = await diaryDao.copyEntries(
        entries: widget.entries,
        targetDate: _targetDate,
        targetMealType: _targetMealType,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        final mealName = _mealTypes.firstWhere((m) => m.$1 == _targetMealType).$2;
        final dateStr = DateFormat('d MMMM', 'ru_RU').format(_targetDate);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Скопировано в $mealName на $dateStr ($count прод.)'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка копирования: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalCals = widget.entries.fold<double>(0, (s, e) => s + e.calculatedCalories);
    final sourceMealName = _mealTypes.firstWhere((m) => m.$1 == widget.sourceMealType).$2;

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
            // Заголовок
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.copy_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Скопировать $sourceMealName',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.entries.length} прод. · ${totalCals.round()} ккал',
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

            // Выбор даты
            Text('Куда скопировать (дата):', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _DateChip(
                    label: 'Завтра',
                    isSelected: DateUtils.isSameDay(_targetDate, tomorrow),
                    onTap: () => setState(() => _targetDate = tomorrow),
                  ),
                  const SizedBox(width: 6),
                  _DateChip(
                    label: 'Сегодня',
                    isSelected: DateUtils.isSameDay(_targetDate, today),
                    onTap: () => setState(() => _targetDate = today),
                  ),
                  const SizedBox(width: 6),
                  _DateChip(
                    label: '+2 дня',
                    isSelected: DateUtils.isSameDay(_targetDate, dayAfterTomorrow),
                    onTap: () => setState(() => _targetDate = dayAfterTomorrow),
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
            const SizedBox(height: 16),

            // Выбор приёма пищи
            Text('Приём пищи:', style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _mealTypes.map((mt) {
                final isSelected = _targetMealType == mt.$1;
                return ChoiceChip(
                  selected: isSelected,
                  avatar: Icon(mt.$3, size: 16, color: isSelected ? Colors.white : mt.$4),
                  label: Text(mt.$2),
                  onSelected: (val) {
                    if (val) setState(() => _targetMealType = mt.$1);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Кнопки действий
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
                  label: const Text('Скопировать'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}
