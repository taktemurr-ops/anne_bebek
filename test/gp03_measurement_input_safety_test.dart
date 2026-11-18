import 'package:anne_bebek/utils/growth_measurement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GP-03 measurement input safety regression', () {
    test('accepts only ASCII decimal digits with one separator', () {
      for (final input in <String>[
        '٣,٣٨٥', // Arabic-Indic numerals
        '３.３８５', // full-width numerals
        '3\u00a0385', // non-breaking space grouping
        '3_385',
        '3,3,8',
        '3.3.8',
        '1e309',
      ]) {
        expect(GrowthMeasurementValidator.parseMeasurement(input), isNull,
            reason: 'Unsafe or ambiguous numeric input: $input');
      }
      expect(GrowthMeasurementValidator.parseMeasurement('003,385'), 3.385);
    });

    test('date-only validation works across month and year boundaries', () {
      final birth = DateTime.utc(2025, 12, 31, 23, 59);
      final today = DateTime.utc(2026, 1, 1);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime.utc(2025, 12, 31), birthDate: birth, today: today), isNull);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime.utc(2026, 1, 1, 23), birthDate: birth, today: today), isNull);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime.utc(2026, 1, 2), birthDate: birth, today: today), isNotNull);
    });
  });
}
