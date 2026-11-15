import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/models/app_data.dart';
import 'package:anne_bebek/services/legacy_child_import.dart';

void main() {
  final entry = BabyEntry(id: 'a', category: 'Beslenme', note: 'Not',
    createdAt: DateTime(2026, 1, 1));
  test('kopyalama doğru çocuğa bağlanır', () {
    final result = LegacyChildImport.merge(childId: 'c1', legacy: [entry], existing: []);
    expect(result.single.childId, 'c1');
    expect(result.single.note, 'Not');
  });
  test('tekrarlanan kopyalama yeni kayıt üretmez', () {
    final first = LegacyChildImport.merge(childId: 'c1', legacy: [entry], existing: []);
    final again = LegacyChildImport.merge(childId: 'c1', legacy: [entry], existing: first);
    expect(again.length, 1);
  });
  test('diğer çocuğun kayıtları değiştirilmez', () {
    final first = LegacyChildImport.merge(childId: 'c1', legacy: [entry], existing: []);
    final second = LegacyChildImport.merge(childId: 'c2', legacy: [entry], existing: first);
    expect(second.length, 2);
    expect(second.first.childId, 'c1');
    expect(second.last.childId, 'c2');
  });
}
