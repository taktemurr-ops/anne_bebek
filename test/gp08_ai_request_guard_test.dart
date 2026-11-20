import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/ai_request_guard.dart';

void main() {
  test('GP-08 AI request requires explicit external processing consent', () {
    expect(AiRequestGuard.validate(prompt: 'Uyku önerisi',
      consentToExternalProcessing: false), isNotNull);
    expect(AiRequestGuard.validate(prompt: 'Uyku önerisi',
      consentToExternalProcessing: true), isNull);
  });
  test('GP-08 empty and excessive prompts are rejected', () {
    expect(AiRequestGuard.validate(prompt: ' ',
      consentToExternalProcessing: true), isNotNull);
    expect(AiRequestGuard.validate(prompt: 'a' * 2001,
      consentToExternalProcessing: true), isNotNull);
  });
  test('GP-08 contact details are masked before optional processing', () {
    final masked = AiRequestGuard.maskContactDetails(
      'E-posta: user@example.com Telefon: +90 555 123 45 67');
    expect(masked, contains('[e-posta gizlendi]'));
    expect(masked, contains('[telefon gizlendi]'));
    expect(masked, isNot(contains('user@example.com')));
  });
}
