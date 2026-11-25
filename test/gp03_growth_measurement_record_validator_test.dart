import 'package:anne_bebek/utils/growth_measurement_record_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final birth = DateTime(2025, 8, 26);
  final today = DateTime(2026, 11, 19);
  final measuredAt = DateTime(2026, 11, 18);

  test('requires at least one actual measurement', () {
    expect(GrowthMeasurementRecordValidator.validate(
      birthDate: birth, measuredAt: measuredAt, today: today,
    ), 'En az bir ölçüm girilmelidir.');
  });

  test('accepts each measurement independently', () {
    expect(GrowthMeasurementRecordValidator.validate(
      birthDate: birth, measuredAt: measuredAt, today: today, weightKg: 10.2,
    ), isNull);
    expect(GrowthMeasurementRecordValidator.validate(
      birthDate: birth, measuredAt: measuredAt, today: today, heightCm: 75,
    ), isNull);
    expect(GrowthMeasurementRecordValidator.validate(
      birthDate: birth, measuredAt: measuredAt, today: today,
      headCircumferenceCm: 45,
    ), isNull);
  });

  test('rejects invalid value even when other fields are valid', () {
    expect(GrowthMeasurementRecordValidator.validate(
      birthDate: birth, measuredAt: measuredAt, today: today,
      weightKg: 10, heightCm: double.nan,
    ), isNotNull);
    expect(GrowthMeasurementRecordValidator.validate(
      birthDate: birth, measuredAt: measuredAt, today: today,
      weightKg: 10, headCircumferenceCm: -1,
    ), isNotNull);
  });

  test('rejects missing, prebirth and future dates before saving', () {
    for (final date in <DateTime?>[
      null, DateTime(2025, 8, 25), DateTime(2026, 11, 20),
    ]) {
      expect(GrowthMeasurementRecordValidator.validate(
        birthDate: birth, measuredAt: date, today: today, weightKg: 10,
      ), isNotNull);
    }
  });
}
