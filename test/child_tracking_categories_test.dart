import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_journals.dart';

void main() {
  test('Emzirme, mama, uyku ve bez kayıtları çocuğa özel saklanır', () {
    final at = DateTime(2026, 11, 7);
    final input = [
      for (final category in ['Emzirme', 'Mama', 'Uyku', 'Bez'])
        ChildJournalEntry(id: category, childId: 'bebek-1',
          category: category, note: 'Örnek kayıt', at: at),
    ];
    final output = decodeChildJournal(encodeChildJournal(input));
    expect(output.map((e) => e.category).toList(),
      ['Emzirme', 'Mama', 'Uyku', 'Bez']);
    expect(output.every((e) => e.childId == 'bebek-1'), isTrue);
  });
}
