/// GP-05: Calendar-day pregnancy and cycle calculations.
/// This is an informational estimate, never a medical diagnosis.
class ReproductiveCalendar {
  const ReproductiveCalendar._();

  static DateTime dayOnly(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);

  /// Pregnancy age in whole weeks and remaining days, counted from LMP.
  /// Rejects future dates and implausible durations instead of silently
  /// returning misleading values.
  static ({int weeks, int days})? gestationalAge({
    required DateTime lastMenstrualPeriod,
    required DateTime asOf,
  }) {
    final elapsed = dayOnly(asOf).difference(dayOnly(lastMenstrualPeriod)).inDays;
    if (elapsed < 0 || elapsed > 315) return null;
    return (weeks: elapsed ~/ 7, days: elapsed % 7);
  }

  /// Estimated due date: 280 days after the first day of the last period.
  static DateTime? estimatedDueDate(DateTime lastMenstrualPeriod,
      {required DateTime asOf}) {
    if (gestationalAge(lastMenstrualPeriod: lastMenstrualPeriod, asOf: asOf) == null) {
      return null;
    }
    return dayOnly(lastMenstrualPeriod).add(const Duration(days: 280));
  }

  /// Estimated next period for a user-entered cycle length (21–35 days).
  static DateTime? nextPeriodStart(DateTime periodStart, int cycleDays) {
    if (cycleDays < 21 || cycleDays > 35) return null;
    return dayOnly(periodStart).add(Duration(days: cycleDays));
  }
}
