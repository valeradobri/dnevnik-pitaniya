import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Модель продукта из Open Food Facts
class RemoteFoodProduct {
  const RemoteFoodProduct({
    required this.name,
    this.brand,
    this.barcode,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.servingSizeG = 100.0,
    this.category = 'other',
  });

  final String name;
  final String? brand;
  final String? barcode;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final double servingSizeG;
  final String category;

  factory RemoteFoodProduct.fromJson(Map<String, dynamic> json) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};

    // Извлечение калорий (в ккал)
    double cals = 0.0;
    if (nutriments['energy-kcal_100g'] != null) {
      cals = (nutriments['energy-kcal_100g'] as num).toDouble();
    } else if (nutriments['energy-kcal'] != null) {
      cals = (nutriments['energy-kcal'] as num).toDouble();
    } else if (nutriments['energy_100g'] != null) {
      // КДж в Ккал
      cals = (nutriments['energy_100g'] as num).toDouble() / 4.184;
    }

    final prot = (nutriments['proteins_100g'] as num?)?.toDouble() ??
        (nutriments['proteins'] as num?)?.toDouble() ??
        0.0;

    final fats = (nutriments['fat_100g'] as num?)?.toDouble() ??
        (nutriments['fat'] as num?)?.toDouble() ??
        0.0;

    final carb = (nutriments['carbohydrates_100g'] as num?)?.toDouble() ??
        (nutriments['carbohydrates'] as num?)?.toDouble() ??
        0.0;

    final productName = json['product_name_ru'] as String? ??
        json['product_name'] as String? ??
        'Продукт без названия';

    final brands = json['brands'] as String?;
    final barcode = json['code'] as String?;

    return RemoteFoodProduct(
      name: productName,
      brand: brands,
      barcode: barcode,
      calories: cals,
      protein: prot,
      fat: fats,
      carbs: carb,
    );
  }
}

/// HTTP клиент для Open Food Facts API с безопасным фолбэком при оффлайн режиме
class OpenFoodFactsClient {
  OpenFoodFactsClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 5);

  /// Поиск продуктов по строке запроса
  Future<List<RemoteFoodProduct>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(
        'https://ru.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&search_simple=1&action=process&json=1&page_size=20',
      );

      final response = await _client.get(
        uri,
        headers: {'User-Agent': 'DnevnikNutritionApp - Android/iOS - Version 1.0.0'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final productsJson = data['products'] as List<dynamic>? ?? [];

        return productsJson
            .whereType<Map<String, dynamic>>()
            .map((p) => RemoteFoodProduct.fromJson(p))
            .where((p) => p.name.isNotEmpty && (p.calories > 0 || p.protein > 0 || p.fat > 0 || p.carbs > 0))
            .toList();
      }
    } catch (e) {
      debugPrint('OpenFoodFacts API error (offline or timeout): $e');
    }
    return [];
  }

  /// Поиск по штрихкоду
  Future<RemoteFoodProduct?> getByBarcode(String barcode) async {
    if (barcode.trim().isEmpty) return null;

    try {
      final uri = Uri.parse('https://ru.openfoodfacts.org/api/v2/product/$barcode.json');
      final response = await _client.get(
        uri,
        headers: {'User-Agent': 'DnevnikNutritionApp - Android/iOS - Version 1.0.0'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 1 && data['product'] != null) {
          return RemoteFoodProduct.fromJson(data['product'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('OpenFoodFacts Barcode API error: $e');
    }
    return null;
  }
}
