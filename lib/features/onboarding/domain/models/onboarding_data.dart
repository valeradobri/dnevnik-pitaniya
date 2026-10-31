import 'package:equatable/equatable.dart';
import '../../../../core/utils/nutrition_calculator.dart';

/// Данные, собираемые в процессе интерактивного онбординга
class OnboardingData extends Equatable {
  const OnboardingData({
    this.currentStep = 0,
    this.name = '',
    this.gender = 'female',
    this.birthDate,
    this.heightCm = 170.0,
    this.currentWeightKg = 70.0,
    this.targetWeightKg = 65.0,
    this.activityLevel = 'moderate',
    this.goalType = 'lose_weight',
    this.weeklyRateKg = 0.5,
    this.customCalories,
  });

  final int currentStep;
  final String name;
  final String gender;
  final DateTime? birthDate;
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final String activityLevel;
  final String goalType;
  final double weeklyRateKg;
  final int? customCalories;

  /// Возраст пользователя (по умолчанию 28 лет, если дата рождения не указана)
  int get ageYears {
    if (birthDate != null) {
      return NutritionCalculator.calculateAge(birthDate!);
    }
    return 28;
  }

  /// Расчет базового метаболизма (BMR)
  double get bmr => NutritionCalculator.calculateBmr(
        weightKg: currentWeightKg,
        heightCm: heightCm,
        ageYears: ageYears,
        gender: gender,
      );

  /// Расчет суточного расхода калорий (TDEE)
  double get tdee => NutritionCalculator.calculateTdee(
        bmr: bmr,
        activityLevel: activityLevel,
      );

  /// Расчет целевого суточного калоража
  CalorieTarget get calorieTarget => NutritionCalculator.calculateTargetCalories(
        tdee: tdee,
        goalType: goalType,
        weeklyRateKg: weeklyRateKg,
        bmr: bmr,
        gender: gender,
      );

  /// Итоговые целевые калории (рассчитанные или кастомные)
  int get finalCalories => customCalories ?? calorieTarget.calories;

  /// Расчет макронутриентов
  MacroTargets get macros => NutritionCalculator.calculateMacros(
        calories: finalCalories,
        weightKg: currentWeightKg,
      );

  /// Расчет целевой воды
  int get targetWaterMl => NutritionCalculator.calculateWaterTarget(
        weightKg: currentWeightKg,
      );

  /// Индекс массы тела (ИМТ)
  double get bmi {
    final heightM = heightCm / 100.0;
    if (heightM <= 0) return 0.0;
    return currentWeightKg / (heightM * heightM);
  }

  OnboardingData copyWith({
    int? currentStep,
    String? name,
    String? gender,
    DateTime? birthDate,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    String? activityLevel,
    String? goalType,
    double? weeklyRateKg,
    int? customCalories,
  }) {
    return OnboardingData(
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goalType: goalType ?? this.goalType,
      weeklyRateKg: weeklyRateKg ?? this.weeklyRateKg,
      customCalories: customCalories ?? this.customCalories,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        name,
        gender,
        birthDate,
        heightCm,
        currentWeightKg,
        targetWeightKg,
        activityLevel,
        goalType,
        weeklyRateKg,
        customCalories,
      ];
}
