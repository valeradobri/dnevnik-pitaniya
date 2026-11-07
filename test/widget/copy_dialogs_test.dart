import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/diary/presentation/widgets/copy_meal_dialog.dart';
import 'package:dnevnik/features/diary/presentation/widgets/copy_day_dialog.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    await initializeDateFormatting('ru_RU', null);
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestApp(Widget child) {
    return ProviderScope(
      overrides: [
        diaryDaoProvider.overrideWithValue(db.diaryDao),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  testWidgets('CopyMealDialog renders meal chips and submits copy', (tester) async {
    final foodId = await db.foodDao.insertFood(
      FoodProductsCompanion.insert(
        name: 'Овсяная каша',
        caloriesPer100g: 350.0,
        proteinPer100g: 12.0,
        fatPer100g: 6.0,
        carbsPer100g: 60.0,
      ),
    );

    await db.diaryDao.insertEntry(
      DiaryEntriesCompanion.insert(
        mealType: 'breakfast',
        foodProductId: foodId,
        customName: 'Овсяная каша',
        grams: 100,
        calculatedCalories: 350,
        calculatedProtein: 12,
        calculatedFat: 6,
        calculatedCarbs: 60,
        entryDate: DateTime(2026, 11, 7),
      ),
    );

    final entries = await db.diaryDao.getEntriesForDate(DateTime(2026, 11, 7));

    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => CopyMealDialog.show(
              context,
              sourceDate: DateTime(2026, 11, 7),
              sourceMealType: 'breakfast',
              entries: entries,
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('Скопировать Завтрак'), findsOneWidget);
    expect(find.text('1 прод. · 350 ккал'), findsOneWidget);
    expect(find.text('Обед'), findsOneWidget);
    expect(find.text('Ужин'), findsOneWidget);
    expect(find.text('Перекус'), findsOneWidget);

    // Select "Обед"
    await tester.tap(find.text('Обед'));
    await tester.pumpAndSettle();

    // Tap "Скопировать"
    await tester.tap(find.text('Скопировать'));
    await tester.pumpAndSettle();

    // Verify dialog dismissed
    expect(find.byType(CopyMealDialog), findsNothing);

    // Verify copied to tomorrow (2026-11-08) as lunch
    final targetEntries = await db.diaryDao.getEntriesForDate(DateTime(2026, 11, 8));
    expect(targetEntries.length, 1);
    expect(targetEntries.first.mealType, 'lunch');
    expect(targetEntries.first.customName, 'Овсяная каша');
  });

  testWidgets('CopyDayDialog renders options and copies all day entries', (tester) async {
    final foodId = await db.foodDao.insertFood(
      FoodProductsCompanion.insert(
        name: 'Творог 5%',
        caloriesPer100g: 120.0,
        proteinPer100g: 16.0,
        fatPer100g: 5.0,
        carbsPer100g: 3.0,
      ),
    );

    await db.diaryDao.insertEntry(
      DiaryEntriesCompanion.insert(
        mealType: 'breakfast',
        foodProductId: foodId,
        customName: 'Творог 5%',
        grams: 200,
        calculatedCalories: 240,
        calculatedProtein: 32,
        calculatedFat: 10,
        calculatedCarbs: 6,
        entryDate: DateTime(2026, 11, 7),
      ),
    );

    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => CopyDayDialog.show(
              context,
              sourceDate: DateTime(2026, 11, 7),
              entriesCount: 1,
              totalCalories: 240,
            ),
            child: const Text('Open Day Dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Day Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog elements
    expect(find.text('Скопировать весь день'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Завтра'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Сегодня'), findsOneWidget);

    // Tap "Скопировать день" button
    final copyButton = find.widgetWithText(FilledButton, 'Скопировать день');
    expect(copyButton, findsOneWidget);
    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    // Dialog closed
    expect(find.byType(CopyDayDialog), findsNothing);

    // Verify target day has copied entry
    final targetEntries = await db.diaryDao.getEntriesForDate(DateTime(2026, 11, 8));
    expect(targetEntries.length, 1);
    expect(targetEntries.first.customName, 'Творог 5%');
  });
}
