import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/daily_routines.dart';

void main() {
  test('GP-04 rejects malformed JSON objects and non-string keys', () {
    expect(() => decodeDailyRoutines('[null]'), throwsFormatException);
    expect(() => decodeDailyRoutines('[42]'), throwsFormatException);
    expect(() => decodeDailyRoutines('[{"kind":"sleep"}]'), throwsFormatException);
  });
  test('GP-04 accepts complete sleep and feeding records', () {
    final entries = [
      DailyRoutineEntry(id: 'sleep-1', childId: 'child-1', kind: 'sleep',
        startedAt: DateTime.utc(2026, 11, 19, 8),
        endedAt: DateTime.utc(2026, 11, 19, 9)),
      DailyRoutineEntry(id: 'feed-1', childId: 'child-1', kind: 'feeding',
        startedAt: DateTime.utc(2026, 11, 19, 10), amountMl: 120),
    ];
    final result = decodeDailyRoutines(encodeDailyRoutines(entries));
    expect(result.length, 2);
    expect(result.last.amountMl, 120);
  });
  test('GP-04 rejects incomplete sleep and feeding entries', () {
    final incompleteSleep = DailyRoutineEntry(id: 's', childId: 'c',
      kind: 'sleep', startedAt: DateTime.utc(2026, 11, 19));
    final incompleteFeed = DailyRoutineEntry(id: 'f', childId: 'c',
      kind: 'feeding', startedAt: DateTime.utc(2026, 11, 19));
    expect(() => decodeDailyRoutines(encodeDailyRoutines([incompleteSleep])),
      throwsFormatException);
    expect(() => decodeDailyRoutines(encodeDailyRoutines([incompleteFeed])),
      throwsFormatException);
  });
}
