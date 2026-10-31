import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/diary_dao.dart';
export '../../../../core/database/daos/diary_dao.dart';

/// Выбранная дата для просмотра дашборда и дневника (по умолчанию сегодня)
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Реактивный профиль пользователя
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final userDao = ref.watch(userDaoProvider);
  return userDao.watchProfile();
});

/// Реактивные сводные КБЖУ за выбранную дату
final dateTotalsProvider = StreamProvider.family<DayTotals, DateTime>((ref, date) {
  final diaryDao = ref.watch(diaryDaoProvider);
  return diaryDao.watchTotalsForDate(date);
});

/// Реактивный суммарный объем воды за выбранную дату (мл)
final dateWaterProvider = StreamProvider.family<int, DateTime>((ref, date) {
  final waterDao = ref.watch(waterDaoProvider);
  return waterDao.watchTotalWaterMlForDate(date);
});

/// Реактивный список записей воды за выбранную дату
final dateWaterEntriesProvider = StreamProvider.family<List<WaterEntry>, DateTime>((ref, date) {
  final waterDao = ref.watch(waterDaoProvider);
  return waterDao.watchWaterEntriesForDate(date);
});

/// Реактивный список записей дневника за выбранную дату
final dateDiaryEntriesProvider = StreamProvider.family<List<DiaryEntry>, DateTime>((ref, date) {
  final diaryDao = ref.watch(diaryDaoProvider);
  return diaryDao.watchEntriesForDate(date);
});

/// Последняя запись взвешивания
final latestWeightProvider = StreamProvider<WeightEntry?>((ref) {
  final weightDao = ref.watch(weightDaoProvider);
  return weightDao.watchWeightHistory().map((list) => list.isNotEmpty ? list.first : null);
});
