/// Bilgilendirme amaçlı Türkiye çocukluk dönemi aşı planı.
/// Kaynaklar: asi.saglik.gov.tr (2025 takvimi), saglik.gov.tr 14.04.2025
/// Altılı karma geçişi. Özel durumlar / yakalama şeması aile hekimince belirlenir.
class PlannedVaccine {
  final String code, title;
  final int month;
  const PlannedVaccine(this.code, this.title, this.month);
  DateTime dueDate(DateTime birth) {
    final total = birth.year * 12 + birth.month - 1 + month;
    final year = total ~/ 12;
    final targetMonth = total % 12 + 1;
    final last = DateTime(year, targetMonth + 1, 0).day;
    return DateTime(year, targetMonth, birth.day > last ? last : birth.day);
  }
}

/// Temel 2025 şeması. 2026 suçiçeği ek dozu ayrı kuralla hesaplanır.
const standardVaccines = <PlannedVaccine>[
  PlannedVaccine('hepb_birth', 'Hepatit B (doğum)', 0),
  PlannedVaccine('bcg_2', 'BCG (verem)', 2),
  PlannedVaccine('hex_2', 'Altılı karma – 1. doz', 2),
  PlannedVaccine('pcv_2', 'Pnömokok – 1. doz', 2),
  PlannedVaccine('hex_4', 'Altılı karma – 2. doz', 4),
  PlannedVaccine('pcv_4', 'Pnömokok – 2. doz', 4),
  PlannedVaccine('hex_6', 'Altılı karma – 3. doz', 6),
  PlannedVaccine('opv_6', 'Oral polio – 1. doz', 6),
  PlannedVaccine('mmr_12', 'KKK – 1. doz', 12),
  PlannedVaccine('var_12', 'Suçiçeği – 1. doz', 12),
  PlannedVaccine('pcv_12', 'Pnömokok – rapel', 12),
  PlannedVaccine('hex_18', 'Altılı karma – rapel', 18),
  PlannedVaccine('opv_18', 'Oral polio – 2. doz', 18),
  PlannedVaccine('hepa_18', 'Hepatit A – 1. doz', 18),
  PlannedVaccine('hepa_24', 'Hepatit A – 2. doz', 24),
];


/// 1 Eylül 2026 itibarıyla 48. ayda ikinci suçiçeği dozu uygulaması.
/// 49–72 aylık yakalama grubu kişiye özel değerlendirme gerektirir;
/// bu fonksiyon geçmiş tarihli dozu yapılmış gibi işaretlemez.
/// Kaynak: T.C. Sağlık Bakanlığı İskilip Devlet Hastanesi, 03.09.2026.
final secondVaricellaStart = DateTime.utc(2026, 9, 1);

List<PlannedVaccine> routineVaccinesForBirth(DateTime birth) {
  final vaccines = <PlannedVaccine>[...standardVaccines];
  const second = PlannedVaccine('var_48', 'Suçiçeği – 2. doz', 48);
  final dueDate = second.dueDate(birth);
  if (!dueDate.isBefore(secondVaricellaStart)) {
    vaccines.add(second);
  }
  return List<PlannedVaccine>.unmodifiable(vaccines);
}

/// 2026 güncellemesinde 49–72 ay yakalama grubuna giren çocuklar.
/// Gerçek aşı gereksinimi aile hekimi tarafından belirlenmelidir.
bool mayNeedVaricellaCatchup(DateTime birth, DateTime today) {
  final day = DateTime(today.year, today.month, today.day);
  if (day.isBefore(DateTime(2026, 9, 1))) return false;
  final month = (day.year - birth.year) * 12 + day.month - birth.month - (day.day < birth.day ? 1 : 0);
  return month >= 49 && month <= 72;
}

/// Bugünden itibaren en yakın planlı aşı günü ve o gün planlanan aşılar.
/// [withinDays] içinde değilse null (ana ekranı gereksiz kalabalıklaştırmamak için).
({DateTime date, List<PlannedVaccine> vaccines})? nextVaccineVisit(DateTime birth, DateTime now, {int withinDays = 60}) {
  final today = DateTime(now.year, now.month, now.day);
  DateTime? best;
  for (final v in routineVaccinesForBirth(birth)) {
    final d = v.dueDate(birth);
    if (d.isBefore(today)) continue;
    if (best == null || d.isBefore(best)) best = d;
  }
  if (best == null || best.difference(today).inDays > withinDays) return null;
  final date = best;
  return (date: date, vaccines: routineVaccinesForBirth(birth).where((v) => v.dueDate(birth) == date).toList());
}
