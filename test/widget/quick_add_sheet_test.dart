import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/diary/presentation/widgets/quick_add_sheet.dart';

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
        foodDaoProvider.overrideWithValue(db.foodDao),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  testWidgets('QuickAddSheet renders presets, accepts inputs and logs entry', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testDate = DateTime(2026, 11, 7);

    await tester.pumpWidget(
      buildTestApp(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => QuickAddSheet.show(
              context,
              initialMealType: 'lunch',
              initialDate: testDate,
            ),
            child: const Text('Open Quick Add'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Quick Add'));
    await tester.pumpAndSettle();

    // Verify UI elements
    expect(find.text('Быстрая запись'), findsOneWidget);
    expect(find.text('Калорийность (ккал) *'), findsOneWidget);
    expect(find.text('+50'), findsOneWidget);
    expect(find.text('+100'), findsOneWidget);
    expect(find.text('+250'), findsOneWidget);
    expect(find.text('+500'), findsOneWidget);

    // Tap +250 preset
    await tester.tap(find.text('+250'));
    await tester.pumpAndSettle();

    // Tap +100 preset -> 350
    await tester.tap(find.text('+100'));
    await tester.pumpAndSettle();

    // Scroll down to submit button
    final submitButton = find.byType(FilledButton);
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();

    // Verify button text includes 350 ккал
    expect(find.text('Записать в Обед (350 ккал)'), findsOneWidget);

    // Enter custom name
    final nameField = find.widgetWithText(TextField, 'Название блюда (необязательно)');
    await tester.enterText(nameField, 'Кофе и десерт в кофейне');
    await tester.pumpAndSettle();

    // Tap save button
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Verify sheet closed
    expect(find.byType(QuickAddSheet), findsNothing);

    // Verify entry in database
    final entries = await db.diaryDao.getEntriesForDate(testDate);
    expect(entries.length, 1);
    expect(entries.first.customName, 'Кофе и десерт в кофейне');
    expect(entries.first.calculatedCalories, 350);
    expect(entries.first.mealType, 'lunch');
  });
}
