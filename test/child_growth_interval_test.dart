import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_growth_summary.dart';

void main() {
  test('empty measurements have no growth interval', () {
    expect(latestGrowthInterval([], 'Kilo (kg)'), isNull);
  });
}
