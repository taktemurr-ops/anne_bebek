import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_growth_summary.dart';
import 'package:anne_bebek/services/child_journals.dart';
void main() {
  ChildJournalEntry item(String id, int day, String cat, double? value) => ChildJournalEntry(
    id: id, childId: 'one', category: cat, note: '', at: DateTime(2026, 1, day), value: value);
  test('chronological growth delta independent of insertion order', () {
    final items = [item('b', 10, 'Kilo (kg)', 6), item('a', 1, 'Kilo (kg)', 5)];
    expect(measurementChange(items, 'Kilo (kg)'), 1);
    expect(measurementHistory(items, 'Kilo (kg)').first.id, 'a');
  });
  test('missing measurements do not produce a change', () {
    expect(measurementChange([item('a', 1, 'Boy (cm)', 60)], 'Boy (cm)'), isNull);
  });
  test('invalid values are excluded', () {
    expect(measurementHistory([item('a', 1, 'Kilo (kg)', -2), item('b', 2, 'Kilo (kg)', 5)], 'Kilo (kg)').length, 1);
  });
}
