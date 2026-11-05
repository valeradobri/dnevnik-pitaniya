import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/notification_preferences_repository.dart';
import '../../data/services/notification_service.dart';
import '../../domain/models/notification_setting.dart';

/// Провайдер сервиса уведомлений
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Провайдер SharedPreferences (может быть переопределен в тестах)
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

/// Провайдер репозитория настроек уведомлений
final notificationPreferencesRepoProvider =
    Provider<NotificationPreferencesRepository?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  if (prefs != null) {
    return NotificationPreferencesRepository(prefs);
  }
  return null;
});

/// Состояние экрана настроек уведомлений
class NotificationSettingsState {
  const NotificationSettingsState({
    required this.isMasterEnabled,
    required this.settings,
    this.isLoading = false,
  });

  final bool isMasterEnabled;
  final List<NotificationSetting> settings;
  final bool isLoading;

  NotificationSettingsState copyWith({
    bool? isMasterEnabled,
    List<NotificationSetting>? settings,
    bool? isLoading,
  }) {
    return NotificationSettingsState(
      isMasterEnabled: isMasterEnabled ?? this.isMasterEnabled,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get enabledCount =>
      isMasterEnabled ? settings.where((s) => s.isEnabled).length : 0;
}

/// Нотифаер управления настройками уведомлений
class NotificationSettingsNotifier
    extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier({
    required this.service,
    NotificationPreferencesRepository? repo,
  })  : _repo = repo,
        super(
          NotificationSettingsState(
            isMasterEnabled: repo?.isMasterEnabled() ?? true,
            settings: repo?.loadSettings() ?? NotificationSetting.defaultSettings,
          ),
        ) {
    if (_repo == null) {
      _lazyLoadRepo();
    }
  }

  final NotificationService service;
  NotificationPreferencesRepository? _repo;

  Future<void> _lazyLoadRepo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _repo = NotificationPreferencesRepository(prefs);
      state = state.copyWith(
        isMasterEnabled: _repo!.isMasterEnabled(),
        settings: _repo!.loadSettings(),
      );
    } catch (_) {}
  }

  /// Первичная инициализация и синхронизация алармов с ОС
  Future<void> syncWithSystem() async {
    await service.initialize();
    if (state.isMasterEnabled) {
      for (final setting in state.settings) {
        if (setting.isEnabled) {
          await service.scheduleDailyReminder(setting);
        } else {
          await service.cancelReminder(setting.notificationId);
        }
      }
    } else {
      await service.cancelAll();
    }
  }

  /// Переключение главного тумблера всех уведомлений
  Future<void> toggleMaster(bool enabled) async {
    state = state.copyWith(isLoading: true);
    if (enabled) {
      await service.requestPermissions();
      if (_repo != null) {
        await _repo!.setMasterEnabled(true);
      }
      state = state.copyWith(isMasterEnabled: true, isLoading: false);

      // Планируем все активные напоминания
      for (final s in state.settings) {
        if (s.isEnabled) {
          await service.scheduleDailyReminder(s);
        }
      }
    } else {
      if (_repo != null) {
        await _repo!.setMasterEnabled(false);
      }
      await service.cancelAll();
      state = state.copyWith(isMasterEnabled: false, isLoading: false);
    }
  }

  /// Переключение конкретного напоминания (Завтрак, Обед, Вода и т.д.)
  Future<void> toggleSetting(NotificationType type, bool isEnabled) async {
    final updatedList = state.settings.map((s) {
      if (s.type == type) {
        return s.copyWith(isEnabled: isEnabled);
      }
      return s;
    }).toList();

    state = state.copyWith(settings: updatedList);
    if (_repo != null) {
      await _repo!.saveSettings(updatedList);
    }

    final updatedSetting = updatedList.firstWhere((s) => s.type == type);
    if (state.isMasterEnabled && isEnabled) {
      await service.scheduleDailyReminder(updatedSetting);
    } else {
      await service.cancelReminder(updatedSetting.notificationId);
    }
  }

  /// Изменение времени напоминания
  Future<void> updateTime(NotificationType type, TimeOfDay time) async {
    final updatedList = state.settings.map((s) {
      if (s.type == type) {
        return s.copyWith(hour: time.hour, minute: time.minute);
      }
      return s;
    }).toList();

    state = state.copyWith(settings: updatedList);
    if (_repo != null) {
      await _repo!.saveSettings(updatedList);
    }

    final updatedSetting = updatedList.firstWhere((s) => s.type == type);
    if (state.isMasterEnabled && updatedSetting.isEnabled) {
      await service.cancelReminder(updatedSetting.notificationId);
      await service.scheduleDailyReminder(updatedSetting);
    }
  }

  /// Отправка мгновенного тестового уведомления для проверки
  Future<void> sendTestNotification(NotificationType type) async {
    final setting = state.settings.firstWhere(
      (s) => s.type == type,
      orElse: () => NotificationSetting.defaultSettings.first,
    );

    await service.showInstantNotification(
      id: 999,
      title: '🔔 Тест: ${setting.title}',
      body: setting.message,
      payload: 'test_${setting.type.key}',
    );
  }

  /// Запрос системных разрешений вручную
  Future<bool> requestPermissions() async {
    return await service.requestPermissions();
  }
}

/// Провайдер настроек уведомлений
final notificationSettingsProvider = StateNotifierProvider<
    NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  final repo = ref.watch(notificationPreferencesRepoProvider);
  return NotificationSettingsNotifier(service: service, repo: repo);
});
