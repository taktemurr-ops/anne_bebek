import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_care_plans.dart';

void main() {
  final item = ChildCareItem(id: '1', childId: 'child-a', category: 'Aşı',
    title: 'Doktorun önerdiği aşı', note: 'Randevu', date: DateTime(2026, 11, 3), completed: false);
  test('Kayıtları kayıpsız dönüştürür', () {
    final result = decodeChildCareItems(encodeChildCareItems([item]));
    expect(result.single.title, item.title);
    expect(result.single.date, item.date);
  });
  test('Çocukların kayıtlarını birbirinden ayırır', () {
    expect(careItemsForChild([item], 'child-b'), isEmpty);
    expect(careItemsForChild([item], 'child-a'), hasLength(1));
  });
  test('Tamamlanma durumu değişirken kayıt kimliği korunur', () {
    final done = item.withCompleted(true);
    expect(done.id, item.id);
    expect(done.completed, isTrue);
  });
  test('Bozuk kayıtlar reddedilir', () {
    expect(() => decodeChildCareItems('[{"id":"x"}]'), throwsFormatException);
  });
}
