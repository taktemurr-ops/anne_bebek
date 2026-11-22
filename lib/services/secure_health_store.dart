import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage for three sensitive journals. Android Keystore / iOS Keychain
/// manage the platform-protected encryption keys.
/// Do not use this as a general replacement for a database or cloud backup.
class SecureHealthStore {
  static const keys = <String>{
    'daily_routines_v1', 'reproductive_calendar_settings_v1',
    // GP-05 takvim deposu ve gebelik randevuları bu anahtarlarla yazılıyor;
    // listede olmadıkları için kayıt/okuma ArgumentError ile düşüyordu.
    'reproductive_calendar_v1', 'pregnancy_appointments_v3',
    // Kasılma/tekme sayacı ve emzirme zamanlayıcısı.
    'mom_tools_v1',
    'baby_fever_log_v1',
    // Bebek/anne/aile araçları (2026-11).
    'baby_milestones_v1', 'baby_teeth_v1', 'baby_food_intro_v1', 'baby_memories_v1', 'mood_screening_v1', 'ttc_journal_v1', 'mother_exercise_v1', 'milk_stash_v1', 'birth_plan_v1', 'newborn_checklist_v1', 'potty_training_v1', 'caregiver_card_v1', 'pregnancy_weight_v1', 'home_safety_v1', 'travel_checklist_v1',
    'my_health_v1',
    'mother_profile_v1',
    'doctor_questions_v1',
    'shopping_checklist_v1', 'family_recipes_v1',
    'family_notification_preferences_v1',
    'child_care_plan_v96', 'child_journal_entries_v59', 'child_profiles_directory_v58', 'family_activity_planner_v57', 'age_guide_checklist_v56', 'baby_health_journal_v41', 'womens_health_journal_v46', 'postpartum_companion_v1', 'cycle_history_v1', 'family_reminders_v40',
    'baby_feeding_journal_v5',
    'pregnancy_journal_v5',
    'family_calendar_v3',
    'pregnancy_last_period_v3',
    'bebekAdi', 'dogum', 'sonAdet', 'pregnancy_checklist_v3',
    'olaylar', 'olcumler', 'baby_sleep_journal_v1',
    'baby_v2', 'entries_v2', 'anne_bebek_lifehub_v1', 'women_lifestyle_v1', 'product_catalog_v1', 'cloud_auth_session_v1',
  };
  /// Çocuğa özel uyku günlüğü anahtarlarının öneki (bkz. SleepJournalPage).
  static const childSleepPrefix = 'baby_sleep_journal_v1_child_';

  /// Sabit anahtarlar ve çocuk başına üretilen uyku günlüğü anahtarları.
  static bool isAllowed(String key) {
    if (keys.contains(key)) return true;
    if (!key.startsWith(childSleepPrefix)) return false;
    final id = key.substring(childSleepPrefix.length);
    return id.isNotEmpty && id.length <= 128 &&
        !id.runes.any((r) => r < 32 || (r >= 127 && r <= 159));
  }

  /// Cihazda bulunan çocuk başına uyku günlüğü anahtarları (güvenli depo ve
  /// henüz taşınmamış eski düz kayıtlar). Yedek ve silme işlemleri için.
  static Future<List<String>> dynamicKeys() async {
    final found = <String>{};
    final all = await _storage.readAll();
    found.addAll(all.keys.where((k) => k.startsWith(childSleepPrefix) && isAllowed(k)));
    final prefs = await SharedPreferences.getInstance();
    found.addAll(prefs.getKeys().where((k) => k.startsWith(childSleepPrefix) && isAllowed(k)));
    return found.toList()..sort();
  }

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
    if (!isAllowed(key)) throw ArgumentError.value(key, 'key');
  }
}
