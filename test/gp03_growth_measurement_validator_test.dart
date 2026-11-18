import 'package:anne_bebek/utils/growth_measurement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GP-03 growth measurements', () {
    test('parses localized decimals and rejects ambiguous or unsafe input', () {
      expect(GrowthMeasurementValidator.parseMeasurement('3,385'), 3.385);
      expect(GrowthMeasurementValidator.parseMeasurement(' 54.5 '), 54.5);
      expect(GrowthMeasurementValidator.parseMeasurement('0'), 0);
      expect(GrowthMeasurementValidator.parseMeasurement('0,001'), 0.001);
      expect(GrowthMeasurementValidator.parseMeasurement('0,0001'), isNull);
      expect(GrowthMeasurementValidator.parseMeasurement('3.3859'), isNull);
      expect(GrowthMeasurementValidator.parseMeasurement(List.filled(65, '9').join()), isNull);
      expect(GrowthMeasurementValidator.parseMeasurement(List.filled(64, '9').join()), isNotNull);
      for (final input in <String>[
        '', ' ', '-1', '+1', '1.234,56', '1,234.56', '1..2',
        '.5', '5.', 'NaN', 'Infinity', '1e3', '1 000', 'abc',
      ]) {
        expect(GrowthMeasurementValidator.parseMeasurement(input), isNull,
            reason: 'Unexpected accepted input: $input');
      }
    });

    test('weight boundaries and nonfinite values', () {
      expect(GrowthMeasurementValidator.validateWeightGrams(3385), isNull);
      expect(GrowthMeasurementValidator.validateWeightGrams(200000), isNull);
      for (final value in <num?>[null, 0, -1, 200001, double.nan, double.infinity]) {
        expect(GrowthMeasurementValidator.validateWeightGrams(value), isNotNull);
      }
    });

    test('kilogram input is converted to grams with matching bounds', () {
      expect(GrowthMeasurementValidator.validateWeightKg(3.385), isNull);
      expect(GrowthMeasurementValidator.validateWeightKg(200), isNull);
      for (final value in <num?>[null, 0, -1, 200.001, double.nan, double.infinity, double.negativeInfinity]) {
        expect(GrowthMeasurementValidator.validateWeightKg(value), isNotNull);
      }
    });

    test('localized measurement precision remains valid at category boundaries', () {
      final weight = GrowthMeasurementValidator.parseMeasurement('200,000');
      final overWeight = GrowthMeasurementValidator.parseMeasurement('200,001');
      expect(weight, isNotNull);
      expect(overWeight, isNotNull);
      expect(GrowthMeasurementValidator.validateWeightKg(weight), isNull);
      expect(GrowthMeasurementValidator.validateWeightKg(overWeight), isNotNull);
      expect(GrowthMeasurementValidator.validateHeightCm(
          GrowthMeasurementValidator.parseMeasurement('250,000')), isNull);
      expect(GrowthMeasurementValidator.validateHeightCm(
          GrowthMeasurementValidator.parseMeasurement('250,001')), isNotNull);
      expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(
          GrowthMeasurementValidator.parseMeasurement('100,000')), isNull);
      expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(
          GrowthMeasurementValidator.parseMeasurement('100,001')), isNotNull);
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

    test('rejects upper bounds and accepts positive fractional measurements', () {
      expect(GrowthMeasurementValidator.validateWeightGrams(0.1), isNull);
      expect(GrowthMeasurementValidator.validateHeightCm(250), isNull);
      expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(100), isNull);
      expect(GrowthMeasurementValidator.validateWeightGrams(200000.1), isNotNull);
      expect(GrowthMeasurementValidator.validateHeightCm(250.1), isNotNull);
      expect(GrowthMeasurementValidator.validateHeadCircumferenceCm(100.1), isNotNull);
    });

    test('date validation handles leap day and ignores time of day', () {
      final birth = DateTime(2024, 2, 29, 23, 59);
      final today = DateTime(2024, 3, 1, 0, 1);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2024, 2, 29, 0, 1), birthDate: birth, today: today), isNull);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2024, 3, 1, 23, 59), birthDate: birth, today: today), isNull);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2024, 2, 28), birthDate: birth, today: today), isNotNull);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2024, 3, 2), birthDate: birth, today: today), isNotNull);
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
