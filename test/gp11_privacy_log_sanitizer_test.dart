import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/privacy_log_sanitizer.dart';

void main() {
  test('GP-11 hides common contact details and line breaks', () {
    final result = PrivacyLogSanitizer.sanitize(
      'contact@example.com\n+90 555 123 45 67');
    expect(result, contains('[email]'));
    expect(result, contains('[phone]'));
    expect(result, isNot(contains('contact@example.com')));
    expect(result, isNot(contains('\n')));
  });
  test('GP-11 caps log message length', () {
    expect(PrivacyLogSanitizer.sanitize('abcdef', maxLength: 3), 'abc');
    expect(() => PrivacyLogSanitizer.sanitize('a', maxLength: -1), throwsArgumentError);
  });
}
