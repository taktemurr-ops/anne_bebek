import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/privacy_service.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'support/secure_storage_mock.dart';

String _backup(Map<String, Object> data) => jsonEncode({
  'format': BackupService.format, 'version': BackupService.version, 'data': data,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(installSecureStorageMock);

  test('GP-05: takvim ve gebelik randevusu anahtarları güvenli depoda kayıtlı', () async {
    SharedPreferences.setMockInitialValues({});
    for (final key in ['reproductive_calendar_v1', 'pregnancy_appointments_v3']) {
      expect(SecureHealthStore.isAllowed(key), isTrue, reason: key);
      await SecureHealthStore.write(key, '[]');
      expect(await SecureHealthStore.read(key), '[]');
    }
  });

  test('çocuk başına uyku günlüğü kaydedilebilir, kontrol karakteri reddedilir', () async {
    SharedPreferences.setMockInitialValues({});
    const key = '${SecureHealthStore.childSleepPrefix}abc-1';
    await SecureHealthStore.write(key, '[]');
    expect(await SecureHealthStore.read(key), '[]');
    expect(SecureHealthStore.isAllowed('${SecureHealthStore.childSleepPrefix}a\nb'), isFalse);
    expect(SecureHealthStore.isAllowed('baska_anahtar'), isFalse);
  });

  test('her güvenli JSON anahtarı yedekte ve güvenli depoda tanımlı', () {
    for (final key in BackupService.jsonAnyKeys) {
      expect(BackupService.keys, contains(key));
    }
    for (final key in ['family_recipes_v1', 'family_reminders_v40',
        'baby_health_journal_v41', 'womens_health_journal_v46',
        'paket39_pantry_ingredients_v1', 'general_recipe_favorites_v22']) {
      expect(BackupService.keys, contains(key), reason: key);
    }
    expect(BackupService.keys, isNot(contains('cloud_auth_session_v1')));
  });

  test('dışa aktar → sil → geri yükle döngüsünde veri kaybolmaz', () async {
    SharedPreferences.setMockInitialValues({
      'bebekAdi': 'Ada',
      'general_recipe_favorites_v22': '["g1"]',
      'paket39_shopping_budget_v1': 1500.0,
      'module_hub_favorites_v1': <String>['tarif'],
      'unrelated_setting': 'keep',
    });
    await SecureHealthStore.write('family_recipes_v1', '[{"id":"r1"}]');
    await SecureHealthStore.write('reproductive_calendar_v1', '{"cycle":28}');
    await SecureHealthStore.write('${SecureHealthStore.childSleepPrefix}c1',
        '[{"start":"2026-01-01T20:00:00.000","end":"2026-01-02T06:00:00.000"}]');

    final exported = await BackupService.export();
    await PrivacyService.deleteLocalRecords();
    final prefs = await SharedPreferences.getInstance();
    expect(await SecureHealthStore.read('bebekAdi'), isNull);
    expect(await SecureHealthStore.read('family_recipes_v1'), isNull);
    expect(await SecureHealthStore.read('${SecureHealthStore.childSleepPrefix}c1'), isNull);
    expect(prefs.getString('unrelated_setting'), 'keep');

    await BackupService.restore(exported);
    expect(await SecureHealthStore.read('bebekAdi'), 'Ada');
    expect(prefs.getString('general_recipe_favorites_v22'), '["g1"]');
    expect(prefs.getDouble('paket39_shopping_budget_v1'), 1500.0);
    expect(prefs.getStringList('module_hub_favorites_v1'), ['tarif']);
    expect(await SecureHealthStore.read('family_recipes_v1'), '[{"id":"r1"}]');
    expect(await SecureHealthStore.read('reproductive_calendar_v1'), '{"cycle":28}');
    expect(await SecureHealthStore.read('${SecureHealthStore.childSleepPrefix}c1'),
        contains('2026-01-01'));
  });

  test('eski sürüm yedeği yeni alanlardaki kayıtları silmez', () async {
    SharedPreferences.setMockInitialValues({'bebekAdi': 'Eski'});
    await SecureHealthStore.write('family_reminders_v40', '[{"id":"h1"}]');
    await BackupService.restore(_backup({'bebekAdi': 'Yeni'}));
    expect(await SecureHealthStore.read('bebekAdi'), 'Yeni');
    expect(await SecureHealthStore.read('family_reminders_v40'), '[{"id":"h1"}]');
  });

  test('bozuk yeni alan geri yüklemeyi başlamadan durdurur', () async {
    SharedPreferences.setMockInitialValues({'bebekAdi': 'Korunur'});
    for (final bad in <Map<String, Object>>[
      {'bebekAdi': 'X', 'family_recipes_v1': '[bozuk'},
      {'bebekAdi': 'X', 'family_recipes_v1': '42'},
      {'bebekAdi': 'X', 'paket39_shopping_budget_v1': -5},
      {'bebekAdi': 'X', '${SecureHealthStore.childSleepPrefix}c1': '{}'},
    ]) {
      await expectLater(BackupService.restore(_backup(bad)), throwsFormatException);
    }
    expect(await SecureHealthStore.read('bebekAdi'), 'Korunur');
  });
}
