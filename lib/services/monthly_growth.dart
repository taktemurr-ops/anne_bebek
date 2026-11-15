import 'growth_analysis.dart';

/// Calendar-month summaries based only on recorded measurements.
/// Not a percentile, expected-growth estimate or medical interpretation.
class MonthlyGrowth {
  final int year;
  final int month;
  final double first;
  final double last;
  final int count;
  const MonthlyGrowth(this.year, this.month, this.first, this.last, this.count);

  double get withinMonthChange => last - first;
  String get label => '$month.$year';
}

List<MonthlyGrowth> monthlyGrowth(List<GrowthPoint> points) {
  if (points.isEmpty) return [];
  final sorted = [...points]..sort((a, b) => a.date.compareTo(b.date));
  final result = <MonthlyGrowth>[];
  var index = 0;
  while (index < sorted.length) {
    final first = sorted[index];
    var last = first;
    var count = 0;
    while (index < sorted.length &&
        sorted[index].date.year == first.date.year &&
        sorted[index].date.month == first.date.month) {
      last = sorted[index];
      count++;
      index++;
    }
    result.add(MonthlyGrowth(first.date.year, first.date.month,
        first.value, last.value, count));
  }
  return result;
}

/// Difference between the final recorded values of consecutive months.
/// A month without measurements is not silently treated as zero.
double? lastMonthDifference(List<MonthlyGrowth> months) {
  if (months.length < 2) return null;
  final previous = months[months.length - 2];
  final current = months.last;
  final adjacent = (current.year * 12 + current.month) -
      (previous.year * 12 + previous.month) == 1;
  return adjacent ? current.last - previous.last : null;
}
