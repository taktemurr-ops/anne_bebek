import 'growth_measurement_validator.dart';

/// Validates a growth record as a unit before it is persisted.
/// Optional measurements may be omitted, but at least one is required.
class GrowthMeasurementRecordValidator {
  const GrowthMeasurementRecordValidator._();

  static String? validate({
    required DateTime birthDate,
    required DateTime? measuredAt,
    DateTime? today,
    num? weightKg,
    num? heightCm,
    num? headCircumferenceCm,
  }) {
    final dateError = GrowthMeasurementValidator.validateMeasurementDate(
      measuredAt,
      birthDate: birthDate,
      today: today,
    );
    if (dateError != null) return dateError;

    if (weightKg == null && heightCm == null && headCircumferenceCm == null) {
      return 'En az bir ölçüm girilmelidir.';
    }
    if (weightKg != null) {
      final error = GrowthMeasurementValidator.validateWeightKg(weightKg);
      if (error != null) return error;
    }
    if (heightCm != null) {
      final error = GrowthMeasurementValidator.validateHeightCm(heightCm);
      if (error != null) return error;
    }
    if (headCircumferenceCm != null) {
      final error = GrowthMeasurementValidator.validateHeadCircumferenceCm(
        headCircumferenceCm,
      );
      if (error != null) return error;
    }
    return null;
  }
}
