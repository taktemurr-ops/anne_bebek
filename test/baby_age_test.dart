import 'package:anne_bebek/utils/baby_age.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profil yoksa bilgi verir', () {
    expect(BabyAge.label(null, DateTime(2026, 11, 16)), 'Doğum tarihi eklenmedi');
  });

  test('gelecekteki doğum tarihi', () {
    expect(BabyAge.label(DateTime(2026, 12, 1), DateTime(2026, 11, 16)),
        'Doğum bekleniyor');
  });

  test('ilk 30 gün günlük hesaplanır', () {
    expect(BabyAge.label(DateTime(2026, 11, 1), DateTime(2026, 11, 16)),
        '15 günlük');
  });

  test('takvim ayı sınırlarını doğru hesaplar', () {
    expect(BabyAge.label(DateTime(2025, 8, 26), DateTime(2026, 11, 16)),
        '1 yaş 2 aylık');
    expect(BabyAge.label(DateTime(2025, 8, 26), DateTime(2026, 8, 26)),
        '1 yaşında');
    expect(BabyAge.label(DateTime(2025, 8, 26), DateTime(2026, 8, 25)),
        '11 aylık');
  });

  test('ayın son günü doğan bebek kısa aylarda doğru hesaplanır', () {
    expect(BabyAge.label(DateTime(2026, 1, 31), DateTime(2026, 2, 28)),
        '28 günlük');
    expect(BabyAge.label(DateTime(2026, 1, 31), DateTime(2026, 3, 31)),
        '2 aylık');
  });
  test('yaz saati gecisinde takvim gunu eksilmez', () {
    // Europe/Berlin 2026-03-29 tarihinde saat ileri alinir.
    // Saat dilimi ortamindan bagimsiz olarak iki takvim tarihi arasi 1 gundur.
    expect(BabyAge.label(DateTime(2026, 3, 28, 23, 30),
        DateTime(2026, 3, 29, 0, 30)), '1 günlük');
    expect(BabyAge.label(DateTime(2026, 3, 28),
        DateTime(2026, 3, 30)), '2 günlük');
  });

  test('artik yil subat ayinin 29. gunu sayilir', () {
    expect(BabyAge.label(DateTime(2024, 2, 28), DateTime(2024, 2, 29)),
        '1 günlük');
  });

  test('farkli saat dilimi temsilinde takvim gunu korunur', () {
    // Saat dilimi donusumu degil, kullanicinin girdigi takvim tarihi esastir.
    expect(
      BabyAge.label(
        DateTime.utc(2026, 3, 28, 23, 30),
        DateTime.utc(2026, 3, 29, 0, 30),
      ),
      '1 günlük',
    );
  });

  test('artik yil ve yil donumunde ay hesabini korur', () {
    expect(BabyAge.label(DateTime(2024, 2, 29), DateTime(2025, 2, 28)),
        '1 yaşında');
    expect(BabyAge.label(DateTime(2025, 12, 31), DateTime(2026, 1, 30)),
        '0 aylık');
    expect(BabyAge.label(DateTime(2025, 12, 31), DateTime(2026, 1, 31)),
        '1 aylık');
  });

  test('tamamlanan takvim aylari yeniden kullanilabilir ve sinirlar dogru', () {
    expect(BabyAge.completedMonths(null, DateTime(2026, 2, 28)), isNull);
    expect(BabyAge.completedMonths(DateTime(2026, 3, 1),
        DateTime(2026, 2, 28)), isNull);
    expect(BabyAge.completedMonths(DateTime(2026, 1, 31),
        DateTime(2026, 2, 27)), 0);
    expect(BabyAge.completedMonths(DateTime(2026, 1, 31),
        DateTime(2026, 2, 28)), 1);
    expect(BabyAge.completedMonths(DateTime(2024, 2, 29),
        DateTime(2025, 2, 28)), 12);
    expect(BabyAge.completedMonths(DateTime(2025, 12, 31),
        DateTime(2026, 1, 30)), 0);
    expect(BabyAge.completedMonths(DateTime(2025, 12, 31),
        DateTime(2026, 1, 31)), 1);
  });
  test('29 ve 30 gun esiginde takvim ayi davranisi korunur', () {
    expect(BabyAge.label(DateTime(2026, 4, 1), DateTime(2026, 4, 30)),
        '29 günlük');
    expect(BabyAge.label(DateTime(2026, 4, 1), DateTime(2026, 5, 1)),
        '1 aylık');
    expect(BabyAge.label(DateTime(2026, 1, 31), DateTime(2026, 3, 1)),
        '29 günlük');
    expect(BabyAge.label(DateTime(2026, 1, 31), DateTime(2026, 3, 2)),
        '1 aylık');
  });

  test('ayni takvim gunundeki saat farki yasi degistirmez', () {
    expect(BabyAge.label(DateTime(2026, 11, 16, 0, 1),
        DateTime(2026, 11, 16, 23, 59)), '0 günlük');
    expect(BabyAge.completedMonths(DateTime(2026, 11, 16, 23, 59),
        DateTime(2026, 11, 16, 0, 1)), 0);
  });

}
