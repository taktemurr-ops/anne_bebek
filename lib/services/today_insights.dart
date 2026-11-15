/// Kayıt temelli özetler; tıbbi değerlendirme değildir.
class TodayInsights {
  static DateTime? parse(String? value) => DateTime.tryParse(value ?? '');
  static bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  static int countToday(List<Map<String, String>> events, String type, DateTime now) =>
      events.where((e) { final date = parse(e['zaman']); return e['tur'] == type && date != null && sameDay(date, now); }).length;
  static int countLastDays(List<Map<String, String>> events, String type, DateTime now, int days) {
    final end = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
    return events.where((e) { final date = parse(e['zaman']); return e['tur'] == type && date != null && !date.isBefore(start) && date.isBefore(end); }).length;
  }
  static Map<String, String>? latestMeasurement(List<Map<String, String>> measurements) {
    final valid = measurements.where((e) => parse(e['tarih']) != null).toList();
    if (valid.isEmpty) return null;
    valid.sort((a,b) => parse(b['tarih'])!.compareTo(parse(a['tarih'])!));
    return valid.first;
  }
  static String report({required String babyName, required DateTime? birth, required List<Map<String, String>> events, required List<Map<String, String>> measurements, required DateTime now}) {
    final last = latestMeasurement(measurements);
    final lines = <String>['ANNE & BEBEK – DOKTOR GÖRÜŞMESİ KAYIT ÖZETİ', 'Hazırlanma: ${now.day}.${now.month}.${now.year}', 'Bebek: ${babyName.trim().isEmpty ? "Belirtilmedi" : babyName.trim()}', 'Doğum tarihi: ${birth == null ? "Belirtilmedi" : "${birth.day}.${birth.month}.${birth.year}"}', '', 'Son 7 gün (uygulamaya girilen kayıt sayıları):'];
    for (final type in ['Beslenme','Uyku']) { lines.add('$type: ${countLastDays(events, type, now, 7)}'); }
    lines.add('Son ölçüm: ${last == null ? "Kayıt yok" : "Boy ${last['boy'] ?? '-'} cm, kilo ${last['kilo'] ?? '-'} kg, baş çevresi ${last['basCevresi'] ?? '-'} cm"}');
    lines.add('Not: Bu özet yalnızca kullanıcının girdiği kayıtları içerir; tanı veya klinik değerlendirme değildir.');
    return lines.join('\n');
  }
}
