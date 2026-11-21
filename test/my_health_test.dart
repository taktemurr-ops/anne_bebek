import 'package:anne_bebek/screens/mother_profile_page.dart';
import 'package:anne_bebek/screens/my_health_page.dart';
import 'package:anne_bebek/screens/questions_page.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/my_health.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 11, 21, 21);

  test('ölçüm doğrulama ve uyarılar', () {
    expect(validateEntry('weight', 62, null), isNull);
    expect(validateEntry('weight', 5, null), isNotNull);
    expect(validateEntry('bp', 120, 80), isNull);
    expect(validateEntry('bp', 120, null), isNotNull);
    expect(validateEntry('bp', 80, 120), isNotNull, reason: 'küçük tansiyon büyükten küçük olmalı');
    expect(entryWarning(HealthEntry('bp', now, 185, value2: 100)), contains('112'));
    expect(entryWarning(HealthEntry('glucose', now, 60)), contains('düşük'));
    final low = [for (var i = 0; i < 5; i++) HealthEntry('mood', now.subtract(Duration(days: i)), 1)];
    expect(entryWarning(low.first, history: low), contains('konuş'));
    expect(entryWarning(HealthEntry('mood', now, 2)), isNull);
  });

  test('günlük toplam ve VKİ', () {
    final e = [HealthEntry('water', now, 1), HealthEntry('water', now, 1),
      HealthEntry('water', now.subtract(const Duration(days: 1)), 5), HealthEntry('weight', now, 60)];
    expect(todayValue(e, 'water', now), 2);
    expect(todayValue(e, 'weight', now), 60);
    expect(bmi(60, 165)!.toStringAsFixed(1), '22.0');
    expect(bmiLabel(22), 'normal');
  });

  test('kontrol zamanı ve ay ekleme', () {
    final smear = checkups.firstWhere((c) => c.id == 'cervical');
    expect(checkupState(smear, null, 25, now), CheckupState.notApplicable);
    expect(checkupState(smear, null, 35, now), CheckupState.never);
    expect(checkupState(smear, DateTime(2018, 1, 1), 35, now), CheckupState.due);
    expect(checkupState(smear, DateTime(2024, 1, 1), 35, now), CheckupState.ok);
    expect(addMonths(DateTime(2026, 1, 31), 1), DateTime(2026, 2, 28));
  });

  test('veri kodla-çöz; eski doz işaretleri atılır', () {
    final d = MyHealthData(entries: [HealthEntry('weight', now, 60)],
        meds: const [Medication('m1', 'Folik asit', times: ['08:00', '20:00'], notify: true)],
        taken: {doseKey('m1', now, '08:00'), doseKey('m1', now.subtract(const Duration(days: 200)), '08:00')},
        checks: {'dental': DateTime(2026, 6, 1)}, heightCm: 165);
    final back = MyHealthData.decode(d.encode(now));
    expect(back.entries.single.value, 60);
    expect(back.meds.single.times, ['08:00', '20:00']);
    expect(back.taken, {doseKey('m1', now, '08:00')});
    expect(back.checks['dental'], DateTime(2026, 6, 1));
    expect(back.heightCm, 165);
    expect(MyHealthData.decode('{bozuk').entries, isEmpty);
    expect(validTime('25:00'), isFalse);
  });

  test('yeni anahtarlar güvenli depoda ve yedekte', () {
    for (final k in [MyHealthPage.storageKey, MotherProfile.storageKey, QuestionsPage.storageKey]) {
      expect(SecureHealthStore.isAllowed(k), isTrue, reason: k);
      expect(BackupService.keys, contains(k));
    }
  });

  group('ekranlar', () {
    setUp(() { SharedPreferences.setMockInitialValues({}); installSecureStorageMock(); });

    testWidgets('su +1, tansiyon kaydı ve uyarı', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: MyHealthPage(clock: () => now, age: 35, scheduleNotifications: false))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('olcum_water')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Bugün 1 bardak su'), findsOneWidget);
      await tester.tap(find.byKey(const Key('olcum_bp')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('olcum_deger')), '150');
      await tester.enterText(find.byKey(const Key('olcum_deger2')), '95');
      await tester.tap(find.byKey(const Key('olcum_kaydet')));
      await tester.pumpAndSettle();
      final saved = MyHealthData.decode(await SecureHealthStore.read(MyHealthPage.storageKey));
      expect(saved.entries.map((e) => e.kind), containsAll(['water', 'bp']));
      expect(find.textContaining('Tansiyon yüksek'), findsWidgets);
    });

    testWidgets('ilaç eklenir, doz işaretlenir', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: MyHealthPage(initialTab: 1, clock: () => now, scheduleNotifications: false))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ilac_ekle')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('ilac_ad')), 'D vitamini');
      await tester.enterText(find.byKey(const Key('ilac_saat')), '9:00, 21:00');
      await tester.tap(find.byKey(const Key('ilac_kaydet')));
      await tester.pumpAndSettle();
      expect(find.textContaining('0 / 2 doz'), findsOneWidget);
      final saved = MyHealthData.decode(await SecureHealthStore.read(MyHealthPage.storageKey));
      final id = saved.meds.single.id;
      expect(saved.meds.single.times, ['09:00', '21:00']);
      await tester.tap(find.byKey(Key('doz_${id}_09:00')));
      await tester.pumpAndSettle();
      expect(find.textContaining('1 / 2 doz'), findsOneWidget);
    });

    testWidgets('kontroller yaşa göre listelenir', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: MyHealthPage(initialTab: 2, clock: () => now, age: 25, scheduleNotifications: false))));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('kontrol_dental')), findsOneWidget);
      expect(find.byKey(const Key('kontrol_mammography')), findsNothing);
    });

    testWidgets('anne profili kaydedilir ve acil kartı gösterilir', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: MotherProfilePage())));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('profil_name')), 'Ayşe');
      await tester.enterText(find.byKey(const Key('profil_blood')), 'A Rh+');
      await tester.scrollUntilVisible(find.byKey(const Key('profil_kaydet')), 300, scrollable: find.byType(Scrollable).first);
      await tester.tap(find.byKey(const Key('profil_kaydet')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('profil_kart_ad')), findsOneWidget);
      expect(find.text('A Rh+'), findsOneWidget);
      expect((await MotherProfile.load()).values['blood'], 'A Rh+');
    });

    testWidgets('soru defteri: soru eklenir', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: QuestionsPage())));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('soru_ekle')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('soru_metin')), 'Demir ilacı ne zamana kadar?');
      await tester.tap(find.byKey(const Key('soru_kaydet')));
      await tester.pumpAndSettle();
      expect(find.text('Demir ilacı ne zamana kadar?'), findsOneWidget);
      expect(decodeQuestions(await SecureHealthStore.read(QuestionsPage.storageKey)), hasLength(1));
      await tester.tap(find.byKey(const Key('soru_tab_sss')));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.help_outline_rounded), findsWidgets);
    });
  });
}
