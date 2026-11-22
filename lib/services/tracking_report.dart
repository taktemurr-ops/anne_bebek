import 'dart:convert';

/// Takip merkezi: uygulamadaki tüm takip edilen süreçlerin özet raporu.
/// Kayıt biçimleri farklı olduğundan özet, JSON yapısını genel kurallarla
/// okur: en büyük kayıt listesini sayar, içindeki en yeni tarihi bulur.

class TrackerDef {
  final String key;
  final String label;
  final String section;
  const TrackerDef(this.key, this.label, this.section);
}

const trackerSections = <String>['Bebek', 'Anne', 'Kadın', 'Aile'];

const trackerDefs = <TrackerDef>[
  TrackerDef('olaylar', 'Günlük bakım kayıtları (beslenme, uyku, bez)', 'Bebek'),
  TrackerDef('olcumler', 'Büyüme ölçümleri', 'Bebek'),
  TrackerDef('baby_sleep_journal_v1', 'Uyku günlüğü', 'Bebek'),
  TrackerDef('baby_feeding_journal_v5', 'Beslenme günlüğü', 'Bebek'),
  TrackerDef('baby_fever_log_v1', 'Ateş ve ilaç takibi', 'Bebek'),
  TrackerDef('baby_health_journal_v41', 'Bebek sağlık günlüğü (aşı, hastalık, alerji)', 'Bebek'),
  TrackerDef('baby_milestones_v1', 'Gelişim basamakları', 'Bebek'),
  TrackerDef('baby_teeth_v1', 'Diş takibi', 'Bebek'),
  TrackerDef('baby_food_intro_v1', 'Ek gıda ve alerjen', 'Bebek'),
  TrackerDef('baby_memories_v1', 'Anı defteri', 'Bebek'),
  TrackerDef('potty_training_v1', 'Tuvalet eğitimi', 'Bebek'),
  TrackerDef('newborn_checklist_v1', 'Yeni doğan yapılacaklar', 'Bebek'),
  TrackerDef('home_safety_v1', 'Ev güvenliği', 'Bebek'),
  TrackerDef('child_journal_entries_v59', 'Çocuk günlüğü', 'Bebek'),
  TrackerDef('pregnancy_appointments_v3', 'Gebelik kontrolleri', 'Anne'),
  TrackerDef('pregnancy_weight_v1', 'Gebelikte kilo', 'Anne'),
  TrackerDef('mom_tools_v1', 'Kasılma, tekme ve emzirme sayaçları', 'Anne'),
  TrackerDef('milk_stash_v1', 'Anne sütü stoğu', 'Anne'),
  TrackerDef('mood_screening_v1', 'Ruh hâli testleri', 'Anne'),
  TrackerDef('mother_exercise_v1', 'Pelvik taban ve egzersiz', 'Anne'),
  TrackerDef('birth_plan_v1', 'Doğum planı', 'Anne'),
  TrackerDef('postpartum_companion_v1', 'Doğum sonrası rehberi', 'Anne'),
  TrackerDef('cycle_history_v1', 'Adet döngüsü', 'Kadın'),
  TrackerDef('womens_health_journal_v46', 'Kadın sağlığı günlüğü', 'Kadın'),
  TrackerDef('my_health_v1', 'Sağlığım (ölçüm, ilaç, kontrol)', 'Kadın'),
  TrackerDef('ttc_journal_v1', 'Bebek planlama günlüğü', 'Kadın'),
  TrackerDef('doctor_questions_v1', 'Soru defteri', 'Kadın'),
  TrackerDef('family_reminders_v40', 'Aile hatırlatıcıları', 'Aile'),
  TrackerDef('shopping_checklist_v1', 'Alışveriş listesi', 'Aile'),
  TrackerDef('family_activity_planner_v57', 'Etkinlik planı', 'Aile'),
];

class TrackerSummary {
  final TrackerDef def;
  final int records;
  final DateTime? lastDate;
  final int last7;
  final int last30;
  const TrackerSummary(this.def, {this.records = 0, this.lastDate, this.last7 = 0, this.last30 = 0});
  bool get active => records > 0;
}

final _iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})');
final _dmy = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})');

DateTime? _asDate(Object? v) {
  if (v is String) {
    final m = _iso.firstMatch(v);
    if (m != null) return DateTime.tryParse(v) ?? DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
    final d = _dmy.firstMatch(v);
    if (d != null) {
      final y = int.parse(d[3]!), mo = int.parse(d[2]!), da = int.parse(d[1]!);
      if (mo >= 1 && mo <= 12 && da >= 1 && da <= 31) return DateTime(y, mo, da);
    }
  } else if (v is int && v > 1000000000000 && v < 10000000000000) {
    return DateTime.fromMillisecondsSinceEpoch(v);
  }
  return null;
}

/// Bir kaydın içindeki en yeni (gelecekte olmayan) tarih.
DateTime? latestDateIn(Object? v, DateTime now, [int depth = 0]) {
  if (depth > 6) return null;
  final limit = now.add(const Duration(days: 1));
  DateTime? best;
  void consider(DateTime? d) {
    if (d != null && d.isBefore(limit) && (best == null || d.isAfter(best!))) best = d;
  }
  consider(_asDate(v));
  if (v is List) {
    for (final e in v) { consider(latestDateIn(e, now, depth + 1)); }
  } else if (v is Map) {
    for (final e in v.values) { consider(latestDateIn(e, now, depth + 1)); }
  }
  return best;
}

/// Yapının içindeki asıl kayıt listesini bulur: en uzun liste; liste yoksa
/// en çok dolu alanı olan sözlüğün girdileri.
List<Object?> recordsIn(Object? v, [int depth = 0]) {
  if (depth > 5 || v == null) return const [];
  if (v is List) return v;
  if (v is Map) {
    var best = const <Object?>[];
    for (final e in v.values) {
      final inner = recordsIn(e, depth + 1);
      if (inner.length > best.length) best = inner;
    }
    if (best.isNotEmpty) return best;
    final scalars = v.values.where((e) => e != null && e != false && e != '' && e is! Map && e is! List).toList();
    return scalars;
  }
  return const [];
}

TrackerSummary summarizeTracker(TrackerDef def, String? raw, DateTime now) {
  if (raw == null || raw.trim().isEmpty) return TrackerSummary(def);
  Object? data;
  try {
    data = jsonDecode(raw);
  } catch (_) {
    return TrackerSummary(def, records: raw.trim().isEmpty ? 0 : 1);
  }
  final recs = recordsIn(data);
  var last7 = 0, last30 = 0;
  final today = DateTime(now.year, now.month, now.day);
  for (final r in recs) {
    final d = latestDateIn(r, now);
    if (d == null) continue;
    final age = today.difference(DateTime(d.year, d.month, d.day)).inDays;
    if (age >= 0 && age < 7) last7++;
    if (age >= 0 && age < 30) last30++;
  }
  return TrackerSummary(def, records: recs.length, lastDate: latestDateIn(data, now), last7: last7, last30: last30);
}

/// Günlük bakım kayıtlarının (olaylar) son [days] gündeki türlere göre sayısı.
Map<String, int> careEventTotals(String? raw, DateTime now, {int days = 7}) {
  final out = <String, int>{};
  if (raw == null) return out;
  Object? data;
  try { data = jsonDecode(raw); } catch (_) { return out; }
  if (data is! List) return out;
  final from = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
  for (final e in data) {
    if (e is! Map) continue;
    final t = e['tur'];
    final z = DateTime.tryParse('${e['zaman']}');
    if (t is! String || z == null || z.isBefore(from) || z.isAfter(now.add(const Duration(days: 1)))) continue;
    out[t] = (out[t] ?? 0) + 1;
  }
  return out;
}

class ReportTotals {
  final int activeTrackers;
  final int totalRecords;
  final int last7;
  const ReportTotals(this.activeTrackers, this.totalRecords, this.last7);
}

ReportTotals reportTotals(Iterable<TrackerSummary> list) => ReportTotals(
      list.where((s) => s.active).length,
      list.fold(0, (a, s) => a + s.records),
      list.fold(0, (a, s) => a + s.last7),
    );

String _d(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// Paylaşılabilir düz metin rapor. [tr] çeviri işlevidir (testlerde kimlik).
String buildTrackingReport(List<TrackerSummary> list, Map<String, int> careWeek, DateTime now, String Function(String) tr) {
  final b = StringBuffer();
  final tot = reportTotals(list);
  final dateL = tr('Tarih'), activeL = tr('Aktif takip'), totalL = tr('Toplam kayıt'),
      weekL = tr('Son 7 gün'), recL = tr('kayıt'), lastL = tr('son kayıt');
  b.writeln(tr('Anne & Bebek toplu takip raporu'));
  b.writeln('$dateL: ${_d(now)}');
  b.writeln('$activeL: ${tot.activeTrackers} · $totalL: ${tot.totalRecords} · $weekL: ${tot.last7}');
  if (careWeek.isNotEmpty) {
    b.writeln();
    b.writeln(tr('Son 7 günde bebek bakımı'));
    for (final e in careWeek.entries) { b.writeln('• ${tr(e.key)}: ${e.value}'); }
  }
  for (final sec in trackerSections) {
    final items = list.where((s) => s.def.section == sec && s.active).toList();
    if (items.isEmpty) continue;
    b.writeln();
    b.writeln(tr(sec).toUpperCase());
    for (final s in items) {
      final last = s.lastDate == null ? '' : ' · $lastL: ${_d(s.lastDate!)}';
      b.writeln('• ${tr(s.def.label)}: ${s.records} $recL$last');
    }
  }
  b.writeln();
  b.writeln(tr('Bu rapor cihazdaki kayıtların özetidir; tıbbi değerlendirme yerine geçmez.'));
  return b.toString();
}
