import 'package:intl/intl.dart';

/// Утилиты форматирования для отображения данных в UI
abstract final class AppFormatters {
  // ─── Локализованные форматтеры ───────────────────────────────────────
  static const _ruLocale = 'ru_RU';

  static final _dateFormat = DateFormat('d MMMM yyyy', _ruLocale);
  static final _shortDateFormat = DateFormat('d MMM', _ruLocale);
  static final _dayOfWeekFormat = DateFormat('EEEE', _ruLocale);
  static final _shortDayFormat = DateFormat('EE', _ruLocale);
  static final _timeFormat = DateFormat('HH:mm', _ruLocale);

  // ─── Калории ────────────────────────────────────────────────────────
  static String formatCalories(double value) =>
      '${value.round()} ккал';

  static String formatCaloriesShort(double value) =>
      '${value.round()}';

  // ─── Граммы и миллилитры ─────────────────────────────────────────────
  static String formatGrams(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} кг';
    }
    return '${value.round()} г';
  }

  static String formatMl(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)} л';
    }
    return '$value мл';
  }

  static String formatWeight(double value) =>
      '${value.toStringAsFixed(1)} кг';

  // ─── Макронутриенты ──────────────────────────────────────────────────
  static String formatMacro(double value) =>
      '${value.toStringAsFixed(1)} г';

  static String formatMacroShort(double value) =>
      value.round().toString();

  // ─── Даты ───────────────────────────────────────────────────────────

  /// Отображение даты дневника (с учётом «Сегодня» / «Вчера»)
  static String formatDiaryDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Сегодня';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Вчера';
    if (dateOnly == today.add(const Duration(days: 1))) return 'Завтра';
    return _shortDateFormat.format(date);
  }

  static String formatFullDate(DateTime date) => _dateFormat.format(date);
  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);
  static String formatDayOfWeek(DateTime date) => _dayOfWeekFormat.format(date);
  static String formatShortDay(DateTime date) => _shortDayFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);

  // ─── Процент выполнения цели ─────────────────────────────────────────
  static String formatProgress(double current, double target) {
    if (target <= 0) return '0%';
    final pct = ((current / target) * 100).round();
    return '$pct%';
  }
}
