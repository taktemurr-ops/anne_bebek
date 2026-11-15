import 'dart:convert';

/// Reads older locally stored JSON without crashing the whole application when
/// one optional record is malformed. Never modifies the stored source value.
List<Map<String, String>> readRecordList(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.whereType<Map>().map((entry) {
      final result = <String, String>{};
      for (final item in entry.entries) {
        if (item.key is String && item.value is String) {
          result[item.key as String] = item.value as String;
        }
      }
      return result;
    }).toList();
  } on FormatException {
    return [];
  } catch (_) {
    return [];
  }
}

List<String> readStringList(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    return decoded is List ? decoded.whereType<String>().toList() : [];
  } on FormatException {
    return [];
  } catch (_) {
    return [];
  }
}
