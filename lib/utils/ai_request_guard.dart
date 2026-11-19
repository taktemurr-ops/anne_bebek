/// GP-08: Explicit consent and redaction for optional AI requests.
/// Never send sensitive baby or family records by default.
class AiRequestGuard {
  const AiRequestGuard._();

  static String? validate({required String prompt,
    required bool consentToExternalProcessing, int maxCharacters = 2000}) {
    if (!consentToExternalProcessing) {
      return 'Harici yapay zekâ işlemesi için açık onay gerekli.';
    }
    if (prompt.trim().isEmpty) return 'Soru boş olamaz.';
    if (prompt.runes.length > maxCharacters) return 'Soru çok uzun.';
    return null;
  }

  /// Minimal best-effort masking. It is NOT a guarantee of anonymization;
  /// requests still require explicit consent and a privacy review.
  static String maskContactDetails(String text) {
    final emails = RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
    final phones = RegExp(r'\+?\d[\d\s()\-]{8,}\d');
    return text.replaceAll(emails, '[e-posta gizlendi]')
        .replaceAll(phones, '[telefon gizlendi]');
  }
}
