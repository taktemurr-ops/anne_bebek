import 'package:anne_bebek/utils/growth_measurement_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('measurement parser rejects invisible and direction control input', () {
    for (final input in <String>[
      '12\u200b3', // zero-width space
      '12\u200d3', // zero-width joiner
      '12\u202e3', // right-to-left override
      '12\u20663', // left-to-right isolate
      '12\u00003', // NUL
      '12\u007f3', // DEL
      '12\n3',
      '12\t3',
    ]) {
      expect(GrowthMeasurementValidator.parseMeasurement(input), isNull,
          reason: 'Invisible or control characters must not be parsed');
    }
  });
}
