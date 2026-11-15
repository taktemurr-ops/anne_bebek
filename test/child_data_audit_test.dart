import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_data_audit.dart';
import 'package:anne_bebek/services/child_journals.dart';
import 'package:anne_bebek/services/child_profiles.dart';

void main() {
  final child = ChildProfile(id: 'a', name: 'Çocuk', birthDate: DateTime(2024, 1, 1));
  ChildJournalEntry entry(String id, String childId, DateTime at) =>
    ChildJournalEntry(id: id, childId: childId, category: 'uyku', note: '', at: at);

  test('sağlıklı bağlantılar temizdir', () {
    final result = auditChildData([child], [entry('1', 'a', DateTime(2024, 2))], now: DateTime(2025));
    expect(result.isClean, isTrue);
    expect(result.journalCount, 1);
  });
  test('yetim kayıtları bulur, veri silmez', () {
    final result = auditChildData([child], [entry('2', 'missing', DateTime(2024, 2))], now: DateTime(2025));
    expect(result.orphanEntryIds, ['2']);
    expect(result.isClean, isFalse);
  });
  test('doğum öncesi ve gelecekteki tarihleri işaretler', () {
    final result = auditChildData([child], [
      entry('before', 'a', DateTime(2023, 12)),
      entry('future', 'a', DateTime(2026, 1)),
    ], now: DateTime(2025));
    expect(result.beforeBirthEntryIds, ['before']);
    expect(result.futureEntryIds, ['future']);
  });
}
