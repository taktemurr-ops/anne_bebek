import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/reproductive_calendar_settings.dart';

void main() {
  test('GP-05 settings round trip preserves date and cycle', () {
    final value = ReproductiveCalendarSettings(
      lastMenstrualPeriod: DateTime(2026, 10, 2), cycleDays: 30);
    final restored = decodeReproductiveSettings(encodeReproductiveSettings(value));
    expect(restored?.cycleDays, 30);
    expect(restored?.lastMenstrualPeriod, DateTime(2026, 10, 2));
  });
  test('GP-05 empty secure record is not an invented date', () {
    expect(decodeReproductiveSettings(null), isNull);
    expect(decodeReproductiveSettings(''), isNull);
  });
  test('GP-05 invalid cycle lengths and dates are rejected', () {
    expect(() => decodeReproductiveSettings('{"cycleDays":20}'), throwsFormatException);
    expect(() => decodeReproductiveSettings('{"cycleDays":36}'), throwsFormatException);
    expect(() => decodeReproductiveSettings('{"cycleDays":28,"lastMenstrualPeriod":"bad"}'), throwsFormatException);
  });
}
