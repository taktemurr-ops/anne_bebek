import 'package:anne_bebek/utils/growth_measurement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GP-03 measurement input normalization', () {
    test('accepts comma and dot decimal separators consistently', () {
      expect(GrowthMeasurementValidator.parseMeasurement(' 3,125 '), 3.125);
      expect(GrowthMeasurementValidator.parseMeasurement('3.125'), 3.125);
      expect(GrowthMeasurementValidator.parseMeasurement('0003,5'), 3.5);
    });

    test('rejects grouping, exponent and excessive precision', () {
      for (final raw in ['1,234.5', '1.234,5', '1e3', '3.1234', '.5']) {
        expect(GrowthMeasurementValidator.parseMeasurement(raw), isNull,
            reason: 'Unsupported numeric representation: $raw');
      }
    });

    test('rejects control characters and oversized numeric payloads', () {
      for (final raw in ['1\n2', '1\t2', '1\u200b2', '9' * 65]) {
        expect(GrowthMeasurementValidator.parseMeasurement(raw), isNull);
      }
    });

    test('parsed numeric input still requires medical field validation', () {
      final zero = GrowthMeasurementValidator.parseMeasurement('0');
      expect(zero, 0);
      expect(GrowthMeasurementValidator.validateWeightKg(zero), isNotNull);
      expect(GrowthMeasurementValidator.validateHeightCm(zero), isNotNull);
      expect(
        GrowthMeasurementValidator.validateHeadCircumferenceCm(zero),
        isNotNull,
      );
    });
  });
}
