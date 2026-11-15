import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/who_reference_csv.dart';
import 'package:anne_bebek/services/who_reference_series.dart';

void main() {
  const source = 'https://www.who.int/tools/child-growth-standards';
  test('LMS median returns approximately 50th percentile', () {
    final data = WhoMonthlyReference.parse(csv: 'month,L,M,S\n0,0.3487,3.3464,0.14602',
      indicator: GrowthIndicator.weightForAge, sex: ReferenceSex.male, source: source);
    expect(data.evaluate(completedMonths: 0, measurement: 3.3464)!.percentile,
      closeTo(50, 0.01));
    expect(data.evaluate(completedMonths: 1, measurement: 4), isNull);
  });
  test('rejects duplicate, malformed and untrusted input', () {
    WhoMonthlyReference parse(String csv, String url) => WhoMonthlyReference.parse(
      csv: csv, indicator: GrowthIndicator.weightForAge,
      sex: ReferenceSex.female, source: url);
    expect(() => parse('0,1,3,0.1\n0,1,3,0.1', source), throwsFormatException);
    expect(() => parse('0,1,3,0.1', 'https://example.com'), throwsFormatException);
    expect(() => parse('0,1,-3,0.1', source), throwsFormatException);
    expect(() => parse('1,1,3,0.1', source), throwsFormatException);
  });
}
