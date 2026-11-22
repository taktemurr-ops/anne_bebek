import 'package:url_launcher/url_launcher.dart';

/// Web bağlantılarını telefonun tarayıcısında ya da ilgili uygulamada açar.
class LinkLauncher {
  static Future<bool> open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
