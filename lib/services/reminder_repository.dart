import 'dart:convert';
import 'secure_health_store.dart';

/// Device-local reminders. These are shown inside the app; they do not send
/// operating-system notifications or run when the app is closed.
class FamilyReminder {
  final String id;
  final String title;
  final DateTime due;
  final bool completed;
  final bool notify;

  const FamilyReminder({required this.id, required this.title,
    required this.due, this.completed = false, this.notify = false});

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'due': due.toIso8601String(),
    'completed': completed, 'notify': notify,
  };

  static FamilyReminder fromJson(Object? raw) {
    if (raw is! Map) throw const FormatException('Hatırlatıcı geçersiz');
    final id = raw['id'];
    final title = raw['title'];
    final due = DateTime.tryParse(raw['due']?.toString() ?? '');
    if (id is! String || id.isEmpty || title is! String ||
        title.trim().isEmpty || due == null || title.length > 120) {
      throw const FormatException('Hatırlatıcı alanları geçersiz');
    }
    return FamilyReminder(id: id, title: title, due: due,
      completed: raw['completed'] == true, notify: raw['notify'] == true);
  }
}

class ReminderRepository {
  static const storageKey = 'family_reminders_v40';

  static List<FamilyReminder> decode(String? encoded) {
    if (encoded == null || encoded.isEmpty) return [];
    final raw = jsonDecode(encoded);
    if (raw is! List || raw.length > 1000) {
      throw const FormatException('Hatırlatıcı listesi geçersiz');
    }
    final result = raw.map(FamilyReminder.fromJson).toList();
    if (result.map((e) => e.id).toSet().length != result.length) {
      throw const FormatException('Tekrarlanan hatırlatıcı kimliği');
    }
    result.sort((a, b) => a.due.compareTo(b.due));
    return result;
  }

  static String encode(List<FamilyReminder> items) =>
    jsonEncode(items.map((item) => item.toJson()).toList());

  static Future<List<FamilyReminder>> load() async =>
    decode(await SecureHealthStore.read(storageKey));

  static Future<void> save(List<FamilyReminder> items) async =>
    SecureHealthStore.write(storageKey, encode(items));
}
