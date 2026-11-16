/// Takvim aylarını kullanarak bebeğin yaşını hesaplar.
/// 30,44 günlük yaklaşık ay hesabı yerine gerçek ay sınırlarını esas alır.
class BabyAge {
  const BabyAge._();

  static String label(DateTime? birth, DateTime today) {
    if (birth == null) return 'Doğum tarihi eklenmedi';
    final b = DateTime(birth.year, birth.month, birth.day);
    final now = DateTime(today.year, today.month, today.day);
    if (b.isAfter(now)) return 'Doğum bekleniyor';
    // UTC takvim tarihleri yaz/kis saati gecislerinde 23/25 saatlik gunleri onler.
    final days = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(b.year, b.month, b.day))
        .inDays;
    if (days < 30) return '$days günlük';

    var months = (now.year - b.year) * 12 + now.month - b.month;
    // Ayın son gününde doğan bebekler için kısa aylarda ay dönümünü koru.
    final lastDayOfCurrentMonth = DateTime(now.year, now.month + 1, 0).day;
    final anniversaryDay = b.day < lastDayOfCurrentMonth
        ? b.day
        : lastDayOfCurrentMonth;
    if (now.day < anniversaryDay) months--;
    if (months < 0) months = 0;
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years == 0) return '$months aylık';
    if (remainingMonths == 0) return '$years yaşında';
    return '$years yaş $remainingMonths aylık';
  }
}
