import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_report.dart';
import 'package:anne_bebek/services/child_profiles.dart';
import 'package:anne_bebek/services/child_journals.dart';

void main() {
  final child = ChildProfile(id: 'one', name: 'Deniz', birthDate: DateTime(2025, 1, 1));
  test('CSV contains only selected child and escapes dangerous cells', () {
    final entries = [
      ChildJournalEntry(id: 'a', childId: 'one', category: 'Ölçüm', note: '=1+1, "deneme"', at: DateTime(2026, 1, 1), value: 10),
      ChildJournalEntry(id: 'b', childId: 'other', category: 'Ölçüm', note: 'SECRET', at: DateTime(2026, 1, 1)),
    ];
    final csv = ChildReport.csvReport(child, entries);
    expect(csv, contains('Deniz'));
    expect(csv, contains("'=1+1"));
    expect(csv, contains('""deneme""'));
    expect(csv, isNot(contains('SECRET')));
  });
  test('numeric history sorted by date and excludes empty values', () {
    final entries = [
      ChildJournalEntry(id: 'a', childId: 'one', category: 'Kilo', note: '', at: DateTime(2026, 2, 1), value: 11),
      ChildJournalEntry(id: 'b', childId: 'one', category: 'Kilo', note: '', at: DateTime(2026, 1, 1), value: 10),
      ChildJournalEntry(id: 'c', childId: 'one', category: 'Uyku', note: '', at: DateTime(2026, 1, 1)),
    ];
    final series = ChildReport.numericSeries(entries);
    expect(series['Kilo']!.first.value, 10);
    expect(series.containsKey('Uyku'), false);
  });
}
