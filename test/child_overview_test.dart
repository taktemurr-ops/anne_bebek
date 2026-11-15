import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_overview.dart';
import 'package:anne_bebek/services/child_journals.dart';
void main() {
  test('Çocuk verileri birbirine karışmaz', () {
    final now = DateTime(2026, 11, 1, 12);
    final data = [
      ChildJournalEntry(id: '1', childId: 'a', category: 'Beslenme', note: 'x', at: now),
      ChildJournalEntry(id: '2', childId: 'b', category: 'Uyku', note: 'x', at: now),
      ChildJournalEntry(id: '3', childId: 'a', category: 'Uyku', note: 'x', at: now.subtract(const Duration(days: 8))),
    ];
    final a = childOverview(data, 'a', now);
    expect(a.total, 2); expect(a.last7Days, 1); expect(a.feeding, 1); expect(a.sleep, 1);
    final b = childOverview(data, 'b', now);
    expect(b.total, 1); expect(b.feeding, 0); expect(b.sleep, 1);
  });
}
