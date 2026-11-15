import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_calendar_export.dart';
import 'package:anne_bebek/services/child_care_plans.dart';
void main() {
  test('exports only pending appointments for the selected child', () {
    ChildCareItem make(String id, String child, bool done) => ChildCareItem(
      id: id, childId: child, category: 'Doktor kontrolü', title: 'Kontrol',
      note: 'Not', date: DateTime(2026, 12, 31), completed: done);
    final result = buildChildCareCalendar([make('1','a',false),make('2','b',false),make('3','a',true)], 'a', 'Bebek');
    expect(result, contains('DTSTART;VALUE=DATE:20261231'));
    expect(result, contains('DTEND;VALUE=DATE:20270101'));
    expect(result, contains('UID:a-1@annebebek.local'));
    expect(result, isNot(contains('UID:b-2@annebebek.local')));
    expect(result, isNot(contains('UID:a-3@annebebek.local')));
  });
}
