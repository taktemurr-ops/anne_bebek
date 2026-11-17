import 'package:anne_bebek/utils/growth_measurement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GP-03 growth measurements', () {
    test('weight boundaries and nonfinite values', () {
      expect(GrowthMeasurementValidator.validateWeightGrams(3385), isNull);
      expect(GrowthMeasurementValidator.validateWeightGrams(200000), isNull);
      for (final value in <num?>[null, 0, -1, 200001, double.nan, double.infinity]) {
        expect(GrowthMeasurementValidator.validateWeightGrams(value), isNotNull);
      }
    });

    test('height and head circumference boundaries', () {
      expect(GrowthMeasurementValidator.validateHeightCm(54), isNull);
      expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(35), isNull);
      for (final value in <num?>[null, 0, -1, double.nan, double.negativeInfinity]) {
        expect(GrowthMeasurementValidator.validateHeightCm(value), isNotNull);
        expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(value), isNotNull);
      }
      expect(GrowthMeasurementValidator.validateHeightCm(251), isNotNull);
      expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(101), isNotNull);
    });

    test('measurement date respects birth date and current calendar day', () {
      final birth = DateTime(2025, 8, 26, 23, 59);
      final now = DateTime(2026, 11, 17, 1);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2025, 8, 26), birthDate: birth, today: now), isNull);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2026, 11, 17, 23), birthDate: birth, today: now), isNull);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2025, 8, 25), birthDate: birth, today: now), isNotNull);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2026, 11, 18), birthDate: birth, today: now), isNotNull);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        null, birthDate: birth, today: now), isNotNull);
    });
  });
}
