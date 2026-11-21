// Gerçek Android emülatöründe kabul testleri (docs/CIHAZ_TEST_LISTESI.md).
// Çalıştırma: flutter test integration_test/device_acceptance_test.dart -d <cihaz>
// Gerçek şifreli depo (Android Keystore) ve gerçek platform kanalları kullanılır.
import 'package:anne_bebek/main.dart';
import 'package:anne_bebek/screens/ai_assistant_page.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/family_recipe_repository.dart';
import 'package:anne_bebek/services/privacy_service.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:anne_bebek/widgets/pastel_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Platform kanalı G/Ç'si kare dışında sürer; koşul sağlanana kadar bekle.
Future<void> pumpUntil(WidgetTester tester, bool Function() done, {int tries = 80}) async {
  for (var i = 0; i < tries && !done(); i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.pumpAndSettle();
}

Future<void> startApp(WidgetTester tester) async {
  await tester.pumpWidget(const AnneBebekApp());
  await pumpUntil(tester, () => find.byType(PastelModuleTile).evaluate().isNotEmpty);
}

Future<void> openTile(WidgetTester tester, String title) async {
  final tile = find.descendant(of: find.byType(PastelModuleTile), matching: find.text(title));
  tester.widget<PastelModuleTile>(find.ancestor(of: tile, matching: find.byType(PastelModuleTile))).onTap();
  await tester.pumpAndSettle();
}

String todayIso() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day).toIso8601String();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('1) Şifreli depo bu cihazda tüm anahtarlarda yazar ve okur', (tester) async {
    final keys = [
      ...SecureHealthStore.keys.where((k) => k != 'pregnancy_checklist_v3'),
      '${SecureHealthStore.childSleepPrefix}cihaz-test',
    ];
    final failures = <String>[];
    for (final key in keys) {
      try {
        await SecureHealthStore.write(key, '["cihaz-testi"]');
        if (await SecureHealthStore.read(key) != '["cihaz-testi"]') failures.add('$key: okuma farklı');
        await SecureHealthStore.delete(key);
        if (await SecureHealthStore.read(key) != null) failures.add('$key: silinmedi');
      } catch (e) {
        failures.add('$key: $e');
      }
    }
    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('2) İlk açılış: açık rıza ekranı, onay sonrası ana sayfa', (tester) async {
    await PrivacyService.deleteLocalRecords();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('privacy_consent_v1');

    await tester.pumpWidget(const AnneBebekApp());
    await pumpUntil(tester, () => find.byKey(const ValueKey('consent_checkbox')).evaluate().isNotEmpty);
    await tester.tap(find.byKey(const ValueKey('consent_checkbox')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('consent_accept')));
    await tester.tap(find.byKey(const ValueKey('consent_accept')));
    await pumpUntil(tester, () => find.byType(PastelModuleTile).evaluate().isNotEmpty);
    expect(find.textContaining('Merhaba'), findsWidgets);
  });

  testWidgets('3) Adet başlangıcı kaydedilir ve yeniden açılışta korunur', (tester) async {
    await startApp(tester);
    await openTile(tester, 'Kadınlar');
    final today = find.byKey(const ValueKey('adet_bugun'));
    await tester.ensureVisible(today);
    await tester.tap(today);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Kaydet')));
    await pumpUntil(tester, () => find.textContaining('Adet başlangıcı kaydedildi').evaluate().isNotEmpty);
    expect(find.textContaining('kaydedilemedi'), findsNothing);
    expect(await SecureHealthStore.read('cycle_history_v1'), contains(todayIso()));

    await tester.pumpWidget(const SizedBox.shrink());
    await startApp(tester);
    await openTile(tester, 'Kadınlar');
    expect(find.textContaining('Sonraki adet (tahmini)'), findsOneWidget);
  });

  testWidgets('4) + menüsünden uyku kaydı eklenir', (tester) async {
    await startApp(tester);
    await tester.tap(find.byTooltip('Hızlı kayıt ekle'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Uyku kaydı'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uyku kaydı'));
    await tester.pumpAndSettle();
    await tester.enterText(find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)), 'cihaz testi uyku');
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Kaydet')));
    await pumpUntil(tester, () => find.byType(AlertDialog).evaluate().isEmpty);
    expect(find.textContaining('kaydedilemedi'), findsNothing);
    expect(await SecureHealthStore.read('olaylar'), contains('cihaz testi uyku'));
  });

  testWidgets('5) Tarif detayından aile tarif defterine ekleme', (tester) async {
    await startApp(tester);
    await tester.tap(find.text('Tarifler').last);
    await tester.pumpAndSettle();
    final recipe = find.textContaining('çorbası').first;
    await tester.ensureVisible(recipe);
    await tester.pumpAndSettle();
    await tester.tap(recipe);
    await tester.pumpAndSettle();
    final add = find.byKey(const ValueKey('add_to_notebook'));
    await tester.ensureVisible(add);
    await tester.tap(add);
    await pumpUntil(tester, () => find.textContaining('tarif defterine eklendi').evaluate().isNotEmpty);
    expect((await FamilyRecipeRepository.load()), isNotEmpty);
  });

  testWidgets('6) A\'dan Z\'ye Rehber araması ve konu ayrıntısı', (tester) async {
    await startApp(tester);
    final search = find.text('A’dan Z’ye Rehber’de ara...');
    await tester.ensureVisible(search);
    await tester.tap(search);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('ansiklopedi_ara')), 'ateş');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bebeklerde ateş'));
    await tester.pumpAndSettle();
    final doctor = find.textContaining('Ne zaman doktora');
    await tester.scrollUntilVisible(doctor, 300, scrollable: find.byType(Scrollable).first);
    expect(doctor, findsOneWidget);
  });

  testWidgets('7) Bilgi asistanı cihazda yanıt verir', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiAssistantPage()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('assistant_input')), 'mastit belirtileri');
    await tester.tap(find.byKey(const ValueKey('assistant_send')));
    await tester.pumpAndSettle();
    expect(find.text('Meme dolgunluğu ve mastit'), findsOneWidget);
  });

  testWidgets('8) Yedek: dışa aktar → sil → geri yükle gerçek depoda kayıpsız', (tester) async {
    final before = await SecureHealthStore.read('cycle_history_v1');
    final recipes = (await FamilyRecipeRepository.load()).length;
    expect(before, isNotNull, reason: 'Önceki test adet kaydı oluşturmalıydı.');

    final backup = await BackupService.export();
    await PrivacyService.deleteLocalRecords();
    expect(await SecureHealthStore.read('cycle_history_v1'), isNull);

    await BackupService.restore(backup);
    expect(await SecureHealthStore.read('cycle_history_v1'), before);
    expect((await FamilyRecipeRepository.load()).length, recipes);
  });
}
