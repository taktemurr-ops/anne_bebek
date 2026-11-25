import 'child_journals.dart';

/// Sort measurements by their actual measurement timestamp, not insertion order.
List<ChildJournalEntry> measurementHistory(List<ChildJournalEntry> entries, String category) {
  final result = entries.where((e) => e.category == category &&
      e.value != null && e.value!.isFinite && e.value! > 0).toList();
  result.sort((a, b) { final c = a.at.compareTo(b.at); return c != 0 ? c : a.id.compareTo(b.id); });
  return result;
}

double? measurementChange(List<ChildJournalEntry> entries, String category) {
  final history = measurementHistory(entries, category);
  if (history.length < 2) return null;
  return history.last.value! - history.first.value!;
}

/// Difference between the two most recent measurements on distinct dates.
/// Returns null for insufficient data or invalid/non-positive time intervals.
GrowthInterval? latestGrowthInterval(List<ChildJournalEntry> entries, String category) {
  final history = measurementHistory(entries, category);
  if (history.length < 2) return null;
  final latest = history.last;
  // Same-day corrections should not produce an artificial growth rate.
  final latestDay = DateTime(latest.at.year, latest.at.month, latest.at.day);
  ChildJournalEntry? previous;
  for (final entry in history.reversed.skip(1)) {
    final day = DateTime(entry.at.year, entry.at.month, entry.at.day);
    if (day.isBefore(latestDay)) { previous = entry; break; }
  }
  if (previous == null) return null;
  final previousDay = DateTime(previous.at.year, previous.at.month, previous.at.day);
  final days = latestDay.difference(previousDay).inDays;
  if (days <= 0) return null;
  return GrowthInterval(days: days, change: latest.value! - previous.value!);
}

class GrowthInterval {
  final int days;
  final double change;
  const GrowthInterval({required this.days, required this.change});
  double get changePer30Days => change * 30 / days;
}

/// Büyüme geçmişi dönem filtresi: son [months] takvim ayındaki kayıtlar.
/// [months] null ise tüm kayıtlar döner. Ay sonu taşmaları (ör. 31 Mayıs →
/// 3 ay önce) ayın son gününe sabitlenir; yaz saati kaymasından etkilenmez.
List<ChildJournalEntry> growthEntriesInPeriod(
    List<ChildJournalEntry> entries, int? months, DateTime now) {
  if (months == null) return entries;
  if (months <= 0) throw ArgumentError.value(months, 'months');
  var year = now.year;
  var month = now.month - months;
  while (month < 1) { month += 12; year--; }
  final lastDay = DateTime(year, month + 1, 0).day;
  final start = DateTime(year, month, now.day > lastDay ? lastDay : now.day);
  return entries.where((e) => !e.at.isBefore(start)).toList();
}
