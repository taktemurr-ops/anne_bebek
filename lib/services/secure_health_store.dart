import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage for three sensitive journals. Android Keystore / iOS Keychain
/// manage the platform-protected encryption keys.
/// Do not use this as a general replacement for a database or cloud backup.
class SecureHealthStore {
  static const keys = <String>{
    'child_care_plan_v96', 'child_journal_entries_v59', 'child_profiles_directory_v58', 'family_activity_planner_v57', 'age_guide_checklist_v56', 'baby_health_journal_v41', 'womens_health_journal_v46', 'postpartum_companion_v1', 'cycle_history_v1', 'family_reminders_v40',
    'baby_feeding_journal_v5',
    'pregnancy_journal_v5',
    'family_calendar_v3',
    'pregnancy_last_period_v3',
    'bebekAdi', 'dogum', 'sonAdet', 'pregnancy_checklist_v3',
    'olaylar', 'olcumler', 'baby_sleep_journal_v1',
    'baby_v2', 'entries_v2', 'anne_bebek_lifehub_v1', 'women_lifestyle_v1', 'product_catalog_v1', 'cloud_auth_session_v1',
  };
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Migration is idempotent. Delete legacy plaintext ONLY after a successful
  /// secure write and read-back. Errors propagate instead of losing records.
  static Future<String?> read(String key) async {
    _checkKey(key);
    final existing = await _storage.read(key: key);
    final prefs = await SharedPreferences.getInstance();
    final legacy = key == 'pregnancy_checklist_v3'
        ? (prefs.getStringList(key) == null ? null : _encodeList(prefs.getStringList(key)!))
        : prefs.getString(key);
    if (existing != null) {
      // A previous interrupted migration may have left a plaintext copy.
      // Never discard divergent data: that requires manual recovery.
      if (legacy != null) {
        if (legacy != existing) {
          throw StateError('Çakışan eski ve güvenli kayıt: $key');
        }
        if (!await prefs.remove(key)) {
          throw StateError('Eski kayıt kaldırılamadı: $key');
        }
      }
      return existing;
    }
    if (legacy == null) return null;
    await _storage.write(key: key, value: legacy);
    if (await _storage.read(key: key) != legacy) {
      throw StateError('Güvenli veri taşıma doğrulanamadı: $key');
    }
    if (!await prefs.remove(key)) {
      throw StateError('Eski kayıt kaldırılamadı: $key');
    }
    return legacy;
  }

  static Future<void> write(String key, String value) async {
    _checkKey(key);
    // Prevent overwriting an un-migrated, different plaintext record.
    // Call read first to complete migration and detect any conflict.
    await read(key);
    await _storage.write(key: key, value: value);
    if (await _storage.read(key: key) != value) {
      throw StateError('Güvenli kayıt doğrulanamadı: $key');
    }
    // Cleanup in case a legacy copy remained after an interrupted migration.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key) && !await prefs.remove(key)) {
      throw StateError('Eski kayıt kaldırılamadı: $key');
    }
  }

  static Future<void> delete(String key) async {
    _checkKey(key);
    // Remove both copies when explicitly deleting, including after a failed
    // migration. This is intentionally different from read/write behavior.
    await _storage.delete(key: key);
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key) && !await prefs.remove(key)) {
      throw StateError('Eski kayıt kaldırılamadı: $key');
    }
  }

  static String _encodeList(List<String> values) => jsonEncode(values);

  static void _checkKey(String key) {
    if (!keys.contains(key)) throw ArgumentError.value(key, 'key');
  }
}
