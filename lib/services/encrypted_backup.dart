import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'backup_service.dart';

/// Password-protected export container. Does not encrypt live SharedPreferences.
class EncryptedBackup {
  static const format = 'anne_bebek_encrypted_backup';
  static const version = 1;
  static const iterations = 210000;
  static const maxInputBytes = 5 * 1024 * 1024;

  static void _checkPassword(String password) {
    if (password.runes.length > 256) {
      throw const FormatException('Yedek parolası en fazla 256 karakter olabilir.');
    }
    if (password.runes.length < 12) {
      throw const FormatException('Yedek parolası en az 12 karakter olmalıdır.');
    }
  }

  static List<int> _random(int count) {
    final random = Random.secure();
    return List<int>.generate(count, (_) => random.nextInt(256));
  }

  static Future<SecretKey> _key(String password, List<int> salt) async {
    final kdf = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iterations, bits: 256);
    return kdf.deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
  }

  static Future<String> encrypt(String plainBackup, String password) async {
    _checkPassword(password);
    if (utf8.encode(plainBackup).length > BackupService.maxBytes) {
      throw const FormatException('Yedek boyutu sınırı aşıldı (3 MB).');
    }
    BackupService.parse(plainBackup);
    final salt = _random(16);
    final nonce = _random(12);
    final key = await _key(password, salt);
    final cipher = AesGcm.with256bits();
    final box = await cipher.encrypt(utf8.encode(plainBackup), secretKey: key, nonce: nonce);
    return jsonEncode({
      'format': format, 'version': version, 'kdf': 'PBKDF2-HMAC-SHA256',
      'iterations': iterations, 'salt': base64Encode(salt),
      'nonce': base64Encode(nonce), 'ciphertext': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  static Future<String> decrypt(String encrypted, String password) async {
    _checkPassword(password);
    if (utf8.encode(encrypted).length > maxInputBytes) {
      throw const FormatException('Yedek dosyası çok büyük.');
    }
    try {
      final object = jsonDecode(encrypted);
      if (object is! Map || object['format'] != format ||
          object['version'] != version || object['iterations'] != iterations ||
          object['kdf'] != 'PBKDF2-HMAC-SHA256') {
        throw const FormatException('Şifreli yedek biçimi desteklenmiyor.');
      }
      final salt = base64Decode(object['salt'] as String);
      final nonce = base64Decode(object['nonce'] as String);
      final ciphertext = base64Decode(object['ciphertext'] as String);
      if (ciphertext.length > BackupService.maxBytes) {
        throw const FormatException('Şifreli yedek veri sınırını aşıyor.');
      }
      final mac = base64Decode(object['mac'] as String);
      if (salt.length != 16 || nonce.length != 12 || mac.length != 16) {
        throw const FormatException('Yedek şifreleme alanları geçersiz.');
      }
      final key = await _key(password, salt);
      final clear = await AesGcm.with256bits().decrypt(
        SecretBox(ciphertext, nonce: nonce, mac: Mac(mac)), secretKey: key);
      final result = utf8.decode(clear);
      BackupService.parse(result);
      return result;
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Parola yanlış veya yedek hasarlı.');
    }
  }
}
