// Gelişim basamakları. Yaşlar, çocukların çoğunun (yaklaşık %75) o beceriyi
// gösterdiği ay olarak verilmiştir (CDC "Learn the Signs. Act Early." 2022 ve
// DSÖ motor gelişim çalışması temel alınmıştır). Her çocuk kendi hızında
// gelişir; liste tanı aracı değildir.

class Milestone {
  final String id;
  final int month;
  final String area; // Hareket, Dil, Sosyal, Düşünme
  final String title;
  const Milestone(this.id, this.month, this.area, this.title);
}

const milestoneAreas = ['Hareket', 'Dil ve iletişim', 'Sosyal ve duygusal', 'Düşünme ve öğrenme'];

const milestones = <Milestone>[
  // 2 ay
  Milestone('m2_head', 2, 'Hareket', 'Yüzüstü yatarken başını kısa süre kaldırır'),
  Milestone('m2_hands', 2, 'Hareket', 'Kollarını ve bacaklarını hareket ettirir'),
  Milestone('m2_sounds', 2, 'Dil ve iletişim', 'Ağlama dışında sesler çıkarır'),
  Milestone('m2_smile', 2, 'Sosyal ve duygusal', 'Konuşunca ya da gülümseyince sana gülümser'),
  Milestone('m2_watch', 2, 'Düşünme ve öğrenme', 'Hareket eden bir şeyi gözleriyle izler'),
  // 4 ay
  Milestone('m4_headsteady', 4, 'Hareket', 'Kucakta başını destek olmadan dik tutar'),
  Milestone('m4_push', 4, 'Hareket', 'Yüzüstüyken dirseklerine dayanıp kalkar'),
  Milestone('m4_coo', 4, 'Dil ve iletişim', '“Ooo, aaa” gibi agulama sesleri çıkarır'),
  Milestone('m4_laugh', 4, 'Sosyal ve duygusal', 'Dikkat çekmek için güler ya da ses çıkarır'),
  Milestone('m4_mouth', 4, 'Düşünme ve öğrenme', 'Oyuncağı ağzına götürür'),
  // 6 ay
  Milestone('m6_roll', 6, 'Hareket', 'Yüzüstünden sırtüstüne döner'),
  Milestone('m6_sitsupport', 6, 'Hareket', 'Ellerine dayanarak kısa süre oturur'),
  Milestone('m6_turns', 6, 'Dil ve iletişim', 'Ses gelen yöne başını çevirir'),
  Milestone('m6_knows', 6, 'Sosyal ve duygusal', 'Tanıdık insanları tanır'),
  Milestone('m6_reach', 6, 'Düşünme ve öğrenme', 'İstediği oyuncağa uzanır'),
  // 9 ay
  Milestone('m9_sit', 9, 'Hareket', 'Destek almadan oturur'),
  Milestone('m9_pass', 9, 'Hareket', 'Nesneyi bir elinden diğerine geçirir'),
  Milestone('m9_babble', 9, 'Dil ve iletişim', '“Mamama, babababa” gibi heceler çıkarır'),
  Milestone('m9_stranger', 9, 'Sosyal ve duygusal', 'Yabancılardan çekinir, tanıdığına sığınır'),
  Milestone('m9_hidden', 9, 'Düşünme ve öğrenme', 'Gözünün önünde saklanan oyuncağı arar'),
  // 12 ay
  Milestone('m12_pull', 12, 'Hareket', 'Tutunarak ayağa kalkar ve mobilyaya tutunarak yürür'),
  Milestone('m12_pincer', 12, 'Hareket', 'Küçük şeyleri başparmak ve işaret parmağıyla alır'),
  Milestone('m12_wave', 12, 'Dil ve iletişim', '“Bay bay” der gibi el sallar'),
  Milestone('m12_mama', 12, 'Dil ve iletişim', 'Anne ya da babaya “mama”, “baba” gibi bir adla seslenir'),
  Milestone('m12_game', 12, 'Sosyal ve duygusal', 'Ce-e gibi oyunlar oynar'),
  Milestone('m12_container', 12, 'Düşünme ve öğrenme', 'Bir şeyi kaba koyar, kaptan çıkarır'),
  // 15 ay
  Milestone('m15_steps', 15, 'Hareket', 'Kendi başına birkaç adım atar'),
  Milestone('m15_words', 15, 'Dil ve iletişim', '“Mama”, “baba” dışında bir iki kelime söyler'),
  Milestone('m15_point', 15, 'Dil ve iletişim', 'İstediği bir şeyi parmağıyla gösterir'),
  Milestone('m15_show', 15, 'Sosyal ve duygusal', 'Sevdiği bir şeyi sana gösterir'),
  Milestone('m15_use', 15, 'Düşünme ve öğrenme', 'Nesneleri doğru kullanmayı dener (telefon, kaşık)'),
  // 18 ay
  Milestone('m18_walk', 18, 'Hareket', 'Tutunmadan yürür'),
  Milestone('m18_spoon', 18, 'Hareket', 'Kaşıkla yemeye çalışır'),
  Milestone('m18_threewords', 18, 'Dil ve iletişim', '“Mama, baba” dışında en az üç kelime söyler'),
  Milestone('m18_followone', 18, 'Dil ve iletişim', 'Hareket olmadan verilen tek adımlı yönergeyi izler'),
  Milestone('m18_pretend', 18, 'Düşünme ve öğrenme', 'Oyuncağı besler gibi basit taklit oyunları oynar'),
  // 24 ay
  Milestone('m24_kick', 24, 'Hareket', 'Topa tekme atar'),
  Milestone('m24_run', 24, 'Hareket', 'Koşar'),
  Milestone('m24_twowords', 24, 'Dil ve iletişim', '“Su ver” gibi iki kelimeyi birlikte söyler'),
  Milestone('m24_body', 24, 'Dil ve iletişim', 'Sorunca en az iki vücut bölümünü gösterir'),
  Milestone('m24_notice', 24, 'Sosyal ve duygusal', 'Başkası üzülünce fark eder'),
  Milestone('m24_twohands', 24, 'Düşünme ve öğrenme', 'İki elini birlikte kullanarak bir şey yapar'),
  // 30 ay
  Milestone('m30_jump', 30, 'Hareket', 'İki ayağıyla zıplar'),
  Milestone('m30_fifty', 30, 'Dil ve iletişim', 'Yaklaşık 50 kelime söyler'),
  Milestone('m30_play', 30, 'Sosyal ve duygusal', 'Diğer çocukların yanında ve onlarla oynar'),
  Milestone('m30_colors', 30, 'Düşünme ve öğrenme', 'Basit problemleri çözer (taburenin üstüne çıkıp uzanmak gibi)'),
  // 36 ay
  Milestone('m36_dress', 36, 'Hareket', 'Bol giysileri kendi giyer'),
  Milestone('m36_talk', 36, 'Dil ve iletişim', 'En az iki cümlelik karşılıklı konuşma yapar'),
  Milestone('m36_name', 36, 'Dil ve iletişim', 'Adını söyler'),
  Milestone('m36_calm', 36, 'Sosyal ve duygusal', 'Bırakıldıktan kısa süre sonra sakinleşir'),
  Milestone('m36_circle', 36, 'Düşünme ve öğrenme', 'Gösterince daire çizer'),
  // 48 ay
  Milestone('m48_catch', 48, 'Hareket', 'Büyük bir topu çoğunlukla yakalar'),
  Milestone('m48_story', 48, 'Dil ve iletişim', 'Duyduğu bir hikâyeden bir şeyler anlatır'),
  Milestone('m48_comfort', 48, 'Sosyal ve duygusal', 'Üzülen birini teselli eder'),
  Milestone('m48_colors', 48, 'Düşünme ve öğrenme', 'Birkaç rengin adını söyler'),
  // 60 ay
  Milestone('m60_hop', 60, 'Hareket', 'Tek ayağı üzerinde sekebilir'),
  Milestone('m60_letters', 60, 'Dil ve iletişim', 'Bazı harfleri tanır'),
  Milestone('m60_rules', 60, 'Sosyal ve duygusal', 'Oyunlarda kurallara uyar ve sırasını bekler'),
  Milestone('m60_count', 60, 'Düşünme ve öğrenme', '10’a kadar sayar'),
];

const milestoneAges = [2, 4, 6, 9, 12, 15, 18, 24, 30, 36, 48, 60];

String milestoneAgeLabel(int month) =>
    month < 24 ? '$month. ay' : (month % 12 == 0 ? '${month ~/ 12} yaş' : '${month ~/ 12},5 yaş');

/// Bebeğin yaşına uygun (yaşının bir sonraki basamağı dahil) grup.
int currentMilestoneAge(int? ageMonths) {
  if (ageMonths == null) return milestoneAges.first;
  for (final a in milestoneAges) {
    if (ageMonths <= a) return a;
  }
  return milestoneAges.last;
}

/// Yaş grubunu geçtiği hâlde işaretlenmemiş basamaklar (doktorla konuşulacaklar).
List<Milestone> overdueMilestones(Map<String, String> done, int? ageMonths) {
  if (ageMonths == null) return const [];
  return milestones.where((m) => ageMonths >= m.month + 2 && !done.containsKey(m.id)).toList();
}

Map<String, String> decodeMilestoneDone(Object? raw) {
  if (raw is! Map) return {};
  final ids = milestones.map((m) => m.id).toSet();
  final out = <String, String>{};
  raw.forEach((k, v) {
    if (ids.contains(k) && v is String && DateTime.tryParse(v) != null) out['$k'] = v;
  });
  return out;
}
