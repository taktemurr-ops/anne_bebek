import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/daily_routines.dart';

void main() {
  final start = DateTime(2026, 11, 19, 8);
  test('GP-04 routine round trip preserves child ownership', () {
    final records = [DailyRoutineEntry(id: 'a', childId: 'baby-1',
      kind: 'feeding', startedAt: start, amountMl: 120, note: 'Anne sütü')];
    final restored = decodeDailyRoutines(encodeDailyRoutines(records));
    expect(restored.single.childId, 'baby-1');
    expect(restored.single.amountMl, 120);
    expect(restored.single.note, 'Anne sütü');
  });
  test('GP-04 empty storage is an empty list', () {
    expect(decodeDailyRoutines(null), isEmpty);
    expect(decodeDailyRoutines(''), isEmpty);
  });
  test('GP-04 rejects duplicate ids without partial recovery', () {
    final entry = DailyRoutineEntry(id: 'a', childId: 'baby-1',
      kind: 'sleep', startedAt: start, endedAt: start.add(const Duration(hours: 2)));
    expect(() => decodeDailyRoutines(encodeDailyRoutines([entry, entry])), throwsFormatException);
  });
  test('GP-04 rejects corrupt child ownership and malformed entries', () {
    expect(() => decodeDailyRoutines('[null]'), throwsFormatException);
    expect(() => decodeDailyRoutines('[{"id":"x","childId":"","kind":"note","startedAt":"2026-11-19T08:00:00"}]'), throwsFormatException);
  });
  test('GP-04 rejects nonfinite or excessive feeding amounts', () {
    expect(() => DailyRoutineEntry.fromJson({'id':'x','childId':'baby-1',
      'kind':'feeding','startedAt':start.toIso8601String(),'amountMl':2001}), throwsFormatException);
    expect(() => DailyRoutineEntry.fromJson({'id':'x','childId':'baby-1',
      'kind':'feeding','startedAt':start.toIso8601String(),'amountMl':double.nan}), throwsFormatException);
  });
  test('GP-04 rejects reversed sleep intervals', () {
    expect(() => DailyRoutineEntry.fromJson({'id':'x','childId':'baby-1',
      'kind':'sleep','startedAt':start.toIso8601String(),
      'endedAt':start.subtract(const Duration(minutes: 1)).toIso8601String()}), throwsFormatException);
  });
}
