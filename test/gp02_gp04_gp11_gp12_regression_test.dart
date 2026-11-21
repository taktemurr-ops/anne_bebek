import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/privacy_log_sanitizer.dart';
import 'package:anne_bebek/utils/release_readiness.dart';
import 'package:anne_bebek/services/child_profiles.dart';
import 'package:anne_bebek/services/daily_routines.dart';

void main() {
  test('GP11 logs redact contact data and strip line breaks', () {
    final value = PrivacyLogSanitizer.sanitize(
      'test@example.com\n+90 555 123 45 67\tmerhaba');
    expect(value, isNot(contains('test@example.com')));
    expect(value, isNot(contains('555 123')));
    expect(value, isNot(contains('\n')));
    expect(value, isNot(contains('\t')));
  });

  test('GP11 sanitizer enforces maximum length', () {
    expect(PrivacyLogSanitizer.sanitize('abcdef', maxLength: 3), 'abc');
    expect(() => PrivacyLogSanitizer.sanitize('a', maxLength: -1),
      throwsArgumentError);
  });

  test('GP12 release stays blocked when one gate is missing', () {
    const gates = ReleaseReadiness(
      flutterAnalyzePassed: true,
      unitTestsPassed: true,
      androidBuildPassed: true,
      androidDeviceTestsPassed: true,
      iosBuildPassed: true,
      iosDeviceTestsPassed: false,
      privacyReviewPassed: true,
      storeMetadataReady: true,
      signingConfigured: true,
    );
    expect(gates.isReady, isFalse);
    expect(gates.missingGates, ['iOS cihaz testleri']);
  });

  test('GP02 profile identifiers remain stable across serialization', () {
    final profile = ChildProfile(
      id: 'child-001', name: 'Test',
      birthDate: DateTime.utc(2025, 8, 26));
    final decoded = decodeChildProfiles(encodeChildProfiles([profile]));
    expect(decoded.single.id, 'child-001');
    expect(decoded.single.name, 'Test');
  });

  test('GP04 daily routines reject invalid child data', () {
    expect(() => DailyRoutineEntry.fromJson({
      'id': 'r1', 'childId': '', 'kind': 'feeding',
      'startedAt': '2026-11-21T10:00:00.000Z',
      'amountMl': 100.0, 'note': '',
    }), throwsFormatException);
  });
}
