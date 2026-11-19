import 'dart:convert';

/// All entries carry an explicit child id. The legacy main-child journals
/// are deliberately not migrated automatically, preventing accidental mixing.
class ChildJournalEntry {
  final String id, childId, category, note;
  final DateTime at;
  final double? value;
  const ChildJournalEntry({required this.id, required this.childId,
    required this.category, required this.note, required this.at, this.value});
  Map<String, dynamic> toJson() => {'id': id, 'childId': childId,
    'category': category, 'note': note, 'at': at.toIso8601String(), 'value': value};
  factory ChildJournalEntry.fromJson(Map<String, dynamic> map) {
    final id = map['id'], childId = map['childId'], category = map['category'];
    final note = map['note'], at = DateTime.tryParse(map['at']?.toString() ?? '');
    if (id is! String || childId is! String || category is! String ||
        note is! String || at == null || id.isEmpty || childId.isEmpty) {
      throw const FormatException('Geçersiz çocuk günlüğü kaydı');
    }
    final value = map['value'];
    if (value != null && (value is! num || !value.isFinite)) {
      throw const FormatException('Geçersiz ölçüm');
    }
    return ChildJournalEntry(id: id, childId: childId, category: category,
      note: note, at: at, value: (value as num?)?.toDouble());
  }
}
String encodeChildJournal(List<ChildJournalEntry> entries) =>
  jsonEncode(entries.map((e) => e.toJson()).toList());
List<ChildJournalEntry> decodeChildJournal(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  final value = jsonDecode(raw);
  if (value is! List) throw const FormatException('Günlük listesi bozuk');
  final entries = <ChildJournalEntry>[];
  for (final item in value) {
    if (item is! Map || item.keys.any((key) => key is! String)) {
      throw const FormatException('Geçersiz günlük kaydı');
    }
    entries.add(ChildJournalEntry.fromJson(Map<String, dynamic>.from(item)));
  }
  if (entries.map((e) => e.id).toSet().length != entries.length) {
    throw const FormatException('Yinelenen günlük kaydı');
  }
  return entries;
}
