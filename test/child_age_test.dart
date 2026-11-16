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
  test('time of day does not change completed calendar months', () {
    final birth = DateTime(2025, 8, 26, 23, 59);
    expect(completedChildMonths(birth, DateTime(2025, 9, 26, 0, 1)), 1);
    expect(completedChildMonths(birth, DateTime(2025, 9, 25, 23, 59)), 0);
  });
  test('leap day and year rollover stay on calendar boundaries', () {
    final birth = DateTime(2024, 2, 29);
    expect(completedChildMonths(birth, DateTime(2024, 3, 28)), 0);
    expect(completedChildMonths(birth, DateTime(2024, 3, 29)), 1);
    expect(completedChildMonths(birth, DateTime(2025, 2, 28)), 11);
    expect(completedChildMonths(birth, DateTime(2025, 3, 29)), 13);
  });
}
