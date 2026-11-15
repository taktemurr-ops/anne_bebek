import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/cycle_statistics.dart';
void main() {
  test('Boş ve tek kayıt için istatistik üretilmez', () {
    expect(summarizeCycleStarts([]).averageDays, isNull);
    expect(summarizeCycleStarts([DateTime(2025,1,1)]).count, 0);
  });
  test('Sırasız, tekrarlı tarihlerden geçmiş aralıklar hesaplanır', () {
    final result = summarizeCycleStarts([DateTime(2025,3,2),DateTime(2025,1,1),
      DateTime(2025,1,30),DateTime(2025,1,1)]);
    expect(result.intervals, [29,31]);
    expect(result.averageDays, 30);
    expect(result.shortestDays, 29);
    expect(result.longestDays, 31);
  });
}
