import 'dart:convert';
import '../models/app_data.dart';
import 'child_journals.dart';

/// Copies the old primary-baby notes into a chosen child's journal.
/// Original entries are never deleted or modified. Repeated imports are safe.
/// The caller must obtain explicit user confirmation before persisting.
class LegacyChildImport {
  static List<BabyEntry> parseLegacy(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final parsed = jsonDecode(raw);
    if (parsed is! List) throw const FormatException('Eski kayıt listesi geçersiz');
    return parsed.map((item) => BabyEntry.fromJson(
      Map<String, dynamic>.from(item as Map))).toList();
  }

  static List<ChildJournalEntry> merge({
    required String childId,
    required List<BabyEntry> legacy,
    required List<ChildJournalEntry> existing,
  }) {
    if (childId.isEmpty) throw ArgumentError('Çocuk profili seçilmeli');
    final ids = existing.map((e) => e.id).toSet();
    final result = [...existing];
    for (final item in legacy) {
      // Namespaced identifiers prevent collisions with normal journal entries.
      final importedId = 'legacy_${childId}_${item.id}';
      if (ids.add(importedId)) {
        result.add(ChildJournalEntry(
          id: importedId, childId: childId,
          category: item.category, note: item.note,
          at: item.createdAt,
        ));
      }
    }
    return result;
  }

  static int newEntryCount({
    required String childId,
    required List<BabyEntry> legacy,
    required List<ChildJournalEntry> existing,
  }) => merge(childId: childId, legacy: legacy, existing: existing).length - existing.length;
}
