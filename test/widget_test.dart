import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/app/app.dart';
import 'package:dnevnik/core/database/app_database.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru_RU', null);
  });

  testWidgets('DnevnikApp smoke test - renders dashboard when onboarding completed',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();
    final testDb = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(testDb),
        ],
        child: DnevnikApp(prefs: prefs),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DnevnikApp), findsOneWidget);
    expect(find.textContaining('👋'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Белки'), 200);
    expect(find.text('Белки'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Вода за сегодня'), 200);
    expect(find.text('Вода за сегодня'), findsOneWidget);

    await testDb.close();
  });

  testWidgets('DnevnikApp smoke test - renders onboarding when first launch',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': false});
    final prefs = await SharedPreferences.getInstance();
    final testDb = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(testDb),
        ],
        child: DnevnikApp(prefs: prefs),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DnevnikApp), findsOneWidget);
    expect(find.text('Начать настройку'), findsOneWidget);

    await testDb.close();
  });
}
