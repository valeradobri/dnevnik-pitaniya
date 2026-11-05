import 'package:flutter/material.dart';

/// Типы ненавязчивых локальных напоминаний
enum NotificationType {
  breakfast,
  lunch,
  dinner,
  water,
  weight;

  String get key => name;

  int get notificationId {
    switch (this) {
      case NotificationType.breakfast:
        return 101;
      case NotificationType.lunch:
        return 102;
      case NotificationType.dinner:
        return 103;
      case NotificationType.water:
        return 104;
      case NotificationType.weight:
        return 105;
    }
  }

  String get defaultTitle {
    switch (this) {
      case NotificationType.breakfast:
        return 'Завтрак';
      case NotificationType.lunch:
        return 'Обед';
      case NotificationType.dinner:
        return 'Ужин';
      case NotificationType.water:
        return 'Водный баланс';
      case NotificationType.weight:
        return 'Утренний вес';
    }
  }

  String get defaultMessage {
    switch (this) {
      case NotificationType.breakfast:
        return 'Доброе утро! Время для вкусного и питательного завтрака 🍳';
      case NotificationType.lunch:
        return 'Время подкрепиться! Сбалансированный обед зарядит силами на день 🥗';
      case NotificationType.dinner:
        return 'Пора поужинать! Легкий сытный ужин подарит комфортный вечер 🍲';
      case NotificationType.water:
        return 'Время освежиться! Стакан чистой воды поддержит тонус и баланс 💧';
      case NotificationType.weight:
        return 'Доброе утро! Самое время для утреннего взвешивания натощак ⚖️';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.breakfast:
        return Icons.wb_sunny_outlined;
      case NotificationType.lunch:
        return Icons.restaurant_outlined;
      case NotificationType.dinner:
        return Icons.nights_stay_outlined;
      case NotificationType.water:
        return Icons.water_drop_outlined;
      case NotificationType.weight:
        return Icons.monitor_weight_outlined;
    }
  }

  Color get accentColor {
    switch (this) {
      case NotificationType.breakfast:
        return const Color(0xFFF59E0B); // Теплый янтарный
      case NotificationType.lunch:
        return const Color(0xFF10B981); // Свежий изумрудный
      case NotificationType.dinner:
        return const Color(0xFF6366F1); // Мягкий вечерний индиго
      case NotificationType.water:
        return const Color(0xFF0EA5E9); // Чистый аквамарин
      case NotificationType.weight:
        return const Color(0xFFEC4899); // Розовый коралл
    }
  }
}

/// Модель настройки конкретного напоминания
class NotificationSetting {
  const NotificationSetting({
    required this.type,
    required this.hour,
    required this.minute,
    this.isEnabled = true,
    this.customTitle,
    this.customMessage,
  });

  final NotificationType type;
  final int hour;
  final int minute;
  final bool isEnabled;
  final String? customTitle;
  final String? customMessage;

  String get title => customTitle ?? type.defaultTitle;
  String get message => customMessage ?? type.defaultMessage;
  int get notificationId => type.notificationId;

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  NotificationSetting copyWith({
    NotificationType? type,
    int? hour,
    int? minute,
    bool? isEnabled,
    String? customTitle,
    String? customMessage,
  }) {
    return NotificationSetting(
      type: type ?? this.type,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      customTitle: customTitle ?? this.customTitle,
      customMessage: customMessage ?? this.customMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.key,
      'hour': hour,
      'minute': minute,
      'isEnabled': isEnabled,
      'customTitle': customTitle,
      'customMessage': customMessage,
    };
  }

  factory NotificationSetting.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String? ?? 'breakfast';
    final type = NotificationType.values.firstWhere(
      (e) => e.key == typeName,
      orElse: () => NotificationType.breakfast,
    );

    return NotificationSetting(
      type: type,
      hour: json['hour'] as int? ?? 8,
      minute: json['minute'] as int? ?? 30,
      isEnabled: json['isEnabled'] as bool? ?? true,
      customTitle: json['customTitle'] as String?,
      customMessage: json['customMessage'] as String?,
    );
  }

  /// Набор настроек по умолчанию для нового пользователя
  static List<NotificationSetting> get defaultSettings => const [
        NotificationSetting(
          type: NotificationType.weight,
          hour: 8,
          minute: 0,
          isEnabled: true,
        ),
        NotificationSetting(
          type: NotificationType.breakfast,
          hour: 8,
          minute: 30,
          isEnabled: true,
        ),
        NotificationSetting(
          type: NotificationType.water,
          hour: 11,
          minute: 30,
          isEnabled: true,
        ),
        NotificationSetting(
          type: NotificationType.lunch,
          hour: 13,
          minute: 30,
          isEnabled: true,
        ),
        NotificationSetting(
          type: NotificationType.dinner,
          hour: 19,
          minute: 30,
          isEnabled: true,
        ),
      ];
}
