/// GP-11: Safe text handling for local display and logging.
class PrivacyLogSanitizer {
  const PrivacyLogSanitizer._();

  static String sanitize(String input, {int maxLength = 200}) {
    final email = RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}');
    final phone = RegExp(r'\\+?\\d[\\d\\s()\\-]{8,}\\d');
    final cleaned = input.replaceAll(email, '[email]')
      .replaceAll(phone, '[phone]')
      .replaceAll(RegExp(r'[\\r\\n\\t]+'), ' ');
    if (maxLength < 0) throw ArgumentError.value(maxLength, 'maxLength');
    return cleaned.runes.take(maxLength).map(String.fromCharCode).join();
  }
}
