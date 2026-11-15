import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/cdc_who_reference_csv.dart';

void main() {
  final sample = ['Sex,Agemos,L,M,S',
      ...List.generate(25, (i) =>
        '1,${i == 0 ? '0' : '$i.5'},${i == 0 ? '0.3487' : '0.2297'},${i == 0 ? '3.3464' : '4.4709'},${i == 0 ? '0.14602' : '0.13395'}')].join('\n');
  test('CDC WHO birth median gives approximately 50th percentile', () {
    final rows = CdcWhoReferenceCsv.parse(sample, expectedSex: 1);
    expect(rows.length, 25);
    expect(rows[1].completedMonth, 1);
    expect(CdcWhoReferenceCsv.percentileAtCompletedMonth(rows, 0, 3.3464)!, closeTo(50, 0.01));
  });
  test('rejects absent sex, duplicate months and missing birth', () {
    expect(() => CdcWhoReferenceCsv.parse(sample, expectedSex: 2), throwsFormatException);
    expect(() => CdcWhoReferenceCsv.parse('$sample\n1,1.5,0.2,4.5,0.13', expectedSex: 1), throwsFormatException);
    expect(() => CdcWhoReferenceCsv.parse('Sex,Agemos,L,M,S\n1,1.5,0.2,4.5,0.13', expectedSex: 1), throwsFormatException);
  });
  test('filters official mixed-sex reference data correctly', () {
    final mixed = ['Sex,Agemos,L,M,S', ...List.generate(25, (i) {
      final age = i == 0 ? '0' : '$i.5';
      return '1,$age,0.3487,3.3464,0.14602\n2,$age,0.3809,3.2322,0.14171';
    })].join('\n');
    final boys = CdcWhoReferenceCsv.parse(mixed, expectedSex: 1);
    final girls = CdcWhoReferenceCsv.parse(mixed, expectedSex: 2);
    expect(boys.length, 25);
    expect(girls.length, 25);
    expect(boys.first.lms.m, 3.3464);
    expect(girls.first.lms.m, 3.2322);
  });
  test('rejects invalid sex code even in mixed files', () {
    expect(() => CdcWhoReferenceCsv.parse('$sample\n3,2.5,0.2,5,0.1', expectedSex: 1), throwsFormatException);
  });
  test('does not invent missing reference months', () {
    final rows = CdcWhoReferenceCsv.parse(sample, expectedSex: 1);
    // The complete reference contains month 3. Remove it to test a gap
    // in the lookup without weakening CSV completeness validation.
    final missingMonthRows = rows.where((row) => row.completedMonth != 3).toList();
    expect(CdcWhoReferenceCsv.percentileAtCompletedMonth(missingMonthRows, 3, 6), isNull);
  });
}
