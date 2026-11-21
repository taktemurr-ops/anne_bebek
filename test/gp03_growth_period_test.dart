import 'package:anne_bebek/services/child_growth_summary.dart';
import 'package:anne_bebek/services/child_journals.dart';
import 'package:flutter_test/flutter_test.dart';

ChildJournalEntry _e(String id, DateTime at) => ChildJournalEntry(
    id: id, childId: 'c1', category: 'Kilo (kg)', note: '', at: at, value: 7);

void main() {
  final entries = [
    _e('a', DateTime(2025, 11, 30)),
    _e('b', DateTime(2026, 2, 28)),
    _e('c', DateTime(2026, 5, 15)),
    _e('d', DateTime(2026, 11, 20)),
  ];

  test('dönem filtresi takvim ayına göre keser', () {
    final now = DateTime(2026, 11, 21);
    expect(growthEntriesInPeriod(entries, null, now), hasLength(4));
    expect(growthEntriesInPeriod(entries, 3, now).map((e) => e.id), ['d']);
    expect(growthEntriesInPeriod(entries, 6, now).map((e) => e.id), ['d']);
    expect(growthEntriesInPeriod(entries, 6, DateTime(2026, 11, 10)).map((e) => e.id), ['c', 'd']);
    expect(growthEntriesInPeriod(entries, 12, now).map((e) => e.id), ['a', 'b', 'c', 'd']);
    expect(growthEntriesInPeriod(entries, 12, DateTime(2026, 12, 1)).map((e) => e.id), ['b', 'c', 'd']);
  });

  test('ay sonu taşması son güne sabitlenir', () {
    // 31 Mayıs'tan 3 ay önce: 28 Şubat (2026 artık yıl değil).
    final r = growthEntriesInPeriod(entries, 3, DateTime(2026, 5, 31));
    expect(r.map((e) => e.id), ['b', 'c', 'd']);
  });

  test('geçersiz dönem reddedilir', () {
    expect(() => growthEntriesInPeriod(entries, 0, DateTime(2026)), throwsArgumentError);
  });
}
