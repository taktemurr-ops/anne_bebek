import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/sleep_journal.dart';

void main() {
  test('Uyku süreleri gelecek ve ters aralığı reddeder', () {
    final now = DateTime(2026, 11, 7, 12);
    expect(sleepDurationMinutes(now.subtract(const Duration(hours: 2)), now, now), 120);
    expect(sleepDurationMinutes(now, now, now), isNull);
    expect(sleepDurationMinutes(now, now.add(const Duration(minutes: 1)), now), isNull);
  });
  test('Çakışan uyku kaydı reddedilir', () {
    final records = [
      {'start': '2026-11-06T10:00:00.000', 'end': '2026-11-06T11:00:00.000'},
    ];
    expect(sleepOverlaps(records, DateTime(2026, 11, 6, 10, 30), DateTime(2026, 11, 6, 11, 30)), isTrue);
    expect(sleepOverlaps(records, DateTime(2026, 11, 6, 11), DateTime(2026, 11, 6, 12)), isFalse);
  });
}
