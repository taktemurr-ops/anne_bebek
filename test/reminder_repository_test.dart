import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/reminder_repository.dart';

void main() {
  test('Hatırlatıcılar kodlanır, sıralanır ve çözülür', () {
    final items = [
      FamilyReminder(id: 'b', title: 'Kontrol', due: DateTime(2027, 2, 2)),
      FamilyReminder(id: 'a', title: 'Aşı randevusu',
        due: DateTime(2027, 1, 1), completed: true),
    ];
    final restored = ReminderRepository.decode(ReminderRepository.encode(items));
    expect(restored.map((e) => e.id).toList(), ['a', 'b']);
    expect(restored.first.completed, isTrue);
  });

  test('Bildirim tercihi kayıttan geri yüklenir', () {
    final item = FamilyReminder(id: '123', title: 'Kontrol',
      due: DateTime(2027, 5, 20, 14, 30), notify: true);
    final restored = ReminderRepository.decode(ReminderRepository.encode([item]));
    expect(restored.single.notify, isTrue);
    expect(restored.single.due.hour, 14);
    expect(restored.single.due.minute, 30);
  });

  test('Eski kayıtlar varsayılan olarak bildirim kapalı açılır', () {
    final restored = ReminderRepository.decode(
      '[{"id":"1","title":"Aşı","due":"2027-01-01T10:00:00"}]');
    expect(restored.single.notify, isFalse);
  });

  test('Bozuk tarih kabul edilmez', () {
    expect(() => ReminderRepository.decode(
      '[{"id":"1","title":"Kontrol","due":"bozuk"}]'), throwsFormatException);
  });

  test('Tekrarlanan kimlik reddedilir', () {
    expect(() => ReminderRepository.decode(
      '[{"id":"1","title":"A","due":"2027-01-01"},'
      '{"id":"1","title":"B","due":"2027-01-02"}]'), throwsFormatException);
  });

  test('Boş liste geçerlidir', () {
    expect(ReminderRepository.decode(null), isEmpty);
    expect(ReminderRepository.decode('[]'), isEmpty);
  });
}
