import 'package:anne_bebek/screens/life_guides_pages.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/life_guides.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seyahat listesi anahtarı kayıtlı ve maddeler tekil', () {
    expect(SecureHealthStore.isAllowed(TravelWithBabyPage.storageKey), isTrue);
    expect(BackupService.isBackupKey(TravelWithBabyPage.storageKey), isTrue);
    expect(travelItems.toSet().length, travelItems.length);
  });

  test('haklar ve muayene içerikleri dolu', () {
    for (final s in rightsSections) {
      expect(s.$2, isNotEmpty, reason: s.$1);
    }
    expect(breastExamSteps.length, greaterThan(5));
    expect(breastExamDoctor, isNotEmpty);
  });

  test('günün bilgisi her gün değişir ve bağlama uyar', () {
    final a = dailyTopic(DateTime(2026, 11, 22), hasBaby: true);
    final b = dailyTopic(DateTime(2026, 11, 23), hasBaby: true);
    expect(a.id, isNot(b.id));
    expect(['Bebek (0–12 ay)', 'Çocuk (1–6 yaş)', 'Lohusalık ve Emzirme'], contains(a.category));
    expect(dailyTopic(DateTime(2026, 11, 22, 23, 59)).id, dailyTopic(DateTime(2026, 11, 22, 0, 1)).id);
  });

  testWidgets('seyahat listesi işaretlenip kaydedilir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TravelWithBabyPage())));
    await tester.pumpAndSettle();
    await tester.tap(find.text(travelItems.first));
    await tester.pumpAndSettle();
    expect(find.text('1 / ${travelItems.length}'), findsOneWidget);
    final saved = await SecureHealthStore.read(TravelWithBabyPage.storageKey);
    expect(saved, contains(travelItems.first));
  });
}
