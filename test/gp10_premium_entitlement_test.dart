import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/premium_entitlement.dart';

void main() {
  final now = DateTime.utc(2026, 11, 19);
  test('GP-10 unverified premium never grants access', () {
    expect(PremiumEntitlement(productId: 'premium_monthly',
      expiresAt: now.add(const Duration(days: 30))).isActive(now), isFalse);
  });
  test('GP-10 verified unexpired entitlement is active', () {
    final entitlement = PremiumEntitlement(productId: 'premium_monthly',
      verifiedByServer: true, expiresAt: now.add(const Duration(days: 30)));
    expect(entitlement.isActive(now), isTrue);
    expect(decodePremiumEntitlement(encodePremiumEntitlement(entitlement))
      ?.isActive(now), isTrue);
  });
  test('GP-10 expired entitlement is inactive', () {
    expect(PremiumEntitlement(productId: 'premium_monthly',
      verifiedByServer: true,
      expiresAt: now.subtract(const Duration(seconds: 1))).isActive(now), isFalse);
  });
  test('GP-10 invalid entitlement payload is rejected', () {
    expect(() => decodePremiumEntitlement('{"productId":"premium","verifiedByServer":true,"expiresAt":"invalid"}'),
      throwsFormatException);
  });
}
