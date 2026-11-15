import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/secure_health_store.dart';

void main() {
  test('pregnancy date is registered for secure storage and backup', () {
    expect(SecureHealthStore.keys, contains('pregnancy_last_period_v3'));
    expect(BackupService.keys, contains('pregnancy_last_period_v3'));
  });

  test('pregnancy date is preserved in backup parsing', () {
    const date = '2026-10-01T00:00:00.000';
    final raw = jsonEncode({
      'format': BackupService.format,
      'version': BackupService.version,
      'data': {'pregnancy_last_period_v3': date},
    });
    expect(BackupService.parse(raw)['pregnancy_last_period_v3'], date);
    expect(BackupService.preview(raw)['pregnancy_last_period_v3'], 1);
  });
}
