import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/reproductive_calendar.dart';

void main() {
  group('GP-05 reproductive calendar', () {
    test('gestational age uses calendar days, not clock time', () {
      final result = ReproductiveCalendar.gestationalAge(
        lastMenstrualPeriod: DateTime(2026, 1, 1, 23, 59),
        asOf: DateTime(2026, 1, 15, 0, 1));
      expect(result?.weeks, 2);
      expect(result?.days, 0);
    });
    test('due date uses 280 calendar days', () {
      final lmp = DateTime(2026, 1, 1);
      expect(ReproductiveCalendar.estimatedDueDate(lmp,
        asOf: DateTime(2026, 2, 1)),
        DateTime.utc(2026, 1, 1).add(const Duration(days: 280)));
    });
    test('future period and excessive gestation are rejected', () {
      expect(ReproductiveCalendar.gestationalAge(
        lastMenstrualPeriod: DateTime(2026, 11, 20),
        asOf: DateTime(2026, 11, 19)), isNull);
      expect(ReproductiveCalendar.gestationalAge(
        lastMenstrualPeriod: DateTime(2025, 1, 1),
        asOf: DateTime(2026, 11, 19)), isNull);
    });
    test('cycle lengths are bounded and leap dates are supported', () {
      expect(ReproductiveCalendar.nextPeriodStart(DateTime(2024, 2, 29), 28),
        DateTime.utc(2024, 3, 28));
      expect(ReproductiveCalendar.nextPeriodStart(DateTime(2024, 2, 29), 20), isNull);
      expect(ReproductiveCalendar.nextPeriodStart(DateTime(2024, 2, 29), 36), isNull);
    });
  });
}
