import 'dart:convert';

import 'package:anne_bebek/main.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:anne_bebek/widgets/daily_quick_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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
    await tester.pumpAndSettle();

    // A failed save must remain visible and must not be mistaken for success.
    expect(find.text('Kayıt kaydedilemedi. Lütfen tekrar deneyin.'),
        findsNothing);
    expect(find.text('Beslenme kaydı'), findsNothing,
        reason: 'Kayit basariliysa dialog kapanmalidir.');
    final raw = await SecureHealthStore.read('olaylar');
    expect(raw, isNotNull,
        reason: 'Android Keystore uzerinde beslenme kaydi bulunamadi.');
    final records = jsonDecode(raw!) as List<dynamic>;
    expect(records, isNotEmpty);
    expect(records.any((item) =>
        item is Map && item['tur'] == 'Beslenme' &&
        item['not'] == 'GP01 Android smoke kaydi'), isTrue);

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
  });
}
