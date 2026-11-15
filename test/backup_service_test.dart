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
      'data': {'bebekAdi': 'Özel İsim', 'olaylar': '[{},{}]',
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

}
