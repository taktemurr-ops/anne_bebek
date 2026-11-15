import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/data/age_guides.dart';

void main() {
  test('tamamlanmış ay hesaplaması', () {
    expect(ageInCompletedMonths(DateTime(2025, 1, 15), DateTime(2025, 3, 14)), 1);
    expect(ageInCompletedMonths(DateTime(2025, 1, 15), DateTime(2025, 3, 15)), 2);
    expect(ageInCompletedMonths(null, DateTime(2025)), isNull);
    expect(ageInCompletedMonths(DateTime(2026), DateTime(2025)), isNull);
  });
  test('yaşa göre içerik filtreleme', () {
    expect(ageGuides.firstWhere((g) => g.id == 'feeding_0').matchesAge(4), isTrue);
    expect(ageGuides.firstWhere((g) => g.id == 'feeding_0').matchesAge(7), isFalse);
    expect(ageGuides.firstWhere((g) => g.id == 'feeding_6').matchesAge(7), isTrue);
  });
  test('arama filtreleme', () {
    expect(ageGuides.firstWhere((g) => g.id == 'sleep_0').matchesQuery('UYKU'), isTrue);
    expect(ageGuides.firstWhere((g) => g.id == 'sleep_0').matchesQuery('alışveriş'), isFalse);
  });
}
