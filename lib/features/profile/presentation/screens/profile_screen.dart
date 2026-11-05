import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/utils/nutrition_calculator.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../weight/presentation/widgets/weight_history_sheet.dart';

/// Экран профиля пользователя с отображением текущих целей и параметров
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;

    final name = profile?.name.isNotEmpty == true ? profile!.name : 'Пользователь';
    final age = profile != null ? NutritionCalculator.calculateAge(profile.birthDate) : 28;
    final height = profile?.heightCm.toInt() ?? 170;
    final currentWeight = profile?.currentWeightKg ?? 70.0;
    final targetWeight = profile?.targetWeightKg ?? 65.0;
    final targetCalories = profile?.targetCalories ?? 2000;
    final targetProtein = profile?.targetProteinG.toInt() ?? 120;
    final targetFat = profile?.targetFatG.toInt() ?? 65;
    final targetCarbs = profile?.targetCarbsG.toInt() ?? 230;
    final targetWater = profile?.targetWaterMl ?? 2000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль и цели'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        children: [
          // ── Карточка аватара и имени ──────────────────────────────
          Center(
            child: CircleAvatar(
              radius: 46,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'П',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              name,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              '$age лет · Рост $height см',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Карточка параметров веса ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ProfileMetric(
                        label: 'Текущий вес',
                        value: '${currentWeight.toStringAsFixed(1)} кг',
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                    Container(width: 1, height: 36, color: theme.colorScheme.outlineVariant),
                    Expanded(
                      child: _ProfileMetric(
                        label: 'Целевой вес',
                        value: '${targetWeight.toStringAsFixed(1)} кг',
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Container(width: 1, height: 36, color: theme.colorScheme.outlineVariant),
                    Expanded(
                      child: _ProfileMetric(
                        label: 'Осталось',
                        value: '${(currentWeight - targetWeight).abs().toStringAsFixed(1)} кг',
                        color: const Color(0xFFF97316),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => WeightHistorySheet.show(context),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: const Text('История взвешиваний'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Карточка суточных норм ───────────────────────────────
          Text(
            'Ваши суточные нормы',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.local_fire_department_rounded, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Целевой калораж', style: theme.textTheme.bodyMedium),
                          Text(
                            '$targetCalories ккал / день',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _MacroItem(label: 'Белки', value: '$targetProtein г', color: AppColors.protein),
                    ),
                    Expanded(
                      child: _MacroItem(label: 'Жиры', value: '$targetFat г', color: AppColors.fat),
                    ),
                    Expanded(
                      child: _MacroItem(label: 'Углеводы', value: '$targetCarbs г', color: AppColors.carbs),
                    ),
                    Expanded(
                      child: _MacroItem(label: 'Вода', value: '$targetWater мл', color: AppColors.water),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Настройки и сброс ────────────────────────────────────
          Text(
            'Настройки приложения',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.emoji_events_outlined,
            label: 'Достижения и привычки',
            onTap: () => context.push('/achievements'),
          ),
          _SettingsTile(
            icon: Icons.tune_rounded,
            label: 'Пройти анкету заново',
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Пересчитать цели?'),
                  content: const Text('Вы сможете заново указать параметры тела и цели.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Начать')),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('onboarding_complete', false);
                if (context.mounted) {
                  context.go('/onboarding');
                }
              }
            },
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Напоминания',
            subtitle: ref.watch(notificationSettingsProvider).isMasterEnabled
                ? 'Включены (${ref.watch(notificationSettingsProvider).enabledCount} активных)'
                : 'Отключены',
            onTap: () => context.push(RouteNames.notificationsSettings),
          ),
          _SettingsTile(
            icon: Icons.backup_outlined,
            label: 'Резервная копия и экспорт',
            subtitle: 'Экспорт всей базы в JSON и таблиц в Excel/CSV',
            onTap: () => context.push(RouteNames.backup),
          ),
          const SizedBox(height: 16),
          Text('О приложении', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.verified_outlined,
            label: 'Дневник питания v1.0.0 (Релизная версия)',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _MacroItem extends StatelessWidget {
  const _MacroItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      onTap: onTap,
    );
  }
}
