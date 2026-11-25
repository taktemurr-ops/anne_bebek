import 'package:anne_bebek/screens/extra_guides_pages.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/extra_guides.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('anahtarlar kayıtlı', () {
    for (final k in ['pregnancy_weight_v1', 'home_safety_v1']) {
      expect(SecureHealthStore.isAllowed(k), isTrue);
      expect(BackupService.isBackupKey(k), isTrue);
    }
  });

  test('IOM kilo aralıkları', () {
    expect(weightGainPlan(50, 170)!.category, 'Zayıf');
    final n = weightGainPlan(60, 165)!;
    expect(n.category, 'Normal kilolu');
    expect(n.totalMin, 11.5);
    expect(n.totalMax, 16);
    final (lo, hi) = n.expectedBy(40);
    expect(lo, closeTo(0.5 + 27 * 0.35, 0.01));
    expect(hi, closeTo(2 + 27 * 0.5, 0.01));
    expect(weightGainPlan(80, 165)!.category, 'Fazla kilolu');
    expect(weightGainPlan(95, 165)!.category, 'Obez');
    expect(weightGainPlan(10, 165), isNull);
  });

  test('uyku ihtiyacı yaşa göre', () {
    expect(sleepNeedFor(2).total, '14–17 saat');
    expect(sleepNeedFor(8).naps, '2–3 gündüz uykusu');
    expect(sleepNeedFor(30).label, '1,5–3 yaş');
    expect(sleepNeedFor(200).label, '3–6 yaş');
  });

  test('ev güvenliği kimlikleri benzersiz ve aşamalar tanımlı', () {
    expect(homeSafetyItems.map((e) => e.id).toSet().length, homeSafetyItems.length);
    for (final e in homeSafetyItems) {
      expect(safetyStages, contains(e.stage));
    }
  });

  test('alkol ve cıvalı balık her iki dönemde kaçınılır', () {
    final alkol = foodSafetyList.firstWhere((f) => f.name == 'Alkol');
    expect(alkol.pregnancy, FoodVerdict.avoid);
    expect(alkol.breastfeeding, FoodVerdict.avoid);
  });

  testWidgets('Yiyebilir miyim aramada süzer ve emzirme sekmesine geçer', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FoodSafetyPage())));
    await tester.enterText(find.byKey(const Key('yiyebilir_ara')), 'suşi');
    await tester.pump();
    expect(find.text('Suşi ve çiğ balık'), findsOneWidget);
    expect(find.text('Kaçın'), findsOneWidget);
    await tester.tap(find.text('Emzirirken'));
    await tester.pump();
    expect(find.text('Güvenli'), findsOneWidget);
  });

  testWidgets('Ev güvenliği işaretlemesi kaydedilir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: HomeSafetyPage())));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('guvenlik_s_back')));
    await tester.pumpAndSettle();
    expect(find.text('1 / ${homeSafetyItems.length}'), findsOneWidget);
  });
}
