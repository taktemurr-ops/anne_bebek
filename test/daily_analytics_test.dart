import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/daily_analytics.dart';

void main() {
  final now = DateTime(2026, 11, 1, 12);
  test('seven days ordered and invalid/future feeding excluded', () {
    final days = dailyBabyStats([
      {'type': 'Mama', 'date': '2026-11-01T09:00:00', 'amount': 120},
      {'type': 'Mama', 'date': '2026-11-01T14:00:00', 'amount': 90},
      {'type': 'Mama', 'date': '2026-11-01T08:00:00', 'amount': -1},
      {'type': 'Emzirme', 'date': '2026-10-31T08:00:00', 'amount': 25},
      {'type': 'Ek gıda', 'date': '2026-11-01T09:00:00'},
    ], [], now);
    expect(days.length, 7);
    expect(days.first.day.day, 26);
    expect(days.last.formulaMl, 120);
    expect(days.last.solids, 1);
    expect(days[5].nursingMinutes, 25);
  });

  test('overnight sleep allocated to each calendar day', () {
    final days = dailyBabyStats([], [
      {'start': '2026-10-31T23:00:00', 'end': '2026-11-01T02:00:00'},
    ], now);
    expect(days[5].sleepMinutes, 60);
    expect(days[6].sleepMinutes, 120);
  });

  test('overlapping sleep records are counted only once', () {
    final days = dailyBabyStats([], [
      {'start': '2026-11-01T08:00:00', 'end': '2026-11-01T10:00:00'},
      {'start': '2026-11-01T09:00:00', 'end': '2026-11-01T11:00:00'},
      {'start': '2026-11-01T11:00:00', 'end': '2026-11-01T11:30:00'},
    ], now);
    expect(days.last.sleepMinutes, 210);
  });

  test('invalid and future sleep excluded', () {
    final days = dailyBabyStats([], [
      {'start': '2026-11-01T10:00:00', 'end': '2026-11-01T13:00:00'},
      {'start': '2026-11-01T09:00:00', 'end': '2026-11-01T08:00:00'},
      {'start': '2026-10-31T08:00:00', 'end': '2026-11-01T10:00:00'},
    ], now);
    expect(days.fold<int>(0, (total, d) => total + d.sleepMinutes), 0);
  });
}
