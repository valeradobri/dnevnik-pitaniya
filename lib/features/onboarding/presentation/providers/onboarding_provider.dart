import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/models/onboarding_data.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>((ref) {
  return OnboardingNotifier(ref);
});

class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier(this._ref) : super(const OnboardingData());

  final Ref _ref;

  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 5) {
      state = state.copyWith(currentStep: step);
    }
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
  }

  void updateBirthDate(DateTime birthDate) {
    state = state.copyWith(birthDate: birthDate);
  }

  void updateHeight(double heightCm) {
    state = state.copyWith(heightCm: heightCm);
  }

  void updateCurrentWeight(double weightKg) {
    state = state.copyWith(currentWeightKg: weightKg);
  }

  void updateTargetWeight(double weightKg) {
    state = state.copyWith(targetWeightKg: weightKg);
  }

  void updateActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
  }

  void updateGoal({required String goalType, required double weeklyRateKg}) {
    state = state.copyWith(
      goalType: goalType,
      weeklyRateKg: weeklyRateKg,
    );
  }

  void updateCustomCalories(int? calories) {
    state = state.copyWith(customCalories: calories);
  }

  /// Завершение онбординга: сохранение профиля и стартового веса в Drift БД
  Future<void> completeOnboarding(SharedPreferences prefs) async {
    final userDao = _ref.read(userDaoProvider);
    final weightDao = _ref.read(weightDaoProvider);

    final birth = state.birthDate ??
        DateTime.now().subtract(const Duration(days: 365 * 28));

    final macros = state.macros;
    final displayName = state.name.trim().isEmpty ? 'Пользователь' : state.name.trim();

    final profileCompanion = UserProfilesCompanion(
      name: Value(displayName),
      birthDate: Value(birth),
      gender: Value(state.gender),
      heightCm: Value(state.heightCm),
      currentWeightKg: Value(state.currentWeightKg),
      targetWeightKg: Value(state.targetWeightKg),
      activityLevel: Value(state.activityLevel),
      goalType: Value(state.goalType),
      weeklyRateKg: Value(state.weeklyRateKg),
      targetCalories: Value(state.finalCalories),
      targetProteinG: Value(macros.proteinG),
      targetFatG: Value(macros.fatG),
      targetCarbsG: Value(macros.carbsG),
      targetWaterMl: Value(state.targetWaterMl),
      updatedAt: Value(DateTime.now()),
    );

    // Сохраняем профиль
    await userDao.saveProfile(profileCompanion);

    // Записываем стартовую точку веса
    await weightDao.addWeight(
      weightKg: state.currentWeightKg,
      date: DateTime.now(),
      notes: 'Стартовый вес при настройке профиля',
    );

    // Фиксируем завершение онбординга
    await prefs.setBool('onboarding_complete', true);
  }
}
