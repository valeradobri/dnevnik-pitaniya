import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/food_database/presentation/screens/barcode_scanner_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru_RU', null);
  });

  group('BarcodeScannerScreen & Barcode Lookup Tests', () {
    late AppDatabase testDb;

    setUp(() async {
      testDb = AppDatabase.forTesting(NativeDatabase.memory());
      // Добавляем тестовый продукт со штрихкодом
      await testDb.foodDao.insertFood(
        FoodProductsCompanion.insert(
          name: 'Творог 5% Простоквашино',
          brand: const drift.Value('Простоквашино'),
          barcode: const drift.Value('4607025392238'),
          caloriesPer100g: 121.0,
          proteinPer100g: 16.0,
          fatPer100g: 5.0,
          carbsPer100g: 3.0,
          category: const drift.Value('dairy'),
          sourceType: const drift.Value('verified'),
        ),
      );
    });

    tearDown(() async {
      await testDb.close();
    });

    test('FoodDao getFoodByBarcode returns product by exact code', () async {
      final found = await testDb.foodDao.getFoodByBarcode('4607025392238');
      expect(found, isNotNull);
      expect(found!.name, equals('Творог 5% Простоквашино'));

      final notFound = await testDb.foodDao.getFoodByBarcode('9999999999999');
      expect(notFound, isNull);
    });

    testWidgets('BarcodeScannerScreen renders UI controls and manual input button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(testDb),
            foodDaoProvider.overrideWithValue(testDb.foodDao),
            diaryDaoProvider.overrideWithValue(testDb.diaryDao),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: BarcodeScannerScreen(
                mealType: 'breakfast',
                date: DateTime.now(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Проверяем элементы верхней панели
      expect(find.text('Сканер штрих-кода'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Проверяем кнопку ручного ввода
      final manualButton = find.text('Ввести штрих-код вручную');
      expect(manualButton, findsOneWidget);

      // Нажимаем «Ввести штрих-код вручную»
      await tester.tap(manualButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Проверяем открытие диалога ввода
      expect(find.text('Ввод штрих-кода'), findsOneWidget);
      expect(find.text('Найти'), findsOneWidget);

      // Вводим существующий штрих-код
      await tester.enterText(find.byType(TextField).last, '4607025392238');
      await tester.tap(find.text('Найти'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Должна открыться шторка размера порции с найденным творогом
      expect(find.text('Творог 5% Простоквашино'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
