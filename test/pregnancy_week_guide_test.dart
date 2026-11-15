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
  test('outside supported weeks rejected', () {
    expect(() => pregnancyGuideForWeek(0), throwsRangeError);
    expect(() => pregnancyGuideForWeek(41), throwsRangeError);
  });
}
