import 'package:anne_bebek/main.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:anne_bebek/widgets/pastel_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({'privacy_consent_v1': 1});
    installSecureStorageMock();
  });

  testWidgets('Kadınlar: "Adetim bugün başladı" kaydı kalıcı olarak ekler', (tester) async {
    await tester.pumpWidget(const AnneBebekApp());
    await tester.pumpAndSettle();
    final tile = find.descendant(of: find.byType(PastelModuleTile), matching: find.text('Kadınlar'));
    // Alt menü çubuğunun altında kalmaması için kartı ekranın ortasına getir.
    await Scrollable.ensureVisible(tester.element(tile), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('adet_bugun')));
    await tester.pumpAndSettle();
    // Onay diyaloğu
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Adet başlangıcı kaydedildi'), findsOneWidget);
    final saved = await SecureHealthStore.read('cycle_history_v1');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    expect(saved, contains(today));
    expect(await SecureHealthStore.read('sonAdet'), today);

    // Aynı gün ikinci kez eklenmez.
    await tester.tap(find.byKey(const ValueKey('adet_bugun')));
    await tester.pumpAndSettle();
    expect(find.textContaining('zaten kayıtlı'), findsOneWidget);
  });
}
