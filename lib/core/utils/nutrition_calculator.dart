/// Расчёт нутриционных показателей для приложения «Дневник»
///
/// Использует формулу Миффлина-Сан Жеора как международный клинический стандарт.
/// Все методы — чистые функции без побочных эффектов для простоты тестирования.
///
/// МЕДИЦИНСКАЯ БЕЗОПАСНОСТЬ:
/// - Минимально допустимая суточная норма: 1200 ккал (женщины), 1500 ккал (мужчины).
/// - Дефицит не может быть ниже значения BMR без явного предупреждения.
/// - Данные применяются только для информационных целей, не для медицинских назначений.
abstract final class NutritionCalculator {
  // Минимальные безопасные пороги суточного потребления калорий
  static const double minCaloriesWomen = 1200.0;
  static const double minCaloriesMen = 1500.0;

  /// Коэффициенты физической активности (PAL — Physical Activity Level)
  static const Map<String, double> activityMultipliers = {
    'sedentary': 1.2,    // Сидячий: нет или минимум физической активности
    'light': 1.375,      // Лёгкий: 1-3 тренировки в неделю
    'moderate': 1.55,    // Умеренный: 3-5 тренировок в неделю
    'active': 1.725,     // Высокий: 6-7 тренировок в неделю
    'very_active': 1.9,  // Очень высокий: тяжёлый физический труд + тренировки
  };

  // ─── Формула Миффлина-Сан Жеора (BMR) ──────────────────────────────

  /// Рассчитывает базовый метаболизм (BMR) в ккал/день.
  ///
  /// [weightKg]  — вес тела в кг.
  /// [heightCm]  — рост в см.
  /// [ageYears]  — возраст в годах.
  /// [gender]    — пол: `'male'` или `'female'`.
  ///
  /// Формула:
  /// - Мужчины: BMR = 10 × вес + 6.25 × рост − 5 × возраст + 5
  /// - Женщины: BMR = 10 × вес + 6.25 × рост − 5 × возраст − 161
  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int ageYears,
    required String gender,
  }) {
    assert(weightKg > 0, 'Вес должен быть положительным');
    assert(heightCm > 0, 'Рост должен быть положительным');
    assert(ageYears > 0 && ageYears < 120, 'Некорректный возраст');

    final base = 10 * weightKg + 6.25 * heightCm - 5 * ageYears;
    return gender == 'male' ? base + 5 : base - 161;
  }

  /// Рассчитывает суточный расход энергии (TDEE) в ккал/день.
  ///
  /// [bmr]           — базовый метаболизм.
  /// [activityLevel] — уровень активности (ключ из [activityMultipliers]).
  static double calculateTdee({
    required double bmr,
    required String activityLevel,
  }) {
    final multiplier = activityMultipliers[activityLevel] ?? 1.2;
    return bmr * multiplier;
  }

  /// Рассчитывает целевое суточное потребление калорий.
  ///
  /// [tdee]        — суточный расход.
  /// [goalType]    — `'lose_weight'`, `'maintain'`, `'gain_weight'`.
  /// [weeklyRateKg] — желаемый темп изменения веса в кг/нед (0.25–1.0).
  /// [bmr]         — базовый метаболизм для защиты от экстремального дефицита.
  /// [gender]      — для выбора нижнего безопасного порога.
  ///
  /// Returns [CalorieTarget] с целевым значением и флагами безопасности.
  static CalorieTarget calculateTargetCalories({
    required double tdee,
    required String goalType,
    required double weeklyRateKg,
    required double bmr,
    required String gender,
  }) {
    // 1 кг жира ≈ 7700 ккал; дефицит/профицит в ккал/день
    final dailyDelta = weeklyRateKg * 7700 / 7;
    final minSafe = gender == 'male' ? minCaloriesMen : minCaloriesWomen;

    late double target;
    switch (goalType) {
      case 'lose_weight':
        target = tdee - dailyDelta;
        break;
      case 'gain_weight':
        target = tdee + dailyDelta;
        break;
      case 'maintain':
      default:
        target = tdee;
    }

    final bool wasClamped = target < minSafe;
    if (wasClamped) target = minSafe;

    return CalorieTarget(
      calories: target.round(),
      wasClamped: wasClamped,
      minSafe: minSafe.round(),
      tdee: tdee.round(),
    );
  }

  /// Рассчитывает распределение БЖУ в граммах.
  ///
  /// [calories]  — суточный калораж.
  /// [weightKg]  — вес тела для расчёта норм белка и жиров.
  ///
  /// Нормы:
  /// - Белки: 1.8 г/кг (4 ккал/г)
  /// - Жиры: 0.9 г/кг (9 ккал/г)
  /// - Углеводы: остаток калорий (4 ккал/г)
  static MacroTargets calculateMacros({
    required int calories,
    required double weightKg,
  }) {
    final proteinG = (weightKg * 1.8).roundToDouble();
    final fatG = (weightKg * 0.9).roundToDouble();

    final proteinKcal = proteinG * 4;
    final fatKcal = fatG * 9;
    final carbsKcal = (calories - proteinKcal - fatKcal).clamp(0, double.infinity);
    final carbsG = (carbsKcal / 4).roundToDouble();

    return MacroTargets(
      proteinG: proteinG,
      fatG: fatG,
      carbsG: carbsG,
    );
  }

  /// Рассчитывает целевое потребление воды в мл.
  ///
  /// Норма: 33 мл/кг массы тела.
  static int calculateWaterTarget({required double weightKg}) {
    return (weightKg * 33).round();
  }

  /// Пересчитывает КБЖУ продукта на заданный вес (граммы).
  ///
  /// Все нутриционные данные хранятся на 100 г — этот метод делает пересчёт.
  static NutrientAmount calculateForGrams({
    required double grams,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
  }) {
    final factor = grams / 100;
    return NutrientAmount(
      calories: caloriesPer100g * factor,
      protein: proteinPer100g * factor,
      fat: fatPer100g * factor,
      carbs: carbsPer100g * factor,
    );
  }

  /// Рассчитывает возраст из даты рождения.
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // ─── Расчёт сухого и готового продукта (варка / ужарка) ──────────────

  /// Определение типового коэффициента готовки по названию и категории.
  ///
  /// Коэффициент [k]:
  /// - k > 1.0: разваривание (крупы, бобовые, макароны увеличиваются в весе)
  /// - k < 1.0: ужарка / потеря влаги (мясо, птица, рыба уменьшаются в весе)
  /// - k = 1.0: уже готовые продукты, овощи, фрукты, хлеб
  static double getCookingCoefficient({
    required String name,
    required String category,
  }) {
    final lowerName = name.toLowerCase();

    // Если в названии уже указано, что блюдо готовое/вареное/каша на воде
    if (lowerName.contains('каша на') ||
        lowerName.contains('варен') ||
        lowerName.contains('готов') ||
        lowerName.contains('жарен') ||
        lowerName.contains('запечен')) {
      return 1.0;
    }

    // Гречка (100г сухой → ~250г каши)
    if (lowerName.contains('гречк') || lowerName.contains('гречнев')) {
      return 2.5;
    }
    // Рис (100г сухой → ~280г риса)
    if (lowerName.contains('рис')) {
      return 2.8;
    }
    // Макароны / паста (100г сухих → ~220г готовых)
    if (lowerName.contains('макарон') ||
        lowerName.contains('спагетти') ||
        lowerName.contains('паста') ||
        lowerName.contains('вермишель') ||
        lowerName.contains('лапша')) {
      return 2.2;
    }
    // Овсянка / геркулес (100г хлопьев → ~300г каши)
    if (lowerName.contains('овсян') || lowerName.contains('геркулес')) {
      return 3.0;
    }
    // Пшено, перловка, булгур, кускус, киноа, бобовые
    if (lowerName.contains('пшен') ||
        lowerName.contains('перлов') ||
        lowerName.contains('булгур') ||
        lowerName.contains('кускус') ||
        lowerName.contains('киноа') ||
        lowerName.contains('чечевиц') ||
        lowerName.contains('нут') ||
        lowerName.contains('фасол')) {
      return 2.5;
    }

    // Мясо и птица (ужарка: ~0.75)
    if (category == 'meat' ||
        lowerName.contains('куриц') ||
        lowerName.contains('курин') ||
        lowerName.contains('говядин') ||
        lowerName.contains('свинин') ||
        lowerName.contains('индейк') ||
        lowerName.contains('фарш')) {
      return 0.75;
    }

    // Рыба (ужарка: ~0.80)
    if (category == 'fish' ||
        lowerName.contains('рыб') ||
        lowerName.contains('треск') ||
        lowerName.contains('лосос') ||
        lowerName.contains('минтай') ||
        lowerName.contains('тунец')) {
      return 0.80;
    }

    // Общая категория круп
    if (category == 'cereals' || category == 'grains') {
      return 2.5;
    }

    return 1.0;
  }

  /// Рассчитывает сухой/исходный эквивалент веса (в граммах) из веса готового продукта.
  ///
  /// [cookedGrams] — вес готового блюда (например, 200 г каши на тарелке).
  /// [coefficient] — коэффициент разваривания/уварки (например, 2.5 для гречки).
  ///
  /// Формула: dryGrams = cookedGrams / coefficient.
  static double calculateDryEquivalent({
    required double cookedGrams,
    required double coefficient,
  }) {
    if (coefficient <= 0) return cookedGrams;
    return cookedGrams / coefficient;
  }

  /// Рассчитывает ожидаемый вес готового продукта из веса сухого/сырого.
  ///
  /// [dryGrams] — вес сухого продукта (например, 80 г сухой гречки).
  /// [coefficient] — коэффициент разваривания/уварки (например, 2.5 для гречки).
  ///
  /// Формула: cookedGrams = dryGrams * coefficient.
  static double calculateCookedWeight({
    required double dryGrams,
    required double coefficient,
  }) {
    return dryGrams * coefficient;
  }

  /// Пересчитывает КБЖУ продукта для указанного веса ГОТОВОГО блюда,
  /// когда нутриенты в базе заданы для сухого/сырого состояния.
  static NutrientAmount calculateForCookedGrams({
    required double cookedGrams,
    required double coefficient,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double fatPer100g,
    required double carbsPer100g,
  }) {
    final dryGrams = calculateDryEquivalent(
      cookedGrams: cookedGrams,
      coefficient: coefficient,
    );
    return calculateForGrams(
      grams: dryGrams,
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g,
      fatPer100g: fatPer100g,
      carbsPer100g: carbsPer100g,
    );
  }
}

// ─── Value Objects ──────────────────────────────────────────────────────────

/// Результат расчёта целевого калоража
final class CalorieTarget {
  const CalorieTarget({
    required this.calories,
    required this.wasClamped,
    required this.minSafe,
    required this.tdee,
  });

  /// Итоговый рекомендуемый калораж
  final int calories;

  /// Был ли калораж ограничен по минимальному безопасному порогу
  final bool wasClamped;

  /// Минимально безопасный порог (1200 / 1500 ккал)
  final int minSafe;

  /// Суточный расход (TDEE)
  final int tdee;
}

/// Распределение макронутриентов в граммах
final class MacroTargets {
  const MacroTargets({
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
  });

  final double proteinG;
  final double fatG;
  final double carbsG;
}

/// Количество нутриентов для конкретной порции
final class NutrientAmount {
  const NutrientAmount({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  final double calories;
  final double protein;
  final double fat;
  final double carbs;
}
