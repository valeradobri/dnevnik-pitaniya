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

    final prot = (nutriments['proteins_100g'] as num?)?.toDouble() ??
        (nutriments['proteins_value'] as num?)?.toDouble() ??
        (nutriments['proteins'] as num?)?.toDouble() ??
        0.0;

    final fats = (nutriments['fat_100g'] as num?)?.toDouble() ??
        (nutriments['fat_value'] as num?)?.toDouble() ??
        (nutriments['fat'] as num?)?.toDouble() ??
        0.0;

    final carb = (nutriments['carbohydrates_100g'] as num?)?.toDouble() ??
        (nutriments['carbohydrates_value'] as num?)?.toDouble() ??
        (nutriments['carbohydrates'] as num?)?.toDouble() ??
        0.0;

    // Извлечение калорий (в ккал) с несколькими фолбэками
    double cals = 0.0;
    if (nutriments['energy-kcal_100g'] != null) {
      cals = (nutriments['energy-kcal_100g'] as num).toDouble();
    } else if (nutriments['energy-kcal_value'] != null) {
      cals = (nutriments['energy-kcal_value'] as num).toDouble();
    } else if (nutriments['energy-kcal'] != null) {
      cals = (nutriments['energy-kcal'] as num).toDouble();
    } else if (nutriments['energy_100g'] != null) {
      // КДж в Ккал
      cals = (nutriments['energy_100g'] as num).toDouble() / 4.184;
    } else if (nutriments['energy_value'] != null) {
      final unit = (nutriments['energy_unit'] as String?)?.toLowerCase();
      final val = (nutriments['energy_value'] as num).toDouble();
      cals = unit == 'kcal' ? val : val / 4.184;
    }

    // Если калории не указаны явно, но есть БЖУ — считаем по формуле Этуотера
    if (cals <= 0 && (prot > 0 || fats > 0 || carb > 0)) {
      cals = (prot * 4.0) + (fats * 9.0) + (carb * 4.0);
    }

    // Наименование с приоритетом русского языка
    String productName = 'Продукт без названия';
    final nameRu = (json['product_name_ru'] as String?)?.trim();
    final nameGen = (json['product_name'] as String?)?.trim();
    final genericRu = (json['generic_name_ru'] as String?)?.trim();
    final genericGen = (json['generic_name'] as String?)?.trim();

    if (nameRu != null && nameRu.isNotEmpty) {
      productName = nameRu;
    } else if (nameGen != null && nameGen.isNotEmpty) {
      productName = nameGen;
    } else if (genericRu != null && genericRu.isNotEmpty) {
      productName = genericRu;
    } else if (genericGen != null && genericGen.isNotEmpty) {
      productName = genericGen;
    }

    // Бренд
    String? brands = (json['brands'] as String?)?.trim();
    if (brands != null && brands.contains(',')) {
      brands = brands.split(',').first.trim();
    }
    if (brands != null && brands.isEmpty) brands = null;

    final barcode = json['code'] as String?;

    // Определение категории
    final category = _detectCategory(json, productName);

    return RemoteFoodProduct(
      name: productName,
      brand: brands,
      barcode: barcode,
      calories: cals,
      protein: prot,
      fat: fats,
      carbs: carb,
      category: category,
    );
  }

  static String _detectCategory(Map<String, dynamic> json, String name) {
    final tags = (json['categories_tags'] as List<dynamic>?)
            ?.map((e) => e.toString().toLowerCase())
            .toList() ??
        [];
    final text = '${name.toLowerCase()} ${tags.join(' ')}';

    if (text.contains('молок') ||
        text.contains('творог') ||
        text.contains('сыр') ||
        text.contains('сметан') ||
        text.contains('йогурт') ||
        text.contains('кефир') ||
        text.contains('dairy')) {
      return 'dairy';
    }
    if (text.contains('хлеб') ||
        text.contains('батон') ||
        text.contains('лаваш') ||
        text.contains('булоч') ||
        text.contains('тост') ||
        text.contains('bakery')) {
      return 'bakery';
    }
    if (text.contains('гречк') ||
        text.contains('рис') ||
        text.contains('овсянк') ||
        text.contains('макарон') ||
        text.contains('хлопья') ||
        text.contains('круп') ||
        text.contains('спагетти') ||
        text.contains('cereal')) {
      return 'cereals';
    }
    if (text.contains('куриц') ||
        text.contains('индейк') ||
        text.contains('говядин') ||
        text.contains('свинин') ||
        text.contains('мясо') ||
        text.contains('колбас') ||
        text.contains('сосиск') ||
        text.contains('ветчин') ||
        text.contains('meat')) {
      return 'meat';
    }
    if (text.contains('рыб') ||
        text.contains('тунец') ||
        text.contains('лосось') ||
        text.contains('форель') ||
        text.contains('fish')) {
      return 'fish';
    }
    if (text.contains('вод') ||
        text.contains('сок') ||
        text.contains('кофе') ||
        text.contains('чай') ||
        text.contains('напиток') ||
        text.contains('drink') ||
        text.contains('beverage')) {
      return 'drinks';
    }
    if (text.contains('яблок') ||
        text.contains('банан') ||
        text.contains('фрукт') ||
        text.contains('ягод') ||
        text.contains('fruit')) {
      return 'fruits';
    }
    if (text.contains('огур') ||
        text.contains('помидор') ||
        text.contains('томат') ||
        text.contains('овощ') ||
        text.contains('vegetable')) {
      return 'vegetables';
    }
    if (text.contains('шоколад') ||
        text.contains('батончик') ||
        text.contains('конфет') ||
        text.contains('печень') ||
        text.contains('слад') ||
        text.contains('sweet')) {
      return 'sweets';
    }

    return 'other';
  }
}

/// HTTP клиент для Open Food Facts API с каскадным поиском ru -> world
class OpenFoodFactsClient {
  OpenFoodFactsClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _timeout = Duration(seconds: 4);

  static const _headers = {
    'User-Agent': 'DnevnikNutritionApp - Android/iOS - Version 1.0.0',
    'Accept': 'application/json',
  };

  /// Поиск продуктов по строке запроса с фолбэком на мировую базу
  Future<List<RemoteFoodProduct>> searchProducts(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return [];

    // 1. Поиск в русском регионе
    final ruResults = await _searchEndpoint(
      'https://ru.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(clean)}&search_simple=1&action=process&json=1&page_size=20',
    );
    if (ruResults.isNotEmpty) return ruResults;

    // 2. Фолбэк на общемировой регион
    return _searchEndpoint(
      'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(clean)}&search_simple=1&action=process&json=1&page_size=20',
    );
  }

  Future<List<RemoteFoodProduct>> _searchEndpoint(String url) async {
    try {
      final response = await _client.get(Uri.parse(url), headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final productsJson = data['products'] as List<dynamic>? ?? [];

        return productsJson
            .whereType<Map<String, dynamic>>()
            .map((p) => RemoteFoodProduct.fromJson(p))
            .where((p) =>
                p.name.isNotEmpty &&
                p.name != 'Продукт без названия' &&
                (p.calories > 0 || p.protein > 0 || p.fat > 0 || p.carbs > 0))
            .toList();
      }
    } catch (e) {
      debugPrint('OpenFoodFacts Search error: $e');
    }
    return [];
  }

  /// Каскадный поиск по штрихкоду:
  /// 1. ru.openfoodfacts.org (v2)
  /// 2. world.openfoodfacts.org (v2)
  /// 3. world.openfoodfacts.org (v0)
  Future<RemoteFoodProduct?> getByBarcode(String barcode) async {
    final clean = barcode.trim();
    if (clean.isEmpty) return null;

    final endpoints = [
      'https://ru.openfoodfacts.org/api/v2/product/$clean.json',
      'https://world.openfoodfacts.org/api/v2/product/$clean.json',
      'https://world.openfoodfacts.org/api/v0/product/$clean.json',
    ];

    for (final url in endpoints) {
      final product = await _fetchProduct(url);
      if (product != null) {
        return product;
      }
    }

    return null;
  }

  Future<RemoteFoodProduct?> _fetchProduct(String url) async {
    try {
      final response = await _client.get(Uri.parse(url), headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final status = data['status'];
        final productJson = data['product'] as Map<String, dynamic>?;

        if ((status == 1 || status == '1') && productJson != null) {
          final product = RemoteFoodProduct.fromJson(productJson);
          if (product.name.isNotEmpty && product.name != 'Продукт без названия') {
            return product;
          }
        }
      }
    } catch (e) {
      debugPrint('OpenFoodFacts fetch error for $url: $e');
    }
    return null;
  }
}
