import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/backup_data.dart';
import '../providers/backup_providers.dart';

/// Экран резервного копирования, экспорта в Excel и восстановления данных
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _isLoading = false;
  String? _loadingMessage;

  void _setLoading(bool loading, [String? message]) {
    setState(() {
      _isLoading = loading;
      _loadingMessage = message;
    });
  }

  Future<void> _handleExportJson() async {
    final backupService = ref.read(backupServiceProvider);
    _setLoading(true, 'Формирование резервной копии...');
    try {
      final jsonContent = await backupService.exportToJson();
      final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final fileName = 'dnevnik_backup_$timestamp.json';

      await backupService.shareContent(
        content: jsonContent,
        fileName: fileName,
        subject: 'Резервная копия «Дневник питания» ($timestamp)',
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Ошибка при создании бэкапа: $e');
      }
    } finally {
      if (mounted) _setLoading(false);
    }
  }

  Future<void> _handleExportDiaryCsv() async {
    final backupService = ref.read(backupServiceProvider);
    _setLoading(true, 'Экспорт дневника питания...');
    try {
      final csvContent = await backupService.exportDiaryToCsv();
      final timestamp = DateFormat('yyyyMMdd').format(DateTime.now());
      final fileName = 'dnevnik_diary_$timestamp.csv';

      await backupService.shareContent(
        content: csvContent,
        fileName: fileName,
        subject: 'История питания Дневник ($timestamp)',
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Ошибка при экспорте дневника: $e');
      }
    } finally {
      if (mounted) _setLoading(false);
    }
  }

  Future<void> _handleExportWeightCsv() async {
    final backupService = ref.read(backupServiceProvider);
    _setLoading(true, 'Экспорт истории веса...');
    try {
      final csvContent = await backupService.exportWeightToCsv();
      final timestamp = DateFormat('yyyyMMdd').format(DateTime.now());
      final fileName = 'dnevnik_weight_$timestamp.csv';

      await backupService.shareContent(
        content: csvContent,
        fileName: fileName,
        subject: 'История взвешиваний Дневник ($timestamp)',
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Ошибка при экспорте веса: $e');
      }
    } finally {
      if (mounted) _setLoading(false);
    }
  }

  Future<void> _handleRestore() async {
    final backupService = ref.read(backupServiceProvider);
    try {
      final jsonContent = await backupService.pickBackupFile();
      if (jsonContent == null || !mounted) return;

      _setLoading(true, 'Проверка файла резервной копии...');
      BackupData backup;
      try {
        backup = backupService.parseBackupJson(jsonContent);
      } catch (e) {
        _setLoading(false);
        _showErrorSnackBar('Не удалось прочитать файл: $e');
        return;
      }
      _setLoading(false);

      if (!mounted) return;
      final summary = backup.summary;

      // Показ диалога подтверждения с деталями бэкапа
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          bool clearExisting = false;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final theme = Theme.of(context);
              return AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.restore_page_outlined, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Восстановление данных'),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'В выбранном файле найдено:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _PreviewRow(
                        icon: Icons.person_outline,
                        label: 'Профиль: ${summary.profileName ?? "Не указан"}',
                      ),
                      _PreviewRow(
                        icon: Icons.restaurant_outlined,
                        label: 'Записей дневника: ${summary.diaryCount}',
                      ),
                      _PreviewRow(
                        icon: Icons.water_drop_outlined,
                        label: 'Записей воды: ${summary.waterCount}',
                      ),
                      _PreviewRow(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Взвешиваний: ${summary.weightCount}',
                      ),
                      _PreviewRow(
                        icon: Icons.menu_book_outlined,
                        label: 'Рецептов: ${summary.recipesCount}',
                      ),
                      _PreviewRow(
                        icon: Icons.fastfood_outlined,
                        label: 'Своих продуктов: ${summary.customFoodsCount}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Дата экспорта: ${DateFormat('dd.MM.yyyy HH:mm').format(summary.exportedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Divider(height: 24),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Заменить текущие данные'),
                        subtitle: const Text(
                          'Удалить текущие записи перед восстановлением. Если выключено — данные объединятся.',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: clearExisting,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) {
                          setDialogState(() => clearExisting = val);
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Отмена'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, clearExisting),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Восстановить'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (confirmed != null && mounted) {
        _setLoading(true, 'Восстановление базы данных...');
        await backupService.restoreBackup(backup, clearExisting: confirmed);
        _setLoading(false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Данные успешно восстановлены! 🎉'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Ошибка восстановления: $e');
      }
    } finally {
      if (mounted) _setLoading(false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Резервная копия и экспорт'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              // ── Информационный баннер Local-First ─────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primary.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '100% приватность данных',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Все ваши записи хранятся исключительно в памяти вашего смартфона. Экспорт позволяет сохранить файл бэкапа в Telegram, Google Drive или на флешку и восстановить всё в один клик.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── СЕКЦИЯ 1: Полный бэкап приложения (JSON) ─────────────
              Text(
                'Резервная копия приложения (JSON)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _ActionCard(
                icon: Icons.cloud_upload_outlined,
                accentColor: AppColors.primary,
                title: 'Создать резервную копию',
                description:
                    'Полный снимок: профиль, дневник питания, вода, взвешивания, авторские рецепты и продукты.',
                buttonText: 'Экспортировать и поделиться',
                isPrimary: true,
                onPressed: _handleExportJson,
              ),
              const SizedBox(height: 12),

              _ActionCard(
                icon: Icons.cloud_download_outlined,
                accentColor: const Color(0xFF6366F1),
                title: 'Восстановить из файла',
                description:
                    'Загрузите сохранённый ранее файл .json для переноса истории на это устройство.',
                buttonText: 'Выбрать файл бэкапа',
                isPrimary: false,
                onPressed: _handleRestore,
              ),
              const SizedBox(height: 28),

              // ── СЕКЦИЯ 2: Экспорт таблиц (Excel / CSV) ───────────────
              Text(
                'Экспорт в Excel / Таблицы (CSV)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Удобные таблицы для анализа своего прогресса на компьютере',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              _ActionCard(
                icon: Icons.table_chart_outlined,
                accentColor: AppColors.secondary,
                title: 'История питания (CSV)',
                description:
                    'Дата, время, приём пищи, продукт, вес в граммах, калории, белки, жиры и углеводы.',
                buttonText: 'Поделиться таблицей питания',
                isPrimary: false,
                onPressed: _handleExportDiaryCsv,
              ),
              const SizedBox(height: 12),

              _ActionCard(
                icon: Icons.show_chart_rounded,
                accentColor: const Color(0xFF0EA5E9),
                title: 'Динамика веса (CSV)',
                description:
                    'Полный журнал взвешиваний с датами, временем и заметками для построения графиков.',
                buttonText: 'Поделиться таблицей веса',
                isPrimary: false,
                onPressed: _handleExportWeightCsv,
              ),
            ],
          ),

          // Индикатор прогресса при тяжелых операциях
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        _loadingMessage ?? 'Обработка данных...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.isPrimary,
    required this.onPressed,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;
  final String buttonText;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: isPrimary
                ? FilledButton.icon(
                    onPressed: onPressed,
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: Text(buttonText),
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: onPressed,
                    icon: Icon(icon, size: 18, color: accentColor),
                    label: Text(buttonText),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
