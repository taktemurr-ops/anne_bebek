import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_age.dart';

void main() {
  test('calendar month boundary', () {
    final birth = DateTime(2025, 8, 26);
    expect(completedChildMonths(birth, DateTime(2026, 9, 25)), 12);
    expect(completedChildMonths(birth, DateTime(2026, 9, 26)), 13);
    expect(childAgeLabel(birth, DateTime(2026, 9, 26)), '1 yaş 1 aylık');
  });
  test('future date is clamped to zero', () {
    expect(completedChildMonths(DateTime(2027, 1, 1), DateTime(2026, 1, 1)), 0);
  });
  test('age topics change by stage', () {
    expect(childAgeTopics(4).first, 'Sütle beslenme');
    expect(childAgeTopics(8).first, 'Ek gıdaya geçiş');
  });
}
