import '../services/turkey_vaccine_schedule.dart';

/// Ay ay bebek rehberi (0–24 ay her ay, sonrasında her yaş).
/// Genel ebeveyn rehberidir; bireysel tanı veya beslenme reçetesi değildir.
/// Gelişim basamakları geniş bir aralıkta ortaya çıkar; tek bir ayda
/// görülmemesi tek başına sorun anlamına gelmez.
class MonthlyBabyGuide {
  final int month;
  final Map<String, String> sections;
  const MonthlyBabyGuide(this.month, this.sections);
}

const babyGuideCategories = <String>['Gelişim', 'Oyun', 'Beslenme', 'Uyku', 'Sağlık', 'Güvenlik'];

// 0–24. aylar: (gelişim, oyun)
const _months = <(String, String)>[
  ('Yenidoğan yüzleri 20–30 cm mesafeden en iyi görür, annesinin sesini ve kokusunu tanır. Emme, yakalama ve irkilme refleksleri vardır.',
   'Ten tene temas, yüz yüze konuşma, ninni. Kısa süreli, uyanıkken gözetimli karın üstü zaman.'),
  ('Başını kısa süre kaldırmayı dener; ellerini yumruk yapar. Sese irkilir veya sakinleşir. Gözüyle yakındaki yüzü kısa süre takip eder.',
   'Siyah-beyaz kontrastlı kartlar, yüzünü yavaşça sağa-sola hareket ettirerek takip ettirme, günde birkaç kez karın üstü oyun.'),
  ('Sosyal gülümseme başlar; "agu" gibi sesler çıkarır. Karın üstünde başını 45° kaldırabilir, ellerini açmaya başlar.',
   'Gülümsemesine gülümseyerek karşılık ver, seslerini taklit et. Hafif çıngırak sallayarak sesi bulmasını bekle.'),
  ('Başını daha dik tutar; ellerini birleştirip ağzına götürür. Kahkahaya yakın sesler, renkli nesnelere uzun bakma.',
   'Göğüs hizasında asılı oyuncaklara uzanma, ayna oyunu, nazik bacak bisikleti.'),
  ('Başını dik ve sabit tutar; nesnelere uzanır ve tutar. Kahkaha atar, yüzüstüyken kollarıyla doğrulur. Yuvarlanma denemeleri başlayabilir.',
   'Uzanabileceği mesafede güvenli oyuncak, farklı dokular, sesli kitaplar. Konuşurken duraklayıp "cevap" vermesini bekle.'),
  ('Yuvarlanır (çoğunlukla yüzüstüden sırtüstüne); nesneleri ağzına götürür. Adına tepki vermeye başlar, ses tonlarını ayırt eder.',
   'Yerde güvenli bir minderde serbest hareket, oyuncağı biraz uzağa koyup uzanmasını teşvik etme, şarkılı el oyunları.'),
  ('Destekle oturur; nesneyi bir elinden diğerine aktarır. "ba", "ma" gibi heceler deneyebilir. Tanıdık yüzleri ayırt eder.',
   'Oturma desteği için minder, kap içine nesne koyup çıkarma, ce-ee oyunu, resimli kalın kitaplar.'),
  ('Kısa süre desteksiz oturabilir; sesin geldiği yöne döner. Hece tekrarları artar, ayna görüntüsüne ilgi gösterir.',
   'İki elle tutulacak oyuncaklar, birbirine vurma (ritim), aynada yüz ifadeleri.'),
  ('Desteksiz oturur, emeklemeye hazırlanır veya sürünür. Yabancı kaygısı başlayabilir. Nesne kalıcılığı gelişir: saklanan nesneyi arar.',
   'Bez altına saklanan oyuncağı bulma, emeklemeyi teşvik eden tünel/yastık parkuru (gözetimli), "yok-oldu" oyunu.'),
  ('Emekler; tutunarak ayağa kalkmayı dener. Başparmak ve işaret parmağıyla küçük nesneleri tutmaya başlar. "baba", "mama" heceleri.',
   'Yumuşak bloklar, kapaklı kutular, el sallama ve alkış oyunu. Günlük işleri anlatarak konuşmayı sürdür.'),
  ('Mobilyalara tutunarak kalkar ve yan yan yürüyebilir. Basit sözcükleri anlar ("hayır", "gel"); el sallar.',
   'İtme oyuncakları (sağlam, devrilmeyen), top yuvarlama, hayvan sesleri taklidi.'),
  ('Tutunarak yürür; kısa süre tek başına ayakta durabilir. İşaret ederek ister, basit yönergeleri anlamaya başlar.',
   'Kutuya nesne atma, kaşık-bardakla taklit oyunları, resimdeki nesneyi gösterme.'),
  ('İlk adımlar atılabilir (9–18 ay arası olağandır). 1–3 anlamlı sözcük, el sallama, işaret etme. Kendi başına kaşık kullanmayı dener.',
   'Yürüme için güvenli alan, basit şekil yerleştirme, birlikte şarkı ve kitap. 1 yaş kontrolüne git.'),
  ('Birkaç adım yürür; nesneleri üst üste koymayı dener. Tanıdık kişileri isimle tanır.',
   'İki blok üst üste koyma, büyük boya kalemiyle karalama (gözetimli), saklambaç benzeri basit oyunlar.'),
  ('Daha emin yürür; çömelip kalkar. Sözcük sayısı artar, "ver" gibi yönergeleri uygular.',
   'Topu ileri itme, kapları iç içe geçirme, resimli kitapta "nerede?" soruları.'),
  ('Merdivenleri emekleyerek çıkabilir; bardaktan içmeyi öğrenir. Taklit oyunları artar.',
   'Oyuncak telefonla konuşma, bebeğe mama verme gibi taklit oyunları, açık havada yürüyüş.'),
  ('Geri geri yürüyebilir; 3–4 blok üst üste koyar. Vücut bölümlerinden birkaçını gösterir.',
   '"Burnun nerede?" oyunu, kum-su oyunu (gözetimli), basit yapbozlar.'),
  ('Yaklaşık 6–10 sözcük; basit yönergeleri anlar. Kaşıkla yemekte daha becerikli, inatlaşma başlayabilir.',
   'Seçenek sunma ("elma mı muz mu?"), kutu içine şekil yerleştirme, birlikte toplama oyunu.'),
  ('Koşmaya çalışır; yardım alarak merdiven çıkar. Resimdeki nesneleri gösterir, oyuncak bebeği besler.',
   'Kitap okurken sayfa çevirmesine izin ver, büyük legolar, dans ve müzik.'),
  ('Sözcük dağarcığı hızla artar; bazı çocuklar iki sözcüğü yan yana getirmeye başlar.',
   'Günlük işlerde küçük görevler ("ayakkabını getir"), boyama, parmak oyunları.'),
  ('Topa ayakla vurmayı dener; kaşık-çatal kullanımı gelişir. Diğer çocuklara ilgi artar ama genellikle yan yana oynar.',
   'Top oyunları, basit sıralama (büyük-küçük), oyun hamuru (gözetimli).'),
  ('Kendini ifade etme isteği artar; öfke nöbetleri görülebilir. Basit soruları anlar.',
   'Duyguları adlandırma ("kızgın mısın?"), rol oyunları, açık havada tırmanma (alçak ve güvenli).'),
  ('Merdiveni tutunarak çıkıp iner; çizgi karalamaları daha kontrollü. Sahiplenme ("benim") belirginleşir.',
   'Sıra bekleme oyunları, kova-kürek, hikâyeyi birlikte anlatma.'),
  ('İki sözcüklü cümleler yaygınlaşır; 50 civarı sözcük olağandır. Taklit ve hayali oyun artar.',
   'Mutfak oyuncakları, kılık değiştirme, basit sayma şarkıları.'),
  ('İki yaş: koşar, top atar, 2–3 sözcüklü cümleler kurar, basit iki aşamalı yönergeleri yapar. Tuvalet eğitimine hazırlık belirtileri görülebilir.',
   'Yapboz, boyama, top oyunları, kitap okuma. Ekran yerine açık havada oyun.'),
];

// 2–6 yaş (yıllık)
const _years = <(String, String)>[
  ('2–3 yaş: cümleleri uzar, renkleri ve şekilleri öğrenmeye başlar, "neden?" soruları çoğalır. Bağımsız giyinmeyi dener.',
   'Hayali oyun, yapboz, oyun hamuru, bisiklet (üç tekerlekli), birlikte yemek hazırlama.'),
  ('3–4 yaş: hikâye anlatır, sırasını bekleyebilir, arkadaşlarla birlikte oynamaya başlar. Tek ayak üzerinde kısa süre durur.',
   'Kurallı basit oyunlar, makasla kesme (çocuk makası), dans, doğa yürüyüşü.'),
  ('4–5 yaş: harf ve sayılara ilgi, kendi adını yazmaya çalışma, karmaşık cümleler. Duygularını sözle anlatmaya başlar.',
   'Kutu oyunları, rol yapma, bahçe işleri, kütüphane ziyaretleri.'),
  ('5–6 yaş: okula hazırlık; dikkat süresi uzar, kurallı oyunları kavrar, ayakkabı bağlamayı öğrenebilir.',
   'Hafıza oyunları, ip atlama, bisiklet (yardımcı tekerlekli), birlikte kitap okuma ve sorular sorma.'),
];

String _feeding(int m) {
  if (m < 6) {
    return 'İlk 6 ay yalnızca anne sütü önerilir; su, şekerli su veya bitki çayı gerekmez. Anne sütü yeterli değilse mama ihtiyacını çocuk doktoruyla değerlendir. Bebek açlık işareti verdikçe besle (günde 8–12 kez).';
  }
  if (m == 6) {
    return 'Hazır olma belirtileri varsa ek gıdaya başla: tek tek, birkaç gün arayla, püre kıvamında. Demirden zengin besinler (et, yumurta sarısı, mercimek) öncelikli. Tuz, şeker ve bal eklenmez; anne sütü devam eder.';
  }
  if (m < 9) {
    return 'Günde 2–3 öğün ek gıda; kıvamı yavaş yavaş ezme ve yumuşak parçalara ilerlet. Bardaktan su içmeyi tanıt. Alerjen besinleri (yumurta, fıstık ezmesi inceltilmiş) uygun biçimde tanıtabilirsin; riskli bebeklerde doktora danış.';
  }
  if (m < 12) {
    return 'Günde 3 öğün ve 1–2 ara öğün; parmakla yenebilecek yumuşak yiyecekler. Bütün üzüm, bütün kuruyemiş gibi boğulma riski taşıyan besinler verilmez. Bal 12 aydan önce verilmez; inek sütü ana içecek olarak verilmez.';
  }
  if (m < 24) {
    return 'Aile sofrasına az tuzlu, yaşa uygun kıvamda katıl. Günde 3 öğün + 2 ara öğün. Günlük süt yaklaşık 2 su bardağını aşmamalı. Emzirme isteğe bağlı olarak sürebilir. Seçici yeme bu yaşta olağandır.';
  }
  return 'Sebze, meyve, tam tahıl, protein ve süt ürünlerinden çeşitlilik sun. Ne yiyeceğine sen, ne kadar yiyeceğine çocuk karar versin. Şekerli içecekleri ve paketli atıştırmalıkları sınırla.';
}

String _sleep(int m) {
  if (m < 3) return 'Günde yaklaşık 14–17 saat, kısa bloklar hâlinde uyku olağandır. Her uykuda sırtüstü, düz ve sert zemin; yatakta yastık, yorgan ve oyuncak olmamalı. İlk 6 ay aynı odada, ayrı yatakta.';
  if (m < 12) return 'Günde yaklaşık 12–16 saat (gündüz uykuları dahil). Gece uyanmaları sürebilir. Akşam rutini (banyo, beslenme, ninni) ve uykulu ama uyanıkken yatırma alışkanlığı yardımcı olur.';
  if (m < 24) return 'Günde yaklaşık 11–14 saat; gündüz uykusu genellikle bire iner. Düzenli yatış saati ve ekransız bir akşam rutini önemlidir.';
  return 'Günde yaklaşık 10–13 saat (gündüz uykusu dahil). Gündüz uykusu genellikle 3–5 yaş arasında bırakılır. Yatmadan 1 saat önce ekranları kapat.';
}

String _health(int m) {
  final vaccines = standardVaccines.where((v) => v.month == m).map((v) => v.title).toList();
  final checkup = switch (m) {
    0 => 'Doğumdan sonraki ilk günlerde topuk kanı ve işitme taraması yapılır; 3–5. günde ilk kontrol önerilir.',
    1 => 'Aile hekimi izlemi: kilo alımı, sarılık, göbek ve beslenme değerlendirmesi.',
    2 || 4 || 6 => 'Aile hekimi izlemi ve aşılar. D vitamini düzenli verilmeli; demir desteği 4. ayda başlar (doz hekim tarafından belirlenir).',
    9 => 'Gelişim değerlendirmesi; demir desteği sürer.',
    12 => '1 yaş kontrolü: büyüme, gelişim, kansızlık ve diş değerlendirmesi.',
    18 || 24 => 'Gelişim ve konuşma değerlendirmesi; diş hekimi kontrolü.',
    _ => 'Büyümeyi düzenli ölç ve uygulamaya kaydet; endişelerini aile hekimiyle paylaş.',
  };
  final v = vaccines.isEmpty ? '' : ' Bu ay planlanan aşılar: ${vaccines.join(', ')}.';
  return '$checkup$v Kesin tarihler için uygulamadaki aşı takvimine ve aile hekimine başvur.';
}

String _safety(int m) {
  if (m < 4) return 'Bebeği yüksek yüzeylerde bir an bile yalnız bırakma; sarsma. Arkaya bakan oto koltuğu kullan. 3 aydan küçük bebekte ateş acil değerlendirme gerektirir.';
  if (m < 7) return 'Yuvarlanma başladığı için alt değiştirme masasında elini bebekten ayırma. Küçük nesneleri, düğme pilleri ve ipleri ulaşamayacağı yerde tut.';
  if (m < 12) return 'Emekleme ve tutunarak kalkma dönemi: priz kapakları, merdiven kapısı, köşe koruyucu, mobilyaları duvara sabitleme. Yürüteç kullanma.';
  if (m < 24) return 'İlaç ve temizlik ürünlerini kilitli dolapta sakla; zehirlenmede 114. Sıcak içecekleri ve tencere saplarını ulaşamayacağı yerde tut. Su kenarında kol mesafesinde ol.';
  return 'Pencere ve balkon kilitleri, sokakta el ele yürüme, yaşa uygun oto koltuğu. Çocuğa adını, soyadını ve 112\'yi öğret.';
}

MonthlyBabyGuide babyGuideForMonth(int month) {
  final m = month.clamp(0, 72).toInt();
  final (development, play) = m <= 24 ? _months[m] : _years[((m - 24) ~/ 12).clamp(0, _years.length - 1)];
  return MonthlyBabyGuide(m, {
    'Gelişim': development,
    'Oyun': play,
    'Beslenme': _feeding(m),
    'Uyku': _sleep(m),
    'Sağlık': _health(m),
    'Güvenlik': _safety(m),
  });
}
