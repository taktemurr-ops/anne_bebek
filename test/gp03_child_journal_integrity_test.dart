import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_journals.dart';

void main() {
  test('GP-03 journal round trip preserves child ownership', () {
    final entry = ChildJournalEntry(id: 'e1', childId: 'baby-1',
      category: 'Kilo (kg)', note: '', at: DateTime(2026, 11, 19), value: 8.5);
    final result = decodeChildJournal(encodeChildJournal([entry]));
    expect(result.single.childId, 'baby-1');
    expect(result.single.value, 8.5);
  });
  test('GP-03 rejects malformed journal elements', () {
    expect(() => decodeChildJournal('[null]'), throwsFormatException);
    expect(() => decodeChildJournal('[3]'), throwsFormatException);
  });
  test('GP-03 rejects nonfinite measurement values', () {
    expect(() => ChildJournalEntry.fromJson({
      'id': 'e1', 'childId': 'baby-1', 'category': 'Kilo (kg)',
      'note': '', 'at': '2026-11-19T08:00:00', 'value': double.nan,
    }), throwsFormatException);
    expect(() => ChildJournalEntry.fromJson({
      'id': 'e1', 'childId': 'baby-1', 'category': 'Kilo (kg)',
      'note': '', 'at': '2026-11-19T08:00:00', 'value': double.infinity,
    }), throwsFormatException);
  });
}
