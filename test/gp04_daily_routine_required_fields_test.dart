import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/daily_routines.dart';

void main() {
  final start = DateTime(2026, 11, 19, 8);
  test('GP-04 feeding requires an amount', () {
    expect(() => DailyRoutineEntry.fromJson({
      'id': 'f1', 'childId': 'baby-1', 'kind': 'feeding',
      'startedAt': start.toIso8601String(),
    }), throwsFormatException);
  });
  test('GP-04 sleep requires a valid end time', () {
    expect(() => DailyRoutineEntry.fromJson({
      'id': 's1', 'childId': 'baby-1', 'kind': 'sleep',
      'startedAt': start.toIso8601String(),
    }), throwsFormatException);
  });
  test('GP-04 non-sleep record cannot include an end time', () {
    expect(() => DailyRoutineEntry.fromJson({
      'id': 'd1', 'childId': 'baby-1', 'kind': 'diaper',
      'startedAt': start.toIso8601String(),
      'endedAt': start.add(const Duration(minutes: 1)).toIso8601String(),
    }), throwsFormatException);
  });
  test('GP-04 completed sleep record can be restored', () {
    final entry = DailyRoutineEntry(id: 's1', childId: 'baby-1',
      kind: 'sleep', startedAt: start,
      endedAt: start.add(const Duration(hours: 2)));
    expect(decodeDailyRoutines(encodeDailyRoutines([entry])).single.endedAt,
      start.add(const Duration(hours: 2)));
  });
}
