import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';

class AddWaterDialog extends ConsumerStatefulWidget {
  const AddWaterDialog({super.key, required this.date});

  final DateTime date;

  static Future<bool?> show(BuildContext context, {required DateTime date}) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AddWaterDialog(date: date),
    );
  }

  @override
  ConsumerState<AddWaterDialog> createState() => _AddWaterDialogState();
}

class _AddWaterDialogState extends ConsumerState<AddWaterDialog> {
  final _customController = TextEditingController();
  int _selectedPreset = 250;
  bool _isCustom = false;
  bool _isLoading = false;

  final _presets = const [
    (150, '150 мл', 'Чашка', Icons.coffee_rounded),
    (250, '250 мл', 'Стакан', Icons.local_drink_rounded),
    (330, '330 мл', 'Банка', Icons.sports_bar_rounded),
    (500, '500 мл', 'Бутылка', Icons.water_drop_rounded),
  ];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    int amount;
    if (_isCustom) {
      final parsed = int.tryParse(_customController.text.trim());
      if (parsed == null || parsed <= 0 || parsed > 5000) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Укажите корректный объем (от 10 до 5000 мл)')),
        );
        return;
      }
      amount = parsed;
    } else {
      amount = _selectedPreset;
    }

    setState(() => _isLoading = true);
    try {
      final waterDao = ref.read(waterDaoProvider);
      await waterDao.addWater(widget.date, amount);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+$amount мл воды добавлено! 💧'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPresetCard((int, String, String, IconData) p, ThemeData theme) {
    final isSelected = !_isCustom && _selectedPreset == p.$1;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPreset = p.$1;
            _isCustom = false;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.water.withValues(alpha: 0.22)
                    : AppColors.waterLight)
                : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.water
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                p.$4,
                color: isSelected ? AppColors.water : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.$2,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? (isDark ? const Color(0xFF38BDF8) : AppColors.water)
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      p.$3,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.water.withValues(alpha: 0.22)
                  : AppColors.waterLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.water_drop_rounded, color: AppColors.water),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Записать воду'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите порцию или введите свой объем чистой воды:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),

            // Быстрые пресеты без GridView для стабильной компоновки в AlertDialog
            Row(
              children: [
                Expanded(child: _buildPresetCard(_presets[0], theme)),
                const SizedBox(width: 10),
                Expanded(child: _buildPresetCard(_presets[1], theme)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildPresetCard(_presets[2], theme)),
                const SizedBox(width: 10),
                Expanded(child: _buildPresetCard(_presets[3], theme)),
              ],
            ),
            const SizedBox(height: 16),

            // Свой объем
            InkWell(
              onTap: () {
                setState(() => _isCustom = true);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _isCustom
                      ? (isDark
                          ? AppColors.water.withValues(alpha: 0.22)
                          : AppColors.waterLight)
                      : theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isCustom
                        ? AppColors.water
                        : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                    width: _isCustom ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit_rounded, size: 20, color: AppColors.water),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _isCustom
                          ? TextField(
                              controller: _customController,
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: 'Введите объем',
                                suffixText: 'мл',
                                isDense: true,
                                border: InputBorder.none,
                              ),
                            )
                          : Text(
                              'Указать другой объем...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.water,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Добавить'),
        ),
      ],
    );
  }
}
