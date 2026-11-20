import 'family_notification_preferences.dart';
import 'secure_health_store.dart';

/// GP-09: Encrypted, local-first notification preference persistence.
class FamilyNotificationRepository {
  const FamilyNotificationRepository._();
  static const storageKey = 'family_notification_preferences_v1';

  static Future<FamilyNotificationPreferences> load() async =>
      decodeNotificationPreferences(await SecureHealthStore.read(storageKey)) ??
      const FamilyNotificationPreferences();

  static Future<void> save(FamilyNotificationPreferences preferences) async {
    final encoded = encodeNotificationPreferences(preferences);
    decodeNotificationPreferences(encoded);
    await SecureHealthStore.write(storageKey, encoded);
  }

  static Future<void> clear() => SecureHealthStore.delete(storageKey);
}
