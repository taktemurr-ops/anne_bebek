import 'dart:convert';

/// GP-04: Per-child daily routine records. Never merge records across children.
class DailyRoutineEntry {
  final String id;
  final String childId;
  final String kind;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double? amountMl;
  final String note;

  const DailyRoutineEntry({required this.id, required this.childId,
    required this.kind, required this.startedAt, this.endedAt,
    this.amountMl, this.note = ''});

  Map<String, dynamic> toJson() => {
    'id': id, 'childId': childId, 'kind': kind,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'amountMl': amountMl, 'note': note,
  };

  factory DailyRoutineEntry.fromJson(Map<String, dynamic> data) {
    final id = data['id'];
    final childId = data['childId'];
    final kind = data['kind'];
    final start = data['startedAt'];
    final end = data['endedAt'];
    final amount = data['amountMl'];
    final note = data['note'];
    if (id is! String || id.trim().isEmpty ||
        childId is! String || childId.trim().isEmpty ||
        kind is! String || !const ['sleep', 'feeding', 'diaper', 'note'].contains(kind) ||
        start is! String || (end != null && end is! String) ||
        (amount != null && amount is! num) ||
        (note != null && note is! String)) {
      throw const FormatException('Geçersiz günlük rutin kaydı');
    }
    final startedAt = DateTime.tryParse(start);
    final endedAt = end == null ? null : DateTime.tryParse(end as String);
    if (startedAt == null || (end != null && endedAt == null) ||
        (endedAt != null && !endedAt.isAfter(startedAt)) ||
        (amount != null && (!amount.isFinite || amount <= 0 || amount > 2000)) ||
        (kind == 'feeding' && amount == null) ||
        (kind != 'feeding' && amount != null) ||
        (kind == 'sleep' && endedAt == null) ||
        (kind != 'sleep' && endedAt != null) ||
        (note is String && note.runes.length > 300)) {
      throw const FormatException('Geçersiz günlük rutin verisi');
    }
    return DailyRoutineEntry(id: id, childId: childId, kind: kind,
      startedAt: startedAt, endedAt: endedAt,
      amountMl: (amount as num?)?.toDouble(), note: note as String? ?? '');
  }
}

String encodeDailyRoutines(List<DailyRoutineEntry> entries) =>
    jsonEncode(entries.map((entry) => entry.toJson()).toList());

List<DailyRoutineEntry> decodeDailyRoutines(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  final decoded = jsonDecode(raw);
  if (decoded is! List) throw const FormatException('Günlük rutin listesi bozuk');
  final entries = <DailyRoutineEntry>[];
  final ids = <String>{};
  for (final item in decoded) {
    if (item is! Map) throw const FormatException('Geçersiz günlük rutin kaydı');
    if (item.keys.any((key) => key is! String)) {
      throw const FormatException('Geçersiz günlük rutin alanı');
    }
    final entry = DailyRoutineEntry.fromJson(Map<String, dynamic>.from(item));
    if (!ids.add(entry.id)) throw const FormatException('Yinelenen günlük rutin kaydı');
    entries.add(entry);
  }
  return entries;
}
