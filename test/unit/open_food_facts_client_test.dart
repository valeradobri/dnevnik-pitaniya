import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/food_database/data/open_food_facts_client.dart';

void main() {
  group('RemoteFoodProduct & OpenFoodFactsClient Tests', () {
    test('RemoteFoodProduct.fromJson correctly parses energy, macros and detects categories', () {
      final json = {
        'code': '4607053473544',
        'product_name_ru': 'Молоко Простоквашино 2.5%',
        'brands': 'Простоквашино',
        'nutriments': {
          'energy-kj_100g': 225,
          'energy_100g': 225,
          'proteins_100g': 2.9,
          'fat_100g': 2.5,
          'carbohydrates_100g': 4.9,
        },
        'categories_tags': ['en:dairies', 'en:milks'],
      };

      final product = RemoteFoodProduct.fromJson(json);

      expect(product.barcode, equals('4607053473544'));
      expect(product.name, equals('Молоко Простоквашино 2.5%'));
      expect(product.brand, equals('Простоквашино'));
      expect(product.protein, equals(2.9));
      expect(product.fat, equals(2.5));
      expect(product.carbs, equals(4.9));
      expect(product.category, equals('dairy'));
      // 225 kJ / 4.184 ≈ 53.8 kcal
      expect(product.calories, closeTo(53.8, 0.5));
    });

    test('RemoteFoodProduct.fromJson falls back to Atwater formula when energy is 0', () {
      final json = {
        'code': '12345678',
        'product_name': 'Грудка куриная вареная',
        'nutriments': {
          'proteins_100g': 30.0,
          'fat_100g': 2.0,
          'carbohydrates_100g': 0.0,
        },
        'categories_tags': ['en:meats'],
      };

      final product = RemoteFoodProduct.fromJson(json);

      // 30 * 4 + 2 * 9 = 120 + 18 = 138 kcal
      expect(product.calories, equals(138.0));
      expect(product.category, equals('meat'));
    });

    test('OpenFoodFactsClient getByBarcode falls back to world.openfoodfacts.org when ru returns 404', () async {
      final mockClient = MockClient((request) async {
        final url = request.url.toString();
        if (url.contains('ru.openfoodfacts.org')) {
          return http.Response('{"status": 0}', 404);
        }
        if (url.contains('world.openfoodfacts.org/api/v2')) {
          final body = jsonEncode({
            'status': 1,
            'code': '8076809513753',
            'product': {
              'code': '8076809513753',
              'product_name': 'Barilla Pesto alla Genovese',
              'brands': 'Barilla',
              'nutriments': {
                'energy-kcal_100g': 482.0,
                'proteins_100g': 5.0,
                'fat_100g': 46.0,
                'carbohydrates_100g': 9.8,
              },
            },
          });
          return http.Response(body, 200);
        }
        return http.Response('{"status": 0}', 404);
      });

      final client = OpenFoodFactsClient(client: mockClient);
      final product = await client.getByBarcode('8076809513753');

      expect(product, isNotNull);
      expect(product!.name, equals('Barilla Pesto alla Genovese'));
      expect(product.brand, equals('Barilla'));
      expect(product.calories, equals(482.0));
    });
  });

  group('Branded Barcodes Seed Integration Tests', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.seedFoodProducts();
    });

    tearDown(() async {
      await db.close();
    });

    test('seedFoodProducts successfully populates database with pre-seeded branded barcodes', () async {
      final all = await db.foodDao.getAllFoods();
      // Should have ~100 basic + ~300 branded products
      expect(all.length, greaterThan(350));

      // Check specific popular brand barcodes
      final milk = await db.foodDao.getFoodByBarcode('4607053473544');
      expect(milk, isNotNull);
      expect(milk!.name, contains('Молоко'));
      expect(milk.brand, equals('Простоквашино'));

      final sourCream = await db.foodDao.getFoodByBarcode('4600605029275');
      expect(sourCream, isNotNull);
      expect(sourCream!.name, contains('Сметана 15%'));
    });
  });
}
