import 'package:anne_bebek/utils/growth_measurement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GP-03 growth measurement exact limits', () {
    test('weight bounds agree between grams and kilograms', () {
      for (final grams in <double>[0.001, 1, 1000, 199999, 200000]) {
        expect(
          GrowthMeasurementValidator.validateWeightGrams(grams),
          GrowthMeasurementValidator.validateWeightKg(grams / 1000),
          reason: 'Unit mismatch for $grams grams',
        );
      }
      expect(GrowthMeasurementValidator.validateWeightGrams(200000), isNull);
      expect(GrowthMeasurementValidator.validateWeightKg(200), isNull);
      expect(GrowthMeasurementValidator.validateWeightGrams(200001), isNotNull);
      expect(GrowthMeasurementValidator.validateWeightKg(200.001), isNotNull);
    });

    test('height and head circumference enforce inclusive upper limits', () {
      expect(GrowthMeasurementValidator.validateHeightCm(250), isNull);
      expect(GrowthMeasurementValidator.validateHeightCm(250.001), isNotNull);
      expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(100), isNull);
      expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(100.001), isNotNull);
    });

    test('nonfinite and nonpositive values cannot become health records', () {
      for (final value in <double>[double.nan, double.infinity, double.negativeInfinity, 0, -1]) {
        expect(GrowthMeasurementValidator.validateWeightGrams(value), isNotNull);
        expect(GrowthMeasurementValidator.validateWeightKg(value), isNotNull);
        expect(GrowthMeasurementValidator.validateHeightCm(value), isNotNull);
        expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(value), isNotNull);
      }
    });
  });
}
