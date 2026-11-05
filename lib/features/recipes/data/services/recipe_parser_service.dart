import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/database/app_database.dart';

/// Ингредиент, извлечённый из рецепта
class ParsedIngredient {
  ParsedIngredient({
    required this.rawText,
    required this.cleanName,
    required this.grams,
    this.matchedProduct,
    this.notes,
    this.isIncluded = true,
  });

  /// Исходный текст со страницы сайта (например: «Куриное филе — 400 г»)
  final String rawText;

  /// Очищенное название продукта
  String cleanName;

  /// Рассчитанный вес в граммах
  double grams;

  /// Найденный продукт из локальной базы каталога
  FoodProduct? matchedProduct;

  /// Заметка или уточнение
  String? notes;

  /// Включён ли ингредиент в финальный рецепт
  bool isIncluded;
}

/// Распарсенный рецепт из веб-страницы
class ParsedRecipe {
  ParsedRecipe({
    required this.title,
    required this.category,
    required this.prepTimeMinutes,
    required this.servings,
    required this.instructions,
    required this.ingredients,
    this.imageUrl,
    this.sourceUrl,
    this.description,
  });

  String title;
  String category;
  int prepTimeMinutes;
  int servings;
  String instructions;
  String? description;
  String? imageUrl;
  String? sourceUrl;
  List<ParsedIngredient> ingredients;
}

/// Сервис импорта и парсинга рецептов по URL через Schema.org JSON-LD и мета-теги
class RecipeParserService {
  const RecipeParserService();

  /// Загрузка и разбор рецепта по URL с автоматическим сопоставлением ингредиентов
  Future<ParsedRecipe> parseRecipeFromUrl(String url, List<FoodProduct> localFoods) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty || !cleanUrl.startsWith(RegExp(r'https?:\/\/'))) {
      throw const FormatException('Введите корректную ссылку, начинающуюся с http:// или https://');
    }

    final uri = Uri.parse(cleanUrl);
    final response = await http.get(
      uri,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
      },
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Превышено время ожидания ответа от кулинарного сайта (таймаут 15 сек).'),
    );

    if (response.statusCode >= 400) {
      throw Exception('Не удалось загрузить страницу (код ошибки сервера: ${response.statusCode})');
    }

    final html = utf8.decode(response.bodyBytes, allowMalformed: true);
    return parseRecipeHtml(html, sourceUrl: cleanUrl, localFoods: localFoods);
  }

  /// Парсинг HTML-кода страницы
  ParsedRecipe parseRecipeHtml(
    String html, {
    String? sourceUrl,
    List<FoodProduct> localFoods = const [],
  }) {
    // 1. Поиск Schema.org JSON-LD
    final jsonLdMap = _findRecipeJsonLd(html);

    if (jsonLdMap != null) {
      return _buildRecipeFromJsonLd(jsonLdMap, sourceUrl: sourceUrl, localFoods: localFoods);
    }

    // 2. Fallback: поиск по OpenGraph / Meta тегам
    return _buildRecipeFromMeta(html, sourceUrl: sourceUrl, localFoods: localFoods);
  }

  /// Поиск блока Schema.org с типом "Recipe"
  Map<String, dynamic>? _findRecipeJsonLd(String html) {
    final scriptRegex = RegExp(
      r'<script[^>]*type=[\s"\x27]*application/ld\+json[\s"\x27]*[^>]*>([\s\S]*?)</script>',
      caseSensitive: false,
    );

    for (final match in scriptRegex.allMatches(html)) {
      final jsonStr = match.group(1)?.trim();
      if (jsonStr == null || jsonStr.isEmpty) continue;

      try {
        final decoded = jsonDecode(jsonStr);
        final recipeNode = _extractRecipeNode(decoded);
        if (recipeNode != null) return recipeNode;
      } catch (_) {
        // Игнорируем некорректный JSON в других блоках
      }
    }
    return null;
  }

  /// Рекурсивный поиск узла "@type": "Recipe"
  Map<String, dynamic>? _extractRecipeNode(dynamic json) {
    if (json is Map<String, dynamic>) {
      final type = json['@type'];
      if (_isRecipeType(type)) return json;

      if (json.containsKey('@graph') && json['@graph'] is List) {
        for (final item in json['@graph']) {
          final res = _extractRecipeNode(item);
          if (res != null) return res;
        }
      }
    } else if (json is List) {
      for (final item in json) {
        final res = _extractRecipeNode(item);
        if (res != null) return res;
      }
    }
    return null;
  }

  bool _isRecipeType(dynamic type) {
    if (type == null) return false;
    if (type is String) return type.toLowerCase() == 'recipe';
    if (type is List) {
      return type.any((t) => t.toString().toLowerCase() == 'recipe');
    }
    return false;
  }

  /// Построение ParsedRecipe из Schema.org данных
  ParsedRecipe _buildRecipeFromJsonLd(
    Map<String, dynamic> json, {
    String? sourceUrl,
    required List<FoodProduct> localFoods,
  }) {
    final rawTitle = json['name']?.toString() ?? 'Без названия';
    final title = _decodeHtmlEntities(rawTitle).trim();

    final rawDesc = json['description']?.toString();
    final description = rawDesc != null ? _decodeHtmlEntities(rawDesc).trim() : null;

    // Картинка
    String? imageUrl;
    final imgField = json['image'];
    if (imgField is String) {
      imageUrl = imgField;
    } else if (imgField is List && imgField.isNotEmpty) {
      imageUrl = imgField.first.toString();
    } else if (imgField is Map && imgField['url'] != null) {
      imageUrl = imgField['url'].toString();
    }

    // Время приготовления
    int prepTime = 30;
    final totalTimeRaw = json['totalTime'] ?? json['cookTime'] ?? json['prepTime'];
    if (totalTimeRaw != null) {
      prepTime = _parseIsoDuration(totalTimeRaw.toString()) ?? 30;
    }

    // Количество порций
    int servings = 2;
    final yieldRaw = json['recipeYield'];
    if (yieldRaw != null) {
      servings = _parseServings(yieldRaw) ?? 2;
    }

    // Категория
    final category = _detectCategory(
      title: title,
      categoryField: json['recipeCategory']?.toString(),
    );

    // Шаги приготовления (инструкции)
    final instructions = _parseInstructions(json['recipeInstructions'], description: description);

    // Ингредиенты
    final rawIngredients = json['recipeIngredient'];
    final parsedIngredients = <ParsedIngredient>[];

    if (rawIngredients is List) {
      for (final item in rawIngredients) {
        final str = item.toString().trim();
        if (str.isEmpty) continue;
        parsedIngredients.add(_parseIngredientString(str, localFoods));
      }
    }

    return ParsedRecipe(
      title: title,
      category: category,
      prepTimeMinutes: prepTime,
      servings: servings,
      description: description,
      instructions: instructions,
      imageUrl: imageUrl,
      sourceUrl: sourceUrl,
      ingredients: parsedIngredients,
    );
  }

  /// Fallback из OpenGraph и стандартных тегов
  ParsedRecipe _buildRecipeFromMeta(
    String html, {
    String? sourceUrl,
    required List<FoodProduct> localFoods,
  }) {
    String? title = _findMetaContent(html, 'og:title');
    if (title == null || title.isEmpty) {
      final titleMatch = RegExp(r'<title[^>]*>([\s\S]*?)<\/title>', caseSensitive: false).firstMatch(html);
      title = titleMatch?.group(1)?.split(RegExp(r'[\-\|\—]')).first.trim();
    }
    title = _decodeHtmlEntities(title ?? 'Импортированный рецепт').trim();

    String? desc = _findMetaContent(html, 'og:description') ?? _findMetaContent(html, 'description');
    if (desc != null) desc = _decodeHtmlEntities(desc).trim();

    final image = _findMetaContent(html, 'og:image');
    final category = _detectCategory(title: title, categoryField: null);

    return ParsedRecipe(
      title: title,
      category: category,
      prepTimeMinutes: 30,
      servings: 2,
      description: desc,
      instructions: desc != null && desc.isNotEmpty
          ? 'Шаги приготовления:\n1. $desc'
          : 'Шаги приготовления:\n1. Подготовьте необходимые ингредиенты.\n2. Приготовьте блюдо согласно вашим предпочтениям.',
      imageUrl: image,
      sourceUrl: sourceUrl,
      ingredients: [],
    );
  }

  String? _findMetaContent(String html, String propName) {
    final reg = RegExp(
      '<meta[^>]*(?:property|name)=["\']${RegExp.escape(propName)}["\'][^>]*content=["\']([^"\']+)["\']',
      caseSensitive: false,
    );
    final match = reg.firstMatch(html);
    if (match != null) return match.group(1);

    // Обратный порядок атрибутов content и property
    final regRev = RegExp(
      '<meta[^>]*content=["\']([^"\']+)["\'][^>]*(?:property|name)=["\']${RegExp.escape(propName)}["\']',
      caseSensitive: false,
    );
    return regRev.firstMatch(html)?.group(1);
  }

  /// Парсинг строки инструкции
  String _parseInstructions(dynamic instructionsField, {String? description}) {
    if (instructionsField == null) {
      if (description != null && description.isNotEmpty) {
        return 'Шаги приготовления:\n1. $description';
      }
      return 'Шаги приготовления:\n1. Подготовьте ингредиенты и приготовьте блюдо до готовности.';
    }

    final steps = <String>[];

    if (instructionsField is String) {
      final lines = instructionsField.split(RegExp(r'[\r\n]+'));
      for (final line in lines) {
        final clean = _cleanStepText(line);
        if (clean.isNotEmpty) steps.add(clean);
      }
    } else if (instructionsField is List) {
      for (final item in instructionsField) {
        if (item is String) {
          final clean = _cleanStepText(item);
          if (clean.isNotEmpty) steps.add(clean);
        } else if (item is Map) {
          // HowToStep
          if (item['text'] != null) {
            final clean = _cleanStepText(item['text'].toString());
            if (clean.isNotEmpty) steps.add(clean);
          } else if (item['itemListElement'] is List) {
            // HowToSection
            for (final subItem in item['itemListElement'] as List) {
              if (subItem is Map && subItem['text'] != null) {
                final clean = _cleanStepText(subItem['text'].toString());
                if (clean.isNotEmpty) steps.add(clean);
              }
            }
          }
        }
      }
    }

    if (steps.isEmpty) {
      return 'Шаги приготовления:\n1. Приготовьте блюдо согласно описанию.';
    }

    final buffer = StringBuffer('Шаги приготовления:\n');
    for (int i = 0; i < steps.length; i++) {
      buffer.writeln('${i + 1}. ${steps[i]}');
    }
    return buffer.toString().trim();
  }

  String _cleanStepText(String text) {
    var clean = _decodeHtmlEntities(text).trim();
    // Убираем уже существующую нумерацию вроде "1.", "Шаг 1:", "1) "
    clean = clean.replaceFirst(RegExp(r'^(?:шаг\s*)?\d+[\.\)\:\-]\s*', caseSensitive: false), '');
    return clean.trim();
  }

  /// Разбор строки ингредиента (выделение названия, веса и поиск в каталоге)
  ParsedIngredient _parseIngredientString(String raw, List<FoodProduct> localFoods) {
    final decodedRaw = _decodeHtmlEntities(raw).trim();

    // Разделение по разделителям «—», «-», «:»
    String namePart = decodedRaw;
    String? amountPart;

    // Проверяем распространенные разделители
    final dashMatch = RegExp(r'^(.+?)\s*(?:[—–\-:]|\s-\s)\s*(.+)$').firstMatch(decodedRaw);
    if (dashMatch != null) {
      namePart = dashMatch.group(1)!.trim();
      amountPart = dashMatch.group(2)!.trim();
    } else {
      // Проверяем, если количество в начале: "500 г куриного филе", "2 яйца"
      final leadingMatch = RegExp(r'^([\d\/\.,\-]+(?:\s*[а-яёa-z\.]+)?)\s+(.+)$', caseSensitive: false)
          .firstMatch(decodedRaw);
      if (leadingMatch != null) {
        amountPart = leadingMatch.group(1)!.trim();
        namePart = leadingMatch.group(2)!.trim();
      }
    }

    final cleanName = _cleanIngredientName(namePart);
    final grams = _calculateGrams(amountPart ?? namePart, ingredientContext: cleanName);
    final matchedFood = _matchFoodProduct(cleanName, localFoods);

    return ParsedIngredient(
      rawText: decodedRaw,
      cleanName: cleanName,
      grams: grams,
      matchedProduct: matchedFood,
      notes: amountPart != null && amountPart.isNotEmpty ? amountPart : null,
      isIncluded: true,
    );
  }

  /// Извлечение граммов из текста с учетом единиц измерения и названия продукта
  double _calculateGrams(String text, {String? ingredientContext}) {
    final lower = '$text ${ingredientContext ?? ''}'.toLowerCase().replaceAll(',', '.');

    // Число (целое, дробное или обыкновенная дробь 1/2)
    double? number;
    final fracMatch = RegExp(r'(\d+)\s*\/\s*(\d+)').firstMatch(lower);
    if (fracMatch != null) {
      final num = double.tryParse(fracMatch.group(1)!);
      final den = double.tryParse(fracMatch.group(2)!);
      if (num != null && den != null && den > 0) {
        number = num / den;
      }
    } else {
      final rangeMatch = RegExp(r'(\d+(?:\.\d+)?)\s*[\-\–]\s*(\d+(?:\.\d+)?)').firstMatch(lower);
      if (rangeMatch != null) {
        final a = double.tryParse(rangeMatch.group(1)!);
        final b = double.tryParse(rangeMatch.group(2)!);
        if (a != null && b != null) number = (a + b) / 2;
      } else {
        final numMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(lower);
        if (numMatch != null) {
          number = double.tryParse(numMatch.group(1)!);
        }
      }
    }

    if (number == null || number <= 0) {
      if (lower.contains('по вкусу') || lower.contains('щепот')) return 2.0;
      return 100.0; // Значение по умолчанию
    }

    // Проверка единиц измерения
    if (lower.contains('кг') || lower.contains('килограмм')) {
      return number * 1000;
    }
    if (lower.contains('г') || lower.contains('гр') || lower.contains('грамм')) {
      return number;
    }
    if (lower.contains('мл') || lower.contains('миллилитр')) {
      return number; // 1 мл ≈ 1 г
    }
    if (lower.contains('л') || lower.contains('литр')) {
      return number * 1000;
    }
    if (lower.contains('ст. л') || lower.contains('столов')) {
      return number * 15;
    }
    if (lower.contains('ч. л') || lower.contains('чайн')) {
      return number * 5;
    }
    if (lower.contains('стакан')) {
      return number * 200;
    }
    if (lower.contains('зубчик')) {
      return number * 5;
    }
    if (lower.contains('шт') || lower.contains('штук')) {
      // Для яиц обычно 55 г
      if (lower.contains('яйц')) return number * 55;
      return number * 80;
    }

    // Если просто число меньше 10 (например 2, 3) — скорее всего штуки
    if (number <= 10) {
      return number * 55;
    }

    return number;
  }

  /// Очистка названия ингредиента от лишних слов и скобок
  String _cleanIngredientName(String raw) {
    var clean = raw
        .replaceAll(RegExp(r'\([^)]*\)'), '') // убираем скобки
        .replaceAll(RegExp(r'[0-9\.,\/]'), '') // убираем цифры
        .replaceAll(RegExp(r'\b(?:по\s+вкусу|свежий|свежая|свежие|сухой|сухая|сухие|крупный|крупная|мелкий|мелкая)\b',
            caseSensitive: false), '')
        .trim();

    // Убираем ведущие/замыкающие знаки препинания
    clean = clean.replaceAll(RegExp(r'^[\s\-\—\:\,]+|[\s\-\—\:\,]+$'), '').trim();
    if (clean.isEmpty) return raw.trim();
    return clean;
  }

  /// Поиск подходящего продукта в локальной базе данных Drift
  FoodProduct? _matchFoodProduct(String query, List<FoodProduct> foods) {
    if (foods.isEmpty) return null;
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) return null;

    final queryWords = cleanQuery
        .split(RegExp(r'[\s,\.\-]+'))
        .where((w) => w.length >= 3)
        .toList();

    int bestScore = 0;
    FoodProduct? bestProduct;

    for (final food in foods) {
      final name = food.name.toLowerCase();
      int score = 0;

      // Точное совпадение
      if (name == cleanQuery) {
        score += 100;
      } else if (name.startsWith(cleanQuery) || cleanQuery.startsWith(name)) {
        score += 80;
      } else {
        // Подсчет совпадения слов
        for (final word in queryWords) {
          if (name.contains(word)) {
            score += 25;
          }
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestProduct = food;
      }
    }

    return bestScore >= 25 ? bestProduct : null;
  }

  /// Парсинг ISO 8601 продолжительности (например: PT30M, PT1H15M)
  int? _parseIsoDuration(String iso) {
    try {
      final upper = iso.toUpperCase();
      final hoursMatch = RegExp(r'(\d+)H').firstMatch(upper);
      final minutesMatch = RegExp(r'(\d+)M').firstMatch(upper);

      int total = 0;
      if (hoursMatch != null) total += int.parse(hoursMatch.group(1)!) * 60;
      if (minutesMatch != null) total += int.parse(minutesMatch.group(1)!);

      if (total > 0) return total;

      // Если передано просто число
      final num = int.tryParse(upper.replaceAll(RegExp(r'[^\d]'), ''));
      if (num != null && num > 0) return num;
    } catch (_) {}
    return null;
  }

  /// Парсинг порций
  int? _parseServings(dynamic yieldField) {
    if (yieldField is int && yieldField > 0) return yieldField;
    final str = yieldField.toString();
    final match = RegExp(r'\d+').firstMatch(str);
    if (match != null) {
      final val = int.tryParse(match.group(0)!);
      if (val != null && val > 0 && val <= 50) return val;
    }
    return null;
  }

  /// Определение категории рецепта
  String _detectCategory({required String title, String? categoryField}) {
    final combined = '${title.toLowerCase()} ${categoryField?.toLowerCase() ?? ''}';

    if (combined.contains('завтрак') ||
        combined.contains('сырник') ||
        combined.contains('омлет') ||
        combined.contains('каша') ||
        combined.contains('овсяноблин') ||
        combined.contains('панкейк')) {
      return 'breakfast';
    }
    if (combined.contains('суп') ||
        combined.contains('борщ') ||
        combined.contains('щи') ||
        combined.contains('уха') ||
        combined.contains('солянк') ||
        combined.contains('бульон') ||
        combined.contains('крем-суп')) {
      return 'soup';
    }
    if (combined.contains('салат')) {
      return 'salad';
    }
    if (combined.contains('десерт') ||
        combined.contains('торт') ||
        combined.contains('пирог') ||
        combined.contains('печенье') ||
        combined.contains('перекус') ||
        combined.contains('выпечк') ||
        combined.contains('кекс') ||
        combined.contains('маффин')) {
      return 'snack';
    }
    if (combined.contains('ужин') ||
        combined.contains('рыба') ||
        combined.contains('лосось') ||
        combined.contains('минтай') ||
        combined.contains('треск')) {
      return 'dinner';
    }
    return 'lunch';
  }

  /// Декодирование HTML сущностей (&quot;, &#39;, &nbsp; и т.д.)
  String _decodeHtmlEntities(String input) {
    var out = input
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#160;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&#38;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll('&laquo;', '«')
        .replaceAll('&raquo;', '»');

    // Декодирование числовых сущностей &#NNN;
    out = out.replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
      final code = int.tryParse(match.group(1)!);
      if (code != null) return String.fromCharCode(code);
      return match.group(0)!;
    });

    return out;
  }
}
