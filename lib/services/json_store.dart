import 'dart:convert';

import 'secure_health_store.dart';

/// Şifreli depoda JSON nesnesi olarak tutulan basit kayıtlar için yardımcı.
/// Bozuk ya da beklenmeyen içerik boş nesne olarak okunur; yazma hataları
/// çağırana iletilir (sessiz veri kaybı olmasın).
class JsonStore {
  static Future<Map<String, dynamic>> readMap(String key) async {
    final raw = await SecureHealthStore.read(key);
    return decodeJsonMap(raw);
  }

  static Future<void> writeMap(String key, Map<String, dynamic> value) =>
      SecureHealthStore.write(key, jsonEncode(value));
}

Map<String, dynamic> decodeJsonMap(String? raw) {
  if (raw == null || raw.isEmpty) return {};
  try {
    final v = jsonDecode(raw);
    if (v is Map) return v.map((k, e) => MapEntry('$k', e));
  } catch (_) {}
  return {};
}

/// Çocuğa ait alt kayıt: ana profil için 'main', ek çocuklar için profil kimliği.
Map<String, dynamic> childSection(Map<String, dynamic> all, String childKey) {
  final v = all[childKey];
  return v is Map ? v.map((k, e) => MapEntry('$k', e)) : {};
}

/// Bebeğin ay olarak yaşı (doğum tarihi bilinmiyorsa null).
int? ageInMonths(DateTime? birth, DateTime now) {
  if (birth == null) return null;
  var m = (now.year - birth.year) * 12 + now.month - birth.month;
  if (now.day < birth.day) m--;
  return m < 0 ? 0 : m;
}

String dmy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
