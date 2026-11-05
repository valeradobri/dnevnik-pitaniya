import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:dnevnik/core/database/app_database.dart';
import 'package:dnevnik/features/backup/data/services/backup_service.dart';
import 'package:dnevnik/features/backup/presentation/providers/backup_providers.dart';
import 'package:dnevnik/features/backup/presentation/screens/backup_screen.dart';

class FakeBackupService extends BackupService {
  FakeBackupService(super.db);

  bool exportJsonCalled = false;
  bool exportDiaryCsvCalled = false;
  bool exportWeightCsvCalled = false;
  bool pickBackupCalled = false;

  @override
  Future<String> exportToJson() async {
    exportJsonCalled = true;
    return '{"appName":"Dnevnik"}';
  }

  @override
  Future<String> exportDiaryToCsv() async {
    exportDiaryCsvCalled = true;
    return 'Дата;Приём пищи\n';
  }

  @override
  Future<String> exportWeightToCsv() async {
    exportWeightCsvCalled = true;
    return 'Дата;Вес\n';
  }

  @override
  Future<void> shareContent({
    required String content,
    required String fileName,
    String? subject,
  }) async {
    // Fake share implementation without native channels in tests
  }

  @override
  Future<String?> pickBackupFile() async {
    pickBackupCalled = true;
    return null;
  }
}

void main() {
  testWidgets('BackupScreen renders all sections and handles export taps',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final testDb = AppDatabase.forTesting(NativeDatabase.memory());
    final fakeService = FakeBackupService(testDb);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(testDb),
          backupServiceProvider.overrideWithValue(fakeService),
        ],
        child: const MaterialApp(
          home: BackupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify title and privacy banner
    expect(find.text('Резервная копия и экспорт'), findsOneWidget);
    expect(find.text('100% приватность данных'), findsOneWidget);

    // Verify Section 1
    expect(find.text('Резервная копия приложения (JSON)'), findsOneWidget);
    expect(find.text('Создать резервную копию'), findsOneWidget);
    expect(find.text('Восстановить из файла'), findsOneWidget);

    // Verify Section 2 (CSV)
    expect(find.text('Экспорт в Excel / Таблицы (CSV)'), findsOneWidget);
    expect(find.text('История питания (CSV)'), findsOneWidget);
    expect(find.text('Динамика веса (CSV)'), findsOneWidget);

    // Tap on Export JSON button
    await tester.tap(find.text('Экспортировать и поделиться'));
    await tester.pumpAndSettle();
    expect(fakeService.exportJsonCalled, isTrue);

    // Tap on Export Diary CSV button
    await tester.tap(find.text('Поделиться таблицей питания'));
    await tester.pumpAndSettle();
    expect(fakeService.exportDiaryCsvCalled, isTrue);

    // Tap on Export Weight CSV button
    await tester.tap(find.text('Поделиться таблицей веса'));
    await tester.pumpAndSettle();
    expect(fakeService.exportWeightCsvCalled, isTrue);

    // Tap on Restore button
    await tester.tap(find.text('Выбрать файл бэкапа'));
    await tester.pumpAndSettle();
    expect(fakeService.pickBackupCalled, isTrue);

    await testDb.close();
  });
}
