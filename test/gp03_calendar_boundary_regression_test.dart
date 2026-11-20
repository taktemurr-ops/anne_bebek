import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/growth_measurement_validator.dart';

void main() {
  group('GP-03 takvim sinirlari', () {
    test('artik yil dogum gunu ve sonraki gun kabul edilir', () {
      final birth = DateTime(2024, 2, 29);
      final today = DateTime(2024, 3, 1);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2024, 2, 29), birthDate: birth, today: today), isNull);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2024, 3, 1), birthDate: birth, today: today), isNull);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2024, 2, 28), birthDate: birth, today: today), isNotNull);
    });

    test('yil sonunda ertesi gun gelecekte sayilir', () {
      final birth = DateTime(2025, 12, 30);
      final today = DateTime(2025, 12, 31);
      expect(GrowthMeasurementValidator.validateMeasurementDate(
        DateTime(2026, 1, 1), birthDate: birth, today: today),
        'Ölçüm tarihi gelecekte olamaz.');
    });
  });
}
