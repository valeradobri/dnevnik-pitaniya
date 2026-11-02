import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/filter_pill.dart';
import '../providers/gamification_providers.dart';

/// Экран достижений, наград и серии привычек без чувства вины
class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  String _filter = 'all'; // 'all', 'unlocked', 'in_progress'

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'star_outline':
        return Icons.star_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'monitor_weight':
        return Icons.monitor_weight_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      case 'restaurant_menu':
        return Icons.restaurant_menu_rounded;
      default:
        return Icons.military_tech_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final achievementsAsync = ref.watch(achievementsProvider);
    final statsAsync = ref.watch(habitStatsProvider);
    final stats = statsAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения и привычки'),
      ),
      body: achievementsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Ошибка загрузки: $err')),
        data: (achievements) {
          final streak = stats?.currentStreak ?? 0;
          final totalDays = stats?.totalActiveDays ?? 0;
          final unlockedCount = achievements.where((a) => a.isUnlocked).length;
          final totalCount = achievements.length;

          var displayList = achievements;
          if (_filter == 'unlocked') {
            displayList = achievements.where((a) => a.isUnlocked).toList();
          } else if (_filter == 'in_progress') {
            displayList = achievements.where((a) => !a.isUnlocked).toList();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            children: [
              // ── Верхний баннер статистики ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFA7F3D0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          icon: Icons.emoji_events_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          value: '$unlockedCount / $totalCount',
                          label: 'Наград открыто',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFF6EE7B7),
                        ),
                        _StatItem(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: const Color(0xFFF97316),
                          value: '$streak дн.',
                          label: 'Текущая серия',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: isDark ? const Color(0xFF334155) : const Color(0xFF6EE7B7),
                        ),
                        _StatItem(
                          icon: Icons.spa_rounded,
                          iconColor: const Color(0xFF10B981),
                          value: '$totalDays дн.',
                          label: 'Всего осознанно',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite_rounded,
                            size: 16,
                            color: Color(0xFFEC4899),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Привычки формируются без спешки. Любой шаг сегодня ценнее идеала!',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Фильтры (Все / Открытые / В процессе) ─────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    FilterPill(
                      label: 'Все ($totalCount)',
                      isSelected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    FilterPill(
                      label: 'Открытые ($unlockedCount)',
                      icon: Icons.check_circle_rounded,
                      isSelected: _filter == 'unlocked',
                      onTap: () => setState(() => _filter = 'unlocked'),
                    ),
                    const SizedBox(width: 8),
                    FilterPill(
                      label: 'В процессе (${totalCount - unlockedCount})',
                      icon: Icons.timelapse_rounded,
                      isSelected: _filter == 'in_progress',
                      onTap: () => setState(() => _filter = 'in_progress'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Список карточек достижений ────────────────────────────
              if (displayList.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.workspace_premium_outlined,
                          size: 56,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'В этой категории пока ничего нет',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...displayList.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AchievementCard(
                      item: item,
                      icon: _getIcon(item.achievement.iconName),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.item,
    required this.icon,
  });

  final AchievementWithStatus item;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUnlocked = item.isUnlocked;

    final ach = item.achievement;
    final current = item.currentCount;
    final required = item.requiredCount;
    final progress = item.progress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark ? const Color(0xFF172B23) : const Color(0xFFF0FDF4))
            : (isDark ? const Color(0xFF1E242E) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? (isDark ? const Color(0xFF059669) : const Color(0xFF86EFAC))
              : (isDark ? const Color(0xFF333D4D) : const Color(0xFFE2E8F0)),
          width: isUnlocked ? 1.8 : 1.2,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка бейджа
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isUnlocked ? null : (isDark ? const Color(0xFF2B3442) : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isUnlocked ? Colors.white : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            ),
          ),
          const SizedBox(width: 14),

          // Описание и прогресс
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ach.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Открыто',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        '$current / $required',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  ach.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),

                // Прогресс-бар для незавершенных
                if (!isUnlocked) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: isDark ? const Color(0xFF333D4D) : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                    ),
                  ),
                ] else if (item.unlockedAt != null) ...[
                  Text(
                    'Разблокировано: ${DateFormat('d MMMM yyyy', 'ru_RU').format(item.unlockedAt!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF059669),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
