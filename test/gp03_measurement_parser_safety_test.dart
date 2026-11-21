import 'package:anne_bebek/utils/growth_measurement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GP-03 measurement parser safety boundaries', () {
    test('rejects oversized user input before numeric parsing', () {
      expect(GrowthMeasurementValidator.parseMeasurement('1' * 65), isNull);
      expect(GrowthMeasurementValidator.parseMeasurement(' ' * 65), isNull);
    });

    test('rejects exponent, grouping, sign and excess precision', () {
      for (final raw in ['1e3', '1,234.5', '1.234,5', '+12', '-0',
        '12.3456', '12,3456', '.5', '5.', '1\n2']) {
        expect(GrowthMeasurementValidator.parseMeasurement(raw), isNull,
            reason: 'Unexpected accepted measurement: $raw');
      }
    });

    test('accepts supported decimal syntax without altering magnitude', () {
      expect(GrowthMeasurementValidator.parseMeasurement(' 12,345 '), 12.345);
      expect(GrowthMeasurementValidator.parseMeasurement('12.345'), 12.345);
      expect(GrowthMeasurementValidator.parseMeasurement('00012'), 12);
      expect(GrowthMeasurementValidator.parseMeasurement('0,001'), 0.001);
    });
  });
}
