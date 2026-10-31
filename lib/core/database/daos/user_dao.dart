import 'package:drift/drift.dart';
import '../app_database.dart';

/// DAO для работы с профилем пользователя
class UserDao {
  UserDao(this.db);

  final AppDatabase db;

  /// Получить единственный активный профиль пользователя
  Future<UserProfile?> getProfile() {
    return (db.select(db.userProfiles)..limit(1)).getSingleOrNull();
  }

  /// Реактивный стрим изменений профиля пользователя
  Stream<UserProfile?> watchProfile() {
    return (db.select(db.userProfiles)..limit(1)).watchSingleOrNull();
  }

  /// Сохранить профиль (создание или перезапись)
  Future<int> saveProfile(UserProfilesCompanion profile) async {
    final existing = await getProfile();
    if (existing != null) {
      final updated = profile.copyWith(id: Value(existing.id));
      await db.update(db.userProfiles).replace(updated);
      return existing.id;
    } else {
      return db.into(db.userProfiles).insert(profile);
    }
  }

  /// Быстрое обновление текущего веса в профиле
  Future<void> updateWeight(double newWeightKg) async {
    final profile = await getProfile();
    if (profile != null) {
      await (db.update(db.userProfiles)..where((t) => t.id.equals(profile.id))).write(
        UserProfilesCompanion(
          currentWeightKg: Value(newWeightKg),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }
}
