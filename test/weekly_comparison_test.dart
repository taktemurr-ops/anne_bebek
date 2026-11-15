import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/daily_analytics.dart';

void main() {
  final now = DateTime(2026, 11, 1, 18);
  test('consecutive weeks compare formula and solids', () {
    final entries = [
      {'type': 'Mama', 'date': '2026-11-01T09:00:00', 'amount': 120},
      {'type': 'Mama', 'date': '2026-10-25T09:00:00', 'amount': 80},
      {'type': 'Ek gıda', 'date': '2026-10-26T09:00:00'},
      {'type': 'Mama', 'date': '2026-10-18T09:00:00', 'amount': 999},
    ];
    final result = compareBabyWeeks(entries, const [], now);
    expect(result.currentFormulaMl, 120);
    expect(result.previousFormulaMl, 80);
    expect(result.formulaDifferenceMl, 40);
    expect(result.currentSolids, 1);
    expect(result.previousSolids, 0);
  });
  test('sleep spanning midnight is distributed across weeks', () {
    final sleep = [
      {'start': '2026-10-25T23:00:00', 'end': '2026-10-26T01:00:00'},
    ];
    final result = compareBabyWeeks(const [], sleep, now);
    expect(result.previousSleepMinutes, 60);
    expect(result.currentSleepMinutes, 60);
    expect(result.sleepDifferenceMinutes, 0);
  });
  test('future and invalid values do not affect comparison', () {
    final result = compareBabyWeeks([
      {'type': 'Mama', 'date': '2026-11-02T12:00:00', 'amount': 100},
      {'type': 'Mama', 'date': '2026-11-01T12:00:00', 'amount': -1},
    ], const [], now);
    expect(result.currentFormulaMl, 0);
  });
  test('invalid day window is rejected', () {
    expect(() => dailyBabyStats(const [], const [], now, days: 0), throwsArgumentError);
  });
}
