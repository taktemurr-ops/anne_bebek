import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/activity_plan.dart';

void main() {
  test('etkinlik JSON dönüşümünde alanlar korunur', () {
    final item = ActivityPlan(id: 'a', title: 'Kitap oku', category: 'Kitap', day: DateTime(2026, 11, 1));
    final restored = ActivityPlan.fromJson(item.toJson());
    expect(restored.title, 'Kitap oku');
    expect(restored.category, 'Kitap');
    expect(restored.done, false);
    expect(restored.copyWith(done: true).done, true);
  });
  test('tarih karşılaştırması saati dikkate almaz', () {
    expect(sameActivityDay(DateTime(2026, 11, 1, 9), DateTime(2026, 11, 1, 21)), true);
    expect(sameActivityDay(DateTime(2026, 11, 1), DateTime(2026, 11, 2)), false);
  });
  test('boş etkinlik reddedilir', () {
    expect(() => ActivityPlan.fromJson({'id': 'a', 'title': ' ', 'category': 'Oyun', 'day': '2026-11-01'}), throwsFormatException);
  });
}
