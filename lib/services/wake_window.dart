// Uyanıklık penceresi: bebeğin iki uyku arasında rahatça uyanık kalabildiği
// yaklaşık süre. Aralıklar uyku danışmanlığında yaygın kullanılan genel
// değerlerdir; tıbbi ölçüt değildir, her bebek farklıdır.

class WakeWindow {
  final int minMinutes;
  final int maxMinutes;
  const WakeWindow(this.minMinutes, this.maxMinutes);
}

/// Aya göre tipik uyanıklık aralığı (dakika).
WakeWindow wakeWindowForAge(int ageMonths) {
  if (ageMonths < 1) return const WakeWindow(35, 60);
  if (ageMonths < 3) return const WakeWindow(60, 90);
  if (ageMonths < 5) return const WakeWindow(75, 120);
  if (ageMonths < 8) return const WakeWindow(120, 180);
  if (ageMonths < 11) return const WakeWindow(150, 210);
  if (ageMonths < 15) return const WakeWindow(180, 240);
  if (ageMonths < 24) return const WakeWindow(240, 360);
  return const WakeWindow(300, 390);
}

enum WakeStatus { early, inWindow, late }

class NapSuggestion {
  final DateTime lastWake;
  final DateTime from;
  final DateTime to;
  final WakeStatus status;
  final Duration awake;
  const NapSuggestion(this.lastWake, this.from, this.to, this.status, this.awake);
}

int ageInMonths(DateTime birth, DateTime now) {
  var m = (now.year - birth.year) * 12 + now.month - birth.month;
  if (now.day < birth.day) m--;
  return m < 0 ? 0 : m;
}

/// Son uyku kaydının bitişine göre sıradaki uyku için önerilen aralık.
/// Kayıt yoksa, son uyanış gelecekteyse ya da 12 saatten eskiyse null döner
/// (eski kayıt güncel durumu yansıtmaz).
NapSuggestion? nextNapSuggestion(List<Map<String, dynamic>> records, DateTime birth, DateTime now) {
  DateTime? lastWake;
  for (final r in records) {
    final end = DateTime.tryParse('${r['end']}');
    if (end == null || end.isAfter(now)) continue;
    if (lastWake == null || end.isAfter(lastWake)) lastWake = end;
  }
  if (lastWake == null) return null;
  final awake = now.difference(lastWake);
  if (awake > const Duration(hours: 12)) return null;
  final w = wakeWindowForAge(ageInMonths(birth, now));
  final from = lastWake.add(Duration(minutes: w.minMinutes));
  final to = lastWake.add(Duration(minutes: w.maxMinutes));
  final status = now.isBefore(from)
      ? WakeStatus.early
      : (now.isAfter(to) ? WakeStatus.late : WakeStatus.inWindow);
  return NapSuggestion(lastWake, from, to, status, awake);
}

/// Yorgunluk belirtileri; uyanıklık penceresinden daha güvenilir bir işarettir.
const sleepyCues = [
  'Esneme',
  'Gözlerini ya da kulaklarını ovuşturma',
  'Boş bakma, ilgisini kaybetme',
  'Huysuzlanma, mızmızlanma',
  'Kollarını ve bacaklarını sarsak hareket ettirme',
];
