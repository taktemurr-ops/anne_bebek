import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_profiles.dart';

void main() {
  group('GP-02 profile persistence safety', () {
    test('round trip preserves multiple profiles and growth references', () {
      final original = [
        ChildProfile(id: 'child-a', name: 'Çağla', birthDate: DateTime.utc(2024, 2, 29), sex: 'female'),
        ChildProfile(id: 'child-b', name: 'İpek', birthDate: DateTime(2025, 8, 26), sex: 'unknown'),
      ];
      final restored = decodeChildProfiles(encodeChildProfiles(original));
      expect(restored.map((p) => p.id).toList(), ['child-a', 'child-b']);
      expect(restored.map((p) => p.name).toList(), ['Çağla', 'İpek']);
      expect(restored.first.birthDate, original.first.birthDate);
      expect(restored.last.birthDate, original.last.birthDate);
      expect(restored.map((p) => p.sex).toList(), ['female', 'unknown']);
    });

    test('rejects duplicate identifiers rather than silently losing data', () {
      final duplicate = [
        ChildProfile(id: 'same', name: 'Ada', birthDate: DateTime(2025, 1, 1)),
        ChildProfile(id: 'same', name: 'Ece', birthDate: DateTime(2025, 2, 1)),
      ];
      expect(() => decodeChildProfiles(encodeChildProfiles(duplicate)), throwsFormatException);
    });

    test('malformed stored data fails closed without returning a partial list', () {
      expect(() => decodeChildProfiles('[{"id":"ok","name":"Ada","birthDate":"2025-01-01"}, {"id":"broken"}]'), throwsFormatException);
      expect(() => decodeChildProfiles('{"id":"not-a-list"}'), throwsFormatException);
    });

    test('legacy missing and unknown sex values use safe unknown reference', () {
      final legacy = decodeChildProfiles('[{"id":"old","name":"Ada","birthDate":"2025-01-01"}]');
      expect(legacy.single.sex, 'unknown');
      final unexpected = decodeChildProfiles('[{"id":"old","name":"Ada","birthDate":"2025-01-01","sex":"unsupported"}]');
      expect(unexpected.single.sex, 'unknown');
    });
  });
}
