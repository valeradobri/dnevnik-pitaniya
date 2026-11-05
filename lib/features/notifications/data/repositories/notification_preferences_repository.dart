import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/notification_setting.dart';

/// Репозиторий сохранения настроек напоминаний в SharedPreferences
class NotificationPreferencesRepository {
  NotificationPreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyMasterEnabled = 'notifications_master_enabled';
  static const String _keySettingsJson = 'notifications_settings_json';

  /// Общий тумблер включения всех уведомлений
  bool isMasterEnabled() {
    return _prefs.getBool(_keyMasterEnabled) ?? true;
  }

  Future<void> setMasterEnabled(bool enabled) async {
    await _prefs.setBool(_keyMasterEnabled, enabled);
  }

  /// Загрузка персональных настроек напоминаний
  List<NotificationSetting> loadSettings() {
    final rawJson = _prefs.getString(_keySettingsJson);
    if (rawJson == null || rawJson.isEmpty) {
      return NotificationSetting.defaultSettings;
    }

    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      final loaded = decoded
          .map((item) => NotificationSetting.fromJson(item as Map<String, dynamic>))
          .toList();

      // Убеждаемся, что все типы присутствуют (на случай добавления новых типов в обновлениях)
      final existingTypes = loaded.map((s) => s.type).toSet();
      for (final defaultSetting in NotificationSetting.defaultSettings) {
        if (!existingTypes.contains(defaultSetting.type)) {
          loaded.add(defaultSetting);
        }
      }

      return loaded;
    } catch (_) {
      return NotificationSetting.defaultSettings;
    }
  }

  /// Сохранение настроек напоминаний
  Future<void> saveSettings(List<NotificationSetting> settings) async {
    final encoded = jsonEncode(settings.map((s) => s.toJson()).toList());
    await _prefs.setString(_keySettingsJson, encoded);
  }
}
