import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/sleep_journal.dart';

void main() {
  test('overlap detection accepts adjacent intervals and rejects overlaps', () {
    final records = <Map<String, dynamic>>[
      {'start': '2026-11-01T08:00:00', 'end': '2026-11-01T10:00:00'},
    ];
    expect(sleepOverlaps(records, DateTime(2026, 11, 1, 9), DateTime(2026, 11, 1, 11)), isTrue);
    expect(sleepOverlaps(records, DateTime(2026, 11, 1, 10), DateTime(2026, 11, 1, 12)), isFalse);
  });

  test('Uyku süresi doğru hesaplanır', () {
    final now = DateTime(2026, 11, 1, 12);
    expect(sleepDurationMinutes(DateTime(2026, 10, 31, 23), DateTime(2026, 11, 1, 1), now), 120);
  });
  test('Ters, gelecek ve aşırı uzun süreler reddedilir', () {
    final now = DateTime(2026, 11, 1, 12);
    expect(sleepDurationMinutes(now, now, now), isNull);
    expect(sleepDurationMinutes(now, now.add(const Duration(hours: 1)), now), isNull);
    expect(sleepDurationMinutes(now.subtract(const Duration(hours: 26)), now, now), isNull);
  });
  test('Bozuk uyku günlüğü güvenli biçimde boş döner', () {
    expect(parseSleepJournal('{bad'), isEmpty);
    expect(parseSleepJournal('{}'), isEmpty);
  });
}
