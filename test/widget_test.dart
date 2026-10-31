import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:dnevnik/app/app.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru_RU', null);
  });

  testWidgets('DnevnikApp smoke test - renders dashboard when onboarding completed',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        child: DnevnikApp(prefs: prefs),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DnevnikApp), findsOneWidget);
    expect(find.text('Доброе утро! 👋'), findsOneWidget);
  });

  testWidgets('DnevnikApp smoke test - renders onboarding when first launch',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': false});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        child: DnevnikApp(prefs: prefs),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DnevnikApp), findsOneWidget);
    expect(find.text('Начать настройку'), findsOneWidget);
  });
}
