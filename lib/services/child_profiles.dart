import 'dart:convert';

/// Additional child directory. Existing baby journals remain attached to the
/// legacy primary profile until a separate migration is implemented.
class ChildProfile {
  final String id;
  final String name;
  final DateTime birthDate;
  /// WHO growth standards require sex-specific reference data.
  /// 'unknown' keeps existing profiles compatible until explicitly set.
  final String sex;
  const ChildProfile({required this.id, required this.name, required this.birthDate, this.sex = 'unknown'});

  Map<String, String> toJson() => {'id': id, 'name': name, 'birthDate': birthDate.toIso8601String(), 'sex': sex};
  factory ChildProfile.fromJson(Map<String, dynamic> data) {
    final id = data['id']; final name = data['name']; final rawDate = data['birthDate'];
    if (id is! String || id.trim().isEmpty || id != id.trim() || id.runes.any((r) => r < 32 || (r >= 127 && r <= 159)) || name is! String || name.trim().isEmpty || rawDate is! String) {
      throw const FormatException('Geçersiz çocuk profili');
    }
    final date = DateTime.tryParse(rawDate);
    if (date == null) throw const FormatException('Geçersiz doğum tarihi');
    final sex = data['sex'];
    return ChildProfile(id: id, name: name.trim(), birthDate: date,
      sex: sex == 'male' || sex == 'female' ? sex as String : 'unknown');
  }
}

String encodeChildProfiles(List<ChildProfile> profiles) => jsonEncode(profiles.map((e) => e.toJson()).toList());

List<ChildProfile> decodeChildProfiles(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  final decoded = jsonDecode(raw);
  if (decoded is! List) throw const FormatException('Profil listesi bozuk');
  // Validate the entire payload before exposing any profiles to callers.
  // A non-object entry is corrupt input, not a recoverable partial profile.
  final profiles = <ChildProfile>[];
  for (final entry in decoded) {
    if (entry is! Map) throw const FormatException('Geçersiz profil kaydı');
    final data = <String, dynamic>{};
    for (final key in entry.keys) {
      if (key is! String) throw const FormatException('Geçersiz profil alanı');
      data[key] = entry[key];
    }
    profiles.add(ChildProfile.fromJson(data));
  }
  if (profiles.map((e) => e.id).toSet().length != profiles.length) throw const FormatException('Yinelenen profil');
  return profiles;
}
