import 'daily_analytics.dart';

/// A calendar-month comparison of recorded feeding and sleep, not medical advice.
/// Incomplete current months are compared with the same elapsed number of days
/// in the preceding month; days without entries are counted as zero recorded.
class BabyMonthSummary {
  final DateTime start;
  final int days;
  final double formulaMl;
  final double nursingMinutes;
  final int solids;
  final int sleepMinutes;
  const BabyMonthSummary(this.start, this.days, this.formulaMl,
      this.nursingMinutes, this.solids, this.sleepMinutes);
  double get averageFormulaMl => formulaMl / days;
  double get averageSleepMinutes => sleepMinutes / days;
}

class BabyMonthComparison {
  final BabyMonthSummary current;
  final BabyMonthSummary previous;
  const BabyMonthComparison(this.current, this.previous);
  double get formulaChangeMl => current.formulaMl - previous.formulaMl;
  int get sleepChangeMinutes => current.sleepMinutes - previous.sleepMinutes;
}

BabyMonthComparison compareBabyMonths(
    List<Map<String, dynamic>> feeding,
    List<Map<String, dynamic>> sleep,
    DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final thisStart = DateTime(today.year, today.month);
  final previousStart = DateTime(today.year, today.month - 1);
  final previousLastDay = DateTime(today.year, today.month, 0).day;
  final elapsed = today.day;
  final comparableDays = elapsed < previousLastDay ? elapsed : previousLastDay;
  BabyMonthSummary summarize(DateTime start, int days) {
    // dailyBabyStats is anchored to the end of the requested period.
    final periodEnd = DateTime(start.year, start.month, start.day + days - 1, 23, 59, 59);
    final effectiveNow = periodEnd.isAfter(now) ? now : periodEnd;
    final values = dailyBabyStats(feeding, sleep, effectiveNow, days: days);
    return BabyMonthSummary(start, days,
      values.fold<double>(0, (sum, e) => sum + e.formulaMl),
      values.fold<double>(0, (sum, e) => sum + e.nursingMinutes),
      values.fold<int>(0, (sum, e) => sum + e.solids),
      values.fold<int>(0, (sum, e) => sum + e.sleepMinutes));
  }
  return BabyMonthComparison(summarize(thisStart, elapsed),
      summarize(previousStart, comparableDays));
}
