/// GP-04: Daily routine entry validation independent of Flutter UI.
/// Durations are expressed in minutes and quantities in millilitres.
class DailyRoutineValidator {
  const DailyRoutineValidator._();

  static String? validateInterval(DateTime? start, DateTime? end,
      {DateTime? now, Duration maxDuration = const Duration(hours: 24)}) {
    if (start == null || end == null) return 'Başlangıç ve bitiş gerekli.';
    final current = now ?? DateTime.now();
    if (start.isAfter(current) || end.isAfter(current)) {
      return 'Gelecekteki zaman kaydedilemez.';
    }
    if (!end.isAfter(start)) return 'Bitiş başlangıçtan sonra olmalı.';
    if (end.difference(start) > maxDuration) return 'Süre izin verilen sınırı aşıyor.';
    return null;
  }

  static String? validateFeedingAmount(num? ml) {
    if (ml == null || !ml.isFinite || ml <= 0 || ml > 2000) {
      return 'Miktar 0 ile 2000 ml arasında olmalıdır.';
    }
    return null;
  }

  static String? validateNote(String? note, {int maxLength = 300}) {
    if (note == null || note.trim().isEmpty) return 'Not boş olamaz.';
    if (note.runes.length > maxLength) return 'Not çok uzun.';
    return null;
  }
}
