import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/notification_setting.dart';
import '../providers/notification_providers.dart';

/// Экран настройки локальных ненавязчивых напоминаний (Фаза 4.3)
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Напоминания'),
        actions: [
          IconButton(
            tooltip: 'Проверить тестовое уведомление',
            icon: const Icon(Icons.notification_add_outlined),
            onPressed: () async {
              await notifier.sendTestNotification(NotificationType.breakfast);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Тестовое уведомление отправлено! Проверьте шторку телефона 🔔',
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Баннер философии заботы ──────────────────────────────
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
                    Icons.spa_rounded,
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
                        'Забота без чувства вины',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Напоминания созданы, чтобы мягко подсказывать вам о питании и воде. Если вы поели в другое время или пропустили запись — это абсолютно нормально в рамках долгосрочного баланса.',
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
          const SizedBox(height: 16),

          // ── Главный мастер-тумблер ────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (state.isMasterEnabled
                            ? AppColors.primary
                            : theme.colorScheme.outline)
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    state.isMasterEnabled
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_outlined,
                    color: state.isMasterEnabled
                        ? AppColors.primary
                        : theme.colorScheme.outline,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Все напоминания',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.isMasterEnabled
                            ? 'Активно ${state.enabledCount} из ${state.settings.length}'
                            : 'Все напоминания отключены',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: state.isMasterEnabled,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) => notifier.toggleMaster(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Заголовок списка напоминаний ─────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Расписание и типы',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (state.isMasterEnabled)
                Flexible(
                  child: Text(
                    'Нажмите на время для смены',
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Карточки отдельных напоминаний ───────────────────────
          AnimatedOpacity(
            opacity: state.isMasterEnabled ? 1.0 : 0.45,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(
              ignoring: !state.isMasterEnabled,
              child: Column(
                children: state.settings.map((setting) {
                  return _ReminderSettingCard(
                    setting: setting,
                    onToggle: (enabled) {
                      notifier.toggleSetting(setting.type, enabled);
                    },
                    onTimeTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: setting.time,
                        builder: (ctx, child) {
                          return MediaQuery(
                            data: MediaQuery.of(ctx).copyWith(
                              alwaysUse24HourFormat: true,
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        notifier.updateTime(setting.type, picked);
                      }
                    },
                    onTest: () async {
                      await notifier.sendTestNotification(setting.type);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Отправлено: ${setting.title} 🔔',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Кнопка проверки в один клик ───────────────────────────
          OutlinedButton.icon(
            onPressed: () async {
              await notifier.sendTestNotification(NotificationType.lunch);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Тестовое напоминание об обеде отправлено! Проверьте шторку 🥗',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.touch_app_outlined),
            label: const Text('Проверить работу уведомлений сейчас'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Карточка конкретного напоминания с выбором времени и тумблером
class _ReminderSettingCard extends StatelessWidget {
  const _ReminderSettingCard({
    required this.setting,
    required this.onToggle,
    required this.onTimeTap,
    required this.onTest,
  });

  final NotificationSetting setting;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTimeTap;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = setting.type.accentColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: setting.isEnabled
              ? accent.withValues(alpha: 0.3)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Цветная иконка типа напоминания
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  setting.type.icon,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Название и чип времени
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      setting.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Кликабельный чип времени
                    InkWell(
                      onTap: onTimeTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              setting.formattedTime,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.arrow_drop_down,
                              size: 16,
                              color: accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Кнопка быстрого теста
              IconButton(
                tooltip: 'Тест этого напоминания',
                icon: const Icon(Icons.play_circle_outline_rounded, size: 22),
                color: theme.colorScheme.onSurfaceVariant,
                onPressed: onTest,
              ),

              // Тумблер вкл/выкл
              Switch.adaptive(
                value: setting.isEnabled,
                activeTrackColor: accent,
                onChanged: onToggle,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Текст сообщения напоминания
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    setting.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
