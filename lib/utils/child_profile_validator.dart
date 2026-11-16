/// GP-02: Çocuk profili için platformdan bağımsız alan doğrulaması.
/// Bu katman veriyi kaydetmez veya mevcut profilleri değiştirmez.
class ChildProfileValidator {
  const ChildProfileValidator._();

  static const int maxNameLength = 60;

  static String? validateName(String? name) {
    final normalized = name?.trim() ?? '';
    if (normalized.isEmpty) return 'Çocuk adı boş bırakılamaz.';
    if (normalized.runes.length > maxNameLength) {
      return 'Çocuk adı en fazla $maxNameLength karakter olabilir.';
    }
    if (normalized.runes.any((rune) => rune < 32 || rune == 127)) {
      return 'Çocuk adı kontrol karakterleri içeremez.';
    }
    return null;
  }

  static String? validateBirthDate(DateTime? birthDate, {DateTime? today}) {
    if (birthDate == null) return 'Doğum tarihi seçilmelidir.';
    final now = today ?? DateTime.now();
    final date = DateTime(birthDate.year, birthDate.month, birthDate.day);
    final current = DateTime(now.year, now.month, now.day);
    if (date.isAfter(current)) return 'Doğum tarihi gelecekte olamaz.';
    if (date.isBefore(DateTime(current.year - 18, current.month, current.day))) {
      return 'Çocuk profili için yaş sınırı 18 yıldır.';
    }
    return null;
  }
}
