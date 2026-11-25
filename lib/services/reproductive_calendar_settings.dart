import 'dart:convert';

/// GP-05: User-entered reproductive calendar preferences.
/// These dates are sensitive and must only be stored in SecureHealthStore.
class ReproductiveCalendarSettings {
  final DateTime? lastMenstrualPeriod;
  final int cycleDays;

  const ReproductiveCalendarSettings({this.lastMenstrualPeriod,
    this.cycleDays = 28});

  Map<String, dynamic> toJson() => {
    'lastMenstrualPeriod': lastMenstrualPeriod?.toIso8601String(),
    'cycleDays': cycleDays,
  };

  factory ReproductiveCalendarSettings.fromJson(Map<String, dynamic> map) {
    final rawDate = map['lastMenstrualPeriod'];
    final rawCycle = map['cycleDays'];
    if ((rawDate != null && rawDate is! String) ||
        rawCycle is! int || rawCycle < 21 || rawCycle > 35) {
      throw const FormatException('Geçersiz döngü ayarları');
    }
    final date = rawDate == null ? null : DateTime.tryParse(rawDate as String);
    if (rawDate != null && date == null) {
      throw const FormatException('Geçersiz son adet tarihi');
    }
    return ReproductiveCalendarSettings(lastMenstrualPeriod: date,
      cycleDays: rawCycle);
  }
}

String encodeReproductiveSettings(ReproductiveCalendarSettings value) =>
    jsonEncode(value.toJson());

ReproductiveCalendarSettings? decodeReproductiveSettings(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final decoded = jsonDecode(raw);
  if (decoded is! Map) throw const FormatException('Geçersiz döngü kaydı');
  return ReproductiveCalendarSettings.fromJson(Map<String, dynamic>.from(decoded));
}
