import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_profiles.dart';

void main() {
  test('profile serialization round trip', () {
    final original = [ChildProfile(id: 'a', name: 'Ada', birthDate: DateTime(2025, 4, 1))];
    final restored = decodeChildProfiles(encodeChildProfiles(original));
    expect(restored.single.name, 'Ada');
    expect(restored.single.birthDate.year, 2025);
  });
  test('malformed profile data fails closed', () {
    expect(() => decodeChildProfiles('{'), throwsFormatException);
    expect(() => decodeChildProfiles('[{"id":"x","name":"","birthDate":"2025-01-01"}]'), throwsFormatException);
  });
  test('duplicate ids rejected', () {
    final one = ChildProfile(id: 'x', name: 'Ali', birthDate: DateTime(2024));
    expect(() => decodeChildProfiles(encodeChildProfiles([one, one])), throwsFormatException);
  });
}
