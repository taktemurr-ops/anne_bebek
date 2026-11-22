import 'package:anne_bebek/screens/family_more_pages.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/family_more.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 11, 22, 18);

  test('yeni anahtarlar kayıtlı', () {
    for (final k in [TantrumHelperPage.storageKey, ScreenTimePage.storageKey, SiblingPrepPage.storageKey, MenopauseTrackerPage.storageKey]) {
      expect(SecureHealthStore.isAllowed(k), isTrue, reason: k);
      expect(BackupService.isBackupKey(k), isTrue, reason: k);
    }
  });

  test('öfke nöbeti özeti ve kayıt dönüşümü', () {
    final list = [
      TantrumEntry(DateTime(2026, 11, 21, 19), 'Yorgunluk', 8),
      TantrumEntry(DateTime(2026, 11, 20, 18), 'Yorgunluk', 15),
      TantrumEntry(DateTime(2026, 11, 19, 9), 'Açlık', 3),
      TantrumEntry(DateTime(2026, 9, 1, 9), 'Açlık', 3),
    ];
    final s = summarizeTantrums(list, now);
    expect(s.count30, 3);
    expect(s.topTrigger, 'Yorgunluk');
    expect(s.topBand, 'Akşam');
    expect(s.avgMinutes, 9);
    expect(TantrumEntry.fromJson(list.first.toJson())!.trigger, 'Yorgunluk');
    expect(TantrumEntry.fromJson({'at': 'x'}), isNull);
  });

  test('ekran süresi önerisi ve haftalık ortalama', () {
    expect(screenLimitFor(12), 0);
    expect(screenLimitFor(36), 60);
    expect(screenLimitFor(90), isNull);
    final days = {dayKey(now): 30, dayKey(now.subtract(const Duration(days: 1))): 90, dayKey(now.subtract(const Duration(days: 10))): 300};
    expect(weekAverage(days, now), 60);
  });

  test('menopoz özeti', () {
    final (n, avg) = summarizeMenopause({
      dayKey(now): {'Sıcak basması': 3},
      dayKey(now.subtract(const Duration(days: 2))): {'Sıcak basması': 1, 'Uyku sorunu': 2},
      dayKey(now.subtract(const Duration(days: 40))): {'Sıcak basması': 3},
    }, now);
    expect(n, 2);
    expect(avg['Sıcak basması'], 2);
    expect(avg['Uyku sorunu'], 1);
    expect(siblingItems.toSet().length, siblingItems.length);
  });

  testWidgets('ekran süresi eklenir ve kaydedilir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ScreenTimePage(birth: DateTime(2023, 1, 1), clock: () => now))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ekran_15')));
    await tester.pumpAndSettle();
    expect(find.text('15 dk'), findsWidgets);
    expect(await SecureHealthStore.read(ScreenTimePage.storageKey), contains('"2026-11-22":15'));
  });

  testWidgets('öfke nöbeti kaydedilir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: TantrumHelperPage(clock: () => now))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('ofke_kaydet')));
    await tester.tap(find.byKey(const Key('ofke_kaydet')));
    await tester.pumpAndSettle();
    expect(await SecureHealthStore.read(TantrumHelperPage.storageKey), contains('Yorgunluk'));
  });
}
