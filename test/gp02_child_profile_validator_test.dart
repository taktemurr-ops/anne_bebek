import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/child_profile_validator.dart';

void main() {
  group('GP-02 child profile validation', () {
    test('rejects blank and excessively long names', () {
      expect(ChildProfileValidator.validateName('  '), isNotNull);
      expect(ChildProfileValidator.validateName('a' * 61), isNotNull);
      expect(ChildProfileValidator.validateName('  Ada  '), isNull);
    });

    test('accepts exactly 60 Unicode characters', () {
      expect(ChildProfileValidator.validateName('İ' * 60), isNull);
      expect(ChildProfileValidator.validateName('İ' * 61), isNotNull);
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

    test('birth date comparison ignores time of day', () {
      final today = DateTime(2026, 11, 17, 1, 0);
      expect(
        ChildProfileValidator.validateBirthDate(
          DateTime(2026, 11, 17, 23, 59), today: today),
        isNull,
      );
      expect(
        ChildProfileValidator.validateBirthDate(
          DateTime(2026, 11, 18, 0, 0), today: today),
        isNotNull,
      );
    });

    test('rejects dates older than 18 years', () {
      final today = DateTime(2026, 11, 16);
      expect(ChildProfileValidator.validateBirthDate(DateTime(2008, 11, 15), today: today), isNotNull);
      expect(ChildProfileValidator.validateBirthDate(DateTime(2008, 11, 16), today: today), isNull);
    });
  });
}
