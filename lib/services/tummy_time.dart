import 'dart:convert';

/// Karın üstü zamanı (tummy time) takibi.
/// DSÖ (2019): bir yaş altı, henüz hareket edemeyen bebekler için gün içine
/// yayılmış en az 30 dakika yüzüstü (uyanıkken, gözetim altında) süre önerir.
/// Yenidoğanda 3–5 dakikalık kısa seanslarla başlanır.

class TummySession {
  final DateTime start;
  final int minutes;
  const TummySession(this.start, this.minutes);

  Map<String, dynamic> toJson() => {'start': start.toIso8601String(), 'minutes': minutes};

  static TummySession? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final s = DateTime.tryParse('${raw['start']}');
    final m = raw['minutes'];
    if (s == null || m is! int || !validTummyMinutes(m)) return null;
    return TummySession(s, m);
  }
}

bool validTummyMinutes(int m) => m >= 1 && m <= 120;

class TummyTimeData {
  final List<TummySession> sessions; // yeniden eskiye
  final DateTime? runningSince;
  const TummyTimeData(this.sessions, [this.runningSince]);

  String encode() => jsonEncode({
        'sessions': sessions.take(1000).map((e) => e.toJson()).toList(),
        if (runningSince != null) 'running': runningSince!.toIso8601String(),
      });

  static TummyTimeData decode(String? raw) {
    if (raw == null || raw.isEmpty) return const TummyTimeData([]);
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return const TummyTimeData([]);
      final list = data['sessions'] is List
          ? (data['sessions'] as List).map(TummySession.fromJson).whereType<TummySession>().toList()
          : <TummySession>[];
      list.sort((a, b) => b.start.compareTo(a.start));
      return TummyTimeData(list, DateTime.tryParse('${data['running']}'));
    } catch (_) {
      return const TummyTimeData([]);
    }
  }

  TummyTimeData start(DateTime now) => TummyTimeData(sessions, now);

  /// Çalışan seansı bitirir. 1 dakikadan kısa seans kaydedilmez; uzun süre
  /// açık unutulan zamanlayıcı 120 dakikayla sınırlanır.
  TummyTimeData stop(DateTime now) {
    final s = runningSince;
    if (s == null) return this;
    final minutes = now.difference(s).inMinutes.clamp(0, 120);
    if (minutes < 1) return TummyTimeData(sessions);
    return TummyTimeData([TummySession(s, minutes), ...sessions]);
  }

  TummyTimeData add(TummySession s) {
    final list = [s, ...sessions]..sort((a, b) => b.start.compareTo(a.start));
    return TummyTimeData(list, runningSince);
  }

  TummyTimeData remove(TummySession s) =>
      TummyTimeData(sessions.where((x) => !identical(x, s)).toList(), runningSince);

  int minutesOn(DateTime day) => sessions
      .where((s) => s.start.year == day.year && s.start.month == day.month && s.start.day == day.day)
      .fold(0, (sum, s) => sum + s.minutes);

  /// Son 7 günün (bugün dahil, eskiden yeniye) dakikaları.
  List<({DateTime day, int minutes})> lastWeek(DateTime now) => [
        for (var i = 6; i >= 0; i--)
          (
            day: DateTime(now.year, now.month, now.day - i),
            minutes: minutesOn(DateTime(now.year, now.month, now.day - i)),
          ),
      ];
}

/// Günlük hedef (dakika). 12 ay ve üstünde hedef yok (null): çocuk serbestçe
/// hareket eder.
int? tummyGoalMinutes(int? ageMonths) {
  if (ageMonths == null) return 30;
  if (ageMonths >= 12) return null;
  if (ageMonths < 1) return 15;
  return 30;
}

String tummyStageTip(int? ageMonths) {
  if (ageMonths == null || ageMonths < 1) {
    return 'Göbek kordonu düştükten sonra başlayabilirsin. Günde 2–3 kez, 3–5 dakikalık kısa seanslar yeterli; göğsünün üstünde yüzüstü yatırmak da sayılır.';
  }
  if (ageMonths < 3) {
    return 'Seansları yavaş yavaş uzat; gün içine yayılmış toplam en az 30 dakika hedefle. Yüz hizasına renkli bir oyuncak ya da ayna koy.';
  }
  if (ageMonths < 6) {
    return 'Başını ve göğsünü dirseklerinin üstünde kaldırmaya çalışır. Oyuncağı biraz uzağa koyarak uzanmaya teşvik et.';
  }
  if (ageMonths < 12) {
    return 'Dönme, sürünme ve emeklemeye hazırlanır. Yerde güvenli, geniş bir alanda serbest oyun zamanı ver.';
  }
  return 'Artık serbestçe hareket ediyor; ayrı bir karın üstü hedefine gerek yok. Günde en az 3 saat aktif oyun önerilir.';
}

const tummySafetyNotes = [
  'Karın üstü zamanı yalnızca bebek uyanıkken ve sen yanındayken yapılır.',
  'Bebek uykuya dalarsa hemen sırt üstü yatır; uyku her zaman sırt üstü olmalı.',
  'Beslendikten hemen sonra değil, 20–30 dakika geçtikten sonra dene.',
  'Sert, düz bir zemin kullan; yumuşak yastık ya da yorgan üzerinde yapma.',
  'Ağlarsa zorlama; kısa bir ara verip daha sonra tekrar dene.',
];
