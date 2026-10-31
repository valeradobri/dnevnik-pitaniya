import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/app/app.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru_RU', null);
  });

  testWidgets('Onboarding multi-step wizard advances through steps',
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

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Начать настройку'), findsOneWidget);

    // Кликаем "Начать настройку" -> переход к шагу 1 (Давайте познакомимся)
    await tester.tap(find.text('Начать настройку'));
    await tester.pumpAndSettle();

    expect(find.text('Давайте познакомимся'), findsOneWidget);
    expect(find.text('Биологический пол'), findsOneWidget);
    expect(find.text('Мужской'), findsOneWidget);

    // Выбираем Мужской пол
    await tester.tap(find.text('Мужской'));
    await tester.pumpAndSettle();

    // Переходим к шагу 2 (Параметры тела)
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();

    expect(find.text('Параметры тела'), findsOneWidget);
    expect(find.text('Рост'), findsOneWidget);
    expect(find.text('Текущий вес'), findsOneWidget);

    await testDb.close();
  });
}
