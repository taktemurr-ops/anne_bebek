import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/who_reference_series.dart';
import 'package:anne_bebek/services/who_lms_math.dart';

void main() {
  WhoReferenceSeries example() => WhoReferenceSeries(
    indicator: GrowthIndicator.weightForAge, sex: ReferenceSex.female,
    source: 'Synthetic test data - NOT WHO', points: const [
      AgeLmsPoint(0, LmsParameters(1, 3, 0.1)),
      AgeLmsPoint(10, LmsParameters(1, 5, 0.2)),
    ]);
  test('interpolates inside reference range without extrapolation', () {
    final series = example();
    expect(series.atAge(5)!.m, 4);
    expect(series.atAge(-1), isNull);
    expect(series.atAge(11), isNull);
  });
  test('uses calendar days across daylight-saving boundaries', () {
    final result = example().evaluate(birthDate: DateTime(2026, 3, 27),
      measuredAt: DateTime(2026, 4, 1), measurement: 4);
    expect(result!.ageDays, 5);
    expect(result.percentile, closeTo(50, 0.01));
  });
  test('rejects duplicate ages and malformed references', () {
    expect(() => WhoReferenceSeries(indicator: GrowthIndicator.weightForAge,
      sex: ReferenceSex.male, source: 'test', points: const [
      AgeLmsPoint(1, LmsParameters(1, 2, .1)),
      AgeLmsPoint(1, LmsParameters(1, 3, .1))]), throwsArgumentError);
    expect(() => WhoReferenceSeries(indicator: GrowthIndicator.weightForAge,
      sex: ReferenceSex.male, source: 'test', points: const [
      AgeLmsPoint(1, LmsParameters(1, -2, .1))]), throwsArgumentError);
  });
}
