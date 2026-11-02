import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/achievement_dao.dart';
export '../../../../core/database/daos/achievement_dao.dart';

/// Реактивный стрим всех достижений с текущим прогрессом
final achievementsProvider = StreamProvider<List<AchievementWithStatus>>((ref) {
  final dao = ref.watch(achievementDaoProvider);
  // Запускаем фоновую синхронизацию актуальных данных
  dao.syncAchievements();
  return dao.watchAchievementsWithStatus();
});

/// Провайдер текущей статистики привычек и серий
final habitStatsProvider = FutureProvider<HabitStats>((ref) async {
  final dao = ref.watch(achievementDaoProvider);
  await dao.syncAchievements();
  return dao.getHabitStats();
});
