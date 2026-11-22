import 'package:anne_bebek/screens/growing_up_pages.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/growing_up.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 11, 22, 20); // Pazar

  test('anahtarlar kayıtlı, listeler tekil', () {
    for (final k in [SleepTrainingPage.storageKey, SchoolPrepPage.storageKey, PregnancyExercisePage.storageKey]) {
      expect(SecureHealthStore.isAllowed(k), isTrue, reason: k);
      expect(BackupService.isBackupKey(k), isTrue, reason: k);
    }
    expect({...nurseryItems, ...schoolItems}.length, nurseryItems.length + schoolItems.length);
    expect(sleepMethods.map((e) => e.id).toSet().length, sleepMethods.length);
  });

  test('haftalık egzersiz toplamı pazartesiden başlar', () {
    final days = {
      exerciseDayKey(DateTime(2026, 11, 16)): 30, // pazartesi
      exerciseDayKey(DateTime(2026, 11, 22)): 20, // pazar
      exerciseDayKey(DateTime(2026, 11, 15)): 90, // geçen hafta
    };
    expect(weekTotal(days, now), 50);
  });

  test('gece uyanma ortalamaları', () {
    final nights = {
      exerciseDayKey(now): 1,
      exerciseDayKey(now.subtract(const Duration(days: 1))): 3,
      exerciseDayKey(now.subtract(const Duration(days: 8))): 4,
    };
    final (a, b) = wakingAverages(nights, now);
    expect(a, 2);
    expect(b, 4);
    expect(wakingAverages({}, now), (null, null));
  });

  testWidgets('egzersiz eklenir ve kaydedilir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PregnancyExercisePage(clock: () => now))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('egzersiz_10')));
    await tester.pumpAndSettle();
    expect(find.text('Bu hafta: 10 / 150'), findsOneWidget);
    expect(await SecureHealthStore.read(PregnancyExercisePage.storageKey), contains('"2026-11-22":10'));
  });

  testWidgets('uyku eğitimi yöntem seçimi ve gece kaydı', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SleepTrainingPage(birth: DateTime(2026, 1, 1), clock: () => now))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uyku_yontem_sandalye')));
    await tester.pumpAndSettle();
    expect(find.text('6 aydan sonra'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('uyanma_2')));
    await tester.tap(find.byKey(const Key('uyanma_2')));
    await tester.pumpAndSettle();
    final saved = await SecureHealthStore.read(SleepTrainingPage.storageKey);
    expect(saved, contains('sandalye'));
    expect(saved, contains('"2026-11-22":2'));
  });
}
