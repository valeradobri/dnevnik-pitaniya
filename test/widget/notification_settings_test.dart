import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dnevnik/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:dnevnik/features/notifications/presentation/providers/notification_providers.dart';
import 'package:dnevnik/features/notifications/data/repositories/notification_preferences_repository.dart';
import 'package:dnevnik/features/notifications/data/services/notification_service.dart';
import 'package:dnevnik/features/notifications/domain/models/notification_setting.dart';

class MockNotificationService extends NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleDailyReminder(NotificationSetting setting) async {}

  @override
  Future<void> cancelReminder(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {}
}

void main() {
  testWidgets('NotificationSettingsScreen renders all elements and toggles',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = NotificationPreferencesRepository(prefs);
    final mockService = MockNotificationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          notificationPreferencesRepoProvider.overrideWithValue(repo),
          notificationServiceProvider.overrideWithValue(mockService),
        ],
        child: const MaterialApp(
          home: NotificationSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and guilt-free philosophy banner
    expect(find.text('Напоминания'), findsOneWidget);
    expect(find.text('Забота без чувства вины'), findsOneWidget);
    expect(find.text('Все напоминания'), findsOneWidget);
    expect(find.text('Активно 5 из 5'), findsOneWidget);

    // Verify all 5 reminder titles
    expect(find.text('Утренний вес'), findsOneWidget);
    expect(find.text('Завтрак'), findsOneWidget);
    expect(find.text('Водный баланс'), findsOneWidget);
    expect(find.text('Обед'), findsOneWidget);
    expect(find.text('Ужин'), findsOneWidget);

    // Verify time chips
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('08:30'), findsOneWidget);
    expect(find.text('11:30'), findsOneWidget);
    expect(find.text('13:30'), findsOneWidget);
    expect(find.text('19:30'), findsOneWidget);

    // Find master switch (first Switch) and toggle it off
    final masterSwitchFinder = find.byType(Switch).first;
    await tester.tap(masterSwitchFinder);
    await tester.pumpAndSettle();

    // Verify master is disabled
    expect(find.text('Все напоминания отключены'), findsOneWidget);

    // Toggle master switch back on
    await tester.tap(masterSwitchFinder);
    await tester.pumpAndSettle();
    expect(find.text('Активно 5 из 5'), findsOneWidget);
  });
}
