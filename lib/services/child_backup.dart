import 'dart:convert';
import 'child_profiles.dart';
import 'child_journals.dart';

/// Portable, unencrypted JSON export of a single child's journal.
/// Export is user initiated and must never be uploaded automatically.
class ChildBackup {
  static String exportJson(ChildProfile child, List<ChildJournalEntry> all) {
    final own = all.where((entry) => entry.childId == child.id).toList()
      ..sort((a, b) => a.at.compareTo(b.at));
    return const JsonEncoder.withIndent('  ').convert({
      'format': 'anne_bebek_child_backup',
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'child': child.toJson(),
      'entries': own.map((entry) => entry.toJson()).toList(),
    });
  }

  /// Validates a backup without modifying any device records.
  static List<ChildJournalEntry> inspectJson(String raw, {required String childId}) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['format'] != 'anne_bebek_child_backup' ||
        decoded['schemaVersion'] != 1) {
      throw const FormatException('Desteklenmeyen yedek biçimi');
    }
    final child = ChildProfile.fromJson(Map<String, dynamic>.from(decoded['child'] as Map));
    if (child.id != childId) throw const FormatException('Yedek farklı çocuğa ait');
    final rawEntries = decoded['entries'];
    if (rawEntries is! List) throw const FormatException('Kayıt listesi geçersiz');
    final entries = decodeChildJournal(jsonEncode(rawEntries));
    if (entries.any((entry) => entry.childId != childId)) {
      throw const FormatException('Yedekte başka çocuğun kaydı var');
    }
    return entries;
  }
}
