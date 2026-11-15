import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/data/baby_care_guidance.dart';

void main() {
  test('Sekiz bakım başlığı açıklamalar içerir', () {
    expect(babyCareGuidance.length, 8);
    for (final entry in babyCareGuidance.entries) {
      expect(entry.value.length, greaterThanOrEqualTo(4));
      expect(entry.value.every((text) => text.trim().length > 25), isTrue);
    }
  });
}
