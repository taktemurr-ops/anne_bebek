import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/child_profile_validator.dart';

void main() {
  group('GP-02 child profile validation', () {
    test('accepts only supported growth reference values', () {
      for (final value in ['unknown', 'female', 'male']) {
        expect(ChildProfileValidator.validateSex(value), isNull);
      }
      expect(ChildProfileValidator.validateSex(null), isNotNull);
      expect(ChildProfileValidator.validateSex('other'), isNotNull);
      expect(ChildProfileValidator.validateSex('MALE'), isNotNull);
    });

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

    test('rejects C1 controls and bidi overrides in profile names', () {
      expect(ChildProfileValidator.validateName('Ada\u0085Test'), isNotNull);
      expect(ChildProfileValidator.validateName('Ada\u202eTest'), isNotNull);
      expect(ChildProfileValidator.validateName('Ada\u2066Test'), isNotNull);
      expect(ChildProfileValidator.validateName('Çağla'), isNull);
    });

    test('rejects invisible Unicode formatting in child names', () {
      for (final codePoint in [0x00AD, 0x061C, 0x180E, 0x200B, 0x200C, 0x200D, 0x200E, 0x200F, 0x2028, 0x2029, 0x2060, 0x2061, 0x2062, 0x2063, 0x2064, 0xFEFF]) {
        final invisible = String.fromCharCode(codePoint);
        expect(
          ChildProfileValidator.validateName('Ada${invisible}Test'),
          isNotNull,
          reason: 'U+${codePoint.toRadixString(16)} should be rejected',
        );
      }
      expect(ChildProfileValidator.validateName('İpek Çağla'), isNull);
    });

    test('rejects invisible Unicode tag and filler code points', () {
      for (final codePoint in [0x034F, 0x115F, 0x1160, 0xE0001, 0xE0020, 0xE007F]) {
        expect(
          ChildProfileValidator.validateName(
            'Ada${String.fromCharCode(codePoint)}Naz'),
          isNotNull,
          reason: 'U+${codePoint.toRadixString(16)} must be rejected',
        );
      }
      expect(ChildProfileValidator.validateName('Ada Naz'), isNull);
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

    test('birth chronology compares calendar days, not times', () {
      final birth = DateTime(2026, 11, 17, 23, 59);
      expect(
        ChildProfileValidator.hasRecordsBeforeBirth(
          birth, [DateTime(2026, 11, 17, 0, 1)]),
        isFalse,
      );
      expect(
        ChildProfileValidator.hasRecordsBeforeBirth(
          birth, [DateTime(2026, 11, 16, 23, 59)]),
        isTrue,
      );
      expect(
        ChildProfileValidator.hasRecordsBeforeBirth(birth, []),
        isFalse,
      );
    });

    test('birth chronology checks every record and ignores later records', () {
      final birth = DateTime(2026, 11, 17);
      expect(
        ChildProfileValidator.hasRecordsBeforeBirth(birth, [
          DateTime(2026, 11, 19),
          DateTime(2026, 11, 16),
          DateTime(2026, 11, 18),
        ]),
        isTrue,
      );
      expect(
        ChildProfileValidator.hasRecordsBeforeBirth(birth, [
          DateTime(2026, 11, 17),
          DateTime(2026, 11, 18),
        ]),
        isFalse,
      );
    });

    test('rejects dates older than 18 years', () {
      final today = DateTime(2026, 11, 16);
      expect(ChildProfileValidator.validateBirthDate(DateTime(2008, 11, 15), today: today), isNotNull);
      expect(ChildProfileValidator.validateBirthDate(DateTime(2008, 11, 16), today: today), isNull);
    });
    test('birth chronology handles leap days and mixed time zones', () {
      final birth = DateTime.utc(2024, 2, 29, 23, 59);
      expect(
        ChildProfileValidator.hasRecordsBeforeBirth(
          birth, [DateTime(2024, 2, 29, 0, 1)]),
        isFalse,
      );
      expect(
        ChildProfileValidator.hasRecordsBeforeBirth(
          birth, [DateTime.utc(2024, 2, 28, 23, 59)]),
        isTrue,
      );
      expect(
        ChildProfileValidator.hasRecordsBeforeBirth(
          birth, [DateTime.utc(2024, 3, 1)]),
        isFalse,
      );
    });

    test('18-year cutoff respects leap-year calendar normalization', () {
      final today = DateTime(2024, 2, 29);
      expect(
        ChildProfileValidator.validateBirthDate(
          DateTime(2006, 3, 1), today: today),
        isNull,
      );
      expect(
        ChildProfileValidator.validateBirthDate(
          DateTime(2006, 2, 27), today: today),
        isNotNull,
      );
    });

    test('birth-date validation accepts today regardless of clock time', () {
      final today = DateTime(2026, 11, 17, 0, 1);
      expect(
        ChildProfileValidator.validateBirthDate(
          DateTime(2026, 11, 17, 23, 59), today: today),
        isNull,
      );
      expect(
        ChildProfileValidator.validateBirthDate(
          DateTime(2026, 11, 18), today: today),
        isNotNull,
      );
    });

    test('profile names reject directional isolates without rejecting Turkish', () {
      for (final codePoint in [0x202A, 0x202B, 0x202C, 0x202D, 0x202E, 0x2066, 0x2067, 0x2068, 0x2069]) {
        expect(
          ChildProfileValidator.validateName(
            'Ayşe${String.fromCharCode(codePoint)}Naz'),
          isNotNull,
          reason: 'U+${codePoint.toRadixString(16)} must be rejected',
        );
      }
      expect(ChildProfileValidator.validateName('Ayşe Naz'), isNull);
    });

  });
}
