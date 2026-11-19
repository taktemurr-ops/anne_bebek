import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/growth_measurement_validator.dart';

void main() {
  group('GP-03 measurement zero and precision safeguards', () {
    test('zero measurements are parsed but rejected for every vital metric', () {
      final zero = GrowthMeasurementValidator.parseMeasurement('0,000');
      expect(zero, 0);
      expect(GrowthMeasurementValidator.validateWeightKg(zero), isNotNull);
      expect(GrowthMeasurementValidator.validateHeightCm(zero), isNotNull);
      expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(zero), isNotNull);
    });

    test('three fractional digits are supported; four are rejected', () {
      expect(GrowthMeasurementValidator.parseMeasurement('12,345'), 12.345);
      expect(GrowthMeasurementValidator.parseMeasurement('12.3456'), isNull);
      expect(GrowthMeasurementValidator.parseMeasurement('12,34.5'), isNull);
    });

    test('oversized and nonfinite inputs cannot enter health records', () {
      expect(GrowthMeasurementValidator.parseMeasurement('9' * 65), isNull);
      expect(GrowthMeasurementValidator.parseMeasurement('Infinity'), isNull);
      expect(GrowthMeasurementValidator.parseMeasurement('NaN'), isNull);
      expect(GrowthMeasurementValidator.validateWeightKg(double.infinity), isNotNull);
    });
  });
}
