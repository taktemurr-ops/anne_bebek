// Gebe kalmaya çalışma (bebek planlama) günlüğü. Doğurgan dönem tahmini
// CycleEstimate ile aynı yöntemi kullanır; ovulasyon testi ve bazal vücut
// sıcaklığı kayıtları tahmini kişiselleştirmeye yardımcı olur.

import 'cycle_estimate.dart';

const opkResults = ['Negatif', 'Pozitif'];
const pregnancyTestResults = ['Negatif', 'Pozitif'];

class TtcDay {
  final DateTime day;
  final double? bbt; // °C
  final int? opk; // 0 negatif, 1 pozitif
  final int? pregnancyTest; // 0 negatif, 1 pozitif
  final bool intimacy;
  final String note;
  const TtcDay(this.day, {this.bbt, this.opk, this.pregnancyTest, this.intimacy = false, this.note = ''});

  bool get isEmpty => bbt == null && opk == null && pregnancyTest == null && !intimacy && note.isEmpty;

  Map<String, dynamic> toJson() => {
        'day': day.toIso8601String(),
        if (bbt != null) 'bbt': bbt,
        if (opk != null) 'opk': opk,
        if (pregnancyTest != null) 'test': pregnancyTest,
        if (intimacy) 'intimacy': true,
        if (note.isNotEmpty) 'note': note,
      };

  static TtcDay? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final d = DateTime.tryParse('${raw['day']}');
    if (d == null) return null;
    final b = raw['bbt'];
    final o = raw['opk'];
    final p = raw['test'];
    return TtcDay(DateTime(d.year, d.month, d.day),
        bbt: b is num && validBbt(b.toDouble()) ? b.toDouble() : null,
        opk: o == 0 || o == 1 ? o as int : null,
        pregnancyTest: p == 0 || p == 1 ? p as int : null,
        intimacy: raw['intimacy'] == true,
        note: raw['note'] is String ? raw['note'] as String : '');
  }
}

bool validBbt(double? v) => v != null && v.isFinite && v >= 35 && v <= 38.5;

double? parseBbt(String s) {
  final v = double.tryParse(s.trim().replaceAll(',', '.'));
  return validBbt(v) ? v : null;
}

List<TtcDay> decodeTtcDays(Object? raw) {
  if (raw is! List) return [];
  final byDay = <DateTime, TtcDay>{};
  for (final e in raw) {
    final d = TtcDay.fromJson(e);
    if (d != null) byDay[d.day] = d;
  }
  return byDay.values.toList()..sort((a, b) => a.day.compareTo(b.day));
}

class FertileWindow {
  final DateTime start, ovulation, end;
  const FertileWindow(this.start, this.ovulation, this.end);
  bool contains(DateTime d) {
    final x = DateTime(d.year, d.month, d.day);
    return !x.isBefore(start) && !x.isAfter(end);
  }
}

/// Bugünü içeren ya da bugünden sonraki ilk doğurgan dönem.
/// Son pozitif ovulasyon testi varsa ve o döngüye denk geliyorsa yumurtlama
/// testten 1 gün sonraya alınır.
FertileWindow? nextFertileWindow(List<DateTime> periodStarts, List<TtcDay> days, DateTime now) {
  final est = CycleEstimate.from(periodStarts);
  if (!est.hasData) return null;
  final today = DateTime(now.year, now.month, now.day);
  for (final s in est.cycleStarts(aheadCycles: 6)) {
    var ov = DateTime(s.year, s.month, s.day + est.cycleLength - 14);
    final cycleEnd = DateTime(s.year, s.month, s.day + est.cycleLength);
    final positives = days.where((d) => d.opk == 1 && !d.day.isBefore(s) && d.day.isBefore(cycleEnd)).toList();
    if (positives.isNotEmpty) ov = positives.first.day.add(const Duration(days: 1));
    final w = FertileWindow(ov.subtract(const Duration(days: 5)), ov, ov.add(const Duration(days: 1)));
    if (!w.end.isBefore(today)) return w;
  }
  return null;
}

/// Mevcut döngünün kaçıncı günü (1'den başlar).
int? cycleDay(List<DateTime> periodStarts, DateTime now) {
  if (periodStarts.isEmpty) return null;
  final last = periodStarts.reduce((a, b) => a.isAfter(b) ? a : b);
  final d = DateTime(now.year, now.month, now.day).difference(DateTime(last.year, last.month, last.day)).inDays;
  return d < 0 ? null : d + 1;
}

const ttcTips = <String>[
  'Gebelik planlarken en az 1 ay önceden günde 400 mikrogram folik asit kullanmaya başla (doktorun farklı doz önerebilir).',
  'Gebelik öncesi kontrol: aşılar (kızamıkçık, su çiçeği), kansızlık, tiroid ve kullandığın ilaçlar için doktoruna görün.',
  'En yüksek gebelik şansı yumurtlamadan önceki 2–3 gün ve yumurtlama günündedir; doğurgan dönemde gün aşırı ilişki yeterlidir.',
  'Ovulasyon testi pozitif olduktan sonraki 24–36 saat içinde yumurtlama beklenir.',
  'Bazal vücut sıcaklığını her sabah kalkmadan, aynı saatte ölç; yumurtlamadan sonra yaklaşık 0,2–0,5 °C yükselir.',
  'Sigara, alkol ve fazla kafeinden uzak dur; sağlıklı kilo gebe kalmayı kolaylaştırır.',
  '35 yaşın altındaysan 12 ay, 35 yaş ve üstündeysen 6 ay düzenli denemeye rağmen gebelik olmadıysa doktora başvur. Düzensiz adet ya da bilinen bir sağlık sorunu varsa beklemeden görüş.',
];
