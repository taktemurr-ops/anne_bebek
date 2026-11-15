/// Calendar-day summaries for the last seven local days (oldest first).
/// Values are informational only, not clinical targets.
class DailyBabyStats {
  final DateTime day;
  final double formulaMl;
  final double nursingMinutes;
  final int solids;
  final int sleepMinutes;
  const DailyBabyStats(this.day, this.formulaMl, this.nursingMinutes, this.solids, this.sleepMinutes);
}

List<DailyBabyStats> dailyBabyStats(
  List<Map<String, dynamic>> feeding,
  List<Map<String, dynamic>> sleep,
  DateTime now, {
  int days = 7,
}) {
  if (days < 1 || days > 90) throw ArgumentError.value(days, 'days', '1–90 olmalı');
  final today = DateTime(now.year, now.month, now.day);
  final result = <DailyBabyStats>[];
  for (var offset = days - 1; offset >= 0; offset--) {
    final day = DateTime(today.year, today.month, today.day - offset);
    final next = DateTime(day.year, day.month, day.day + 1);
    double formula = 0, nursing = 0;
    var solids = 0, sleepMinutes = 0;
    final sleepIntervals = <({DateTime start, DateTime end})>[];
    for (final item in feeding) {
      final raw = item['date'];
      final date = raw is String ? DateTime.tryParse(raw) : null;
      if (date == null || date.isBefore(day) || !date.isBefore(next) || date.isAfter(now)) continue;
      final amount = item['amount'];
      final value = amount is num ? amount.toDouble() : double.nan;
      if (item['type'] == 'Mama' && value.isFinite && value > 0 && value <= 1000) formula += value;
      if (item['type'] == 'Emzirme' && value.isFinite && value > 0 && value <= 240) nursing += value;
      if (item['type'] == 'Ek gıda') solids++;
    }
    for (final item in sleep) {
      final startRaw = item['start'], endRaw = item['end'];
      final start = startRaw is String ? DateTime.tryParse(startRaw) : null;
      final end = endRaw is String ? DateTime.tryParse(endRaw) : null;
      if (start == null || end == null || !end.isAfter(start) || end.isAfter(now) || end.difference(start).inMinutes > 1440) continue;
      final from = start.isAfter(day) ? start : day;
      final to = end.isBefore(next) ? end : next;
      if (to.isAfter(from)) sleepIntervals.add((start: from, end: to));
    }
    // Merge overlapping intervals to avoid counting the same sleep twice.
    sleepIntervals.sort((a, b) => a.start.compareTo(b.start));
    DateTime? mergedStart, mergedEnd;
    for (final interval in sleepIntervals) {
      if (mergedStart == null) {
        mergedStart = interval.start;
        mergedEnd = interval.end;
      } else if (!interval.start.isAfter(mergedEnd!)) {
        if (interval.end.isAfter(mergedEnd)) mergedEnd = interval.end;
      } else {
        sleepMinutes += mergedEnd.difference(mergedStart).inMinutes;
        mergedStart = interval.start;
        mergedEnd = interval.end;
      }
    }
    if (mergedStart != null && mergedEnd != null) {
      sleepMinutes += mergedEnd.difference(mergedStart).inMinutes;
    }
    result.add(DailyBabyStats(day, formula, nursing, solids, sleepMinutes));
  }
  return result;
}

/// Compare two complete consecutive seven-day calendar windows, including today.
/// The prior window is the seven days immediately before the current window.
class WeeklyBabyComparison {
  final double currentFormulaMl;
  final double previousFormulaMl;
  final int currentSleepMinutes;
  final int previousSleepMinutes;
  final int currentSolids;
  final int previousSolids;
  const WeeklyBabyComparison(this.currentFormulaMl, this.previousFormulaMl,
      this.currentSleepMinutes, this.previousSleepMinutes,
      this.currentSolids, this.previousSolids);
  double get formulaDifferenceMl => currentFormulaMl - previousFormulaMl;
  int get sleepDifferenceMinutes => currentSleepMinutes - previousSleepMinutes;
}

WeeklyBabyComparison compareBabyWeeks(
  List<Map<String, dynamic>> feeding,
  List<Map<String, dynamic>> sleep,
  DateTime now,
) {
  final days = dailyBabyStats(feeding, sleep, now, days: 14);
  final previous = days.take(7);
  final current = days.skip(7);
  double formula(Iterable<DailyBabyStats> values) =>
      values.fold(0.0, (sum, item) => sum + item.formulaMl);
  int sleepTotal(Iterable<DailyBabyStats> values) =>
      values.fold(0, (sum, item) => sum + item.sleepMinutes);
  int solidsTotal(Iterable<DailyBabyStats> values) =>
      values.fold(0, (sum, item) => sum + item.solids);
  return WeeklyBabyComparison(formula(current), formula(previous),
      sleepTotal(current), sleepTotal(previous),
      solidsTotal(current), solidsTotal(previous));
}
