import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/safe_records.dart';

void main() {
  test('existing valid records remain readable', () {
    expect(readRecordList('[{"tur":"Uyku","not":"Gece"}]'), [
      {'tur': 'Uyku', 'not': 'Gece'}
    ]);
  });
  test('invalid records do not crash startup', () {
    expect(readRecordList('{broken'), isEmpty);
    expect(readRecordList('null'), isEmpty);
    expect(readStringList('["süt",12,null,"bez"]'), ['süt', 'bez']);
  });
  test('non-string fields do not cause type cast errors', () {
    expect(readRecordList('[{"tur":"Uyku","zaman":123},null]'), [
      {'tur': 'Uyku'}
    ]);
  });
}
