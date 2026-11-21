/// GP-11: Safe text handling for local display and logging.
class PrivacyLogSanitizer {
  const PrivacyLogSanitizer._();

  static String sanitize(String input, {int maxLength = 200}) {
    final email = RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
    final phone = RegExp(r'\+?\d[\d\s()\-]{8,}\d');
    final cleaned = input.replaceAll(email, '[email]')
      .replaceAll(phone, '[phone]')
      .replaceAll(RegExp(r'[\r\n\t]+'), ' ');
    if (maxLength < 0) throw ArgumentError.value(maxLength, 'maxLength');
    return cleaned.runes.take(maxLength).map(String.fromCharCode).join();
  }
}

/// GP-11: Hata günlüğü. `debugPrint` yayın sürümünde de sistem günlüğüne
/// (logcat) yazar ve hata mesajları (ör. bozuk JSON) kayıt içeriğini
/// taşıyabilir. Yayın sürümünde hiçbir şey yazılmaz; geliştirmede mesaj
/// kısaltılır ve iletişim bilgileri maskelenir.
void logSafeError(String where, Object error, {bool releaseMode = const bool.fromEnvironment('dart.vm.product')}) {
  if (releaseMode) return;
  // ignore: avoid_print
  print('$where: ${error.runtimeType} ${PrivacyLogSanitizer.sanitize('$error', maxLength: 120)}');
}
