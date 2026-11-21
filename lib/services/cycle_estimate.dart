/// Döngü takvimi için yaklaşık hesaplama (Paket 39 Kadınlar ekranı).
///
/// Kayıtlı adet başlangıç tarihlerinden ortalama döngü süresi bulunur
/// (21–45 gün arası aralıklar dikkate alınır; yeterli kayıt yoksa 28 gün).
/// Tahmini yumurtlama, bir sonraki adetten 14 gün öncesi kabul edilir;
/// verimli dönem yumurtlamadan 5 gün önce başlayıp 1 gün sonra biter.
///
/// Bu yalnızca takvim görünümü içindir: doğum kontrolü veya gebelik
/// planlaması için güvenilir yöntem değildir; tıbbi değerlendirme yerine geçmez.
library;

enum CycleDayKind { none, period, ovulation, fertile }

class CycleEstimate {
  CycleEstimate._(this.starts, this.cycleLength, this.periodLength, this.measured);

  /// Kayıtlı başlangıçlar, eskiden yeniye, gün hassasiyetinde ve tekrarsız.
  final List<DateTime> starts;

  /// Hesapta kullanılan döngü süresi (gün).
  final int cycleLength;

  /// Adet süresi (gün).
  final int periodLength;

  /// Döngü süresi kayıtlardan ölçüldüyse true; varsayılan 28 ise false.
  final bool measured;

  static const defaultCycleLength = 28;
  static const defaultPeriodLength = 5;

  factory CycleEstimate.from(List<DateTime> dates,
      {int periodLength = defaultPeriodLength}) {
    final days = {
      for (final d in dates) DateTime(d.year, d.month, d.day),
    }.toList()
      ..sort();
    final intervals = <int>[];
    for (var i = 1; i < days.length; i++) {
      final gap = _daysBetween(days[i - 1], days[i]);
      if (gap >= 21 && gap <= 45) intervals.add(gap);
    }
    final length = intervals.isEmpty
        ? defaultCycleLength
        : (intervals.reduce((a, b) => a + b) / intervals.length).round();
    return CycleEstimate._(
        List.unmodifiable(days), length, periodLength.clamp(2, 10), intervals.isNotEmpty);
  }

  bool get hasData => starts.isNotEmpty;

  /// Son kayıttan sonraki tahmini adet başlangıcı.
  DateTime? get nextPeriod =>
      starts.isEmpty ? null : starts.last.add(Duration(days: cycleLength));

  /// Son kayda göre tahmini yumurtlama günü.
  DateTime? get nextOvulation =>
      nextPeriod?.subtract(const Duration(days: 14));

  /// Gösterim için döngü başlangıçları: kayıtlılar + son kayıttan sonra
  /// [aheadCycles] adet tahmini başlangıç.
  List<DateTime> cycleStarts({int aheadCycles = 6}) {
    if (starts.isEmpty) return const [];
    return [
      ...starts,
      for (var k = 1; k <= aheadCycles; k++)
        starts.last.add(Duration(days: cycleLength * k)),
    ];
  }

  CycleDayKind kindOf(DateTime day) {
    if (starts.isEmpty) return CycleDayKind.none;
    final d = DateTime(day.year, day.month, day.day);
    final all = cycleStarts();
    for (final s in all) {
      final offset = _daysBetween(s, d);
      if (offset >= 0 && offset < periodLength) return CycleDayKind.period;
    }
    for (var i = 0; i < all.length; i++) {
      // Bir döngünün yumurtlaması, bir sonraki başlangıçtan 14 gün öncedir.
      // Kayıtlı ardışık başlangıçlar varsa gerçek aralık kullanılır.
      final next = i + 1 < all.length ? all[i + 1] : all[i].add(Duration(days: cycleLength));
      final ovulation = next.subtract(const Duration(days: 14));
      if (!ovulation.isAfter(all[i])) continue;
      final offset = _daysBetween(ovulation, d);
      if (offset == 0) return CycleDayKind.ovulation;
      if (offset >= -5 && offset <= 1) return CycleDayKind.fertile;
    }
    return CycleDayKind.none;
  }

  static int _daysBetween(DateTime a, DateTime b) =>
      DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;
}
