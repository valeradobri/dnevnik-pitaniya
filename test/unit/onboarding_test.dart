import 'package:flutter_test/flutter_test.dart';
import 'package:dnevnik/features/onboarding/domain/models/onboarding_data.dart';

void main() {
  group('OnboardingData Domain Model Tests', () {
    test('Default values create valid baseline metrics', () {
      const data = OnboardingData();

      expect(data.currentStep, equals(0));
      expect(data.gender, equals('female'));
      expect(data.heightCm, equals(170.0));
      expect(data.currentWeightKg, equals(70.0));
      expect(data.targetWeightKg, equals(65.0));

      // BMR для женщины 70 кг, 170 см, 28 лет:
      // 10*70 + 6.25*170 - 5*28 - 161 = 700 + 1062.5 - 140 - 161 = 1461.5
      expect(data.bmr, equals(1461.5));

      // TDEE для moderate (x1.55):
      // 1461.5 * 1.55 = 2265.325
      expect(data.tdee, closeTo(2265.3, 0.1));

      // CalorieTarget для lose_weight 0.5 кг/нед:
      // 2265.325 - 550 = 1715.325 -> 1715 ккал
      expect(data.finalCalories, equals(1715));

      // БЖУ:
      // Белки: 70 * 1.8 = 126 г
      // Жиры: 70 * 0.9 = 63 г
      // Углеводы: (1715 - 126*4 - 63*9) / 4 = (1715 - 504 - 567) / 4 = 644 / 4 = 161 г
      final macros = data.macros;
      expect(macros.proteinG, equals(126.0));
      expect(macros.fatG, equals(63.0));
      expect(macros.carbsG, equals(161.0));

      // Норма воды: 70 * 33 = 2310 мл
      expect(data.targetWaterMl, equals(2310));

      // ИМТ: 70 / (1.7 * 1.7) = 24.22
      expect(data.bmi, closeTo(24.2, 0.1));
    });

    test('Male calculations apply correct formula and clamp', () {
      const data = OnboardingData(
        gender: 'male',
        currentWeightKg: 85.0,
        heightCm: 182.0,
        activityLevel: 'active', // 1.725
        goalType: 'maintain',
      );

      // BMR: 10*85 + 6.25*182 - 5*28 + 5 = 850 + 1137.5 - 140 + 5 = 1852.5
      expect(data.bmr, equals(1852.5));

      // TDEE: 1852.5 * 1.725 = 3195.56
      expect(data.tdee, closeTo(3195.5, 0.1));

      expect(data.finalCalories, equals(3196));
    });

    test('Custom calories override calculated calories', () {
      const data = OnboardingData(customCalories: 2100);
      expect(data.finalCalories, equals(2100));
    });
  });
}
