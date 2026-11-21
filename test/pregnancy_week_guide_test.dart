import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/pregnancy_week_guide.dart';

void main() {
  test('forty weeks have nonempty guide sections', () {
    for (var week = 1; week <= 40; week++) {
      final guide = pregnancyGuideForWeek(week);
      expect(guide.week, week);
      expect(guide.development.trim(), isNotEmpty);
      expect(guide.maternalChanges.trim(), isNotEmpty);
      expect(guide.preparation.trim(), isNotEmpty);
      expect(guide.safety.trim(), isNotEmpty);
    }
  });
  test('her hafta kendine özgü içerik ve 4. haftadan itibaren boyut bilgisi', () {
    final developments = {for (var w = 1; w <= 40; w++) pregnancyGuideForWeek(w).development};
    expect(developments.length, 40);
    for (var w = 4; w <= 40; w++) {
      final g = pregnancyGuideForWeek(w);
      expect(g.sizeLabel, isNotEmpty, reason: '$w');
      expect(g.measure, contains('yaklaşık'), reason: '$w');
    }
    expect(pregnancyGuideForWeek(13).trimester, 1);
    expect(pregnancyGuideForWeek(14).trimester, 2);
    expect(pregnancyGuideForWeek(28).trimester, 3);
  });
  test('outside supported weeks rejected', () {
    expect(() => pregnancyGuideForWeek(0), throwsRangeError);
    expect(() => pregnancyGuideForWeek(41), throwsRangeError);
  });
}
