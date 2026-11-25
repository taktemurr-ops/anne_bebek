import 'package:anne_bebek/utils/growth_measurement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GP-03 measurement range regression matrix', () {
    test('all supported measurement categories reject invalid extremes', () {
      final validators = <String, String? Function(num?)>{
        'weightKg': GrowthMeasurementValidator.validateWeightKg,
        'heightCm': GrowthMeasurementValidator.validateHeightCm,
        'headCm': GrowthMeasurementValidator.validateHeadCircumferenceCm,
      };
      for (final entry in validators.entries) {
        for (final invalid in <num?>[
          null, -1, 0, double.nan, double.infinity,
          double.negativeInfinity,
        ]) {
          expect(entry.value(invalid), isNotNull,
              reason: '${entry.key} must reject $invalid');
        }
      }
    });

    test('locale-independent parsed input stays within category bounds', () {
      final categories = <String, (String, String? Function(num?))>{
        'weightKg': ('200', GrowthMeasurementValidator.validateWeightKg),
        'heightCm': ('250', GrowthMeasurementValidator.validateHeightCm),
        'headCm': ('100', GrowthMeasurementValidator.validateHeadCircumferenceCm),
      };
      for (final entry in categories.entries) {
        final upper = GrowthMeasurementValidator.parseMeasurement(
            entry.value.$1);
        expect(upper, isNotNull, reason: entry.key);
        expect(entry.value.$2(upper), isNull, reason: entry.key);
        expect(entry.value.$2(upper! + 0.001), isNotNull,
            reason: '${entry.key} must reject values above maximum');
      }
    });
  });
}
