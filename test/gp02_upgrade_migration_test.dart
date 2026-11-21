import 'package:anne_bebek/main.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/secure_storage_mock.dart';

/// GP-02: Önceki sürümler bu kayıtları düz SharedPreferences'ta tutuyordu.
/// Yükseltmeden sonra hiçbir kayıt kaybolmamalı ve düz kopya kalmamalı.
const _legacy = <String, Object>{
  'bebekAdi': 'Ela',
  'dogum': '2025-03-10T00:00:00.000',
  'sonAdet': '2026-10-20T00:00:00.000',
  'olaylar': '[{"tur":"Beslenme","zaman":"2026-11-01T08:00:00.000"}]',
  'olcumler': '[{"kilo":"7.2","boy":"66","tarih":"2026-10-01"}]',
  'cycle_history_v1': '["2026-09-22","2026-10-20"]',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(installSecureStorageMock);

  test('eski düz kayıtlar güvenli depoya kayıpsız taşınır', () async {
    SharedPreferences.setMockInitialValues({
      ..._legacy,
      'pregnancy_checklist_v3': <String>['Folik asit', 'İlk muayene'],
    });
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _legacy.entries) {
      expect(await SecureHealthStore.read(entry.key), entry.value, reason: entry.key);
      expect(prefs.containsKey(entry.key), isFalse, reason: '${entry.key} düz kopyası kaldı');
      // İkinci okuma aynı değeri verir (göç tekrar güvenlidir).
      expect(await SecureHealthStore.read(entry.key), entry.value);
    }
    expect(await SecureHealthStore.read('pregnancy_checklist_v3'),
        '["Folik asit","İlk muayene"]');
    expect(prefs.containsKey('pregnancy_checklist_v3'), isFalse);
  });

  test('yarım kalmış göçte çelişen kopya varsa hiçbiri silinmez', () async {
    // Güvenli depoda farklı bir değer: önceki göç yarıda kalmış gibi.
    SharedPreferences.setMockInitialValues({});
    await SecureHealthStore.write('bebekAdi', 'Yeni ad');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bebekAdi', 'Eski ad');
    await expectLater(SecureHealthStore.read('bebekAdi'), throwsStateError);
    expect(prefs.getString('bebekAdi'), 'Eski ad');
  });

  testWidgets('yükseltme sonrası ana ekran eski bebek profilini gösterir', (tester) async {
    SharedPreferences.setMockInitialValues({..._legacy, 'privacy_consent_v1': 1});
    await tester.pumpWidget(const AnneBebekApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('Ela'), findsWidgets);
    expect(find.textContaining('Kayıtlar yüklenemedi'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
