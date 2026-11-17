import 'dart:convert';

import 'package:anne_bebek/main.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:anne_bebek/widgets/daily_quick_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GP-01 Android: ana sayfa, gunluk kaydi ve temel ekranlar',
      (tester) async {
    await tester.pumpWidget(const AnneBebekApp());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byType(DailyQuickActions), 220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(DailyQuickActions), findsOneWidget);
    final feeding = find.descendant(
      of: find.byType(DailyQuickActions),
      matching: find.text('Beslenme'),
    );
    await tester.ensureVisible(feeding);
    await tester.tap(feeding);
    await tester.pumpAndSettle();

    expect(find.text('Beslenme kaydı'), findsOneWidget);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'GP01 Android smoke kaydi',
    );
    await tester.tap(find.descendant(
      of: find.byType(AlertDialog), matching: find.text('Kaydet'),
    ));
    // Platform channel / Android Keystore work is asynchronous and may outlive
    // the current frame. pumpAndSettle alone does not await that I/O.
    for (var attempt = 0;
        attempt < 40 && find.byType(AlertDialog).evaluate().isNotEmpty;
        attempt++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pumpAndSettle();

    // A failed save must remain visible and must not be mistaken for success.
    expect(find.text('Kayıt kaydedilemedi. Lütfen tekrar deneyin.'),
        findsNothing);
    expect(find.byType(AlertDialog), findsNothing,
        reason: 'Kayit 10 saniyede tamamlanmadi veya guvenli yazma basarisiz.');
    final raw = await SecureHealthStore.read('olaylar');
    expect(raw, isNotNull,
        reason: 'Android Keystore uzerinde beslenme kaydi bulunamadi.');
    final records = jsonDecode(raw!) as List<dynamic>;
    expect(records, isNotEmpty);
    final matchingRecords = records.where((item) =>
        item is Map && item['tur'] == 'Beslenme' &&
        item['not'] == 'GP01 Android smoke kaydi').toList();
    expect(matchingRecords, hasLength(1),
        reason: 'Tek kaydetme islemi tam olarak bir kayit olusturmalidir.');
    expect(DateTime.tryParse(matchingRecords.single['zaman'] as String),
        isNotNull, reason: 'Beslenme kaydinin zaman damgasi gecerlidir.');

    // Sensitive journal entries must not remain in legacy plaintext storage.
    final legacyPrefs = await SharedPreferences.getInstance();
    expect(legacyPrefs.containsKey('olaylar'), isFalse,
        reason: 'Saglik gunlugu SharedPreferences icinde acik metin kalmamalidir.');
    expect(await SecureHealthStore.read('olaylar'), raw,
        reason: 'Guvenli kayit ardisik okumada korunmalidir.');

    await tester.tap(find.byTooltip('Bebek profilleri'));
    await tester.pumpAndSettle();
    expect(find.text('Bebek profillerim'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    final recipes = find.text('Bebeğime uygun tarifler');
    await tester.scrollUntilVisible(
      recipes, 220, scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(recipes);
    await tester.pumpAndSettle();
    expect(find.text('Bebek tarifleri'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    final backup = find.text('Şifreli yedekleme ve geri yükleme');
    await tester.scrollUntilVisible(
      backup, 220, scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(backup);
    await tester.pumpAndSettle();
    expect(find.text('Yedekleme ve geri yükleme'), findsOneWidget);

    // Simulate closing and reopening the Flutter UI without uninstalling the
    // application. The encrypted journal must survive widget-tree recreation.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(const AnneBebekApp());
    await tester.pumpAndSettle();
    final persisted = await SecureHealthStore.read('olaylar');
    expect(persisted, isNotNull,
        reason: 'Gunluk kaydi uygulama arayuzu yeniden acilinca kaybolmamali.');
    final reopenedRecords = jsonDecode(persisted!) as List<dynamic>;
    final reopenedLegacyPrefs = await SharedPreferences.getInstance();
    expect(reopenedLegacyPrefs.containsKey('olaylar'), isFalse,
        reason: 'Yeniden acilistan sonra gunluk kayitlari acik metin depoda olmamali.');
    expect(
      reopenedRecords.where((item) =>
          item is Map &&
          item['tur'] == 'Beslenme' &&
          item['not'] == 'GP01 Android smoke kaydi'),
      hasLength(1),
      reason: 'Yeniden acilista sifreli beslenme kaydi korunmalidir.',
    );
  });
}
