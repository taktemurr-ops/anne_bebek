/// Takvim aylarını kullanarak bebeğin yaşını hesaplar.
/// 30,44 günlük yaklaşık ay hesabı yerine gerçek ay sınırlarını esas alır.
class BabyAge {
  const BabyAge._();

  /// Tamamlanan takvim ayı sayısı. Gelecekteki doğumlarda null döner.
  /// Saat farkı yerine takvim tarihleri esas alınır.
  static int? completedMonths(DateTime? birth, DateTime today) {
    if (birth == null) return null;
    final b = DateTime.utc(birth.year, birth.month, birth.day);
    final now = DateTime.utc(today.year, today.month, today.day);
    if (b.isAfter(now)) return null;
    var months = (now.year - b.year) * 12 + now.month - b.month;
    final lastDay = DateTime.utc(now.year, now.month + 1, 0).day;
    final anniversaryDay = b.day < lastDay ? b.day : lastDay;
    if (now.day < anniversaryDay) months--;
    return months < 0 ? 0 : months;
  }

  static String label(DateTime? birth, DateTime today) {
    if (birth == null) return 'Doğum tarihi eklenmedi';
    final b = DateTime.utc(birth.year, birth.month, birth.day);
    final now = DateTime.utc(today.year, today.month, today.day);
    if (b.isAfter(now)) return 'Doğum bekleniyor';
    // UTC takvim tarihleri yaz/kis saati gecislerinde 23/25 saatlik gunleri onler.
    final days = now.difference(b).inDays;
    if (days < 30) return '$days günlük';

    final months = completedMonths(birth, today)!;
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years == 0) return '$months aylık';
    if (remainingMonths == 0) return '$years yaşında';
    return '$years yaş $remainingMonths aylık';
  }
}
