import 'dart:convert';

/// Kasılma sayacı, tekme sayacı ve emzirme zamanlayıcısının saf mantığı.
/// Arayüzden bağımsızdır; saat dışarıdan verilir, böylece test edilebilir.
/// Hiçbiri tıbbi teşhis yapmaz; yalnızca "doktoruna danış / acile git"
/// eşiklerini hatırlatır.

class Contraction {
  final DateTime start;
  final DateTime? end;
  const Contraction(this.start, [this.end]);

  Duration? get duration => end?.difference(start);
  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        if (end != null) 'end': end!.toIso8601String(),
      };
  static Contraction? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final s = DateTime.tryParse('${raw['start']}');
    if (s == null) return null;
    final e = raw['end'] == null ? null : DateTime.tryParse('${raw['end']}');
    if (e != null && e.isBefore(s)) return null;
    return Contraction(s, e);
  }
}

class ContractionSummary {
  final int countLastHour;
  final Duration? averageDuration;
  final Duration? averageInterval;
  /// 5-1-1: son bir saattir kasılmalar en fazla 5 dk arayla geliyor ve
  /// her biri en az 1 dk sürüyor.
  final bool fiveOneOne;
  const ContractionSummary(this.countLastHour, this.averageDuration,
      this.averageInterval, this.fiveOneOne);
}

/// [items] en yeniden eskiye ya da karışık olabilir; sıralanır.
ContractionSummary summarizeContractions(List<Contraction> items, DateTime now) {
  final done = items.where((c) => c.end != null && !c.start.isAfter(now)).toList()
    ..sort((a, b) => a.start.compareTo(b.start));
  final hourAgo = now.subtract(const Duration(hours: 1));
  final lastHour = done.where((c) => !c.start.isBefore(hourAgo)).toList();
  final recent = lastHour.length >= 2 ? lastHour : done.skip(done.length > 6 ? done.length - 6 : 0).toList();

  Duration? avgDuration;
  if (recent.isNotEmpty) {
    final total = recent.fold<int>(0, (s, c) => s + c.duration!.inSeconds);
    avgDuration = Duration(seconds: (total / recent.length).round());
  }
  Duration? avgInterval;
  final intervals = <int>[];
  for (var i = 1; i < recent.length; i++) {
    intervals.add(recent[i].start.difference(recent[i - 1].start).inSeconds);
  }
  if (intervals.isNotEmpty) {
    avgInterval = Duration(seconds: (intervals.reduce((a, b) => a + b) / intervals.length).round());
  }

  // 5-1-1 için son bir saat boyunca kesintisiz örüntü gerekir: ilk kayıt en
  // az ~55 dk önce başlamış olmalı ve her aralık ≤5 dk, her süre ≥1 dk.
  var fiveOneOne = false;
  if (lastHour.length >= 2) {
    // Bir saat öncesine en yakın kasılmayı da örüntüye kat.
    final before = done.where((c) => c.start.isBefore(hourAgo)).toList();
    final window = [if (before.isNotEmpty) before.last, ...lastHour];
    final spanOk = now.difference(window.first.start) >= const Duration(minutes: 55);
    var ok = spanOk;
    for (var i = 0; i < window.length && ok; i++) {
      if (window[i].duration! < const Duration(seconds: 60)) ok = false;
      if (i > 0 && window[i].start.difference(window[i - 1].start) > const Duration(minutes: 5)) ok = false;
    }
    if (ok && now.difference(window.last.end!) > const Duration(minutes: 5)) ok = false;
    fiveOneOne = ok;
  }
  return ContractionSummary(lastHour.length, avgDuration, avgInterval, fiveOneOne);
}

class KickSession {
  final DateTime start;
  final DateTime? end;
  final int count;
  const KickSession(this.start, {this.end, this.count = 0});

  KickSession kick() => KickSession(start, end: end, count: count + 1);
  KickSession finish(DateTime at) => KickSession(start, end: at, count: count);
  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        if (end != null) 'end': end!.toIso8601String(),
        'count': count,
      };
  static KickSession? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final s = DateTime.tryParse('${raw['start']}');
    final c = raw['count'];
    if (s == null || c is! int || c < 0 || c > 999) return null;
    final e = raw['end'] == null ? null : DateTime.tryParse('${raw['end']}');
    return KickSession(s, end: e, count: c);
  }
}

const kickTarget = 10;
const kickWindow = Duration(hours: 2);

enum KickStatus { counting, reached, overdue }

/// 10 hareket 2 saat içinde sayılırsa hedefe ulaşılmıştır; 2 saat geçip 10'a
/// ulaşılmadıysa doktoruna/doğumhaneye başvurması hatırlatılır.
KickStatus kickStatus(KickSession s, DateTime now) {
  if (s.count >= kickTarget) return KickStatus.reached;
  final elapsed = (s.end ?? now).difference(s.start);
  return elapsed >= kickWindow ? KickStatus.overdue : KickStatus.counting;
}

/// Emzirme zamanlayıcısı: sol/sağ meme için ayrı süre tutar.
class NursingTimer {
  final DateTime? startedAt; // oturumun ilk başlangıcı
  final String? activeSide; // 'Sol' | 'Sağ' | null (duraklatıldı)
  final DateTime? activeSince;
  final int leftSeconds;
  final int rightSeconds;
  const NursingTimer({this.startedAt, this.activeSide, this.activeSince,
      this.leftSeconds = 0, this.rightSeconds = 0});

  bool get running => activeSide != null;
  bool get isEmpty => startedAt == null;

  int secondsFor(String side, DateTime now) {
    final base = side == 'Sol' ? leftSeconds : rightSeconds;
    if (activeSide == side && activeSince != null) {
      final live = now.difference(activeSince!).inSeconds;
      return base + (live < 0 ? 0 : live);
    }
    return base;
  }

  int totalSeconds(DateTime now) => secondsFor('Sol', now) + secondsFor('Sağ', now);

  NursingTimer _banked(DateTime now) => NursingTimer(
      startedAt: startedAt,
      leftSeconds: secondsFor('Sol', now),
      rightSeconds: secondsFor('Sağ', now));

  /// [side] tarafını başlatır; diğer taraf çalışıyorsa önce onu durdurur.
  /// Aynı taraf çalışıyorsa duraklatır.
  NursingTimer toggle(String side, DateTime now) {
    assert(side == 'Sol' || side == 'Sağ');
    if (activeSide == side) return _banked(now);
    final b = _banked(now);
    return NursingTimer(startedAt: startedAt ?? now, activeSide: side,
        activeSince: now, leftSeconds: b.leftSeconds, rightSeconds: b.rightSeconds);
  }

  NursingTimer pause(DateTime now) => _banked(now);

  /// Beslenme günlüğüne yazılacak kayıt; 30 saniyeden kısa oturum kaydedilmez.
  Map<String, dynamic>? toJournalEntry(DateTime now) {
    if (startedAt == null) return null;
    final l = secondsFor('Sol', now), r = secondsFor('Sağ', now);
    if (l + r < 30) return null;
    final minutes = ((l + r) / 60).ceil().clamp(1, 240);
    final side = l > 0 && r > 0 ? 'Her ikisi' : (l > 0 ? 'Sol' : 'Sağ');
    return {
      'type': 'Emzirme',
      'date': startedAt!.toIso8601String(),
      'amount': minutes,
      'side': side,
      'note': 'Zamanlayıcı: Sol ${formatClock(l)}, Sağ ${formatClock(r)}',
    };
  }

  Map<String, dynamic> toJson() => {
        if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
        if (activeSide != null) 'activeSide': activeSide,
        if (activeSince != null) 'activeSince': activeSince!.toIso8601String(),
        'left': leftSeconds,
        'right': rightSeconds,
      };
  static NursingTimer fromJson(Object? raw) {
    if (raw is! Map) return const NursingTimer();
    final side = raw['activeSide'];
    final since = DateTime.tryParse('${raw['activeSince']}');
    final validSide = (side == 'Sol' || side == 'Sağ') && since != null;
    int secs(Object? v) => v is int && v >= 0 && v < 24 * 3600 ? v : 0;
    return NursingTimer(
      startedAt: DateTime.tryParse('${raw['startedAt']}'),
      activeSide: validSide ? side as String : null,
      activeSince: validSide ? since : null,
      leftSeconds: secs(raw['left']),
      rightSeconds: secs(raw['right']),
    );
  }
}

/// Son emzirme kaydına göre sıradaki taraf önerisi (en yeni kayıt önce
/// gelmeyebilir; tarihe göre bakılır). Bilgi yoksa null.
String? suggestNextSide(List<Map<String, dynamic>> journal) {
  Map<String, dynamic>? last;
  DateTime? lastDate;
  for (final e in journal) {
    if (e['type'] != 'Emzirme') continue;
    final d = DateTime.tryParse('${e['date']}');
    if (d == null) continue;
    if (lastDate == null || d.isAfter(lastDate)) { last = e; lastDate = d; }
  }
  if (last == null) return null;
  final note = '${last['note'] ?? ''}';
  // Zamanlayıcı notunda son biten taraf bilinmez; daha uzun emzirilen tarafın
  // karşısı önerilir. Elle girilen kayıtta yazılan tarafın karşısı.
  final m = RegExp(r'Sol (\d+):(\d+), Sağ (\d+):(\d+)').firstMatch(note);
  if (m != null) {
    final l = int.parse(m[1]!) * 60 + int.parse(m[2]!);
    final r = int.parse(m[3]!) * 60 + int.parse(m[4]!);
    return l >= r ? 'Sağ' : 'Sol';
  }
  return switch (last['side']) { 'Sol' => 'Sağ', 'Sağ' => 'Sol', _ => null };
}

String formatClock(int seconds) {
  final m = seconds ~/ 60, s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// Tek güvenli kayıt: {contractions:[], kicks:[], nursing:{}}.
class MomToolsData {
  final List<Contraction> contractions;
  final List<KickSession> kicks;
  final NursingTimer nursing;
  const MomToolsData(this.contractions, this.kicks, this.nursing);

  static const maxItems = 300;

  static MomToolsData decode(String? raw) {
    if (raw == null || raw.isEmpty) return const MomToolsData([], [], NursingTimer());
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return const MomToolsData([], [], NursingTimer());
      List<T> list<T>(Object? v, T? Function(Object?) f) =>
          v is List ? v.map(f).whereType<T>().toList() : <T>[];
      return MomToolsData(
        list(data['contractions'], Contraction.fromJson),
        list(data['kicks'], KickSession.fromJson),
        NursingTimer.fromJson(data['nursing']),
      );
    } catch (_) {
      return const MomToolsData([], [], NursingTimer());
    }
  }

  String encode() {
    List<Map<String, dynamic>> cap<T>(List<T> l, Map<String, dynamic> Function(T) f) =>
        (l.length > maxItems ? l.sublist(l.length - maxItems) : l).map(f).toList();
    return jsonEncode({
      'contractions': cap(contractions, (c) => c.toJson()),
      'kicks': cap(kicks, (k) => k.toJson()),
      'nursing': nursing.toJson(),
    });
  }
}
