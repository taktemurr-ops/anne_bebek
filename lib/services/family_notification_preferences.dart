import 'dart:convert';

/// GP-09: Opt-in notification preferences. No automatic community publishing.
class FamilyNotificationPreferences {
  final bool remindersEnabled;
  final bool communityEnabled;
  final bool marketingEnabled;
  final int quietStartHour;
  final int quietEndHour;

  const FamilyNotificationPreferences({
    this.remindersEnabled = false,
    this.communityEnabled = false,
    this.marketingEnabled = false,
    this.quietStartHour = 22,
    this.quietEndHour = 8,
  });

  Map<String, dynamic> toJson() => {
    'remindersEnabled': remindersEnabled,
    'communityEnabled': communityEnabled,
    'marketingEnabled': marketingEnabled,
    'quietStartHour': quietStartHour,
    'quietEndHour': quietEndHour,
  };

  factory FamilyNotificationPreferences.fromJson(Map<String, dynamic> map) {
    final reminders = map['remindersEnabled'];
    final community = map['communityEnabled'];
    final marketing = map['marketingEnabled'];
    final start = map['quietStartHour'];
    final end = map['quietEndHour'];
    if (reminders is! bool || community is! bool || marketing is! bool ||
        start is! int || end is! int || start < 0 || start > 23 ||
        end < 0 || end > 23) {
      throw const FormatException('Geçersiz bildirim tercihleri');
    }
    return FamilyNotificationPreferences(remindersEnabled: reminders,
      communityEnabled: community, marketingEnabled: marketing,
      quietStartHour: start, quietEndHour: end);
  }

  bool isQuietHour(int hour) {
    if (hour < 0 || hour > 23 || quietStartHour == quietEndHour) return false;
    if (quietStartHour < quietEndHour) {
      return hour >= quietStartHour && hour < quietEndHour;
    }
    return hour >= quietStartHour || hour < quietEndHour;
  }
}

String encodeNotificationPreferences(FamilyNotificationPreferences prefs) =>
    jsonEncode(prefs.toJson());

FamilyNotificationPreferences? decodeNotificationPreferences(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final decoded = jsonDecode(raw);
  if (decoded is! Map) throw const FormatException('Geçersiz bildirim kaydı');
  return FamilyNotificationPreferences.fromJson(Map<String, dynamic>.from(decoded));
}
