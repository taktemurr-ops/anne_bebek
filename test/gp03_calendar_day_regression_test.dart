import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/growth_measurement_validator.dart';

void main() {
  group('GP-03 calendar-day validation regression', () {
    final birth = DateTime(2026, 2, 28, 23, 59);
    final today = DateTime(2026, 3, 1, 0, 1);

    test('same birth calendar day accepts earlier time', () {
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          DateTime(2026, 2, 28, 0, 0),
          birthDate: birth,
          today: today,
        ),
        isNull,
      );
    });

    test('today accepts later time on the same calendar day', () {
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          DateTime(2026, 3, 1, 23, 59),
          birthDate: birth,
          today: today,
        ),
        isNull,
      );
    });

    test('day before birth is rejected even when times are close', () {
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          DateTime(2026, 2, 27, 23, 59),
          birthDate: birth,
          today: today,
        ),
        'Ölçüm doğumdan önce olamaz.',
      );
    });

    test('day after today is rejected', () {
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          DateTime(2026, 3, 2),
          birthDate: birth,
          today: today,
        ),
        'Ölçüm tarihi gelecekte olamaz.',
      );
    });

    test('future birth date takes precedence over measurement date', () {
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          DateTime(2026, 2, 28),
          birthDate: DateTime(2026, 3, 2),
          today: today,
        ),
        'Doğum tarihi gelecekte olamaz.',
      );
    });

    test('UTC and local representations use calendar fields', () {
      expect(
        GrowthMeasurementValidator.validateMeasurementDate(
          DateTime.utc(2026, 3, 1, 23),
          birthDate: DateTime.utc(2026, 2, 28, 23),
          today: DateTime(2026, 3, 1, 1),
        ),
        isNull,
      );
    });
  });
}
