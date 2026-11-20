import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/backup_inspection.dart';
import 'package:anne_bebek/services/backup_service.dart';

String backup(Map<String, Object> data, {String? exportedAt}) => jsonEncode({
  'format': BackupService.format, 'version': BackupService.version,
  'exportedAt': ?exportedAt, 'data': data,
});

void main() {
  test('partial backup confirms missing fields stay unchanged', () {
    final result = BackupInspection.inspect(backup({'bebekAdi': 'Test'}));
    expect(result.fieldCount, 1);
    expect(result.missingFields, BackupService.keys.length - 1);
    expect(result.warnings.any((v) => v.contains('korur')), isTrue);
  });

  test('empty backup does not claim to delete records', () {
    final result = BackupInspection.inspect(backup({}));
    expect(result.recordCount, 0);
    expect(result.warnings.any((v) => v.contains('boş')), isTrue);
  });

  test('full backup does not warn about missing fields', () {
    final data = <String, Object>{'bebekAdi': 'Test'};
    final result = BackupInspection.inspect(backup(data,
      exportedAt: '2026-10-01T12:00:00Z'));
    expect(result.exportedAt, DateTime.utc(2026, 10, 1, 12));
    expect(result.warnings.any((v) => v.contains('tarihi bulunmuyor')), isFalse);
  });

  test('malformed backup is rejected before confirmation', () {
    expect(() => BackupInspection.inspect('not json'), throwsFormatException);
  });
}
