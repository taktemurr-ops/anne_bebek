import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/family_notification_preferences.dart';

void main() {
  test('GP-09 notifications and community are opt-in by default', () {
    final prefs = FamilyNotificationPreferences();
    expect(prefs.remindersEnabled, isFalse);
    expect(prefs.communityEnabled, isFalse);
    expect(prefs.marketingEnabled, isFalse);
  });
  test('GP-09 quiet hours wrap midnight', () {
    final prefs = FamilyNotificationPreferences();
    expect(prefs.isQuietHour(23), isTrue);
    expect(prefs.isQuietHour(3), isTrue);
    expect(prefs.isQuietHour(12), isFalse);
  });
  test('GP-09 preferences round trip and invalid hours', () {
    final original = FamilyNotificationPreferences(remindersEnabled: true,
      quietStartHour: 21, quietEndHour: 7);
    final restored = decodeNotificationPreferences(
      encodeNotificationPreferences(original));
    expect(restored?.remindersEnabled, isTrue);
    expect(restored?.quietStartHour, 21);
    expect(() => decodeNotificationPreferences(
      '{"remindersEnabled":false,"communityEnabled":false,"marketingEnabled":false,"quietStartHour":24,"quietEndHour":8}'),
      throwsFormatException);
  });
}
