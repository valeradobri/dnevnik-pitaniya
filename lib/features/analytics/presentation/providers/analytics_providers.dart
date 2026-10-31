import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';

enum AnalyticsPeriod {
  week(7, '7 дней'),
  month(30, '30 дней'),
  quarter(90, '90 дней');

  const AnalyticsPeriod(this.days, this.label);
  final int days;
  final String label;
}

/// Выбранный период аналитики
final analyticsPeriodProvider = StateProvider<AnalyticsPeriod>((ref) {
  return AnalyticsPeriod.week;
});

/// Диапазон дат (от и до)
final analyticsDateRangeProvider = Provider<(DateTime, DateTime)>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  final now = DateTime.now();
  final end = DateTime(now.year, now.month, now.day);
  final start = end.subtract(Duration(days: period.days - 1));
  return (start, end);
});

/// Записи дневника за выбранный период
final analyticsDiaryEntriesProvider = StreamProvider<List<DiaryEntry>>((ref) {
  final (start, end) = ref.watch(analyticsDateRangeProvider);
  final diaryDao = ref.watch(diaryDaoProvider);
  return diaryDao.watchEntriesForRange(start, end);
});

/// Записи воды за выбранный период
final analyticsWaterEntriesProvider = StreamProvider<List<WaterEntry>>((ref) {
  final (start, end) = ref.watch(analyticsDateRangeProvider);
  final waterDao = ref.watch(waterDaoProvider);
  return waterDao.watchWaterEntriesForRange(start, end);
});

/// Записи веса за выбранный период (по возрастанию даты)
final analyticsWeightEntriesProvider = StreamProvider<List<WeightEntry>>((ref) {
  final (start, end) = ref.watch(analyticsDateRangeProvider);
  final weightDao = ref.watch(weightDaoProvider);
  return weightDao.watchWeightForRange(start, end);
});

/// Суточные агрегации калорий и БЖУ
class DailyNutritionData {
  const DailyNutritionData({
    required this.date,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final DateTime date;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
}

/// Агрегированные суточные данные по питанию для графиков
final dailyNutritionListProvider = Provider<List<DailyNutritionData>>((ref) {
  final (start, end) = ref.watch(analyticsDateRangeProvider);
  final entriesAsync = ref.watch(analyticsDiaryEntriesProvider);
  final entries = entriesAsync.value ?? [];

  // Создаем карту по каждому дню диапазона (даже если записей не было)
  final daysCount = end.difference(start).inDays + 1;
  final map = <DateTime, DailyNutritionData>{};

  for (int i = 0; i < daysCount; i++) {
    final d = DateTime(start.year, start.month, start.day + i);
    map[d] = DailyNutritionData(date: d, calories: 0, protein: 0, fat: 0, carbs: 0);
  }

  for (final e in entries) {
    final d = DateTime(e.entryDate.year, e.entryDate.month, e.entryDate.day);
    final current = map[d];
    if (current != null) {
      map[d] = DailyNutritionData(
        date: d,
        calories: current.calories + e.calculatedCalories,
        protein: current.protein + e.calculatedProtein,
        fat: current.fat + e.calculatedFat,
        carbs: current.carbs + e.calculatedCarbs,
      );
    }
  }

  return map.values.toList();
});

/// Суточные агрегации воды
class DailyWaterData {
  const DailyWaterData({
    required this.date,
    required this.amountMl,
  });

  final DateTime date;
  final int amountMl;
}

final dailyWaterListProvider = Provider<List<DailyWaterData>>((ref) {
  final (start, end) = ref.watch(analyticsDateRangeProvider);
  final waterAsync = ref.watch(analyticsWaterEntriesProvider);
  final entries = waterAsync.value ?? [];

  final daysCount = end.difference(start).inDays + 1;
  final map = <DateTime, int>{};

  for (int i = 0; i < daysCount; i++) {
    final d = DateTime(start.year, start.month, start.day + i);
    map[d] = 0;
  }

  for (final e in entries) {
    final d = DateTime(e.entryDate.year, e.entryDate.month, e.entryDate.day);
    if (map.containsKey(d)) {
      map[d] = (map[d] ?? 0) + e.amountMl;
    }
  }

  return map.entries.map((e) => DailyWaterData(date: e.key, amountMl: e.value)).toList();
});

/// Сглаженный тренд веса (7-дневное скользящее среднее / Moving Average)
class WeightTrendPoint {
  const WeightTrendPoint({
    required this.date,
    required this.rawWeight,
    required this.movingAverage,
  });

  final DateTime date;
  final double rawWeight;
  final double movingAverage;
}

final weightTrendListProvider = Provider<List<WeightTrendPoint>>((ref) {
  final weightAsync = ref.watch(analyticsWeightEntriesProvider);
  final list = weightAsync.value ?? [];
  if (list.isEmpty) return [];

  final points = <WeightTrendPoint>[];

  for (int i = 0; i < list.length; i++) {
    final current = list[i];

    // Окно для Moving Average: берем до 3 предыдущих и до 3 последующих (окно 7)
    final startIdx = (i - 3).clamp(0, list.length - 1);
    final endIdx = (i + 3).clamp(0, list.length - 1);

    double sum = 0;
    int count = 0;
    for (int k = startIdx; k <= endIdx; k++) {
      sum += list[k].weightKg;
      count++;
    }

    final ma = count > 0 ? sum / count : current.weightKg;

    points.add(
      WeightTrendPoint(
        date: current.entryDate,
        rawWeight: current.weightKg,
        movingAverage: ma,
      ),
    );
  }

  return points;
});
