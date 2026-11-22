// Tuvalet eğitimi: hazır olma belirtileri, günlük başarı/kaza kaydı.
// Çoğu çocuk 18–36 ay arasında hazır olur; gece kuruluğu daha geç gelir.

const pottyReadinessSigns = <String>[
  'En az 2 saat bezi kuru kalabiliyor',
  'Bezi kirlenince rahatsız oluyor ya da söylüyor',
  'Çişi veya kakası geldiğini sözle ya da hareketle belli ediyor',
  'Basit yönergeleri izleyebiliyor',
  'Pantolonunu indirip çekmeye çalışıyor',
  'Tuvalete ya da lazımlığa ilgi gösteriyor',
  'Kakası her gün benzer saatlerde geliyor',
];

class PottyDay {
  final DateTime day;
  final int pee, poo, accidents;
  const PottyDay(this.day, {this.pee = 0, this.poo = 0, this.accidents = 0});
  int get successes => pee + poo;

  Map<String, dynamic> toJson() => {'day': day.toIso8601String(), 'pee': pee, 'poo': poo, 'accidents': accidents};

  static PottyDay? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final d = DateTime.tryParse('${raw['day']}');
    if (d == null) return null;
    int n(Object? v) => v is int && v >= 0 && v < 100 ? v : 0;
    return PottyDay(DateTime(d.year, d.month, d.day), pee: n(raw['pee']), poo: n(raw['poo']), accidents: n(raw['accidents']));
  }

  PottyDay add({int pee = 0, int poo = 0, int accidents = 0}) => PottyDay(day,
      pee: (this.pee + pee).clamp(0, 99), poo: (this.poo + poo).clamp(0, 99), accidents: (this.accidents + accidents).clamp(0, 99));
}

List<PottyDay> decodePottyDays(Object? raw) {
  if (raw is! List) return [];
  final m = <DateTime, PottyDay>{};
  for (final e in raw) {
    final d = PottyDay.fromJson(e);
    if (d != null) m[d.day] = d;
  }
  return m.values.toList()..sort((a, b) => a.day.compareTo(b.day));
}

/// Son 7 günün başarı yüzdesi (kayıt yoksa null).
int? weeklySuccessRate(List<PottyDay> days, DateTime now) {
  final from = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  final w = days.where((d) => !d.day.isBefore(from));
  final s = w.fold(0, (a, d) => a + d.successes);
  final total = s + w.fold(0, (a, d) => a + d.accidents);
  return total == 0 ? null : (s * 100 / total).round();
}

const pottyTips = <String>[
  'Hazır olma belirtilerinin çoğu görülmeden başlama; erken başlamak süreci uzatabilir.',
  'Yeni kardeş, taşınma ya da kreşe başlama gibi büyük değişikliklerin olduğu dönemde başlama.',
  'Uyandıktan sonra, yemeklerden 15–30 dakika sonra ve uyumadan önce lazımlığa oturmayı öner.',
  'Başarıyı abartısız övgüyle karşıla; kazalarda kızma, utandırma ya da ceza verme.',
  'Kolay çıkan giysiler seç; çocuğun ayakları yere ya da bir basamağa bassın.',
  'Kız çocuklarına önden arkaya silmeyi öğret; her seferinde el yıkamayı alışkanlık yap.',
  'Gece kuruluğu daha geç gelir; 5–7 yaşa kadar gece altını ıslatmak olağandır.',
  'Kabızlık, ağrılı idrar, daha önce kuruyken yeniden sık ıslatma ya da 4 yaşından sonra gündüz hâlâ zorlanma varsa doktora danış.',
];
