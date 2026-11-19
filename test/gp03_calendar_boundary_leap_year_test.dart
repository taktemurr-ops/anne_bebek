import 'package:anne_bebek/utils/growth_measurement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GP-03 calendar boundary regression', () {
    test('leap-day birth and following March 1 are valid', () {
      final birth = DateTime(2024, 2, 29, 23, 59);
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          DateTime(2024, 2, 29, 0, 1),
          birthDate: birth,
          today: DateTime(2024, 3, 1, 0, 1),
        ),
        isNull,
      );
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          DateTime(2024, 3, 1, 23, 59),
          birthDate: birth,
          today: DateTime(2024, 3, 1, 0, 1),
        ),
        isNull,
      );
    });

    test('year boundary compares calendar dates rather than clock time', () {
      final birth = DateTime(2025, 12, 31, 23, 59);
      final today = DateTime(2026, 1, 1, 0, 1);
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          DateTime(2025, 12, 30, 23, 59),
          birthDate: birth,
          today: today,
        ),
        'Ölçüm doğumdan önce olamaz.',
      );
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          DateTime(2026, 1, 1, 23, 59),
          birthDate: birth,
          today: today,
        ),
        isNull,
      );
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          DateTime(2026, 1, 2),
          birthDate: birth,
          today: today,
        ),
        'Ölçüm tarihi gelecekte olamaz.',
      );
    });
  });
}
