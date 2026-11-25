// Edinburgh Doğum Sonrası Depresyon Ölçeği (EPDS; Cox, Holden ve Sagovsky,
// 1987). Ölçek kaynak gösterilerek serbestçe kullanılabilir. Türkçe geçerlik:
// Engindeniz ve ark., 1996 (kesme puanı 12/13). Tarama aracıdır, tanı koymaz.

class EpdsOption {
  final String text;
  final int score;
  const EpdsOption(this.text, this.score);
}

class EpdsItem {
  final String question;
  final List<EpdsOption> options;
  const EpdsItem(this.question, this.options);
}

const epdsItems = <EpdsItem>[
  EpdsItem('Gülebildim ve olayların komik yanını görebildim.', [
    EpdsOption('Her zaman olduğu kadar', 0), EpdsOption('Artık eskisi kadar değil', 1),
    EpdsOption('Kesinlikle eskisi kadar değil', 2), EpdsOption('Hiç değil', 3)]),
  EpdsItem('Geleceğe hevesle baktım.', [
    EpdsOption('Her zamanki kadar', 0), EpdsOption('Eskisinden biraz daha az', 1),
    EpdsOption('Eskisinden kesinlikle daha az', 2), EpdsOption('Hemen hemen hiç', 3)]),
  EpdsItem('İşler kötü gittiğinde gereksiz yere kendimi suçladım.', [
    EpdsOption('Evet, çoğu zaman', 3), EpdsOption('Evet, bazen', 2),
    EpdsOption('Pek sık değil', 1), EpdsOption('Hayır, hiçbir zaman', 0)]),
  EpdsItem('Belirgin bir neden yokken kaygılandım ya da endişelendim.', [
    EpdsOption('Hayır, hiç', 0), EpdsOption('Çok nadiren', 1),
    EpdsOption('Evet, bazen', 2), EpdsOption('Evet, çok sık', 3)]),
  EpdsItem('Belirgin bir neden yokken korktum ya da paniğe kapıldım.', [
    EpdsOption('Evet, oldukça sık', 3), EpdsOption('Evet, bazen', 2),
    EpdsOption('Hayır, pek değil', 1), EpdsOption('Hayır, hiç', 0)]),
  EpdsItem('Her şey üstüme geliyor gibiydi.', [
    EpdsOption('Evet, çoğu zaman hiç baş edemedim', 3), EpdsOption('Evet, bazen her zamanki gibi baş edemedim', 2),
    EpdsOption('Hayır, çoğu zaman oldukça iyi baş ettim', 1), EpdsOption('Hayır, her zamanki gibi baş ettim', 0)]),
  EpdsItem('Kendimi o kadar mutsuz hissettim ki uyumakta zorlandım.', [
    EpdsOption('Evet, çoğu zaman', 3), EpdsOption('Evet, bazen', 2),
    EpdsOption('Pek sık değil', 1), EpdsOption('Hayır, hiç', 0)]),
  EpdsItem('Kendimi üzgün ve mutsuz hissettim.', [
    EpdsOption('Evet, çoğu zaman', 3), EpdsOption('Evet, oldukça sık', 2),
    EpdsOption('Pek sık değil', 1), EpdsOption('Hayır, hiç', 0)]),
  EpdsItem('Kendimi o kadar mutsuz hissettim ki ağladım.', [
    EpdsOption('Evet, çoğu zaman', 3), EpdsOption('Evet, oldukça sık', 2),
    EpdsOption('Sadece ara sıra', 1), EpdsOption('Hayır, hiç', 0)]),
  EpdsItem('Kendime zarar verme düşüncesi aklıma geldi.', [
    EpdsOption('Evet, oldukça sık', 3), EpdsOption('Bazen', 2),
    EpdsOption('Çok nadiren', 1), EpdsOption('Hiçbir zaman', 0)]),
];

enum EpdsBand { low, possible, likely }

class EpdsResult {
  final DateTime date;
  final int score;
  final bool selfHarm; // 10. soruya 0'dan büyük cevap
  const EpdsResult(this.date, this.score, this.selfHarm);

  EpdsBand get band => score >= 13 ? EpdsBand.likely : (score >= 10 ? EpdsBand.possible : EpdsBand.low);

  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'score': score, 'selfHarm': selfHarm};

  static EpdsResult? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final d = DateTime.tryParse('${raw['date']}');
    final s = raw['score'];
    if (d == null || s is! int || s < 0 || s > 30) return null;
    return EpdsResult(d, s, raw['selfHarm'] == true);
  }
}

/// [answers]: her soru için seçilen seçeneğin indeksi.
EpdsResult scoreEpds(List<int> answers, DateTime now) {
  if (answers.length != epdsItems.length) throw ArgumentError('Tüm soruları yanıtla');
  var total = 0;
  for (var i = 0; i < answers.length; i++) {
    total += epdsItems[i].options[answers[i]].score;
  }
  final q10 = epdsItems.last.options[answers.last].score;
  return EpdsResult(now, total, q10 > 0);
}

List<EpdsResult> decodeEpdsHistory(Object? raw) {
  if (raw is! List) return [];
  return raw.map(EpdsResult.fromJson).whereType<EpdsResult>().toList()..sort((a, b) => b.date.compareTo(a.date));
}

String epdsBandText(EpdsBand b) => switch (b) {
      EpdsBand.low =>
        'Şu an belirgin bir depresyon belirtisi görünmüyor. Kendini kötü hissetmeye başlarsan testi tekrar yap ve yakınlarınla konuş.',
      EpdsBand.possible =>
        'Bazı depresyon belirtileri olabilir. Bunu yalnız taşımak zorunda değilsin: aile hekimin ya da doğum doktorunla konuş, 2 hafta sonra testi tekrarla.',
      EpdsBand.likely =>
        'Doğum sonrası depresyon belirtileri olabilir. Bu tedavi edilebilir bir durum ve senin suçun değil. En kısa sürede aile hekimine, doktoruna ya da bir ruh sağlığı uzmanına başvur.',
    };

const moodSupportTips = <String>[
  'Doğumdan sonraki ilk 2 haftada ağlamaklı ve hassas olmak (lohusa hüznü) çok yaygındır ve kendiliğinden geçer.',
  '2 haftadan uzun süren mutsuzluk, ilgi kaybı, umutsuzluk ya da bebeğe bağ kuramama depresyon belirtisi olabilir.',
  'Doğum sonrası depresyon her 7 anneden birinde görülür; babalarda da olabilir. Tedavisi vardır, emzirirken de tedavi mümkündür.',
  'Uyku, beslenme ve yardım kabul etmek önemlidir: gece bir beslemeyi eşine ya da bir yakınına bırakmayı dene.',
  'Duygularını güvendiğin biriyle paylaş; kendini yalnız hissetmen bir zayıflık değildir.',
];
