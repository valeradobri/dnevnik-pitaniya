import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../domain/models/notification_setting.dart';

/// Сервис локальных ненавязчивых уведомлений приложения
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  static const String channelId = 'dnevnik_reminders';
  static const String channelName = 'Напоминания Дневника';
  static const String channelDescription =
      'Мягкие и поддерживающие напоминания о питании, воде и утреннем весе';

  /// Инициализация плагина, таймзон и Android-канала
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Инициализация базы данных часовых поясов
      tz.initializeTimeZones();
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.local);
      }
    } catch (e) {
      debugPrint('[NotificationService] Ошибка настройки таймзоны: $e');
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Открыть');

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('[NotificationService] Открыто уведомление: ${response.payload}');
      },
    );

    // Создание канала уведомлений для Android (Android 8.0+)
    await _createAndroidChannel();

    _isInitialized = true;
    debugPrint('[NotificationService] Успешно инициализирован');
  }

  /// Создание основного канала уведомлений
  Future<void> _createAndroidChannel() async {
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return;

    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    await androidImpl.createNotificationChannel(channel);
  }

  /// Проверка, разрешены ли уведомления в системе
  Future<bool> arePermissionsGranted() async {
    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final enabled = await androidImpl.areNotificationsEnabled();
        return enabled ?? false;
      }
    } catch (e) {
      debugPrint('[NotificationService] Ошибка проверки прав: $e');
    }
    return true;
  }

  /// Запрос системных разрешений на показ уведомлений
  Future<bool> requestPermissions() async {
    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        try {
          await androidImpl.requestExactAlarmsPermission();
        } catch (_) {}
        final currentlyEnabled = await androidImpl.areNotificationsEnabled() ?? false;
        return granted ?? currentlyEnabled;
      }

      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImpl != null) {
        final granted = await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('[NotificationService] Ошибка запроса прав: $e');
    }
    return true;
  }

  /// Детали оформления уведомления для Android и iOS
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        showWhen: true,
        styleInformation: DefaultStyleInformation(true, true),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Запланировать ежедневное напоминание в указанные час и минуту
  Future<void> scheduleDailyReminder(NotificationSetting setting) async {
    if (!_isInitialized) await initialize();

    final scheduledDate = _nextInstanceOfTime(setting.hour, setting.minute);

    try {
      await _plugin.zonedSchedule(
        id: setting.notificationId,
        title: setting.title,
        body: setting.message,
        scheduledDate: scheduledDate,
        notificationDetails: _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: setting.type.key,
      );
      debugPrint(
        '[NotificationService] Запланировано: ${setting.type.key} в ${setting.formattedTime} (ID: ${setting.notificationId})',
      );
    } catch (e) {
      // Фолбэк на inexactAllowWhileIdle, если система запрещает точные алармы
      try {
        await _plugin.zonedSchedule(
          id: setting.notificationId,
          title: setting.title,
          body: setting.message,
          scheduledDate: scheduledDate,
          notificationDetails: _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: setting.type.key,
        );
        debugPrint(
          '[NotificationService] Запланировано (inexact): ${setting.type.key} в ${setting.formattedTime}',
        );
      } catch (err) {
        debugPrint('[NotificationService] Ошибка планирования ${setting.type.key}: $err');
      }
    }
  }

  /// Показ мгновенного тестового уведомления
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _notificationDetails(),
        payload: payload,
      );
      debugPrint('[NotificationService] Мгновенное уведомление успешно отправлено: $title');
    } catch (e, stack) {
      debugPrint('[NotificationService] Ошибка отправки мгновенного уведомления: $e\n$stack');
    }
  }

  /// Отмена одного конкретного напоминания по ID
  Future<void> cancelReminder(int id) async {
    try {
      await _plugin.cancel(id: id);
      debugPrint('[NotificationService] Отменено напоминание ID: $id');
    } catch (e) {
      debugPrint('[NotificationService] Ошибка отмены ID $id: $e');
    }
  }

  /// Отмена всех напоминаний
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
      debugPrint('[NotificationService] Все напоминания отменены');
    } catch (e) {
      debugPrint('[NotificationService] Ошибка отмены всех: $e');
    }
  }

  /// Вычисление следующего момента времени (сегодня или завтра)
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
