import 'child_journals.dart';

/// Pure, child-scoped counts. Never mixes records belonging to other children.
class ChildOverview {
  final int total, last7Days, feeding, sleep, health;
  const ChildOverview({required this.total, required this.last7Days,
    required this.feeding, required this.sleep, required this.health});
}

ChildOverview childOverview(List<ChildJournalEntry> all, String childId, DateTime now) {
  final end = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  final start = end.subtract(const Duration(days: 7));
  final items = all.where((e) => e.childId == childId && !e.at.isAfter(now)).toList();
  return ChildOverview(
    total: items.length,
    last7Days: items.where((e) => !e.at.isBefore(start) && e.at.isBefore(end)).length,
    feeding: items.where((e) => e.category == 'Beslenme').length,
    sleep: items.where((e) => e.category == 'Uyku').length,
    health: items.where((e) => e.category == 'Belirti' || e.category == 'Alerji gözlemi' || e.category == 'Doktor kontrolü').length,
  );
}
