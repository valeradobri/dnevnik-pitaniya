import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';

/// Шторка быстрой записи калорий и БЖУ напрямую без выбора продукта
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({
    super.key,
    this.initialMealType,
    this.initialDate,
  });

  final String? initialMealType;
  final DateTime? initialDate;

  static Future<bool?> show(
    BuildContext context, {
    String? initialMealType,
    DateTime? initialDate,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddSheet(
        initialMealType: initialMealType,
        initialDate: initialDate,
      ),
    );
  }

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  final _notesController = TextEditingController();

  late String _selectedMealType;
  late DateTime _selectedDate;
  bool _isLoading = false;
  bool _showMacros = true;

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

    // Определение приёма пищи по умолчанию, если не задан
    if (widget.initialMealType != null) {
      _selectedMealType = widget.initialMealType!;
    } else {
      final hour = now.hour;
      if (hour >= 5 && hour < 11) {
        _selectedMealType = 'breakfast';
      } else if (hour >= 11 && hour < 16) {
        _selectedMealType = 'lunch';
      } else if (hour >= 16 && hour < 18) {
        _selectedMealType = 'snack';
      } else {
        _selectedMealType = 'dinner';
      }
    }

    _selectedDate = widget.initialDate ?? DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addCaloriePreset(int amount) {
    final current = double.tryParse(_caloriesController.text.replaceAll(',', '.')) ?? 0;
    final updated = (current + amount).round();
    _caloriesController.text = updated.toString();
    setState(() {});
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Сегодня';
    if (target == today.subtract(const Duration(days: 1))) return 'Вчера';
    if (target == today.add(const Duration(days: 1))) return 'Завтра';
    return DateFormat('d MMM', 'ru_RU').format(date);
  }

  Future<void> _submit() async {
    final calories = double.tryParse(_caloriesController.text.replaceAll(',', '.'));
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, укажите количество калорий')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final diaryDao = ref.read(diaryDaoProvider);
      final protein = double.tryParse(_proteinController.text.replaceAll(',', '.')) ?? 0.0;
      final fat = double.tryParse(_fatController.text.replaceAll(',', '.')) ?? 0.0;
      final carbs = double.tryParse(_carbsController.text.replaceAll(',', '.')) ?? 0.0;

      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : 'Быстрая запись (${calories.round()} ккал)';

      await diaryDao.insertQuickAddEntry(
        mealType: _selectedMealType,
        customName: name,
        calories: calories,
        protein: protein,
        fat: fat,
        carbs: carbs,
        date: _selectedDate,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context, true);
        final mealName = _mealTypes.firstWhere((m) => m.$1 == _selectedMealType).$2;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('«$name» записано в $mealName! ⚡'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final caloriesVal = double.tryParse(_caloriesController.text.replaceAll(',', '.')) ?? 0;
    final selectedMealName = _mealTypes.firstWhere((m) => m.$1 == _selectedMealType).$2;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEC4899)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Быстрая запись',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Ввод калорий и БЖУ без выбора продукта',
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),

            // Body
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                shrinkWrap: true,
                children: [
                  // ─── Выбор приёма пищи ───────────────────────────────────────
                  Text(
                    'Приём пищи:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _mealTypes.map((mt) {
                        final isSelected = _selectedMealType == mt.$1;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: isSelected,
                            label: Text(mt.$2),
                            avatar: Icon(mt.$3, size: 16, color: isSelected ? Colors.white : mt.$4),
                            onSelected: (val) {
                              if (val) setState(() => _selectedMealType = mt.$1);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ─── Выбор даты ──────────────────────────────────────────────
                  Row(
                    children: [
                      Text(
                        'Дата:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('Сегодня'),
                        selected: DateUtils.isSameDay(_selectedDate, today),
                        onSelected: (_) => setState(() => _selectedDate = today),
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('Вчера'),
                        selected: DateUtils.isSameDay(_selectedDate, yesterday),
                        onSelected: (_) => setState(() => _selectedDate = yesterday),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Icon(Icons.calendar_today_rounded, size: 14),
                        label: Text(_formatDateLabel(_selectedDate)),
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
                  const SizedBox(height: 16),

                  // ─── Главное поле: Калории ───────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF59E0B), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Калорийность (ккал) *',
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _caloriesController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.,]?\d{0,1}'))],
                          autofocus: true,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: '0',
                            suffixText: 'ккал',
                            suffixStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        // Быстрые кнопки пресетов (+50, +100, +250, +500)
                        Row(
                          children: [
                            _CaloriePresetChip(label: '+50', onTap: () => _addCaloriePreset(50)),
                            const SizedBox(width: 8),
                            _CaloriePresetChip(label: '+100', onTap: () => _addCaloriePreset(100)),
                            const SizedBox(width: 8),
                            _CaloriePresetChip(label: '+250', onTap: () => _addCaloriePreset(250)),
                            const SizedBox(width: 8),
                            _CaloriePresetChip(label: '+500', onTap: () => _addCaloriePreset(500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ─── Макронутриенты БЖУ (Опционально) ─────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'БЖУ (по желанию):',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _showMacros = !_showMacros),
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        child: Text(_showMacros ? 'Скрыть' : 'Показать'),
                      ),
                    ],
                  ),
                  if (_showMacros) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: _MacroInputField(
                            controller: _proteinController,
                            label: 'Белки',
                            color: AppColors.protein,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MacroInputField(
                            controller: _fatController,
                            label: 'Жиры',
                            color: AppColors.fat,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MacroInputField(
                            controller: _carbsController,
                            label: 'Углеводы',
                            color: AppColors.carbs,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),

                  // ─── Название / описание ─────────────────────────────────────
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Название блюда (необязательно)',
                      hintText: 'Бизнес-ланч, Капучино, Десерт...',
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ─── Заметка ─────────────────────────────────────────────────
                  TextField(
                    controller: _notesController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Заметка (необязательно)',
                      hintText: 'Например: в кафе с коллегами',
                      prefixIcon: const Icon(Icons.comment_outlined),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Кнопка подтверждения ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: (_isLoading || caloriesVal <= 0) ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded, size: 20),
                      label: Text(
                        caloriesVal > 0
                            ? 'Записать в $selectedMealName (${caloriesVal.round()} ккал)'
                            : 'Укажите калории',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
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

class _CaloriePresetChip extends StatelessWidget {
  const _CaloriePresetChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroInputField extends StatelessWidget {
  const _MacroInputField({
    required this.controller,
    required this.label,
    required this.color,
  });

  final TextEditingController controller;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.,]?\d{0,1}'))],
          decoration: InputDecoration(
            hintText: '0',
            suffixText: 'г',
            filled: true,
            fillColor: color.withValues(alpha: 0.08),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: color.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: color, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
