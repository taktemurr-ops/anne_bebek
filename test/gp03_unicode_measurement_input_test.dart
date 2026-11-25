import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/growth_measurement_validator.dart';

void main() {
  group('GP-03 strict measurement parsing', () {
    test('accepts ASCII spaces and comma or dot decimals', () {
      expect(GrowthMeasurementValidator.parseMeasurement(' 12,345 '), 12.345);
      expect(GrowthMeasurementValidator.parseMeasurement('12.3'), 12.3);
      expect(GrowthMeasurementValidator.parseMeasurement('12'), 12);
    });

    test('rejects invisible Unicode separators and formatting', () {
      for (final input in <String>[
        '12\u00a0', // non-breaking space
        '\u200b12', // zero-width space
        '12\u200e', // left-to-right mark
        '12\u202e', // right-to-left override
        '12\u2060', // word joiner
        '12\ufeff', // byte-order mark
        '12\t', // tab
        '12\n', // newline
      ]) {
        expect(GrowthMeasurementValidator.parseMeasurement(input), isNull,
            reason: 'Unexpected acceptance of ${input.codeUnits}');
      }
    });

    test('rejects precision overflow and mixed separators', () {
      for (final input in <String>['1.2345', '1,2.3', '1,234.5', '.5', '5.']) {
        expect(GrowthMeasurementValidator.parseMeasurement(input), isNull);
      }
    });
  });
}
