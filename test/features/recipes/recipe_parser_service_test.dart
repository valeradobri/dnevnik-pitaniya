import 'package:flutter_test/flutter_test.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/recipes/data/services/recipe_parser_service.dart';

void main() {
  late RecipeParserService service;
  late List<FoodProduct> mockFoods;

  setUp(() {
    service = const RecipeParserService();
    mockFoods = [
      FoodProduct(
        id: 1,
        name: 'Творог 5%',
        caloriesPer100g: 121,
        proteinPer100g: 16.0,
        fatPer100g: 5.0,
        carbsPer100g: 3.0,
        category: 'dairy',
        servingSizeG: 100.0,
        sourceType: 'verified',
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
      FoodProduct(
        id: 2,
        name: 'Куриное филе (грудка, сырое)',
        caloriesPer100g: 113,
        proteinPer100g: 23.6,
        fatPer100g: 1.9,
        carbsPer100g: 0.4,
        category: 'meat',
        servingSizeG: 100.0,
        sourceType: 'verified',
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
      FoodProduct(
        id: 3,
        name: 'Яйцо куриное (цельное, 1 шт ~55г)',
        caloriesPer100g: 143,
        proteinPer100g: 12.7,
        fatPer100g: 11.5,
        carbsPer100g: 0.7,
        category: 'eggs',
        servingSizeG: 100.0,
        sourceType: 'verified',
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
      FoodProduct(
        id: 4,
        name: 'Овсяные хлопья «Геркулес»',
        caloriesPer100g: 352,
        proteinPer100g: 12.3,
        fatPer100g: 6.2,
        carbsPer100g: 61.8,
        category: 'cereals',
        servingSizeG: 100.0,
        sourceType: 'verified',
        isFavorite: false,
        createdAt: DateTime.now(),
      ),
    ];
  });

  test('parses Schema.org JSON-LD single recipe correctly', () {
    const htmlFixture = '''
<!DOCTYPE html>
<html>
<head>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "Recipe",
    "name": "Нежные сырники из творога",
    "description": "Идеальные домашние сырники с хрустящей корочкой.",
    "prepTime": "PT10M",
    "cookTime": "PT15M",
    "totalTime": "PT25M",
    "recipeYield": "2 порции",
    "recipeCategory": "Завтрак",
    "image": "https://example.com/syrniki.jpg",
    "recipeIngredient": [
      "Творог 5% — 300 г",
      "Яйцо куриное — 1 шт.",
      "Овсяные хлопья — 40 г"
    ],
    "recipeInstructions": [
      {
        "@type": "HowToStep",
        "text": "Разомните творог вилкой в глубокой миске."
      },
      {
        "@type": "HowToStep",
        "text": "Добавьте яйцо и муку, тщательно перемешайте."
      },
      {
        "@type": "HowToStep",
        "text": "Обжаривайте на среднем огне по 3-4 минуты с каждой стороны."
      }
    ]
  }
  </script>
</head>
<body><h1>Рецепт сырников</h1></body>
</html>
''';

    final result = service.parseRecipeHtml(
      htmlFixture,
      sourceUrl: 'https://example.com/recipe/1',
      localFoods: mockFoods,
    );

    expect(result.title, 'Нежные сырники из творога');
    expect(result.category, 'breakfast');
    expect(result.prepTimeMinutes, 25);
    expect(result.servings, 2);
    expect(result.imageUrl, 'https://example.com/syrniki.jpg');
    expect(result.ingredients.length, 3);

    // Проверяем первый ингредиент (Творог)
    expect(result.ingredients[0].cleanName.toLowerCase(), contains('творог'));
    expect(result.ingredients[0].grams, 300.0);
    expect(result.ingredients[0].matchedProduct?.id, 1);

    // Проверяем второй ингредиент (Яйцо)
    expect(result.ingredients[1].grams, 55.0);
    expect(result.ingredients[1].matchedProduct?.id, 3);

    // Проверяем инструкции
    expect(result.instructions, contains('Шаги приготовления:'));
    expect(result.instructions, contains('1. Разомните творог'));
    expect(result.instructions, contains('2. Добавьте яйцо'));
  });

  test('parses Schema.org with @graph correctly', () {
    const graphHtml = '''
<html>
<head>
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "WebSite",
        "name": "Eda Site"
      },
      {
        "@type": "Recipe",
        "name": "Куриное филе на гриле",
        "recipeCategory": "Обед",
        "totalTime": "PT20M",
        "recipeYield": 1,
        "recipeIngredient": [
          "Куриное филе — 250 г"
        ],
        "recipeInstructions": "1. Промойте и обсушите филе.\\n2. Обжарьте на гриле."
      }
    ]
  }
  </script>
</head>
</html>
''';

    final result = service.parseRecipeHtml(graphHtml, localFoods: mockFoods);

    expect(result.title, 'Куриное филе на гриле');
    expect(result.prepTimeMinutes, 20);
    expect(result.servings, 1);
    expect(result.ingredients.length, 1);
    expect(result.ingredients[0].matchedProduct?.id, 2);
    expect(result.ingredients[0].grams, 250.0);
  });
}
