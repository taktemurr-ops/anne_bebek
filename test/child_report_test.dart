import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_report.dart';
import 'package:anne_bebek/services/child_journals.dart';
import 'package:anne_bebek/services/child_profiles.dart';

void main() {
  final child = ChildProfile(id: 'a', name: 'Deniz', birthDate: DateTime(2025, 1, 1));
  final records = [
    ChildJournalEntry(id: '1', childId: 'a', category: 'Uyku', note: 'Gece', at: DateTime(2026, 1, 2)),
    ChildJournalEntry(id: '2', childId: 'b', category: 'Beslenme', note: 'Başka çocuk', at: DateTime(2026, 1, 3)),
    ChildJournalEntry(id: '3', childId: 'a', category: 'Uyku', note: 'Gündüz', at: DateTime(2026, 1, 4)),
  ];
  test('Farklı çocuğun kayıtları rapora karışmaz', () {
    final report = ChildReport.textReport(child, records);
    expect(report, contains('Deniz'));
    expect(report, contains('Toplam kayıt: 2'));
    expect(report, isNot(contains('Başka çocuk')));
  });
  test('Tarih ve kategori filtresi doğru çalışır', () {
    expect(ChildReport.select(records, 'a', from: DateTime(2026, 1, 3)).length, 1);
    expect(ChildReport.select(records, 'a', category: 'Beslenme'), isEmpty);
  });
  test('Kayıt sayıları doğru hesaplanır', () {
    expect(ChildReport.counts(ChildReport.select(records, 'a'))['Uyku'], 2);
  });
}
