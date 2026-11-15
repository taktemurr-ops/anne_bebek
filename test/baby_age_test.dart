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
}
