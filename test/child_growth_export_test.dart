import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_profiles.dart';
import 'package:anne_bebek/services/child_journals.dart';
import 'package:anne_bebek/services/child_growth_export.dart';

void main() {
  final child = ChildProfile(id: 'c1', name: 'Çocuk', birthDate: DateTime(2025, 1, 1));
  ChildJournalEntry entry(String id, String childId, DateTime date, double value, {String note = ''}) =>
    ChildJournalEntry(id: id, childId: childId, category: 'Kilo (kg)', note: note, at: date, value: value);
  test('Başka çocuğun ölçümleri dışa aktarılmaz', () {
    final csv = exportChildMeasurementsCsv(child, [entry('1','c1',DateTime(2025, 2, 1), 4), entry('2','c2',DateTime(2025, 2, 1), 99)]);
    expect(csv, contains('4.00'));
    expect(csv, isNot(contains('99.00')));
  });
  test('Doğum öncesi ve gelecek tarihli kayıtlar dışlanır', () {
    final csv = exportChildMeasurementsCsv(child, [entry('1','c1',DateTime(2024, 12, 31), 1), entry('2','c1',DateTime(2099, 1, 1), 2)]);
    expect(csv, isNot(contains('1.00')));
    expect(csv, isNot(contains('2.00')));
  });
  test('Notlar CSV formüllerine karşı güvenli biçimde yazılır', () {
    final csv = exportChildMeasurementsCsv(child, [entry('1','c1',DateTime(2025, 2, 1), 4, note: '=HYPERLINK("x")')]);
    expect(csv, contains("'=HYPERLINK"));
    expect(csv, contains('""x""'));
  });
}
