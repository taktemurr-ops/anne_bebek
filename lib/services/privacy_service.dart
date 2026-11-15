import 'package:shared_preferences/shared_preferences.dart';
import 'backup_service.dart';
import 'secure_health_store.dart';

/// Removes only the app's registered local data keys.
/// This does not revoke copies already exported to the clipboard or elsewhere.
class PrivacyService {
  static Future<int> deleteLocalRecords() async {
    final prefs = await SharedPreferences.getInstance();
    var removed = 0;
    for (final key in BackupService.keys) {
      if (SecureHealthStore.keys.contains(key)) {
        final existsInSecure = (await SecureHealthStore.read(key)) != null;
        final existsInPlaintext = prefs.containsKey(key);
        if (existsInSecure || existsInPlaintext) {
          await SecureHealthStore.delete(key);
          removed++;
        }
        continue;
      }
      if (prefs.containsKey(key)) {
        final ok = await prefs.remove(key);
        if (!ok) throw StateError('Kayıt silinemedi: $key');
        removed++;
      }
    }
    return removed;
  }
}
