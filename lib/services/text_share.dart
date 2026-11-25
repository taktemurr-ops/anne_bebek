import 'package:share_plus/share_plus.dart';

/// Metni telefonun paylaşım menüsüyle gönderir (WhatsApp, e-posta, yazdırma…).
class TextShare {
  static Future<void> share(String text, {String? subject}) => Share.share(text, subject: subject);
}
