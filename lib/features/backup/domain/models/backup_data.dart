/// Сводная статистика данных бэкапа для отображения превью пользователю
class BackupSummary {
  const BackupSummary({
    required this.hasProfile,
    required this.profileName,
    required this.diaryCount,
    required this.waterCount,
    required this.weightCount,
    required this.customFoodsCount,
    required this.recipesCount,
    required this.exportedAt,
  });

  final bool hasProfile;
  final String? profileName;
  final int diaryCount;
  final int waterCount;
  final int weightCount;
  final int customFoodsCount;
  final int recipesCount;
  final DateTime exportedAt;

  int get totalRecords =>
      diaryCount + waterCount + weightCount + customFoodsCount + recipesCount + (hasProfile ? 1 : 0);
}

/// Корневой контейнер резервной копии приложения «Дневник»
class BackupData {
  const BackupData({
    required this.version,
    required this.appName,
    required this.exportedAt,
    this.userProfile,
    this.diaryEntries = const [],
    this.waterEntries = const [],
    this.weightEntries = const [],
    this.customFoods = const [],
    this.recipes = const [],
  });

  final int version;
  final String appName;
  final DateTime exportedAt;
  final Map<String, dynamic>? userProfile;
  final List<Map<String, dynamic>> diaryEntries;
  final List<Map<String, dynamic>> waterEntries;
  final List<Map<String, dynamic>> weightEntries;
  final List<Map<String, dynamic>> customFoods;
  final List<Map<String, dynamic>> recipes;

  BackupSummary get summary => BackupSummary(
        hasProfile: userProfile != null,
        profileName: userProfile?['name'] as String?,
        diaryCount: diaryEntries.length,
        waterCount: waterEntries.length,
        weightCount: weightEntries.length,
        customFoodsCount: customFoods.length,
        recipesCount: recipes.length,
        exportedAt: exportedAt,
      );

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'appName': appName,
      'exportedAt': exportedAt.toIso8601String(),
      if (userProfile != null) 'userProfile': userProfile,
      'diaryEntries': diaryEntries,
      'waterEntries': waterEntries,
      'weightEntries': weightEntries,
      'customFoods': customFoods,
      'recipes': recipes,
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as int? ?? 1;
    final appName = json['appName'] as String? ?? 'Dnevnik';
    final exportedAtStr = json['exportedAt'] as String?;
    final exportedAt = exportedAtStr != null
        ? DateTime.tryParse(exportedAtStr) ?? DateTime.now()
        : DateTime.now();

    final userProfile = json['userProfile'] as Map<String, dynamic>?;

    final diaryEntries = (json['diaryEntries'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];

    final waterEntries = (json['waterEntries'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];

    final weightEntries = (json['weightEntries'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];

    final customFoods = (json['customFoods'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];

    final recipes = (json['recipes'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];

    return BackupData(
      version: version,
      appName: appName,
      exportedAt: exportedAt,
      userProfile: userProfile,
      diaryEntries: diaryEntries,
      waterEntries: waterEntries,
      weightEntries: weightEntries,
      customFoods: customFoods,
      recipes: recipes,
    );
  }
}
