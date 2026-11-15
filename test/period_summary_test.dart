import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/tracking_journal.dart';
import 'package:anne_bebek/services/growth_analysis.dart';

void main() {
  test('30 day feeding summary excludes old, future and invalid entries', () {
    final now = DateTime(2026, 11, 1, 12);
    final entries = <Map<String, dynamic>>[
      {'type': 'Mama', 'date': '2026-10-03T10:00:00', 'amount': 100},
      {'type': 'Mama', 'date': '2026-10-02T10:00:00', 'amount': 200},
      {'type': 'Mama', 'date': '2026-11-02T10:00:00', 'amount': 300},
      {'type': 'Mama', 'date': '2026-10-30T10:00:00', 'amount': -5},
      {'type': 'Emzirme', 'date': '2026-11-01T10:00:00', 'amount': 15},
      {'type': 'Ek gıda', 'date': '2026-11-01T11:00:00'},
    ];
    final result = feedingPeriodSummary(entries, now, 30);
    expect(result.formulaMl, 100);
    expect(result.formulaCount, 1);
    expect(result.nursingMinutes, 15);
    expect(result.solidFoodCount, 1);
  });
  test('period length must be valid', () {
    expect(() => feedingPeriodSummary([], DateTime(2026), 0), throwsArgumentError);
  });
  test('growth stats sorts dates and reports range', () {
    final result = growthStats([
      GrowthPoint(DateTime(2026, 3, 11), 8.2),
      GrowthPoint(DateTime(2026, 3, 1), 7.8),
      GrowthPoint(DateTime(2026, 3, 5), 8.5),
    ])!;
    expect(result.count, 3);
    expect(result.first, 7.8);
    expect(result.last, 8.2);
    expect(result.maximum, 8.5);
    expect(result.elapsedDays, 10);
  });
  test('empty growth history returns no stats', () {
    expect(growthStats([]), isNull);
  });
}
