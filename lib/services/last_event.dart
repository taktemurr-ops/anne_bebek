// Ana ekrandaki "en son ne zaman?" özeti: hızlı kayıtlar arasında belirli bir
// türün en yeni kaydından bu yana geçen süre.

Duration? sinceLastEvent(List<Map<String, String>> events, String type, DateTime now) {
  DateTime? last;
  for (final e in events) {
    if (e['tur'] != type) continue;
    final t = DateTime.tryParse(e['zaman'] ?? '');
    if (t == null || t.isAfter(now)) continue;
    if (last == null || t.isAfter(last)) last = t;
  }
  return last == null ? null : now.difference(last);
}

/// Kısa süre metni: "45 dk", "2 sa 10 dk", "3 gün".
String shortAgo(Duration d) {
  if (d.inDays >= 1) return '${d.inDays} gün';
  if (d.inHours >= 1) return '${d.inHours} sa ${d.inMinutes % 60} dk';
  return '${d.inMinutes} dk';
}

/// Bez kaydı türleri; "İkisi" hem ıslak hem kakalı sayılır.
const diaperKinds = ['Islak', 'Kakalı', 'İkisi'];

/// Verilen gündeki ıslak ve kakalı bez sayısı (türü seçilmemiş eski kayıtlar
/// sayılmaz).
({int wet, int dirty}) diaperCounts(List<Map<String, String>> events, DateTime day) {
  var wet = 0, dirty = 0;
  for (final e in events) {
    if (e['tur'] != 'Bez değişimi') continue;
    final t = DateTime.tryParse(e['zaman'] ?? '');
    if (t == null || t.year != day.year || t.month != day.month || t.day != day.day) continue;
    switch (e['bez']) {
      case 'Islak': wet++;
      case 'Kakalı': dirty++;
      case 'İkisi': wet++; dirty++;
    }
  }
  return (wet: wet, dirty: dirty);
}

/// İlk iki ayda ıslak bez için genel beklenti (emzirme rehberleriyle uyumlu):
/// 1–4. günlerde gün sayısı kadar, 5. günden sonra en az 6. Bilgi amaçlıdır.
int? expectedWetDiapers(DateTime? birth, DateTime now) {
  if (birth == null) return null;
  final days = DateTime(now.year, now.month, now.day).difference(DateTime(birth.year, birth.month, birth.day)).inDays + 1;
  if (days < 1 || days > 60) return null;
  return days < 5 ? days : 6;
}
