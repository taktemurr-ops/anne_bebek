import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/data/monthly_baby_guide.dart';

void main() {
  test('0–72 ayın tamamında altı kategori bulunur', () {
    for (var month = 0; month <= 72; month++) {
      final guide = babyGuideForMonth(month);
      expect(guide.month, month);
      expect(guide.sections.keys.toSet(), babyGuideCategories.toSet());
      for (final content in guide.sections.values) {
        expect(content.trim().isNotEmpty, isTrue);
      }
    }
  });
  test('Aralık dışındaki aylar güvenle sınırlandırılır', () {
    expect(babyGuideForMonth(-5).month, 0);
    expect(babyGuideForMonth(90).month, 72);
  });
  test('0–24 ay her ay kendine özgü gelişim içeriği; aşılar ilgili ayda', () {
    final devs = {for (var m = 0; m <= 24; m++) babyGuideForMonth(m).sections['Gelişim']};
    expect(devs.length, 25);
    expect(babyGuideForMonth(2).sections['Sağlık'], contains('BCG'));
    expect(babyGuideForMonth(12).sections['Sağlık'], contains('KKK'));
    expect(babyGuideForMonth(8).sections['Beslenme'], contains('lerjen'));
    expect(babyGuideForMonth(72).sections['Gelişim'], contains('5–6 yaş'));
  });
}
