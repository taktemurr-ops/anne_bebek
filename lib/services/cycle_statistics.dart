/// Descriptive statistics from recorded period start dates only.
/// Not a prediction, fertility estimate, or contraceptive tool.
class CycleStatistics {
  final List<int> intervals;
  const CycleStatistics(this.intervals);
  int get count => intervals.length;
  double? get averageDays => intervals.isEmpty ? null : intervals.reduce((a,b)=>a+b) / intervals.length;
  int? get shortestDays => intervals.isEmpty ? null : intervals.reduce((a,b)=>a<b?a:b);
  int? get longestDays => intervals.isEmpty ? null : intervals.reduce((a,b)=>a>b?a:b);
}

CycleStatistics summarizeCycleStarts(List<DateTime> dates) {
  final ordered = dates.map((d) => DateTime.utc(d.year,d.month,d.day)).toSet().toList()..sort();
  final intervals = <int>[];
  for (var i=1; i<ordered.length; i++) {
    final days = ordered[i].difference(ordered[i-1]).inDays;
    if (days > 0) intervals.add(days);
  }
  return CycleStatistics(intervals);
}
