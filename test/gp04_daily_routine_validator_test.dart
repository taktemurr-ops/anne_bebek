import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/daily_routine_validator.dart';

void main() {
  group('GP-04 daily routine validation', () {
    final now = DateTime(2026, 11, 19, 12);
    test('sleep interval requires valid chronological boundaries', () {
      final start = DateTime(2026, 11, 19, 8);
      expect(DailyRoutineValidator.validateInterval(start, now, now: now), isNull);
      expect(DailyRoutineValidator.validateInterval(now, start, now: now), isNotNull);
      expect(DailyRoutineValidator.validateInterval(start, start, now: now), isNotNull);
      expect(DailyRoutineValidator.validateInterval(null, now, now: now), isNotNull);
    });
    test('future and overly long intervals are rejected', () {
      expect(DailyRoutineValidator.validateInterval(now, now.add(const Duration(minutes: 1)), now: now), isNotNull);
      expect(DailyRoutineValidator.validateInterval(now.subtract(const Duration(days: 2)), now, now: now), isNotNull);
    });
    test('feeding amount must be finite and within range', () {
      expect(DailyRoutineValidator.validateFeedingAmount(120), isNull);
      expect(DailyRoutineValidator.validateFeedingAmount(0), isNotNull);
      expect(DailyRoutineValidator.validateFeedingAmount(double.nan), isNotNull);
      expect(DailyRoutineValidator.validateFeedingAmount(double.infinity), isNotNull);
      expect(DailyRoutineValidator.validateFeedingAmount(2001), isNotNull);
    });
    test('notes cannot be empty or too long', () {
      expect(DailyRoutineValidator.validateNote('  mama verildi  '), isNull);
      expect(DailyRoutineValidator.validateNote('   '), isNotNull);
      expect(DailyRoutineValidator.validateNote('a' * 301), isNotNull);
    });
  });
}
