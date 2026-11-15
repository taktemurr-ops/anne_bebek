import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/period_comparison.dart';

void main() {
  test('compares elapsed calendar days instead of full prior month', () {
    final now = DateTime(2026, 11, 3, 12);
    final feeding = <Map<String, dynamic>>[
      {'date': '2026-11-02T09:00:00', 'type': 'Mama', 'amount': 150},
      {'date': '2026-10-02T09:00:00', 'type': 'Mama', 'amount': 100},
      {'date': '2026-10-20T09:00:00', 'type': 'Mama', 'amount': 900},
    ];
    final comparison = compareBabyMonths(feeding, [], now);
    expect(comparison.current.days, 3);
    expect(comparison.previous.days, 3);
    expect(comparison.current.formulaMl, 150);
    expect(comparison.previous.formulaMl, 100);
    expect(comparison.formulaChangeMl, 50);
  });

  test('clamps prior month at its actual length including leap years', () {
    final comparison = compareBabyMonths([], [], DateTime(2024, 3, 31, 12));
    expect(comparison.current.days, 31);
    expect(comparison.previous.days, 29);
    expect(comparison.current.averageSleepMinutes, 0);
  });

  test('splits midnight-crossing sleep by calendar day', () {
    final sleep = <Map<String, dynamic>>[
      {'start': '2026-10-31T23:30:00', 'end': '2026-11-01T00:30:00'},
    ];
    final comparison = compareBabyMonths([], sleep, DateTime(2026, 11, 2, 12));
    expect(comparison.current.sleepMinutes, 30);
    expect(comparison.previous.sleepMinutes, 0);
  });
}
