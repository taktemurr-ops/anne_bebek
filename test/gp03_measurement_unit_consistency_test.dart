import 'package:anne_bebek/utils/growth_measurement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GP-03 measurement unit consistency', () {
    test('kilograms and grams enforce the same upper boundary', () {
      expect(GrowthMeasurementValidator.validateWeightKg(200), isNull);
      expect(GrowthMeasurementValidator.validateWeightGrams(200000), isNull);
      expect(GrowthMeasurementValidator.validateWeightKg(200.001), isNotNull);
      expect(GrowthMeasurementValidator.validateWeightGrams(200001), isNotNull);
    });

    test('non-finite measurements are never accepted', () {
      expect(GrowthMeasurementValidator.validateWeightKg(double.nan), isNotNull);
      expect(GrowthMeasurementValidator.validateWeightKg(double.infinity), isNotNull);
      expect(GrowthMeasurementValidator.validateHeightCm(double.nan), isNotNull);
      expect(
        GrowthMeasurementValidator.validateHeadCircumferenceCm(
          double.negativeInfinity,
        ),
        isNotNull,
      );
    });

    test('decimal parsing does not silently round extra digits', () {
      expect(GrowthMeasurementValidator.parseMeasurement('3,125'), 3.125);
      expect(GrowthMeasurementValidator.parseMeasurement('3.1250'), isNull);
      expect(GrowthMeasurementValidator.parseMeasurement('1e3'), isNull);
      expect(GrowthMeasurementValidator.parseMeasurement('1,2.3'), isNull);
    });

    test('date validation rejects absent measurement date', () {
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          null,
          birthDate: DateTime(2025, 8, 26),
          today: DateTime(2026, 11, 18),
        ),
        'Ölçüm tarihi gereklidir.',
      );
    });
  });
}
