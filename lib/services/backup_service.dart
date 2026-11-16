import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_health_store.dart';
import 'child_profiles.dart';
import 'child_journals.dart';

/// Portable, plaintext backup of the app's own local records.
/// NOT encrypted: users must store and transfer it securely.
class BackupService {
  static const format = 'anne_bebek_backup';
  static const version = 1;
  static const maxBytes = 3 * 1024 * 1024;
  static const keys = <String>{
    'bebekAdi', 'dogum', 'sonAdet', 'olaylar', 'olcumler',
    'child_profiles_directory_v58', 'child_journal_entries_v59',
    'alisveris', 'favoriler', 'sepet', 'tamamlanan',
    'anne_bebek_lifehub_v1', 'pregnancy_last_period_v3',
    'pregnancy_checklist_v3', 'family_calendar_v3',
    'cycle_history_v1', 'baby_feeding_journal_v5',
    'pregnancy_journal_v5', 'baby_sleep_journal_v1', 'baby_v2', 'entries_v2', 'shopping_v2',
  };

  /// Fields expected to contain a JSON list, rather than a primitive string.
  static const jsonListKeys = <String>{
    'olaylar', 'olcumler', 'alisveris', 'favoriler', 'sepet',
    'tamamlanan', 'family_calendar_v3',
    'cycle_history_v1', 'baby_feeding_journal_v5',
    'pregnancy_journal_v5', 'baby_sleep_journal_v1', 'entries_v2', 'shopping_v2',
  };

  /// Life Hub stores a JSON object keyed by tool name, not a JSON list.
  static const jsonMapKeys = <String>{'anne_bebek_lifehub_v1'};

  /// Metadata only; never returns personal record contents.
  static Map<String, int> preview(String raw) {
    final data = parse(raw);
    final result = <String, int>{};
    for (final entry in data.entries) {
      if (entry.key == 'child_profiles_directory_v58') {
        result[entry.key] = decodeChildProfiles(entry.value as String).length;
      } else if (entry.key == 'child_journal_entries_v59') {
        result[entry.key] = decodeChildJournal(entry.value as String).length;
      } else if (jsonListKeys.contains(entry.key)) {
        result[entry.key] = (jsonDecode(entry.value as String) as List).length;
      } else if (jsonMapKeys.contains(entry.key)) {
        final map = jsonDecode(entry.value as String) as Map;
        result[entry.key] = map.values.fold<int>(0,
          (total, value) => total + (value is List ? value.length : 0));
      } else if (entry.value is List) {
        result[entry.key] = (entry.value as List).length;
      } else {
        result[entry.key] = 1;
      }
    }
    return result;
  }

  static Map<String, Object> parse(String raw) {
    if (utf8.encode(raw).length > maxBytes) {
      throw const FormatException('Yedek boyutu sınırı aşıldı (3 MB).');
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['format'] != format || decoded['version'] != version || decoded['data'] is! Map) {
      throw const FormatException('Geçersiz veya desteklenmeyen yedek biçimi.');
    }
    if ((decoded['data'] as Map).length > keys.length) {
      throw const FormatException('Yedek alan sayısı geçersiz.');
    }
    final data = <String, Object>{};
    for (final entry in (decoded['data'] as Map).entries) {
      if (entry.key is! String || !keys.contains(entry.key)) {
        throw const FormatException('Yedekte tanınmayan kayıt alanı var.');
      }
      final value = entry.value;
      if (value is! String && value is! bool && value is! int && value is! double && value is! List) {
        throw const FormatException('Yedekte geçersiz kayıt türü var.');
      }
      if (value is List && !value.every((v) => v is String)) {
        throw const FormatException('Yedekte geçersiz liste var.');
      }
      // SecureHealthStore.write requires a String for every secure key
      // except the checklist, which is serialized as a string on restore.
      // Reject invalid types before any storage write starts.
      if (SecureHealthStore.keys.contains(entry.key) &&
          entry.key != 'pregnancy_checklist_v3' && value is! String) {
        throw const FormatException('Güvenli yedek kayıt türü geçersiz.');
      }
      if (entry.key == 'pregnancy_checklist_v3' && value is! List<String>) {
        if (value is! List || !value.every((item) => item is String)) {
          throw const FormatException('Gebelik kontrol listesi geçersiz.');
        }
      }
      // Çoklu çocuk kayıtlarını geri yüklemeden önce model düzeyinde doğrula.
      if (entry.key == 'child_profiles_directory_v58' ||
          entry.key == 'child_journal_entries_v59') {
        if (value is! String) {
          throw const FormatException('Çocuk profili veya günlüğü geçersiz.');
        }
        try {
          if (entry.key == 'child_profiles_directory_v58') {
            decodeChildProfiles(value);
          } else {
            decodeChildJournal(value);
          }
        } catch (_) {
          throw const FormatException('Çocuk profili veya günlüğü geçersiz.');
        }
      }
      if (entry.key == 'baby_v2') {
        if (value is! String || jsonDecode(value) is! Map) {
          throw const FormatException('Bebek profili geçersiz.');
        }
      }
      if (jsonMapKeys.contains(entry.key)) {
        if (value is! String) {
          throw const FormatException('Yaşam merkezi kaydı geçersiz.');
        }
        try {
          final parsed = jsonDecode(value);
          if (parsed is! Map || !parsed.values.every((v) => v is List &&
              v.every((item) => item is Map))) {
            throw const FormatException('Yaşam merkezi kaydı geçersiz.');
          }
        } on FormatException {
          throw const FormatException('Yaşam merkezi kaydı geçersiz.');
        }
      }
      if (jsonListKeys.contains(entry.key)) {
        if (value is! String) {
          throw const FormatException('Yedekte geçersiz liste kaydı var.');
        }
        try {
          final parsedList = jsonDecode(value);
          if (parsedList is! List) {
            throw const FormatException('Yedekte geçersiz liste kaydı var.');
          }
          // The main screen expects string-keyed maps with string values.
          // Reject incompatible backups before any records are overwritten.
          if ((entry.key == 'olaylar' || entry.key == 'olcumler') &&
              !parsedList.every((item) => item is Map &&
                  item.keys.every((k) => k is String) &&
                  item.values.every((v) => v is String))) {
            throw const FormatException('Bakım veya ölçüm kaydı geçersiz.');
          }
        } on FormatException {
          throw const FormatException('Yedekte geçersiz liste kaydı var.');
        }
      }
      data[entry.key as String] = value is List ? List<String>.from(value) : value as Object;
    }
    return data;
  }

  static Future<String> export() async {
    final p = await SharedPreferences.getInstance();
    final data = <String, Object>{};
    for (final key in keys) {
      final secureValue = SecureHealthStore.keys.contains(key)
          ? await SecureHealthStore.read(key) : null;
      final value = key == 'pregnancy_checklist_v3'
          ? (secureValue == null ? null : List<String>.from(jsonDecode(secureValue) as List))
          : (SecureHealthStore.keys.contains(key) ? secureValue : p.get(key));
      if (value is String || value is bool || value is int || value is double) {
        data[key] = value as Object;
      } else if (value is List<String>) {
        data[key] = value;
      }
    }
    final result = jsonEncode({'format': format, 'version': version,
      'exportedAt': DateTime.now().toUtc().toIso8601String(), 'data': data});
    if (utf8.encode(result).length > maxBytes) {
      throw const FormatException('Kayıtlar 3 MB sınırını aşıyor.');
    }
    return result;
  }

  /// Restore only keys present in the backup. Roll back if a write fails.
  static Future<int> restore(String raw) async {
    final data = parse(raw); // validate everything before touching storage
    final p = await SharedPreferences.getInstance();
    final before = <String, Object?>{};
    for (final key in data.keys) {
      final secureBefore = SecureHealthStore.keys.contains(key)
          ? await SecureHealthStore.read(key) : null;
      before[key] = key == 'pregnancy_checklist_v3'
          ? (secureBefore == null ? null : List<String>.from(jsonDecode(secureBefore) as List))
          : (SecureHealthStore.keys.contains(key) ? secureBefore : p.get(key));
    }
    final attempted = <String>[];
    try {
      // Older backups may not include newer feature keys. Never erase
      // unrelated records merely because an older backup omitted them.
      for (final entry in data.entries) {
        final key = entry.key;
        final value = entry.value;
        // Include the currently attempted key: a failed write may be partial.
        attempted.add(key);
        if (SecureHealthStore.keys.contains(key)) {
          await SecureHealthStore.write(key, key == 'pregnancy_checklist_v3'
              ? jsonEncode(value) : value as String);
        } else {
          await _write(p, key, value);
        }
      }
    } catch (_) {
      // Only roll back keys this restore intended to modify. A failed restore
      // must never touch unrelated records added by newer app versions.
      for (final key in attempted.reversed) {
        final oldValue = before[key];
        if (oldValue == null) {
          if (SecureHealthStore.keys.contains(key)) {
            await SecureHealthStore.delete(key);
          } else {
            await p.remove(key);
          }
        } else {
          if (SecureHealthStore.keys.contains(key)) {
            await SecureHealthStore.write(key, key == 'pregnancy_checklist_v3'
                ? jsonEncode(oldValue) : oldValue as String);
          } else {
            await _write(p, key, oldValue);
          }
        }
      }
      rethrow;
    }
    return data.length;
  }

  static Future<void> _write(SharedPreferences p, String key, Object value) async {
    if (value is String) { if (!await p.setString(key, value)) throw StateError('Kayıt yazılamadı: $key'); }
    else if (value is bool) { if (!await p.setBool(key, value)) throw StateError('Kayıt yazılamadı: $key'); }
    else if (value is int) { if (!await p.setInt(key, value)) throw StateError('Kayıt yazılamadı: $key'); }
    else if (value is double) { if (!await p.setDouble(key, value)) throw StateError('Kayıt yazılamadı: $key'); }
    else if (value is List<String>) { if (!await p.setStringList(key, value)) throw StateError('Kayıt yazılamadı: $key'); }
    else { throw const FormatException('Desteklenmeyen veri türü.'); }
  }
}
