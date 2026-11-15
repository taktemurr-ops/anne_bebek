import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/encrypted_backup.dart';

void main() {
  const password = 'uzun-guclu-test-parolasi-123';
  final sample = jsonEncode({'format': BackupService.format, 'version': 1,
    'data': {'bebekAdi': 'Deneme', 'olaylar': '[]'}});

  test('encrypted backup roundtrip', () async {
    final encrypted = await EncryptedBackup.encrypt(sample, password);
    expect(encrypted, isNot(contains('Deneme')));
    expect(await EncryptedBackup.decrypt(encrypted, password), sample);
  });

  test('wrong password cannot decrypt', () async {
    final encrypted = await EncryptedBackup.encrypt(sample, password);
    await expectLater(EncryptedBackup.decrypt(encrypted, 'farkli-uzun-parola'),
      throwsFormatException);
  });

  test('tampered ciphertext is rejected', () async {
    final encrypted = await EncryptedBackup.encrypt(sample, password);
    final map = jsonDecode(encrypted) as Map<String, dynamic>;
    map['ciphertext'] = 'AAAA';
    await expectLater(EncryptedBackup.decrypt(jsonEncode(map), password),
      throwsFormatException);
  });

  test('overlong password rejected before key derivation', () async {
    await expectLater(EncryptedBackup.encrypt(sample, 'x' * 257), throwsFormatException);
  });

  test('oversized plaintext rejected', () async {
    await expectLater(EncryptedBackup.encrypt('x' * (BackupService.maxBytes + 1), password),
      throwsFormatException);
  });

  test('malformed encrypted input rejected', () async {
    await expectLater(EncryptedBackup.decrypt('{invalid', password), throwsFormatException);
  });

  test('short password rejected', () async {
    await expectLater(EncryptedBackup.encrypt(sample, 'kisa'), throwsFormatException);
  });
}
