import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/secure_health_store.dart';

void main() {
  test('baby profile, entries and life tools use secure storage', () {
    for (final key in ['baby_v2', 'entries_v2', 'anne_bebek_lifehub_v1']) {
      expect(SecureHealthStore.keys, contains(key));
      expect(BackupService.keys, contains(key));
    }
  });

  test('legacy baby and entry backup data remains compatible', () {
    final raw = jsonEncode({'format': BackupService.format,
      'version': BackupService.version, 'data': {
        'baby_v2': jsonEncode({'name': 'Bebek'}),
        'entries_v2': jsonEncode([{'category': 'uyku'}]),
        'anne_bebek_lifehub_v1': jsonEncode({'Takip': <Map<String, String>>[]}),
      }});
    final data = BackupService.parse(raw);
    expect(data.keys, containsAll(['baby_v2', 'entries_v2', 'anne_bebek_lifehub_v1']));
  });

  test('malformed baby profile backup is rejected before restore', () {
    final raw = jsonEncode({'format': BackupService.format,
      'version': BackupService.version, 'data': {'baby_v2': '[]'}});
    expect(() => BackupService.parse(raw), throwsFormatException);
  });
}
