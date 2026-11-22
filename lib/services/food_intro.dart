// Ek gıdaya geçiş ve alerjen tanıtma takibi.
// Öneriler: DSÖ ek beslenme rehberi, AAP ve EAACI alerjen tanıtma görüşü
// (yaygın alerjenleri 6. aydan itibaren geciktirmeden, tek tek tanıtmak).

class IntroFood {
  final String id;
  final String group;
  final String name;
  final bool allergen;
  final int fromMonth;
  final String tip;
  const IntroFood(this.id, this.group, this.name, {this.allergen = false, this.fromMonth = 6, this.tip = ''});
}

const foodGroups = ['Sebze', 'Meyve', 'Tahıl', 'Et, balık, baklagil', 'Süt ürünleri', 'Alerjenler'];

const introFoods = <IntroFood>[
  IntroFood('kabak', 'Sebze', 'Kabak'),
  IntroFood('havuc', 'Sebze', 'Havuç'),
  IntroFood('patates', 'Sebze', 'Patates'),
  IntroFood('tatli_patates', 'Sebze', 'Tatlı patates'),
  IntroFood('balkabagi', 'Sebze', 'Balkabağı'),
  IntroFood('brokoli', 'Sebze', 'Brokoli'),
  IntroFood('karnabahar', 'Sebze', 'Karnabahar'),
  IntroFood('bezelye', 'Sebze', 'Bezelye'),
  IntroFood('ispanak', 'Sebze', 'Ispanak', tip: 'Haftada 1–2 kez; pişmiş ıspanağı bekletmeden ver.'),
  IntroFood('domates', 'Sebze', 'Domates'),
  IntroFood('elma', 'Meyve', 'Elma'),
  IntroFood('armut', 'Meyve', 'Armut'),
  IntroFood('muz', 'Meyve', 'Muz'),
  IntroFood('seftali', 'Meyve', 'Şeftali'),
  IntroFood('kayisi', 'Meyve', 'Kayısı'),
  IntroFood('avokado', 'Meyve', 'Avokado'),
  IntroFood('erik', 'Meyve', 'Erik'),
  IntroFood('cilek', 'Meyve', 'Çilek'),
  IntroFood('kavun', 'Meyve', 'Kavun / karpuz'),
  IntroFood('portakal', 'Meyve', 'Portakal / mandalina'),
  IntroFood('pirinc', 'Tahıl', 'Pirinç'),
  IntroFood('yulaf', 'Tahıl', 'Yulaf'),
  IntroFood('bulgur', 'Tahıl', 'Bulgur'),
  IntroFood('misir', 'Tahıl', 'Mısır'),
  IntroFood('karabugday', 'Tahıl', 'Karabuğday'),
  IntroFood('tavuk', 'Et, balık, baklagil', 'Tavuk'),
  IntroFood('hindi', 'Et, balık, baklagil', 'Hindi'),
  IntroFood('dana', 'Et, balık, baklagil', 'Kırmızı et'),
  IntroFood('kuzu', 'Et, balık, baklagil', 'Kuzu eti'),
  IntroFood('ciger', 'Et, balık, baklagil', 'Ciğer', tip: 'A vitamini çok yüksek; haftada en fazla 1 kez.'),
  IntroFood('mercimek', 'Et, balık, baklagil', 'Mercimek'),
  IntroFood('nohut', 'Et, balık, baklagil', 'Nohut', tip: 'Ezerek ver; bütün nohut 4 yaşa kadar boğulma riski taşır.'),
  IntroFood('fasulye', 'Et, balık, baklagil', 'Kuru fasulye'),
  IntroFood('yogurt', 'Süt ürünleri', 'Yoğurt'),
  IntroFood('lor', 'Süt ürünleri', 'Lor peyniri (tuzsuz)'),
  IntroFood('peynir', 'Süt ürünleri', 'Beyaz peynir (suda tuzu alınmış)', fromMonth: 12),
  IntroFood('inek_sutu', 'Süt ürünleri', 'İnek sütü (içecek olarak)', fromMonth: 12,
      tip: '12 aydan önce yemeklerde az miktarda kullanılabilir, içecek olarak verilmez.'),
  IntroFood('bal', 'Süt ürünleri', 'Bal', fromMonth: 12, tip: 'Botulizm riski nedeniyle 1 yaşından önce hiç verilmez.'),
  // Yaygın alerjenler
  IntroFood('yumurta', 'Alerjenler', 'Yumurta (iyi pişmiş)', allergen: true),
  IntroFood('yer_fistigi', 'Alerjenler', 'Yer fıstığı (ezme olarak)', allergen: true,
      tip: 'Asla bütün ya da parça fıstık verme; ince ezme suyla sulandırılarak verilir.'),
  IntroFood('agac_yemisi', 'Alerjenler', 'Fındık, ceviz, badem (ezme olarak)', allergen: true,
      tip: 'Bütün kuruyemiş 4–5 yaşa kadar boğulma riski taşır; yalnızca ince ezme ya da toz.'),
  IntroFood('susam', 'Alerjenler', 'Susam (tahin)', allergen: true),
  IntroFood('bugday', 'Alerjenler', 'Buğday (gluten)', allergen: true),
  IntroFood('sut', 'Alerjenler', 'İnek sütü proteini (yoğurt, pişmiş sütlü yemek)', allergen: true),
  IntroFood('balik', 'Alerjenler', 'Balık', allergen: true, tip: 'Kılçıklarını parmakla tek tek kontrol et.'),
  IntroFood('kabuklu', 'Alerjenler', 'Kabuklu deniz ürünleri', allergen: true),
  IntroFood('soya', 'Alerjenler', 'Soya', allergen: true),
];

const reactionLevels = ['Tepki yok', 'Hafif (kızarıklık, birkaç döküntü)', 'Belirgin (kusma, yaygın döküntü, şişlik)'];

class FoodTry {
  final DateTime date;
  final int reaction; // reactionLevels indeksi
  final String note;
  const FoodTry(this.date, {this.reaction = 0, this.note = ''});

  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'reaction': reaction, if (note.isNotEmpty) 'note': note};

  static FoodTry? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final d = DateTime.tryParse('${raw['date']}');
    if (d == null) return null;
    final r = raw['reaction'];
    return FoodTry(d,
        reaction: r is int && r >= 0 && r < reactionLevels.length ? r : 0,
        note: raw['note'] is String ? raw['note'] as String : '');
  }
}

/// foodId → denemeler (en yeni sonda).
Map<String, List<FoodTry>> decodeFoodTries(Object? raw) {
  if (raw is! Map) return {};
  final ids = introFoods.map((f) => f.id).toSet();
  final out = <String, List<FoodTry>>{};
  raw.forEach((k, v) {
    if (!ids.contains(k) || v is! List) return;
    final list = v.map(FoodTry.fromJson).whereType<FoodTry>().toList()..sort((a, b) => a.date.compareTo(b.date));
    if (list.isNotEmpty) out['$k'] = list;
  });
  return out;
}

Map<String, dynamic> encodeFoodTries(Map<String, List<FoodTry>> m) =>
    m.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()));

enum FoodStatus { notTried, ok, watch, reaction }

FoodStatus foodStatus(List<FoodTry>? tries) {
  if (tries == null || tries.isEmpty) return FoodStatus.notTried;
  if (tries.any((t) => t.reaction == 2)) return FoodStatus.reaction;
  if (tries.any((t) => t.reaction == 1)) return FoodStatus.watch;
  return FoodStatus.ok;
}

/// Alerjen tanıtıldıktan sonra tolere ediliyorsa düzenli verilmesi önerilir.
/// Son 14 gündür verilmemiş, sorunsuz tanıtılmış alerjenler.
List<IntroFood> allergensToKeepGiving(Map<String, List<FoodTry>> m, DateTime now) => introFoods.where((f) {
      if (!f.allergen) return false;
      final t = m[f.id];
      if (foodStatus(t) != FoodStatus.ok) return false;
      return now.difference(t!.last.date).inDays > 14;
    }).toList();

const foodIntroTips = <String>[
  'Ek gıdaya 6. ayda başlanır; anne sütü ya da mama 1 yaşına kadar ana besin olmaya devam eder.',
  'Yeni besinleri tek tek, sabah ya da öğlen ver; tepkiyi izleyebilmek için yeni bir alerjenden sonra 2–3 gün bekle.',
  'Yumurta ve yer fıstığı gibi alerjenleri geciktirmek alerjiyi önlemez; tolere ediyorsa haftada birkaç kez vermeye devam et.',
  'Ağır egzaması ya da bilinen yumurta alerjisi olan bebeklerde yer fıstığını vermeden önce doktora danış.',
  'Tuz, şeker ve bal 1 yaşından önce eklenmez.',
  'Bütün üzüm, bütün kuruyemiş, patlamış mısır, sert çiğ sebze ve sosis gibi yiyecekler boğulma riski taşır.',
  'Dudakta ya da yüzde şişlik, nefes darlığı, hırıltı, tekrarlayan kusma ya da halsizlik olursa hemen 112’yi ara.',
];
