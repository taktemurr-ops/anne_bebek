import 'daily_routines.dart';
import 'secure_health_store.dart';

/// GP-04: Store routine data encrypted, without silently replacing corrupt data.
class DailyRoutineRepository {
  const DailyRoutineRepository._();
  static const storageKey = 'daily_routines_v1';

  static Future<List<DailyRoutineEntry>> load() async {
    return decodeDailyRoutines(await SecureHealthStore.read(storageKey));
  }

  static Future<void> save(List<DailyRoutineEntry> entries) async {
    // Validate all records and reject duplicates before touching persisted data.
    final encoded = encodeDailyRoutines(entries);
    decodeDailyRoutines(encoded);
    await SecureHealthStore.write(storageKey, encoded);
  }

  static Future<void> deleteAll() => SecureHealthStore.delete(storageKey);
}
