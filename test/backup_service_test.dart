import 'package:anne_bebek/services/secure_health_store.dart';
import 'support/secure_storage_mock.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anne_bebek/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(installSecureStorageMock);

  test('valid backup parses and retains records', () {
    final raw = jsonEncode({'format': BackupService.format, 'version': 1,
      'data': {'bebekAdi': 'Deneme', 'olaylar': '[]',
        'pregnancy_checklist_v3': ['a', 'b']}});
    final data = BackupService.parse(raw);
    expect(data['bebekAdi'], 'Deneme');
    expect(data['pregnancy_checklist_v3'], ['a', 'b']);
  });

  test('rejects unknown keys and malformed records', () {
    expect(() => BackupService.parse(jsonEncode({'format': BackupService.format,
      'version': 1, 'data': {'secret': 'bad'}})), throwsFormatException);
    expect(() => BackupService.parse(jsonEncode({'format': BackupService.format,
      'version': 1, 'data': {'olaylar': '{}'}})), throwsFormatException);
  });

  test('rejects malformed JSON inside a list record', () {
    final raw = jsonEncode({'format': BackupService.format, 'version': 1,
      'data': {'olaylar': '[invalid'}});
    expect(() => BackupService.parse(raw), throwsFormatException);
  });

  test('rejects incompatible growth and care records', () {
    for (final key in ['olaylar', 'olcumler']) {
      for (final invalid in ['[42]', '[{"boy": 12}]', '{"a": 1}']) {
        final raw = jsonEncode({'format': BackupService.format,
          'version': 1, 'data': {key: invalid}});
        expect(() => BackupService.parse(raw), throwsFormatException);
      }
    }
  });

  test('accepts string-based care and growth records', () {
    final raw = jsonEncode({'format': BackupService.format,
      'version': 1, 'data': {
        'olaylar': jsonEncode([{'tur': 'uyku', 'not': 'Test'}]),
        'olcumler': jsonEncode([{'boy': '72', 'kilo': '9.5'}]),
      }});
    expect(BackupService.preview(raw)['olaylar'], 1);
    expect(BackupService.preview(raw)['olcumler'], 1);
  });

  test('rejects oversized backup input', () {
    expect(() => BackupService.parse('x' * (BackupService.maxBytes + 1)),
      throwsFormatException);
  });

  test('backup preview shows counts without exposing values', () {
    final raw = jsonEncode({'format': BackupService.format, 'version': 1,
      'data': {'bebekAdi': 'Özel İsim', 'olaylar': '[{"tur":"uyku"},{"tur":"beslenme"}]',
        'pregnancy_checklist_v3': ['kontrol']}});
    expect(BackupService.preview(raw), {
      'bebekAdi': 1, 'olaylar': 2, 'pregnancy_checklist_v3': 1,
    });
  });

  test('rejects invalid checklist value', () {
    final raw = jsonEncode({'format': BackupService.format, 'version': 1,
      'data': {'pregnancy_checklist_v3': 'hatalı'}});
    expect(() => BackupService.parse(raw), throwsFormatException);
  });

  test('export and restore round trip', () async {
    SharedPreferences.setMockInitialValues({'bebekAdi': 'Deneme', 'olaylar': '[]'});
    final text = await BackupService.export();
    final prefs = await SharedPreferences.getInstance();
    // An unexpected conflicting plaintext copy must not be silently
    // overwritten during restore. Verify the guard, then clean up the
    // deliberately injected legacy value before restoring the backup.
    await prefs.setString('bebekAdi', 'Degisti');
    await expectLater(BackupService.restore(text), throwsStateError);
    await prefs.remove('bebekAdi');
    final count = await BackupService.restore(text);
    expect(count, greaterThanOrEqualTo(2));
    expect(await SecureHealthStore.read('bebekAdi'), 'Deneme');
    expect(prefs.getString('bebekAdi'), isNull);
  });
  test('Life Hub JSON map is preserved and counted correctly', () async {
    final lifeHub = jsonEncode({'Uyku': [{'date': '2026-10-31'}],
      'Beslenme': [{'date': '2026-10-30'}, {'date': '2026-10-31'}]});
    final raw = jsonEncode({'format': BackupService.format, 'version': 1,
      'data': {'anne_bebek_lifehub_v1': lifeHub}});
    expect(BackupService.parse(raw)['anne_bebek_lifehub_v1'], lifeHub);
    expect(BackupService.preview(raw)['anne_bebek_lifehub_v1'], 3);
    SharedPreferences.setMockInitialValues({'anne_bebek_lifehub_v1': lifeHub});
    final exported = await BackupService.export();
    expect(BackupService.preview(exported)['anne_bebek_lifehub_v1'], 3);
  });

  test('rejects invalid Life Hub object instead of overwriting records', () {
    final raw = jsonEncode({'format': BackupService.format, 'version': 1,
      'data': {'anne_bebek_lifehub_v1': '[1,2]'}});
    expect(() => BackupService.parse(raw), throwsFormatException);
  });

  test('çoklu çocuk profili ve günlüğü yedeğe dahil edilir', () async {
    final profiles = jsonEncode([
      {'id': 'c1', 'name': 'Bebek', 'birthDate': '2025-08-26T00:00:00.000',
        'sex': 'male'}
    ]);
    final journal = jsonEncode([
      {'id': 'e1', 'childId': 'c1', 'category': 'feeding',
        'note': 'Test', 'at': '2026-11-16T10:00:00.000', 'value': 120}
    ]);
    SharedPreferences.setMockInitialValues({
      'child_profiles_directory_v58': profiles,
      'child_journal_entries_v59': journal,
    });
    final exported = await BackupService.export();
    final parsed = BackupService.parse(exported);
    expect(parsed['child_profiles_directory_v58'], profiles);
    expect(parsed['child_journal_entries_v59'], journal);
  });

  test('bozuk çoklu çocuk verisi geri yükleme öncesi reddedilir', () {
    for (final entry in [
      ['child_profiles_directory_v58', '[{"id":"x"}]'],
      ['child_journal_entries_v59', '[{"id":"x"}]'],
    ]) {
      final raw = jsonEncode({'format': BackupService.format, 'version': 1,
        'data': {entry[0]: entry[1]}});
      expect(() => BackupService.parse(raw), throwsFormatException);
    }
  });

  test('eski yedek mevcut yeni modül kayıtlarını silmez', () async {
    SharedPreferences.setMockInitialValues({
      'shopping_v2': '[{"item":"korunacak"}]',
      'alisveris': '[]',
    });
    final oldBackup = jsonEncode({
      'format': BackupService.format,
      'version': 1,
      'data': {'bebekAdi': 'Yedekten gelen'},
    });
    final restored = await BackupService.restore(oldBackup);
    expect(restored, 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('shopping_v2'), '[{"item":"korunacak"}]');
    expect(prefs.getString('alisveris'), '[]');
    expect(await SecureHealthStore.read('bebekAdi'), 'Yedekten gelen');
  });

  test('eski yedek ilgisiz güvenli kayıttaki çakışmaya dokunmaz', () async {
    SharedPreferences.setMockInitialValues({});
    await SecureHealthStore.write('baby_feeding_journal_v5', '[]');
    final prefs = await SharedPreferences.getInstance();
    // This conflict requires explicit recovery, but is unrelated to the
    // restored key. The backup must not read, overwrite or delete it.
    await prefs.setString('baby_feeding_journal_v5', '[{"legacy":true}]');
    final oldBackup = jsonEncode({
      'format': BackupService.format,
      'version': 1,
      'data': {'alisveris': '[]'},
    });
    expect(await BackupService.restore(oldBackup), 1);
    expect(prefs.getString('baby_feeding_journal_v5'),
        '[{"legacy":true}]');
    await expectLater(
      SecureHealthStore.read('baby_feeding_journal_v5'), throwsStateError);
  });

  test('çoklu çocuk yedeği önizlemesi gerçek kayıt sayılarını gösterir', () {
    final profiles = jsonEncode([
      {'id': 'a', 'name': 'Bir', 'birthDate': '2025-08-26T00:00:00.000'},
      {'id': 'b', 'name': 'İki', 'birthDate': '2024-08-26T00:00:00.000'},
    ]);
    final journals = jsonEncode([
      {'id': 'e1', 'childId': 'a', 'category': 'feeding',
        'note': '', 'at': '2026-11-16T10:00:00.000'},
      {'id': 'e2', 'childId': 'b', 'category': 'sleep',
        'note': '', 'at': '2026-11-16T11:00:00.000'},
      {'id': 'e3', 'childId': 'a', 'category': 'growth',
        'note': '', 'at': '2026-11-16T12:00:00.000'},
    ]);
    final raw = jsonEncode({'format': BackupService.format, 'version': 1,
      'data': {'child_profiles_directory_v58': profiles,
        'child_journal_entries_v59': journals}});
    expect(BackupService.preview(raw), {
      'child_profiles_directory_v58': 2,
      'child_journal_entries_v59': 3,
    });
  });

  test('güvenli kayıtların hatalı türleri hiçbir veriyi değiştirmez', () async {
    SharedPreferences.setMockInitialValues({'alisveris': '[]'});
    for (final invalid in [42, true, 1.5, <String>['a']]) {
      final raw = jsonEncode({
        'format': BackupService.format,
        'version': 1,
        'data': {'alisveris': '[{"item":"degistir"}]',
          'baby_feeding_journal_v5': invalid},
      });
      expect(() => BackupService.parse(raw), throwsFormatException);
      await expectLater(BackupService.restore(raw), throwsFormatException);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('alisveris'), '[]');
      expect(await SecureHealthStore.read('baby_feeding_journal_v5'), isNull);
    }
  });

  test('güvenli metin kayıtları ve kontrol listesi geçerlidir', () {
    final raw = jsonEncode({
      'format': BackupService.format,
      'version': 1,
      'data': {'baby_feeding_journal_v5': '[]',
        'pregnancy_checklist_v3': ['kontrol']},
    });
    expect(BackupService.parse(raw)['baby_feeding_journal_v5'], '[]');
    expect(BackupService.parse(raw)['pregnancy_checklist_v3'], ['kontrol']);
  });

  test('profili olmayan çocuk günlüğü geri yükleme öncesi reddedilir', () async {
    SharedPreferences.setMockInitialValues({'alisveris': '[]'});
    final profiles = jsonEncode([
      {'id': 'c1', 'name': 'Bebek', 'birthDate': '2025-08-26T00:00:00.000'}
    ]);
    final journals = jsonEncode([
      {'id': 'e1', 'childId': 'missing', 'category': 'feeding',
        'note': '', 'at': '2026-11-16T10:00:00.000'}
    ]);
    final raw = jsonEncode({'format': BackupService.format, 'version': 1,
      'data': {'alisveris': '[{"item":"degistir"}]',
        'child_profiles_directory_v58': profiles,
        'child_journal_entries_v59': journals}});
    expect(() => BackupService.parse(raw), throwsFormatException);
    await expectLater(BackupService.restore(raw), throwsFormatException);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('alisveris'), '[]');
  });

  test('eşleşen çocuk profili ve günlüğü kabul edilir', () {
    final profiles = jsonEncode([
      {'id': 'c1', 'name': 'Bebek', 'birthDate': '2025-08-26T00:00:00.000'}
    ]);
    final journals = jsonEncode([
      {'id': 'e1', 'childId': 'c1', 'category': 'feeding',
        'note': '', 'at': '2026-11-16T10:00:00.000'}
    ]);
    final raw = jsonEncode({'format': BackupService.format, 'version': 1,
      'data': {'child_profiles_directory_v58': profiles,
        'child_journal_entries_v59': journals}});
    expect(BackupService.preview(raw)['child_journal_entries_v59'], 1);
  });

  test('çoklu çocuk kayıtları yedekten geri yüklenir', () async {
    SharedPreferences.setMockInitialValues({
      'child_profiles_directory_v58': '[]',
      'child_journal_entries_v59': '[]',
      'shopping_v2': '[{"item":"korunacak"}]',
    });
    final profiles = jsonEncode([
      {'id': 'c1', 'name': 'Bebek', 'birthDate': '2025-08-26T00:00:00.000'}
    ]);
    final journals = jsonEncode([
      {'id': 'e1', 'childId': 'c1', 'category': 'feeding',
        'note': '', 'at': '2026-11-16T10:00:00.000'}
    ]);
    final raw = jsonEncode({
      'format': BackupService.format,
      'version': 1,
      'data': {
        'child_profiles_directory_v58': profiles,
        'child_journal_entries_v59': journals,
      },
    });
    expect(await BackupService.restore(raw), 2);
    final prefs = await SharedPreferences.getInstance();
    // Sensitive child records are migrated to encrypted storage, not kept
    // as plaintext SharedPreferences values after a successful restore.
    expect(await SecureHealthStore.read('child_profiles_directory_v58'), profiles);
    expect(await SecureHealthStore.read('child_journal_entries_v59'), journals);
    expect(prefs.getString('child_profiles_directory_v58'), isNull);
    expect(prefs.getString('child_journal_entries_v59'), isNull);
    expect(prefs.getString('shopping_v2'), '[{"item":"korunacak"}]');
  });

  test('geri yuklenen cocuk kayitlari guvenli depodan disa aktarilir', () async {
    SharedPreferences.setMockInitialValues({});
    final profiles = jsonEncode([
      {'id': 'c1', 'name': 'Bebek', 'birthDate': '2025-08-26T00:00:00.000'}
    ]);
    final journals = jsonEncode([
      {'id': 'e1', 'childId': 'c1', 'category': 'feeding',
        'note': '', 'at': '2026-11-16T10:00:00.000'}
    ]);
    final raw = jsonEncode({
      'format': BackupService.format, 'version': 1,
      'data': {'child_profiles_directory_v58': profiles,
        'child_journal_entries_v59': journals},
    });
    expect(await BackupService.restore(raw), 2);
    final exported = BackupService.parse(await BackupService.export());
    expect(exported['child_profiles_directory_v58'], profiles);
    expect(exported['child_journal_entries_v59'], journals);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('child_profiles_directory_v58'), isFalse);
    expect(prefs.containsKey('child_journal_entries_v59'), isFalse);
  });

  test('geçersiz çoklu çocuk yedeği mevcut kayıtları değiştirmez', () async {
    SharedPreferences.setMockInitialValues({
      'child_profiles_directory_v58': '[]',
      'child_journal_entries_v59': '[]',
    });
    final profiles = jsonEncode([
      {'id': 'c1', 'name': 'Bebek', 'birthDate': '2025-08-26T00:00:00.000'}
    ]);
    final journals = jsonEncode([
      {'id': 'e1', 'childId': 'c2', 'category': 'feeding',
        'note': '', 'at': '2026-11-16T10:00:00.000'}
    ]);
    final raw = jsonEncode({
      'format': BackupService.format,
      'version': 1,
      'data': {
        'child_profiles_directory_v58': profiles,
        'child_journal_entries_v59': journals,
      },
    });
    await expectLater(BackupService.restore(raw), throwsFormatException);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('child_profiles_directory_v58'), '[]');
    expect(prefs.getString('child_journal_entries_v59'), '[]');
  });


  test('yedek onizlemesi hassas degerleri gostermeden sayilari verir', () {
    final raw = jsonEncode({
      'format': BackupService.format,
      'version': 1,
      'data': {
        'bebekAdi': 'Gizli Bebek Adi',
        'baby_feeding_journal_v5': jsonEncode([
          {'note': 'Ozel beslenme notu'}
        ]),
        'alisveris': jsonEncode([
          {'item': 'Bez'},
          {'item': 'Mama'},
        ]),
      },
    });
    final preview = BackupService.preview(raw);
    expect(preview['bebekAdi'], 1);
    expect(preview['alisveris'], 2);
    expect(preview.values.every((count) => count >= 0), isTrue);
    expect(preview.toString(), isNot(contains('Gizli Bebek Adi')));
    expect(preview.toString(), isNot(contains('Ozel beslenme notu')));
  });

  test('bozuk yasam merkezi yedegi kayitlari degistirmez', () async {
    SharedPreferences.setMockInitialValues({
      'anne_bebek_lifehub_v1': '{"Uyku":[]}',
      'alisveris': '[]',
    });
    final invalid = jsonEncode({
      'format': BackupService.format,
      'version': 1,
      'data': {
        'alisveris': '[{"item":"degisecek"}]',
        'anne_bebek_lifehub_v1': '{"Uyku":[42]}',
      },
    });
    await expectLater(BackupService.restore(invalid), throwsFormatException);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('alisveris'), '[]');
    expect(prefs.getString('anne_bebek_lifehub_v1'), '{"Uyku":[]}');
  });

}
