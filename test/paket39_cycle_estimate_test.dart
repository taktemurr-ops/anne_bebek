import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/cycle_estimate.dart';

void main() {
  test('Kayıt yoksa takvim işaretlemez', () {
    final e = CycleEstimate.from([]);
    expect(e.hasData, isFalse);
    expect(e.kindOf(DateTime(2025, 1, 10)), CycleDayKind.none);
    expect(e.nextPeriod, isNull);
  });

  test('Tek kayıtta 28 günlük varsayılan döngü kullanılır', () {
    final e = CycleEstimate.from([DateTime(2025, 1, 1)]);
    expect(e.measured, isFalse);
    expect(e.cycleLength, 28);
    // Adet: 1-5 Ocak
    expect(e.kindOf(DateTime(2025, 1, 1)), CycleDayKind.period);
    expect(e.kindOf(DateTime(2025, 1, 5)), CycleDayKind.period);
    expect(e.kindOf(DateTime(2025, 1, 6)), isNot(CycleDayKind.period));
    // Sonraki adet 29 Ocak, yumurtlama 15 Ocak, verimli 10–16 Ocak
    expect(e.nextPeriod, DateTime(2025, 1, 29));
    expect(e.kindOf(DateTime(2025, 1, 15)), CycleDayKind.ovulation);
    expect(e.kindOf(DateTime(2025, 1, 10)), CycleDayKind.fertile);
    expect(e.kindOf(DateTime(2025, 1, 16)), CycleDayKind.fertile);
    expect(e.kindOf(DateTime(2025, 1, 9)), CycleDayKind.none);
    expect(e.kindOf(DateTime(2025, 1, 29)), CycleDayKind.period);
  });

  test('Ortalama döngü süresi kayıtlardan ölçülür; uç değerler dışlanır', () {
    final e = CycleEstimate.from([
      DateTime(2025, 1, 1), DateTime(2025, 1, 31), // 30
      DateTime(2025, 3, 2), // 30
      DateTime(2025, 6, 1), // 91 -> dışlanır
    ]);
    expect(e.measured, isTrue);
    expect(e.cycleLength, 30);
    expect(e.starts.first, DateTime(2025, 1, 1));
    expect(e.nextPeriod, DateTime(2025, 7, 1));
  });

  test('Aynı gün tekrar eden kayıtlar tek sayılır', () {
    final e = CycleEstimate.from([DateTime(2025, 1, 1, 9), DateTime(2025, 1, 1, 20)]);
    expect(e.starts.length, 1);
  });

  test('GP-05 sınırları: artık yıl ve ay/yıl geçişleri', () {
    // 2024 artık yıl: 1 Şubat + 28 gün = 29 Şubat
    final leap = CycleEstimate.from([DateTime(2024, 2, 1)]);
    expect(leap.nextPeriod, DateTime(2024, 2, 29));
    expect(leap.kindOf(DateTime(2024, 2, 29)), CycleDayKind.period);
    // Yıl geçişi: 20 Aralık + 28 = 17 Ocak; yumurtlama 3 Ocak
    final year = CycleEstimate.from([DateTime(2024, 12, 20)]);
    expect(year.nextPeriod, DateTime(2025, 1, 17));
    expect(year.kindOf(DateTime(2025, 1, 3)), CycleDayKind.ovulation);
  });

  test('GP-05 sınırları: saat ve yaz saati farkı gün hesabını bozmaz', () {
    final e = CycleEstimate.from([DateTime(2025, 3, 20, 23, 59)]);
    // 30 Mart (Avrupa yaz saati geçişi) sonrası günler doğru sayılır.
    expect(e.nextPeriod, DateTime(2025, 4, 17));
    expect(e.kindOf(DateTime(2025, 4, 3, 0, 1)), CycleDayKind.ovulation);
  });
}
