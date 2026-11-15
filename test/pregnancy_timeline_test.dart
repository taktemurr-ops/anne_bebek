import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/pregnancy_timeline.dart';

void main() {
  test('calendar day counting ignores hours', () {
    final value = pregnancyTimeline(DateTime(2026, 1, 1, 23), DateTime(2026, 1, 8, 1));
    expect(value?.week, 1);
    expect(value?.dayOfWeek, 0);
  });
  test('trimester boundaries and estimated due date', () {
    expect(pregnancyTimeline(DateTime(2026, 1, 1), DateTime(2026, 4, 8))?.trimester, '1. trimester');
    expect(pregnancyTimeline(DateTime(2026, 1, 1), DateTime(2026, 4, 9))?.trimester, '2. trimester');
    final due = pregnancyTimeline(DateTime(2026, 1, 1), DateTime(2026, 10, 8));
    expect(due?.daysUntilEstimatedDueDate, 0);
    expect(due?.progress, 1);
  });
  test('future and overly old dates are not treated as active pregnancies', () {
    expect(pregnancyTimeline(DateTime(2026, 11, 2), DateTime(2026, 11, 1)), isNull);
    expect(pregnancyTimeline(DateTime(2025, 1, 1), DateTime(2026, 11, 1)), isNull);
  });
  test('weekly notes cover every stage', () {
    for (final week in [0, 8, 17, 30, 40]) {
      expect(pregnancyWeekNote(week), isNotEmpty);
    }
  });
}
