import 'package:anne_bebek/utils/growth_measurement_record_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final birth = DateTime(2025, 8, 26);
  final today = DateTime(2026, 11, 19);
  final measuredAt = DateTime(2026, 11, 19);

  String? validate({num? weight, num? height, num? head, DateTime? date}) {
    return GrowthMeasurementRecordValidator.validate(
      birthDate: birth,
      measuredAt: date ?? measuredAt,
      today: today,
      weightKg: weight,
      heightCm: height,
      headCircumferenceCm: head,
    );
  }

  test('accepts a complete record at inclusive maximum boundaries', () {
    expect(validate(weight: 200, height: 250, head: 100), isNull);
  });

  test('rejects out-of-range fields in otherwise valid complete records', () {
    expect(validate(weight: 200.001, height: 70, head: 40), isNotNull);
    expect(validate(weight: 10, height: 250.001, head: 40), isNotNull);
    expect(validate(weight: 10, height: 70, head: 100.001), isNotNull);
  });

  test('rejects nonfinite values rather than treating them as absent', () {
    expect(validate(weight: double.nan), isNotNull);
    expect(validate(height: double.infinity), isNotNull);
    expect(validate(head: double.negativeInfinity), isNotNull);
  });

  test('rejects invalid measurement date before checking numeric values', () {
    final error = validate(
      weight: -1,
      date: DateTime(2025, 8, 25),
    );
    expect(error, 'Ölçüm doğumdan önce olamaz.');
  });

  test('accepts a measurement on the birth date', () {
    expect(validate(weight: 3.2, date: birth), isNull);
  });
}
