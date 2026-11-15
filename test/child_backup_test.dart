import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_backup.dart';
import 'package:anne_bebek/services/child_profiles.dart';
import 'package:anne_bebek/services/child_journals.dart';

void main() {
  final child = ChildProfile(id: 'a', name: 'Çocuk', birthDate: DateTime(2025, 1, 1));
  test('Yedek sadece seçilen çocuğun kayıtlarını içerir', () {
    final entries = [
      ChildJournalEntry(id: '1', childId: 'a', category: 'Uyku', note: 'İyi', at: DateTime(2025, 2, 1)),
      ChildJournalEntry(id: '2', childId: 'b', category: 'Uyku', note: 'Diğer', at: DateTime(2025, 2, 2)),
    ];
    final backup = ChildBackup.exportJson(child, entries);
    expect(backup.contains('Diğer'), false);
    expect(ChildBackup.inspectJson(backup, childId: 'a').length, 1);
    expect(() => ChildBackup.inspectJson(backup, childId: 'b'), throwsFormatException);
  });
  test('Bozuk yedek reddedilir', () {
    expect(() => ChildBackup.inspectJson('{}', childId: 'a'), throwsFormatException);
  });
}
