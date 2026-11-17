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
    if (normalized.runes.any((rune) =>
        rune < 32 ||
        (rune >= 127 && rune <= 159) ||
        rune == 0x00AD || // soft hyphen: görünmez biçimlendirme
        rune == 0x061C || // Arabic letter mark: metin yönü kontrolü
        rune == 0x180E || // Mongolian vowel separator
        (rune >= 0x200B && rune <= 0x200F) ||
        (rune >= 0x2060 && rune <= 0x2064) || // invisible word joiner / operators
        rune == 0x2028 || rune == 0x2029 || // Unicode line/paragraph separators
        rune == 0xFEFF ||
        (rune >= 0x202A && rune <= 0x202E) ||
        (rune >= 0x2066 && rune <= 0x2069))) {
      return 'Çocuk adı kontrol karakterleri içeremez.';
    }
    return null;
  }

  /// Prevent a birth-date change that would place existing records before birth.
  /// Compare calendar days rather than timestamps; records on the birth day
  /// remain valid even when their time is earlier than the selected date's time.
  static bool hasRecordsBeforeBirth(
    DateTime birthDate,
    Iterable<DateTime> recordDates,
  ) {
    final birthDay = DateTime.utc(birthDate.year, birthDate.month, birthDate.day);
    return recordDates.any((recordDate) {
      final recordDay = DateTime.utc(
        recordDate.year, recordDate.month, recordDate.day);
      return recordDay.isBefore(birthDay);
    });
  }

  static const supportedSexValues = {'unknown', 'female', 'male'};

  static String? validateSex(String? value) {
    if (value == null || !supportedSexValues.contains(value)) {
      return 'Geçerli bir büyüme referansı seçilmelidir.';
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
