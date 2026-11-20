import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/utils/ai_request_guard.dart';
import 'package:anne_bebek/utils/release_readiness.dart';
import 'package:anne_bebek/services/premium_entitlement.dart';

void main() {
  test('AI requests require explicit consent', () {
    expect(AiRequestGuard.validate(prompt: 'Merhaba',
      consentToExternalProcessing: false), isNotNull);
    expect(AiRequestGuard.validate(prompt: 'Merhaba',
      consentToExternalProcessing: true), isNull);
    expect(AiRequestGuard.validate(prompt: '  ',
      consentToExternalProcessing: true), isNotNull);
  });

  test('Contact details are masked before external AI processing', () {
    final masked = AiRequestGuard.maskContactDetails(
      'Mail: test@example.com Tel: +90 555 123 45 67');
    expect(masked, isNot(contains('test@example.com')));
    expect(masked, isNot(contains('555 123')));
  });

  test('Release defaults to blocked until every gate is verified', () {
    const release = ReleaseReadiness();
    expect(release.isReady, isFalse);
    expect(release.missingGates, contains('iOS cihaz testleri'));
  });

  test('Unverified premium cannot unlock paid features', () {
    final unverified = PremiumEntitlement.fromJson({
      'productId': 'premium_monthly', 'verifiedByServer': false,
      'expiresAt': null,
    });
    expect(unverified.isActive(DateTime.utc(2026, 11, 21)), isFalse);
    expect(() => decodePremiumEntitlement('[]'), throwsFormatException);
  });
}
