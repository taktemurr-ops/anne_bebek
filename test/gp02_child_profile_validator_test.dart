import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/child_profile_validator.dart';

void main() {
  group('GP-02 child profile validation', () {
    test('rejects blank and excessively long names', () {
      expect(ChildProfileValidator.validateName('  '), isNotNull);
      expect(ChildProfileValidator.validateName('a' * 81), isNotNull);
      expect(ChildProfileValidator.validateName('  Ada  '), isNull);
    });

    test('rejects control characters', () {
      expect(ChildProfileValidator.validateName('Ada\nTest'), isNotNull);
    });

    test('rejects future and missing birth dates', () {
      final today = DateTime(2026, 11, 16);
      expect(ChildProfileValidator.validateBirthDate(null, today: today), isNotNull);
      expect(ChildProfileValidator.validateBirthDate(DateTime(2026, 11, 17), today: today), isNotNull);
      expect(ChildProfileValidator.validateBirthDate(today, today: today), isNull);
    });

    test('rejects dates older than 18 years', () {
      final today = DateTime(2026, 11, 16);
      expect(ChildProfileValidator.validateBirthDate(DateTime(2008, 11, 15), today: today), isNotNull);
      expect(ChildProfileValidator.validateBirthDate(DateTime(2008, 11, 16), today: today), isNull);
    });
  });
}
