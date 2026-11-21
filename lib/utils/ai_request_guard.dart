/// Consent and minimal contact redaction for explicit AI requests.
/// This is NOT complete anonymisation: users should avoid sharing sensitive data.
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

  static String maskContactDetails(String text) {
    final emails = RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}');
    final phones = RegExp(r'\+?\d[\d\s()\-]{8,}\d');
    return text.replaceAll(emails, '[e-posta gizlendi]')
      .replaceAll(phones, '[telefon gizlendi]');
  }
}
