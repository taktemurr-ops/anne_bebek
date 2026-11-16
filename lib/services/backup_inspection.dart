import 'dart:convert';
import 'backup_service.dart';

/// Read-only preflight report. Never changes on-device records.
class BackupInspection {
  final int fieldCount;
  final int recordCount;
  final int missingFields;
  final DateTime? exportedAt;
  final List<String> warnings;

  const BackupInspection({required this.fieldCount, required this.recordCount,
    required this.missingFields, required this.exportedAt,
    required this.warnings});

  static BackupInspection inspect(String plainBackup) {
    final data = BackupService.parse(plainBackup);
    final counts = BackupService.preview(plainBackup);
    final wrapper = jsonDecode(plainBackup) as Map;
    final timestamp = wrapper['exportedAt'];
    DateTime? exported;
    if (timestamp is String) {
      exported = DateTime.tryParse(timestamp);
    }
    final missing = BackupService.keys.length - data.length;
    final warnings = <String>[];
    if (missing > 0) {
      warnings.add('Yedekte $missing veri alanı bulunmuyor. Geri yükleme '
          'bu alanlardaki mevcut kayıtları korur.');
    }
    if (data.isEmpty) {
      warnings.add('Yedek boş; geri yüklenecek kayıt bulunmuyor. Mevcut kayıtlar korunur.');
    }
    if (exported == null) {
      warnings.add('Yedek oluşturulma tarihi bulunmuyor veya geçersiz.');
    } else if (exported.isAfter(DateTime.now().toUtc().add(const Duration(days: 1)))) {
      warnings.add('Yedek oluşturulma tarihi gelecekte görünüyor.');
    }
    return BackupInspection(fieldCount: data.length,
      recordCount: counts.values.fold<int>(0, (sum, count) => sum + count),
      missingFields: missing, exportedAt: exported,
      warnings: List.unmodifiable(warnings));
  }
}
