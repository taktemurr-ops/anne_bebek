import 'reproductive_calendar_settings.dart';
import 'secure_health_store.dart';

/// GP-05: Encrypted persistence for user-entered cycle information.
class ReproductiveCalendarRepository {
  const ReproductiveCalendarRepository._();
  static const storageKey = 'reproductive_calendar_v1';

  static Future<ReproductiveCalendarSettings?> load() async =>
      decodeReproductiveSettings(await SecureHealthStore.read(storageKey));

  static Future<void> save(ReproductiveCalendarSettings settings) async {
    final encoded = encodeReproductiveSettings(settings);
    decodeReproductiveSettings(encoded);
    await SecureHealthStore.write(storageKey, encoded);
  }

  static Future<void> delete() => SecureHealthStore.delete(storageKey);
}
