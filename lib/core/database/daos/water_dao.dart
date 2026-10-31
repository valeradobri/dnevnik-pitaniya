import 'package:drift/drift.dart';
import '../app_database.dart';

/// DAO для учёта потребления воды
class WaterDao {
  WaterDao(this.db);

  final AppDatabase db;

  (DateTime, DateTime) _dayRange(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return (start, end);
  }

  /// Реактивный стрим всех записей воды за день
  Stream<List<WaterEntry>> watchWaterEntriesForDate(DateTime date) {
    final (start, end) = _dayRange(date);
    return (db.select(db.waterEntries)
          ..where((t) => t.entryDate.isBiggerOrEqualValue(start) & t.entryDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
        .watch();
  }

  /// Реактивный стрим суммарного объёма воды за день (мл)
  Stream<int> watchTotalWaterMlForDate(DateTime date) {
    return watchWaterEntriesForDate(date).map((entries) {
      return entries.fold<int>(0, (sum, entry) => sum + entry.amountMl);
    });
  }

  /// Добавить порцию воды (например, 250 мл)
  Future<int> addWater(DateTime date, int amountMl) {
    return db.into(db.waterEntries).insert(
          WaterEntriesCompanion.insert(
            amountMl: amountMl,
            entryDate: date,
          ),
        );
  }

  /// Сбросить (удалить) записи воды за указанный день
  Future<int> resetWaterForDate(DateTime date) {
    final (start, end) = _dayRange(date);
    return (db.delete(db.waterEntries)
          ..where((t) => t.entryDate.isBiggerOrEqualValue(start) & t.entryDate.isSmallerOrEqualValue(end)))
        .go();
  }

  /// Удалить отдельную запись воды по её ID
  Future<int> deleteWaterEntry(int id) {
    return (db.delete(db.waterEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Реактивный стрим записей воды в диапазоне дат
  Stream<List<WaterEntry>> watchWaterEntriesForRange(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
    return (db.select(db.waterEntries)
          ..where((t) => t.entryDate.isBiggerOrEqualValue(start) & t.entryDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.entryDate), (t) => OrderingTerm(expression: t.timestamp)]))
        .watch();
  }
}
