import 'package:anne_bebek/main.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:anne_bebek/widgets/daily_quick_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'privacy_consent_v1': 1});
    installSecureStorageMock();
  });

  testWidgets('GP-01 ana ekrandan hizli kayit ekleme ve sayac guncelleme',
      (tester) async {
    await tester.pumpWidget(const AnneBebekApp());
    await tester.pumpAndSettle();

    // The home ListView lazily builds cards below the initial viewport.
    await tester.scrollUntilVisible(
      find.byType(DailyQuickActions), 220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(DailyQuickActions), findsOneWidget);
    final quickFeeding = find.descendant(
      of: find.byType(DailyQuickActions),
      matching: find.text('Beslenme'),
    );
    await tester.ensureVisible(quickFeeding);
    await tester.tap(quickFeeding);
    await tester.pumpAndSettle();
    expect(find.text('Beslenme kaydı'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog), matching: find.byType(TextField),
      ),
      'GP01 beslenme kaydi',
    );
    await tester.tap(find.descendant(
      of: find.byType(AlertDialog), matching: find.text('Kaydet'),
    ));
    await tester.pumpAndSettle();

    final raw = await SecureHealthStore.read('olaylar');
    final entries = jsonDecode(raw!) as List<dynamic>;
    expect(entries, hasLength(1));
    final entry = entries.single as Map<String, dynamic>;
    expect(entry['tur'], 'Beslenme');
    expect(entry['not'], 'GP01 beslenme kaydi');
    expect(DateTime.tryParse(entry['zaman'] as String), isNotNull);

    final quickSleep = find.descendant(
      of: find.byType(DailyQuickActions),
      matching: find.text('Uyku'),
    );
    await tester.ensureVisible(quickSleep);
    await tester.tap(quickSleep);
    await tester.pumpAndSettle();
    expect(find.text('Uyku kaydı'), findsOneWidget);
    await tester.tap(find.descendant(
      of: find.byType(AlertDialog), matching: find.text('Vazgeç'),
    ));
    await tester.pumpAndSettle();

    final unchanged = jsonDecode(
      (await SecureHealthStore.read('olaylar'))!,
    ) as List<dynamic>;
    expect(unchanged, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('GP-01 ana ekran profil, tarif ve yedekleme sayfalari acilir',
      (tester) async {
    await tester.pumpWidget(const AnneBebekApp());
    await tester.pumpAndSettle();

    // Paket 39 tasarımı: bebek profillerine ana sayfadaki çocuk kartından gidilir.
    await tester.tap(find.text('Bebek profilini tamamla'));
    await tester.pumpAndSettle();
    expect(find.text('Bebek profillerim'), findsOneWidget);
    await tester.tap(find.byType(BackButton).last);
    await tester.pumpAndSettle();

    final recipes = find.text('Bebeğime uygun tarifler');
    await tester.scrollUntilVisible(
      recipes, 220, scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(recipes);
    await tester.pumpAndSettle();
    expect(find.text('Bebek tarifleri'), findsOneWidget);
    await tester.tap(find.byType(BackButton).last);
    await tester.pumpAndSettle();

    final backup = find.text('Şifreli yedekleme ve geri yükleme');
    await tester.scrollUntilVisible(
      backup, 220, scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(backup);
    await tester.pumpAndSettle();
    expect(find.text('Yedekleme ve geri yükleme'), findsOneWidget);
    await tester.tap(find.byType(BackButton).last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(DailyQuickActions), -220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.byType(DailyQuickActions), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
