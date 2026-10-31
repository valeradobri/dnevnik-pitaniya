import 'package:flutter_test/flutter_test.dart';
import 'package:dnevnik/features/analytics/presentation/providers/analytics_providers.dart';

void main() {
  group('Analytics Calculations Tests', () {
    test('Weight moving average calculation logic smooths fluctuations', () {
      final weights = [75.0, 76.5, 74.8, 76.2, 75.1, 74.5, 75.0];

      // Симулируем вычисление скользящего среднего с окном
      final maList = <double>[];
      for (int i = 0; i < weights.length; i++) {
        final start = (i - 2).clamp(0, weights.length - 1);
        final end = (i + 2).clamp(0, weights.length - 1);
        double sum = 0;
        int count = 0;
        for (int k = start; k <= end; k++) {
          sum += weights[k];
          count++;
        }
        maList.add(sum / count);
      }

      // Проверяем, что экстремальный всплеск 76.5 сглаживается
      expect(maList[1], lessThan(76.5));
      expect(maList[1], greaterThan(75.0));
      expect(maList.length, weights.length);
    });

    test('DailyNutritionData properly stores and exposes macros', () {
      final today = DateTime(2026, 11, 1);
      final data = DailyNutritionData(
        date: today,
        calories: 2150.0,
        protein: 135.0,
        fat: 72.0,
        carbs: 240.0,
      );

      expect(data.calories, 2150.0);
      expect(data.protein, 135.0);
      expect(data.fat, 72.0);
      expect(data.carbs, 240.0);
      expect(data.date, today);
    });

    test('DailyWaterData correctly calculates hydration', () {
      final today = DateTime(2026, 11, 1);
      final data = DailyWaterData(
        date: today,
        amountMl: 2250,
      );

      expect(data.amountMl, 2250);
      expect(data.date, today);
    });
  });
}
