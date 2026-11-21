import 'package:shared_preferences/shared_preferences.dart';
import 'backup_service.dart';
import 'secure_health_store.dart';

/// Removes only the app's registered local data keys.
/// This does not revoke copies already exported to the clipboard or elsewhere.
class PrivacyService {
  /// Yedeğe girmeyen ama kişisel veri içeren yerel kayıtlar.
  static const extraKeys = <String>[
    'cloud_auth_session_v1', 'paket39_weekly_migration_v2',
    'anne_bebek_completion_center_v1',
  ];

  static Future<int> deleteLocalRecords() async {
    final prefs = await SharedPreferences.getInstance();
    var removed = 0;
    for (final key in [...await BackupService.allKeys(), ...extraKeys]) {
      if (SecureHealthStore.isAllowed(key)) {
        await SecureHealthStore.delete(key);
        removed++;
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
