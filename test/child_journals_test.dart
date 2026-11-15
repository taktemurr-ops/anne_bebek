import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_journals.dart';

void main() {
  test('Çocuk günlükleri kimliğe göre ayrı tutulur', () {
    final entries = [ChildJournalEntry(id: '1', childId: 'a', category: 'Uyku', note: '2 saat', at: DateTime(2026, 1, 1)),
      ChildJournalEntry(id: '2', childId: 'b', category: 'Beslenme', note: '100 ml', at: DateTime(2026, 1, 2))];
    final decoded = decodeChildJournal(encodeChildJournal(entries));
    expect(decoded.where((e) => e.childId == 'a').length, 1);
    expect(decoded.where((e) => e.childId == 'b').length, 1);
  });
  test('Bozuk günlük reddedilir', () {
    expect(() => decodeChildJournal('{'), throwsFormatException);
  });
}
