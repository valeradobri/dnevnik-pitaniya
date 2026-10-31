import 'package:drift/drift.dart';
import '../app_database.dart';

/// DAO для учёта динамики веса
class WeightDao {
  WeightDao(this.db);

  final AppDatabase db;

  /// Реактивный стрим истории взвешиваний (по убыванию даты)
  Stream<List<WeightEntry>> watchWeightHistory() {
    return (db.select(db.weightEntries)
          ..orderBy([(t) => OrderingTerm(expression: t.entryDate, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Получить последнее взвешивание
  Future<WeightEntry?> getLatestWeight() {
    return (db.select(db.weightEntries)
          ..orderBy([(t) => OrderingTerm(expression: t.entryDate, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Добавить новую запись веса
  Future<int> addWeight({
    required double weightKg,
    required DateTime date,
    String? notes,
  }) {
    return db.into(db.weightEntries).insert(
          WeightEntriesCompanion.insert(
            weightKg: weightKg,
            entryDate: date,
            notes: Value(notes),
          ),
        );
  }

  /// Удалить запись веса
  Future<int> deleteWeight(int id) {
    return (db.delete(db.weightEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Реактивный стрим записей веса в диапазоне дат (по возрастанию даты для графиков)
  Stream<List<WeightEntry>> watchWeightForRange(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
    return (db.select(db.weightEntries)
          ..where((t) => t.entryDate.isBiggerOrEqualValue(start) & t.entryDate.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm(expression: t.entryDate)]))
        .watch();
  }
}
