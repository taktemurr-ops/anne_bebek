import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/growth_analysis.dart';
import 'package:anne_bebek/services/monthly_growth.dart';

void main() {
  test('Aylık ölçümler tarihe göre gruplanır ve sayılır', () {
    final months = monthlyGrowth([
      GrowthPoint(DateTime(2026, 2, 5), 6.1),
      GrowthPoint(DateTime(2026, 1, 20), 5.5),
      GrowthPoint(DateTime(2026, 1, 3), 5.0),
    ]);
    expect(months.length, 2);
    expect(months.first.label, '1.2026');
    expect(months.first.count, 2);
    expect(months.first.first, 5.0);
    expect(months.first.last, 5.5);
    expect(lastMonthDifference(months), closeTo(0.6, 0.00001));
  });

  test('Eksik ay varsa karşılaştırma üretilmez', () {
    final months = monthlyGrowth([
      GrowthPoint(DateTime(2026, 1, 1), 5),
      GrowthPoint(DateTime(2026, 3, 1), 6),
    ]);
    expect(lastMonthDifference(months), isNull);
  });

  test('Yıl değişiminde aralık doğru hesaplanır', () {
    final months = monthlyGrowth([
      GrowthPoint(DateTime(2025, 12, 31), 5),
      GrowthPoint(DateTime(2026, 1, 1), 5.2),
    ]);
    expect(lastMonthDifference(months), closeTo(0.2, 0.00001));
  });

  test('Boş ve tek aylık ölçümlerde karşılaştırma yoktur', () {
    expect(monthlyGrowth([]), isEmpty);
    expect(lastMonthDifference([]), isNull);
    expect(lastMonthDifference(monthlyGrowth([
      GrowthPoint(DateTime(2026, 4, 1), 8),
    ])), isNull);
  });
}
