import 'package:anne_bebek/utils/growth_measurement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GP-03 measurement boundaries and unit consistency', () {
    test('weight in kilograms uses the same inclusive upper bound as grams', () {
      expect(GrowthMeasurementValidator.validateWeightKg(200), isNull);
      expect(GrowthMeasurementValidator.validateWeightGrams(200000), isNull);
      expect(
        GrowthMeasurementValidator.validateWeightKg(200.001),
        GrowthMeasurementValidator.validateWeightGrams(200001),
      );
      expect(GrowthMeasurementValidator.validateWeightKg(0), isNotNull);
      expect(GrowthMeasurementValidator.validateWeightGrams(0), isNotNull);
    });

    test('height and head circumference reject non-finite values', () {
      for (final value in <double>[double.nan, double.infinity, double.negativeInfinity]) {
        expect(GrowthMeasurementValidator.validateHeightCm(value), isNotNull);
        expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(value), isNotNull);
        expect(GrowthMeasurementValidator.validateWeightKg(value), isNotNull);
      }
    });

    test('upper bounds are inclusive and values above are rejected', () {
      expect(GrowthMeasurementValidator.validateHeightCm(250), isNull);
      expect(GrowthMeasurementValidator.validateHeightCm(250.001), isNotNull);
      expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(100), isNull);
      expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(100.001), isNotNull);
    });

    test('decimal parsing rejects grouped and ambiguous numeric formats', () {
      for (final raw in <String>['1,234.5', '1.234,5', '1 234', '1..2', '1,,2', '+1', '-1', '1e3']) {
        expect(GrowthMeasurementValidator.parseMeasurement(raw), isNull, reason: raw);
      }
      expect(GrowthMeasurementValidator.parseMeasurement(' 12,345 '), 12.345);
      expect(GrowthMeasurementValidator.parseMeasurement('12.345'), 12.345);
    });

    test('missing measurement date is rejected before date comparison', () {
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          null,
          birthDate: DateTime(2026, 1, 1),
          today: DateTime(2026, 1, 2),
        ),
        'Ölçüm tarihi gereklidir.',
      );
    });
  });
}
