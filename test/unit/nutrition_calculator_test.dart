import 'package:flutter_test/flutter_test.dart';
import 'package:dnevnik/core/utils/nutrition_calculator.dart';

void main() {
  group('NutritionCalculator — BMR (Mifflin-St Jeor)', () {
    test('Мужчина 30 лет, 80 кг, 180 см → BMR = 1780.0', () {
      final bmr = NutritionCalculator.calculateBmr(
        weightKg: 80,
        heightCm: 180,
        ageYears: 30,
        gender: 'male',
      );
      expect(bmr, closeTo(1780.0, 0.5));
    });

    test('Женщина 28 лет, 60 кг, 165 см → BMR = 1330.25', () {
      final bmr = NutritionCalculator.calculateBmr(
        weightKg: 60,
        heightCm: 165,
        ageYears: 28,
        gender: 'female',
      );
      expect(bmr, closeTo(1330.25, 0.5));
    });
  });

  group('NutritionCalculator — TDEE', () {
    test('BMR 1800 × sedentary 1.2 → TDEE = 2160', () {
      final tdee = NutritionCalculator.calculateTdee(
        bmr: 1800,
        activityLevel: 'sedentary',
      );
      expect(tdee, closeTo(2160, 0.1));
    });

    test('BMR 1800 × moderate 1.55 → TDEE = 2790', () {
      final tdee = NutritionCalculator.calculateTdee(
        bmr: 1800,
        activityLevel: 'moderate',
      );
      expect(tdee, closeTo(2790, 0.1));
    });
  });

  group('NutritionCalculator — CalorieTarget (безопасный порог)', () {
    test('Цель похудения: дефицит 500 ккал от TDEE 2000 → 1500', () {
      final target = NutritionCalculator.calculateTargetCalories(
        tdee: 2000,
        goalType: 'lose_weight',
        weeklyRateKg: 0.5,
        bmr: 1600,
        gender: 'male',
      );
      // 0.5 кг/нед × 7700 / 7 = 550 ккал дефицит → 2000 - 550 = 1450
      expect(target.calories, greaterThanOrEqualTo(1500)); // мужской минимум
    });

    test('Экстремальный дефицит ограничивается минимумом (женщины: 1200)', () {
      final target = NutritionCalculator.calculateTargetCalories(
        tdee: 1400,
        goalType: 'lose_weight',
        weeklyRateKg: 1.0, // агрессивный темп
        bmr: 1100,
        gender: 'female',
      );
      expect(target.calories, equals(1200)); // ограничено минимумом
      expect(target.wasClamped, isTrue);
    });

    test('Поддержание: цель равна TDEE', () {
      final target = NutritionCalculator.calculateTargetCalories(
        tdee: 2200,
        goalType: 'maintain',
        weeklyRateKg: 0,
        bmr: 1700,
        gender: 'male',
      );
      expect(target.calories, equals(2200));
      expect(target.wasClamped, isFalse);
    });
  });

  group('NutritionCalculator — Макронутриенты', () {
    test('2000 ккал, 75 кг → белки, жиры, углеводы корректны', () {
      const targetCal = 2000;
      const weight = 75.0;

      final macros = NutritionCalculator.calculateMacros(
        calories: targetCal,
        weightKg: weight,
      );

      // Белки ≈ 1.8 × 75 = 135 г
      expect(macros.proteinG, closeTo(135, 1));

      // Жиры ≈ 0.9 × 75 = 67.5 г
      expect(macros.fatG, closeTo(67.5, 1));

      // Углеводы: остаток калорий
      final usedKcal = macros.proteinG * 4 + macros.fatG * 9;
      final carbsKcal = targetCal - usedKcal;
      expect(macros.carbsG, closeTo(carbsKcal / 4, 2));
    });
  });

  group('NutritionCalculator — Пересчёт на граммы', () {
    test('Гречка 100г: 329 ккал на 100г → 80г = 263.2 ккал', () {
      final amount = NutritionCalculator.calculateForGrams(
        grams: 80,
        caloriesPer100g: 329,
        proteinPer100g: 12.6,
        fatPer100g: 3.3,
        carbsPer100g: 62.1,
      );
      expect(amount.calories, closeTo(263.2, 0.1));
      expect(amount.protein, closeTo(10.08, 0.1));
    });
  });

  group('NutritionCalculator — Норма воды', () {
    test('75 кг → 2475 мл (75 × 33)', () {
      final water = NutritionCalculator.calculateWaterTarget(weightKg: 75);
      expect(water, equals(2475));
    });
  });

  group('NutritionCalculator — Сухой vs Готовый продукт (разваривание / ужарка)', () {
    test('Определение коэффициента по крупам и мясу', () {
      expect(NutritionCalculator.getCookingCoefficient(name: 'Гречневая крупа', category: 'cereals'), equals(2.5));
      expect(NutritionCalculator.getCookingCoefficient(name: 'Рис басмати', category: 'cereals'), equals(2.8));
      expect(NutritionCalculator.getCookingCoefficient(name: 'Спагетти Barilla', category: 'cereals'), equals(2.2));
      expect(NutritionCalculator.getCookingCoefficient(name: 'Куриное филе', category: 'meat'), equals(0.75));
      expect(NutritionCalculator.getCookingCoefficient(name: 'Гречневая каша на воде', category: 'cereals'), equals(1.0));
    });

    test('200 г готовой гречки при k=2.5 эквивалентны 80 г сухой', () {
      final dry = NutritionCalculator.calculateDryEquivalent(
        cookedGrams: 200,
        coefficient: 2.5,
      );
      expect(dry, closeTo(80.0, 0.01));
    });

    test('80 г сухой гречки при k=2.5 дают 200 г готовой каши', () {
      final cooked = NutritionCalculator.calculateCookedWeight(
        dryGrams: 80,
        coefficient: 2.5,
      );
      expect(cooked, closeTo(200.0, 0.01));
    });

    test('Расчёт КБЖУ для 200 г готовой гречки (сухая: 313 ккал на 100 г)', () {
      // 200 г готовой = 80 г сухой → 313 * 0.8 = 250.4 ккал
      final amount = NutritionCalculator.calculateForCookedGrams(
        cookedGrams: 200,
        coefficient: 2.5,
        caloriesPer100g: 313.0,
        proteinPer100g: 12.6,
        fatPer100g: 3.3,
        carbsPer100g: 62.1,
      );
      expect(amount.calories, closeTo(250.4, 0.1));
      expect(amount.protein, closeTo(10.08, 0.1));
    });
  });
}

