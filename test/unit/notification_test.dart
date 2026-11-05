import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dnevnik/features/notifications/domain/models/notification_setting.dart';
import 'package:dnevnik/features/notifications/data/repositories/notification_preferences_repository.dart';
import 'package:dnevnik/features/notifications/presentation/providers/notification_providers.dart';
import 'package:dnevnik/features/notifications/data/services/notification_service.dart';

class FakeNotificationService extends NotificationService {
  final List<int> scheduledIds = [];
  final List<int> cancelledIds = [];
  bool masterCancelled = false;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleDailyReminder(NotificationSetting setting) async {
    scheduledIds.add(setting.notificationId);
  }

  @override
  Future<void> cancelReminder(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAll() async {
    masterCancelled = true;
  }
}

void main() {
  group('NotificationSetting Domain Model Tests', () {
    test('Default presets contain all 5 essential daily reminders', () {
      final defaults = NotificationSetting.defaultSettings;
      expect(defaults.length, 5);

      final types = defaults.map((s) => s.type).toSet();
      expect(types, {
        NotificationType.weight,
        NotificationType.breakfast,
        NotificationType.water,
        NotificationType.lunch,
        NotificationType.dinner,
      });

      for (final s in defaults) {
        expect(s.isEnabled, isTrue);
        expect(s.notificationId, greaterThan(100));
        expect(s.formattedTime.length, 5);
        expect(s.title.isNotEmpty, isTrue);
        expect(s.message.isNotEmpty, isTrue);
      }
    });

    test('JSON serialization & deserialization preserves all values', () {
      const setting = NotificationSetting(
        type: NotificationType.water,
        hour: 14,
        minute: 15,
        isEnabled: false,
        customTitle: 'Водичка',
        customMessage: 'Пора пить',
      );

      final json = setting.toJson();
      final restored = NotificationSetting.fromJson(json);

      expect(restored.type, NotificationType.water);
      expect(restored.hour, 14);
      expect(restored.minute, 15);
      expect(restored.isEnabled, isFalse);
      expect(restored.customTitle, 'Водичка');
      expect(restored.customMessage, 'Пора пить');
      expect(restored.formattedTime, '14:15');
    });

    test('copyWith properly updates individual fields', () {
      const setting = NotificationSetting(
        type: NotificationType.lunch,
        hour: 13,
        minute: 0,
      );

      final updated = setting.copyWith(
        hour: 14,
        minute: 30,
        isEnabled: false,
      );

      expect(updated.hour, 14);
      expect(updated.minute, 30);
      expect(updated.isEnabled, isFalse);
      expect(updated.type, NotificationType.lunch);
    });
  });

  group('NotificationPreferencesRepository Tests', () {
    test('Defaults to master enabled and default settings when empty', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = NotificationPreferencesRepository(prefs);

      expect(repo.isMasterEnabled(), isTrue);
      final settings = repo.loadSettings();
      expect(settings.length, 5);
    });

    test('Saves and restores master toggle and settings list', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = NotificationPreferencesRepository(prefs);

      await repo.setMasterEnabled(false);
      expect(repo.isMasterEnabled(), isFalse);

      final customSettings = [
        const NotificationSetting(
          type: NotificationType.breakfast,
          hour: 9,
          minute: 15,
          isEnabled: false,
        ),
      ];

      await repo.saveSettings(customSettings);
      final loaded = repo.loadSettings();

      final breakfast = loaded.firstWhere((s) => s.type == NotificationType.breakfast);
      expect(breakfast.hour, 9);
      expect(breakfast.minute, 15);
      expect(breakfast.isEnabled, isFalse);
      // Other default types must also be preserved
      expect(loaded.length, 5);
    });
  });

  group('NotificationSettingsNotifier Tests', () {
    test('Toggling master switch updates state and calls service', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = NotificationPreferencesRepository(prefs);
      final fakeService = FakeNotificationService();

      final notifier = NotificationSettingsNotifier(
        service: fakeService,
        repo: repo,
      );

      expect(notifier.state.isMasterEnabled, isTrue);
      expect(notifier.state.enabledCount, 5);

      // Disable master
      await notifier.toggleMaster(false);
      expect(notifier.state.isMasterEnabled, isFalse);
      expect(notifier.state.enabledCount, 0);
      expect(fakeService.masterCancelled, isTrue);

      // Re-enable master
      fakeService.scheduledIds.clear();
      await notifier.toggleMaster(true);
      expect(notifier.state.isMasterEnabled, isTrue);
      expect(notifier.state.enabledCount, 5);
      expect(fakeService.scheduledIds.length, 5);
    });

    test('Updating individual reminder time updates state and reschedules', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = NotificationPreferencesRepository(prefs);
      final fakeService = FakeNotificationService();

      final notifier = NotificationSettingsNotifier(
        service: fakeService,
        repo: repo,
      );

      fakeService.cancelledIds.clear();
      fakeService.scheduledIds.clear();

      await notifier.updateTime(NotificationType.lunch, const TimeOfDay(hour: 14, minute: 0));

      final lunch = notifier.state.settings.firstWhere((s) => s.type == NotificationType.lunch);
      expect(lunch.hour, 14);
      expect(lunch.minute, 0);
      expect(fakeService.cancelledIds, contains(lunch.notificationId));
      expect(fakeService.scheduledIds, contains(lunch.notificationId));
    });
  });
}
