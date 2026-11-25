import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/subscription_service.dart';
import 'package:anne_bebek/services/family_notification_preferences.dart';

void main() {
  final now = DateTime.utc(2026, 11, 21);

  test('GP10 rejects missing expiry for paid tiers', () {
    final status = SubscriptionStatus.fromServerPayload({
      'tier': 'premium', 'active': true, 'expires_at': null,
    }, now);
    expect(status.isPremium, isFalse);
    expect(status.tier, 'free');
  });

  test('GP10 accepts valid non-expired server paid entitlement', () {
    final status = SubscriptionStatus.fromServerPayload({
      'tier': 'family', 'active': true,
      'expires_at': '2026-12-21T00:00:00Z',
    }, now);
    expect(status.isPremium, isTrue);
    expect(status.isFamily, isTrue);
  });

  test('GP10 rejects expired, inactive and unknown paid tiers', () {
    for (final payload in [
      {'tier': 'premium', 'active': true, 'expires_at': '2026-11-20T00:00:00Z'},
      {'tier': 'premium', 'active': false, 'expires_at': '2026-12-21T00:00:00Z'},
      {'tier': 'enterprise', 'active': true, 'expires_at': '2026-12-21T00:00:00Z'},
    ]) {
      expect(SubscriptionStatus.fromServerPayload(payload, now).isPremium, isFalse);
    }
  });

  test('GP10 malformed payload fails closed', () {
    expect(() => SubscriptionStatus.fromServerPayload({
      'tier': 'premium', 'active': 'true',
      'expires_at': '2026-12-21T00:00:00Z',
    }, now), throwsFormatException);
    expect(() => SubscriptionStatus.fromServerPayload({
      'tier': 'premium', 'active': true,
      'expires_at': 'invalid',
    }, now), throwsFormatException);
  });

  test('GP09 notification opt-in defaults to off', () {
    const preferences = FamilyNotificationPreferences();
    expect(preferences.remindersEnabled, isFalse);
    expect(preferences.communityEnabled, isFalse);
    expect(preferences.marketingEnabled, isFalse);
  });

  test('GP09 overnight quiet hours wrap midnight', () {
    const preferences = FamilyNotificationPreferences(
      remindersEnabled: true, quietStartHour: 22, quietEndHour: 8);
    expect(preferences.isQuietHour(23), isTrue);
    expect(preferences.isQuietHour(3), isTrue);
    expect(preferences.isQuietHour(8), isFalse);
    expect(preferences.isQuietHour(16), isFalse);
  });
}
