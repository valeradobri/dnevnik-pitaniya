import 'package:flutter/material.dart';

/// Экран профиля пользователя
/// Полная реализация — в Фазе 2.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Заглушка аватара
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person_rounded,
                size: 44,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Пользователь',
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 32),
          Text('Настройки', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            label: 'Тема оформления',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Напоминания',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.backup_outlined,
            label: 'Резервная копия данных',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          Text('О приложении', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'Версия 0.1.0 (Фаза 1)',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right_rounded),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      onTap: onTap,
    );
  }
}
