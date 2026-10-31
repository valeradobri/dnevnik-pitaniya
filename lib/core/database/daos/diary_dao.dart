import 'package:drift/drift.dart';
import '../app_database.dart';

/// Модель сводки КБЖУ за день
class DayTotals {
  const DayTotals({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  static const zero = DayTotals(
    calories: 0.0,
    protein: 0.0,
    fat: 0.0,
    carbs: 0.0,
  );
}

/// DAO для работы с записями дневника питания
class DiaryDao {
  DiaryDao(this.db);

  final AppDatabase db;

  /// Диапазон начала и конца суток для точного среза даты
  (DateTime, DateTime) _dayRange(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
    return (start, end);
  }

  /// Реактивный стрим записей за указанную дату
  Stream<List<DiaryEntry>> watchEntriesForDate(DateTime date) {
    final (start, end) = _dayRange(date);
    return (db.select(db.diaryEntries)
          ..where((t) => t.entryDate.isBiggerOrEqualValue(start) & t.entryDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
        .watch();
  }

  /// Получить записи за дату
  Future<List<DiaryEntry>> getEntriesForDate(DateTime date) {
    final (start, end) = _dayRange(date);
    return (db.select(db.diaryEntries)
          ..where((t) => t.entryDate.isBiggerOrEqualValue(start) & t.entryDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
        .get();
  }

  /// Добавить новую запись в дневник
  Future<int> insertEntry(DiaryEntriesCompanion entry) {
    return db.into(db.diaryEntries).insert(entry);
  }

  /// Удалить запись из дневника
  Future<int> deleteEntry(int id) {
    return (db.delete(db.diaryEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Обновить запись в дневнике
  Future<bool> updateEntry(DiaryEntry entry) {
    return db.update(db.diaryEntries).replace(entry);
  }

  /// Реактивный стрим суммарных КБЖУ за день
  Stream<DayTotals> watchTotalsForDate(DateTime date) {
    return watchEntriesForDate(date).map((entries) {
      double cals = 0;
      double prot = 0;
      double fats = 0;
      double carb = 0;

      for (final e in entries) {
        cals += e.calculatedCalories;
        prot += e.calculatedProtein;
        fats += e.calculatedFat;
        carb += e.calculatedCarbs;
      }

      return DayTotals(
        calories: cals,
        protein: prot,
        fat: fats,
        carbs: carb,
      );
    });
  }

  /// Реактивный стрим записей дневника в диапазоне дат (включительно)
  Stream<List<DiaryEntry>> watchEntriesForRange(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
    return (db.select(db.diaryEntries)
          ..where((t) => t.entryDate.isBiggerOrEqualValue(start) & t.entryDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.entryDate), (t) => OrderingTerm(expression: t.timestamp)]))
        .watch();
  }
}
