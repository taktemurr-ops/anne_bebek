/// Calendar-month age; avoids treating every month as 30 days.
int completedChildMonths(DateTime birthDate, DateTime today) {
  final birth = DateTime(birthDate.year, birthDate.month, birthDate.day);
  final date = DateTime(today.year, today.month, today.day);
  if (date.isBefore(birth)) return 0;
  final months = (date.year - birth.year) * 12 + date.month - birth.month;
  return months - (date.day < birth.day ? 1 : 0);
}

String childAgeLabel(DateTime birthDate, DateTime today) {
  final months = completedChildMonths(birthDate, today);
  if (months == 0) return '0 aylık';
  if (months < 12) return '$months aylık';
  final years = months ~/ 12;
  final rest = months % 12;
  return rest == 0 ? '$years yaşında' : '$years yaş $rest aylık';
}

/// Editorial section suggestions only; not a diagnosis or a feeding plan.
List<String> childAgeTopics(int months) {
  if (months < 6) return const ['Sütle beslenme', 'Güvenli uyku', 'Gelişim ve bağ kurma'];
  if (months < 12) return const ['Ek gıdaya geçiş', 'Alerjen ve boğulma güvenliği', 'Oyun ve hareket'];
  if (months < 24) return const ['Aile sofrasına geçiş', 'Dil ve iletişim', 'Güvenli keşif'];
  if (months < 36) return const ['Dengeli öğünler', 'Oyunla öğrenme', 'Duygu ve rutinler'];
  return const ['Yaşa uygun beslenme', 'Okul öncesi etkinlikler', 'Uyku ve günlük düzen'];
}
