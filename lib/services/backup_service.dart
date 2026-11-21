import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_health_store.dart';
import 'child_profiles.dart';
import 'child_journals.dart';
import 'child_care_plans.dart';

/// Portable, plaintext backup of the app's own local records.
/// NOT encrypted: users must store and transfer it securely.
class BackupService {
  static const format = 'anne_bebek_backup';
  static const version = 1;
  static const maxBytes = 3 * 1024 * 1024;
  static const keys = <String>{
    'bebekAdi', 'dogum', 'sonAdet', 'olaylar', 'olcumler',
    'child_profiles_directory_v58', 'child_journal_entries_v59',
    'child_care_plan_v96',
    'alisveris', 'favoriler', 'sepet', 'tamamlanan', 'alisveris_adet',
    'baby_recipe_favorites_v1',
    'anne_bebek_lifehub_v1', 'pregnancy_last_period_v3',
    'pregnancy_checklist_v3', 'family_calendar_v3',
    'cycle_history_v1', 'baby_feeding_journal_v5',
    'pregnancy_journal_v5', 'baby_sleep_journal_v1', 'baby_v2', 'entries_v2', 'shopping_v2',
    // Önceki sürümde yedeğe girmeyen ve yeni cihazda kaybolan kayıtlar:
    ...jsonAnyKeys,
    'module_hub_favorites_v1', 'paket39_shopping_budget_v1',
  };

  /// JSON liste veya nesne içeren metin kayıtları (sağlık günlükleri,
  /// hatırlatıcılar, aile tarifleri, mutfak/kiler/bütçe verileri ...).
  static const jsonAnyKeys = <String>{
    'baby_health_journal_v41', 'daily_routines_v1',
    'family_activity_planner_v57', 'family_notification_preferences_v1',
    'family_recipes_v1', 'family_reminders_v40', 'postpartum_companion_v1',
    'product_catalog_v1', 'reproductive_calendar_v1', 'shopping_checklist_v1',
    'women_lifestyle_v1', 'womens_health_journal_v46',
    'age_guide_checklist_v56', 'pregnancy_appointments_v3',
    'general_recipe_favorites_v22', 'kitchen_savings_scenarios_v1',
    'paket39_shopping_details_v1', 'paket39_shopping_prices_v1',
    'paket39_shopping_actual_prices_v1', 'paket39_shopping_history_v1',
    'paket39_monthly_shopping_budgets_v1', 'paket39_named_shopping_lists_v1',
    'paket39_shopping_plans_v1', 'paket39_consumption_goals_v1',
    'paket39_kitchen_waste_v1', 'paket39_kitchen_meals_v1',
    'paket39_custom_recipes_v1', 'paket39_ingredient_unit_prices_v1',
    'paket39_meal_templates_v1', 'paket39_kitchen_weekly_budgets_v1',
    'paket39_saved_menu_drafts_v1', 'paket39_kitchen_trash_v1',
    'paket39_pantry_ingredients_v1', 'paket39_pantry_details_v1',
    'paket39_pantry_usage_v1', 'paket39_pantry_consumption_history_v1',
    'paket39_weekly_meal_plan_v1', 'paket39_recipe_recent_v1',
    'paket39_kitchen_manual_qa_v1', 'paket44_weekly_action_estimates_v1',
    'mom_tools_v1', 'baby_name_favorites_v1', 'baby_fever_log_v1', 'my_health_v1', 'mother_profile_v1', 'doctor_questions_v1',
  };

  /// Sabit anahtarlar ve çocuk başına uyku günlükleri yedeklenebilir.
  static bool isBackupKey(String key) =>
      keys.contains(key) || key.startsWith(SecureHealthStore.childSleepPrefix) &&
          SecureHealthStore.isAllowed(key);

  static bool _isSecure(String key) => SecureHealthStore.isAllowed(key);

  /// Dışa aktarma/silme sırasında işlenecek tüm anahtarlar.
  static Future<List<String>> allKeys() async =>
      [...keys, ...await SecureHealthStore.dynamicKeys()];

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
      } else if (entry.key == 'child_care_plan_v96') {
        result[entry.key] = decodeChildCareItems(entry.value as String).length;
      } else if (jsonListKeys.contains(entry.key)) {
        result[entry.key] = (jsonDecode(entry.value as String) as List).length;
      } else if (jsonAnyKeys.contains(entry.key) ||
          entry.key.startsWith(SecureHealthStore.childSleepPrefix)) {
        final any = jsonDecode(entry.value as String);
        result[entry.key] = any is List ? any.length : 1;
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
    if ((decoded['data'] as Map).length > keys.length + 64) {
      throw const FormatException('Yedek alan sayısı geçersiz.');
    }
    final data = <String, Object>{};
    for (final entry in (decoded['data'] as Map).entries) {
      if (entry.key is! String || !isBackupKey(entry.key as String)) {
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
      if (_isSecure(entry.key) &&
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
      if (entry.key == 'child_care_plan_v96') {
        if (value is! String) {
          throw const FormatException('Çocuk sağlık planı geçersiz.');
        }
        try {
          decodeChildCareItems(value);
        } catch (_) {
          throw const FormatException('Çocuk sağlık planı geçersiz.');
        }
      }
      // Alışveriş listesi adetleri: ürün adı -> 1..99 arası tam sayı.
      if (entry.key == 'alisveris_adet') {
        if (value is! String) {
          throw const FormatException('Alışveriş adetleri geçersiz.');
        }
        try {
          final parsed = jsonDecode(value);
          if (parsed is! Map || !parsed.entries.every((e) =>
              e.key is String && e.value is int &&
              (e.value as int) >= 1 && (e.value as int) <= 99)) {
            throw const FormatException('Alışveriş adetleri geçersiz.');
          }
        } on FormatException {
          throw const FormatException('Alışveriş adetleri geçersiz.');
        }
      }
      final key = entry.key as String;
      if (jsonAnyKeys.contains(key) ||
          key.startsWith(SecureHealthStore.childSleepPrefix)) {
        if (value is! String) {
          throw FormatException('Yedekte geçersiz kayıt: $key');
        }
        try {
          final parsedAny = jsonDecode(value);
          if (parsedAny is! List && parsedAny is! Map) {
            throw FormatException('Yedekte geçersiz kayıt: $key');
          }
          if (key.startsWith(SecureHealthStore.childSleepPrefix) &&
              parsedAny is! List) {
            throw FormatException('Yedekte geçersiz kayıt: $key');
          }
        } on FormatException {
          throw FormatException('Yedekte geçersiz kayıt: $key');
        }
      }
      if (key == 'paket39_shopping_budget_v1' &&
          (value is! num || value < 0 || !value.isFinite)) {
        throw const FormatException('Alışveriş bütçesi geçersiz.');
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
      data[key] = value is List
          ? List<String>.from(value)
          : key == 'paket39_shopping_budget_v1'
              ? (value as num).toDouble()
              : value as Object;
    }
    // When a backup includes both collections, every journal must belong to
    // a profile in that same snapshot. Reject inconsistent snapshots before
    // restore changes any local data.
    if (data.containsKey('child_profiles_directory_v58') &&
        data.containsKey('child_journal_entries_v59')) {
      final profiles = decodeChildProfiles(
        data['child_profiles_directory_v58'] as String);
      final journals = decodeChildJournal(
        data['child_journal_entries_v59'] as String);
      final profileIds = profiles.map((profile) => profile.id).toSet();
      if (journals.any((entry) => !profileIds.contains(entry.childId))) {
        throw const FormatException('Yedekte profili olmayan çocuk günlüğü var.');
      }
    }
    if (data.containsKey('child_profiles_directory_v58') &&
        data.containsKey('child_care_plan_v96')) {
      final profiles = decodeChildProfiles(
        data['child_profiles_directory_v58'] as String);
      final plans = decodeChildCareItems(
        data['child_care_plan_v96'] as String);
      final profileIds = profiles.map((profile) => profile.id).toSet();
      if (plans.any((item) => !profileIds.contains(item.childId))) {
        throw const FormatException('Yedekte profili olmayan çocuk sağlık planı var.');
      }
    }
    return data;
  }

  static Future<String> export() async {
    final p = await SharedPreferences.getInstance();
    final data = <String, Object>{};
    for (final key in await allKeys()) {
      final secureValue = _isSecure(key)
          ? await SecureHealthStore.read(key) : null;
      final value = key == 'pregnancy_checklist_v3'
          ? (secureValue == null ? null : List<String>.from(jsonDecode(secureValue) as List))
          : (_isSecure(key) ? secureValue : p.get(key));
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
      final secureBefore = _isSecure(key)
          ? await SecureHealthStore.read(key) : null;
      before[key] = key == 'pregnancy_checklist_v3'
          ? (secureBefore == null ? null : List<String>.from(jsonDecode(secureBefore) as List))
          : (_isSecure(key) ? secureBefore : p.get(key));
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
        if (_isSecure(key)) {
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
          if (_isSecure(key)) {
            await SecureHealthStore.delete(key);
          } else {
            await p.remove(key);
          }
        } else {
          if (_isSecure(key)) {
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
