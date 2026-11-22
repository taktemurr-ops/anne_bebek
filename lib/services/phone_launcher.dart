import 'package:url_launcher/url_launcher.dart';

/// Acil numaraları telefonun arama ekranında açar (arama kullanıcı onayıyla başlar).
class PhoneLauncher {
  static Future<bool> call(String number) async {
    final clean = number.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) return false;
    return launchUrl(Uri(scheme: 'tel', path: clean));
  }
}
