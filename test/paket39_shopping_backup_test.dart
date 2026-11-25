import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/backup_service.dart';

String _backup(Object adet) => jsonEncode({
      'format': BackupService.format,
      'version': BackupService.version,
      'data': {'alisveris': jsonEncode(['Biberon']), 'alisveris_adet': adet},
    });

void main() {
  test('Alışveriş adetleri yedeğe dahildir ve geri okunur', () {
    expect(BackupService.keys, contains('alisveris_adet'));
    final data = BackupService.parse(_backup(jsonEncode({'Biberon': 3})));
    expect(jsonDecode(data['alisveris_adet'] as String), {'Biberon': 3});
  });

  test('Bozuk veya sınır dışı adetler geri yüklemeden önce reddedilir', () {
    for (final bad in [
      jsonEncode({'Biberon': 0}),
      jsonEncode({'Biberon': 100}),
      jsonEncode({'Biberon': 'iki'}),
      jsonEncode(['Biberon']),
      '{bozuk',
    ]) {
      expect(() => BackupService.parse(_backup(bad)), throwsFormatException, reason: bad);
    }
  });
}
