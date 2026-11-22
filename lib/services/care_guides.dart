// Bakım rehberleri: hasta bebek, emzirme sorunları, bez/kaka rengi,
// gebelik ve doğum sonrası acil belirtiler, güvenli mama hazırlama.

/// Belirtiye göre evde yapılacaklar, doktora gidilecek ve acil durumlar.
class CareTopic {
  final String name;
  final String intro;
  final List<String> home;
  final List<String> doctor;
  final List<String> urgent;
  const CareTopic(this.name, this.intro, {this.home = const [], this.doctor = const [], this.urgent = const []});
}

const sickBabyTopics = <CareTopic>[
  CareTopic('Ateş', 'Koltuk altından 37,5 °C, makattan 38 °C ve üstü ateş kabul edilir.', home: [
    'İnce giydir, odayı serin tut, sık emzir ya da sıvı ver.',
    'Ateş düşürücüyü yalnızca bebeğin kilosuna göre, prospektüsteki ya da doktorun önerdiği dozda ver.',
    'Ateşi ve ilacın saatini Ateş takibi bölümüne kaydet.',
    'Soğuk su, alkol ya da sirkeyle silme yapma.',
  ], doctor: [
    '3–6 aylık bebekte 39 °C ve üstü ateş',
    'Ateş 2 günden uzun sürüyorsa',
    'Ateşle birlikte kulak çekiştirme ya da kötü kokulu idrar',
    'Bebek normalden çok daha az besleniyorsa',
  ], urgent: [
    '3 aydan küçük bebekte 38 °C ve üstü ateş',
    'Ateşle birlikte havale (nöbet)',
    'Bastırınca solmayan döküntü',
    'Uyandırması zor, gevşek ya da tiz sesle ağlıyor',
    'Nefes almakta zorlanma',
    'Ense sertliği, ışıktan rahatsızlık',
  ]),
  CareTopic('İshal', 'Normalden çok daha sık ve sulu kaka ishaldir. Asıl tehlike sıvı kaybıdır.', home: [
    'Emzirmeye ya da mamaya ara verme; daha sık ver.',
    'Doktor önerirse ağızdan sıvı tedavisi (ORS) kullan.',
    'Ek gıdaya başladıysa hafif yiyeceklerle devam et; meyve suyu ve şekerli içecek verme.',
    'Pişiği önlemek için bezi sık değiştir, bariyer krem sür.',
    'Bez değiştirdikten sonra ellerini iyice yıka.',
  ], doctor: [
    'İshal 1 haftadan uzun sürüyorsa',
    'Kakada kan ya da sümüksü madde',
    'Ateşle birlikte ishal',
    'Bezler normalden az ıslanıyorsa',
  ], urgent: [
    'Sıvı kaybı belirtileri: 6 saatten uzun kuru bez, ağız kuruluğu, gözyaşsız ağlama, çökük bıngıldak',
    'Çok uykulu, gevşek bebek',
    'İshalle birlikte yeşil kusma',
  ]),
  CareTopic('Kusma', 'Beslendikten sonra az miktarda süt çıkarmak (gulleme) normaldir. Kusma daha fazla ve güçlüdür.', home: [
    'Az ve sık besle.',
    'Beslendikten sonra 20–30 dakika dik tut.',
    'Uyurken her zaman sırt üstü yatır.',
  ], doctor: [
    'Bebek sıvıları tutamıyorsa ya da kusma 24 saatten uzun sürüyorsa',
    'Kilo almıyor ya da kilo kaybediyorsa',
    'Her beslenmeden sonra fışkırır gibi kusma (özellikle 2–8 hafta arası)',
  ], urgent: [
    'Yeşil ya da kanlı kusma',
    'Sıvı kaybı belirtileri',
    'Şişkin, sert karın ve ara ara şiddetli ağlama',
    'Başını çarptıktan sonra kusma',
  ]),
  CareTopic('Öksürük ve nezle', 'Bebekler yılda birkaç kez soğuk algınlığı geçirebilir; çoğu 7–10 günde geçer.', home: [
    'Burnu serum fizyolojik ve burun aspiratörüyle temizle, özellikle beslenme ve uykudan önce.',
    'Sık emzir ya da sıvı ver.',
    'Odayı havalandır; evde sigara içilmesin.',
    '1 yaşından küçüklere bal, 2 yaşından küçüklere doktor önermeden öksürük ve soğuk algınlığı ilacı verme.',
  ], doctor: [
    '10 günden uzun süren ya da kötüleşen belirtiler',
    'Kulak ağrısı, kulak çekiştirme',
    'Ateş 2 günden uzun sürüyorsa',
    'Hırıltılı solunum',
  ], urgent: [
    'Hızlı ya da zorlu nefes alma, kaburga aralarının içe çekilmesi',
    'Dudaklarda ya da dilde morarma',
    'Nefes alıp vermede duraklamalar',
    'Öksürük nöbetinden sonra morarma ya da nefes almakta zorlanma',
  ]),
  CareTopic('Kabızlık', 'Yalnızca anne sütü alan bebekler birkaç gün kaka yapmayabilir; kaka yumuşaksa bu kabızlık değildir.', home: [
    'Mamayı paketteki oranda hazırla; fazla toz mama kabızlık yapabilir.',
    'Ek gıdaya başladıysa su, erik, armut gibi lifli besinler ver.',
    'Karnına saat yönünde masaj yap, bacaklarını bisiklet çevirir gibi hareket ettir.',
    'Doktor önermeden fitil, lavman ya da müshil kullanma.',
  ], doctor: [
    'Birkaç gündür sert, top top kaka ve ıkınırken ağlama',
    'Kakada kan çizgileri',
    'Yenidoğanın ilk 48 saatte kaka yapmaması',
    'İştahsızlık ve kilo alamama',
  ], urgent: [
    'Şişkin, sert karın ve kusma',
    'Hiç kaka ve gaz çıkmıyor, bebek çok huzursuz',
  ]),
  CareTopic('Döküntü', 'Bebeklerde döküntülerin çoğu zararsızdır (bebek sivilcesi, isilik, pişik).', home: [
    'Pişikte bezi sık değiştir, havalandır, bariyer krem kullan.',
    'İsilikte bebeği daha ince giydir.',
    'Kuru ciltte parfümsüz nemlendirici kullan, banyoyu kısa tut.',
    'Bardak testi yap: şeffaf bir bardağı döküntüye bastır; döküntü solmuyorsa hemen doktora git.',
  ], doctor: [
    'Döküntü yayılıyor, kabarcıklı ya da sulanıyorsa',
    'Ateşle birlikte döküntü',
    'Pişik 3 günde düzelmiyorsa',
    'Yeni bir besinden sonra döküntü',
  ], urgent: [
    'Bastırınca solmayan döküntü',
    'Dudakta, göz çevresinde ya da dilde şişlik',
    'Döküntüyle birlikte nefes darlığı',
  ]),
  CareTopic('Göz akıntısı', 'Yenidoğanlarda gözyaşı kanalı tıkanıklığı sık görülür; çoğu 1 yaşına kadar kendiliğinden açılır.', home: [
    'Gözü içten dışa doğru, her göz için ayrı, kaynatılıp soğutulmuş suya batırılmış pamukla sil.',
    'Doktor gösterdiyse burun kenarına, gözyaşı kanalının üstüne nazik masaj yap.',
    'Gözüne dokunmadan önce ve sonra ellerini yıka.',
  ], doctor: [
    'Gözde kızarıklık ve sarı-yeşil yoğun akıntı',
    'Akıntı 1 haftada azalmıyorsa',
    'Göz kapağında şişlik',
  ], urgent: [
    'İlk 2 haftada yoğun irinli akıntı ve göz kapağında şişlik',
    'Göz çevresinde yayılan kızarıklık ve ateş',
  ]),
  CareTopic('Yenidoğan sarılığı', 'Yenidoğanların çoğunda 2–3. gün başlayan hafif sarılık görülür ve 2 haftada geçer.', home: [
    'Sık emzir (günde 8–12 kez); sık beslenme sarılığın atılmasına yardım eder.',
    'Sarılığı gün ışığında bebeğin cildine ve göz beyazına bakarak izle.',
    'Bebeği doğrudan güneşe çıkarma; güneş ışığı tedavi yerine geçmez.',
  ], doctor: [
    'Sarılık 2 haftadan uzun sürüyorsa (prematürede 3 hafta)',
    'Sarılık karına ve bacaklara yayılıyorsa',
    'Bebek uykulu ve emmekte isteksizse',
  ], urgent: [
    'İlk 24 saatte başlayan sarılık',
    'Soluk (beyaz, gri) kaka ya da koyu renkli idrar',
    'Çok uykulu, gevşek, emmeyen bebek',
  ]),
];

const breastfeedingTopics = <CareTopic>[
  CareTopic('Ağrılı emzirme, meme ucu çatlağı', 'İlk günlerde hafif hassasiyet olabilir; emzirme boyunca süren ağrı çoğunlukla kötü kavramadan kaynaklanır.', home: [
    'Bebeğin ağzı genişçe açıkken memeye getir; alt dudağı dışa dönük, çenesi memeye değsin.',
    'Kavrama acıtıyorsa serçe parmağını ağız köşesine sokup vakumu boz ve yeniden dene.',
    'Emzirmeden sonra birkaç damla sütü meme ucuna sürüp kurumaya bırak.',
    'Farklı emzirme pozisyonları dene.',
  ], doctor: [
    'Ağrı ilk haftadan sonra da sürüyorsa',
    'Çatlak iyileşmiyor ya da kanıyorsa',
    'Bebekte dil bağı olabileceğini düşünüyorsan',
    'Bir ebeden ya da emzirme danışmanından destek iste.',
  ], urgent: [
    'Memede kızarıklık, sıcaklık ve ateş (mastit olabilir)',
  ]),
  CareTopic('Meme dolgunluğu', 'Doğumdan 2–5 gün sonra süt gelince memeler şişip sertleşebilir.', home: [
    'Sık ve istekle emzir, en az 2–3 saatte bir.',
    'Meme çok sertse emzirmeden önce biraz süt sağarak yumuşat.',
    'Emzirmeden sonra 10–15 dakika soğuk kompres uygula.',
    'Sıkmayan, destekleyici bir sütyen kullan.',
  ], doctor: [
    'Dolgunluk 2 günde azalmıyorsa',
    'Bebek memeyi kavrayamıyorsa',
  ], urgent: [
    '38 °C üstü ateş ve titreme',
  ]),
  CareTopic('Tıkalı süt kanalı', 'Memede hassas, ağrılı bir şişlik ya da sertlik olur; ateş genellikle yoktur.', home: [
    'O memeden sık emzirmeye devam et.',
    'Bebeğin çenesi sertliğe bakacak şekilde pozisyon değiştir.',
    'Hafif dokunuşla masaj yap; sert ovmak iltihabı artırabilir.',
    'Soğuk kompres ve dinlenme şişliği azaltır.',
  ], doctor: [
    'Sertlik 2–3 günde geçmiyorsa',
    'Aynı yer tekrar tekrar tıkanıyorsa',
  ], urgent: [
    'Ateş, titreme ve grip benzeri halsizlik',
  ]),
  CareTopic('Mastit', 'Memede kızarıklık, sıcaklık, ağrı ve ateşle seyreden iltihaptır.', home: [
    'Emzirmeye devam et; anne sütü bebeğe zarar vermez.',
    'Dinlen ve bol sıvı al.',
    'Doktorun önerdiği ağrı kesiciyi kullan, soğuk kompres uygula.',
  ], doctor: [
    'Belirtiler 12–24 saatte düzelmiyorsa aynı gün doktora git; antibiyotik gerekebilir.',
    'Memede geçmeyen şişlik (apse olabilir)',
  ], urgent: [
    'Yüksek ateş, hızlı nabız, kendini çok kötü hissetme',
    'Kızarıklık hızla yayılıyorsa',
  ]),
  CareTopic('Sütüm az mı?', 'Annelerin çoğu yeterli süt üretir. En iyi gösterge bebeğin bezleri ve kilo alımıdır.', home: [
    'Günde 8–12 kez, bebek istedikçe emzir.',
    'Her emzirmede iki memeyi de sun.',
    'Ten tene temas ve dinlenme süt üretimini destekler.',
    'Gerekmedikçe ek mama ve emziği sınırla; emme azalırsa üretim de azalır.',
  ], doctor: [
    '5. günden sonra günde 6’dan az ıslak bez',
    'Bebek 2 haftalıkken doğum kilosuna ulaşmadıysa',
    'Bebek emerken hemen uyuyor ve kilo almıyorsa',
  ], urgent: [
    'Sıvı kaybı belirtileri: koyu idrar, kuru ağız, çökük bıngıldak',
  ]),
  CareTopic('Fazla süt, hızlı akış', 'Bebek emerken öksürüyor, memeyi bırakıyor ya da çok gaz yapıyorsa akış hızlı olabilir.', home: [
    'Yarı yaslanarak ya da bebeği dik tutarak emzir.',
    'Süt akmaya başlayınca kısa bir ara verip ilk akışı bir beze al.',
    'Bir öğünde tek memeden emzirmeyi ebe ya da danışmanla birlikte dene.',
    'Sık gaz çıkart.',
  ], doctor: [
    'Bebek kilo almıyor ya da çok huzursuzsa',
    'Sık tıkanma ya da mastit oluyorsa',
  ]),
  CareTopic('Memeyi reddetme', 'Bebek burnu tıkalı olduğu, kulağı ağrıdığı, diş çıkardığı ya da dikkati dağıldığı için memeyi reddedebilir.', home: [
    'Sakin, loş bir odada, bebek uykuluyken emzirmeyi dene.',
    'Ten tene temas kur, zorlamadan memeyi sun.',
    'Burnu tıkalıysa önce burnunu temizle.',
    'Süt üretimini korumak için emzirmediğin öğünlerde süt sağ.',
  ], doctor: [
    'Reddetme 1 günden uzun sürüyor ve bezler azaldıysa',
    'Ateş ya da hastalık belirtileri varsa',
  ], urgent: [
    'Sıvı kaybı belirtileri',
  ]),
  CareTopic('Pamukçuk (meme ve ağız)', 'Bebeğin ağzında silinmeyen beyaz plaklar ve annede yanıcı, batıcı meme ağrısı mantar enfeksiyonu olabilir.', home: [
    'Biberon, emzik ve göğüs pompası parçalarını her gün kaynat.',
    'Emzirmeden sonra meme uçlarını kurut.',
    'Anne ve bebek birlikte tedavi edilir; tedaviyi yarıda bırakma.',
  ], doctor: [
    'Belirtiler varsa anne ve bebek için doktora başvur.',
  ], urgent: [
    'Bebek ağrı nedeniyle hiç beslenemiyorsa',
  ]),
];

/// 0 normal, 1 doktoruna danış, 2 aynı gün doktora.
class StoolColor {
  final String name;
  final String note;
  final int level;
  final int color;
  const StoolColor(this.name, this.note, this.level, this.color);
}

String stoolLevelLabel(int level) => switch (level) {
      0 => 'Normal',
      1 => 'Doktoruna danış',
      _ => 'Aynı gün doktora',
    };

const stoolColors = <StoolColor>[
  StoolColor('Koyu yeşil-siyah, yapışkan (mekonyum)', 'İlk 1–3 gün normaldir; sonra açılır.', 0, 0xFF2F3B1F),
  StoolColor('Hardal sarısı, taneli', 'Anne sütü alan bebeğin tipik kakasıdır.', 0, 0xFFE1B12C),
  StoolColor('Açık kahve, sarı-kahve', 'Mama alan bebekte sık görülür; biraz daha koyu ve kokuludur.', 0, 0xFFA0703C),
  StoolColor('Yeşil', 'Çoğunlukla normaldir; demir takviyesi ya da hızlı sindirim yapabilir. Uzun sürerse danış.', 0, 0xFF5E8C31),
  StoolColor('Turuncu', 'Normaldir.', 0, 0xFFE8892B),
  StoolColor('Sert, top top', 'Kabızlık olabilir; Hasta bebek rehberindeki kabızlık bölümüne bak.', 1, 0xFF6D4C2F),
  StoolColor('Çok sulu ve sık', 'İshal olabilir; sıvı kaybı belirtilerine dikkat et.', 1, 0xFFC9B26B),
  StoolColor('Kırmızı ya da kan çizgili', 'Meme ucu çatlağından yutulan kan ya da makatta çatlak olabilir; doktoruna danış. Kan çoksa hemen başvur.', 1, 0xFFC62828),
  StoolColor('Siyah (ilk günlerden sonra)', 'Sindirim kanalında kanama belirtisi olabilir. Demir takviyesi alıyorsa bunu da söyle.', 2, 0xFF1A1A1A),
  StoolColor('Beyaz, gri ya da kil rengi', 'Karaciğer ya da safra yolu sorununun belirtisi olabilir; mutlaka aynı gün doktora göster.', 2, 0xFFD9D6CF),
];

/// İlk günlerde beklenen bez sayıları (anne sütü alan bebek).
const diaperByDay = <(String, String, String)>[
  ('1. gün', 'En az 1 ıslak bez', 'En az 1 kaka (mekonyum)'),
  ('2. gün', 'En az 2 ıslak bez', 'En az 1–2 kaka (mekonyum)'),
  ('3. gün', 'En az 3 ıslak bez', 'En az 2 kaka, renk açılmaya başlar'),
  ('4. gün', 'En az 4 ıslak bez', 'En az 2 kaka, yeşilden sarıya döner'),
  ('5. gün', 'En az 5 ıslak bez', 'En az 2 sarı kaka'),
  ('6. gün ve sonrası', 'Günde en az 6 ağır ıslak bez', 'İlk 6 hafta günde en az 2 sarı kaka; sonra seyrekleşebilir'),
];

const dehydrationSigns = <String>[
  '6 saatten uzun süre ıslanmayan bez',
  'Koyu sarı, keskin kokulu idrar',
  'Kuru ağız ve dudaklar, gözyaşsız ağlama',
  'Çökük bıngıldak',
  'Aşırı uyku hâli, gevşeklik',
];

const pregnancyUrgentSigns = <String>[
  'Vajinal kanama',
  'Suyun gelmesi ya da sürekli sıvı sızması',
  '28. haftadan sonra bebek hareketlerinin azalması ya da durması',
  'Şiddetli ya da geçmeyen karın ağrısı',
  'Şiddetli baş ağrısı, bulanık görme, gözde ışık çakmaları',
  'El, yüz ve göz çevresinde ani şişlik',
  '37. haftadan önce düzenli kasılmalar ya da kasık ağrısı',
  'Nefes darlığı ya da göğüs ağrısı',
  'Bacakta tek taraflı, ağrılı şişlik ve kızarıklık',
  'Bayılma ya da havale',
  'Kendine ya da bebeğine zarar verme düşünceleri',
];

const pregnancySameDaySigns = <String>[
  '38 °C ve üstü ateş',
  'İdrarda yanma, sık idrara çıkma',
  'Her şeyi kusma, sıvıları tutamama',
  'Özellikle avuç içi ve ayak tabanlarında şiddetli kaşıntı',
  'Kötü kokulu ya da renkli vajinal akıntı',
  'Geçmeyen baş dönmesi',
];

const postpartumUrgentSigns = <String>[
  'Saatte bir ped dolduran ya da artan kanama, büyük pıhtılar',
  'Nefes darlığı ya da göğüs ağrısı',
  'Şiddetli baş ağrısı ve görme bozukluğu',
  'Bacakta tek taraflı, ağrılı şişlik',
  '38 °C üstü ateş ya da kötü kokulu akıntı',
  'Dikiş yerinde açılma, kızarıklık ya da irin',
  'Kendine ya da bebeğine zarar verme düşünceleri',
];

const postpartumSameDaySigns = <String>[
  'İdrar yaparken yanma ya da idrarı tutamama',
  'Memede kızarıklık, sıcaklık ve ağrı',
  '2 haftadan uzun süren derin üzüntü, kaygı ya da uykusuzluk',
];

const formulaSteps = <String>[
  'Hazırlık yerini temizle, ellerini sabunla yıka.',
  'Biberonu, emziği ve kapağı yıka ve sterilize et.',
  'Taze suyu kaynat; 30 dakikadan fazla bekletmeden (en az 70 °C’deyken) kullan.',
  'Önce suyu biberona koy, sonra paketteki ölçeği düz sıyırarak, yazan sayıda ekle.',
  'Kapağı kapatıp mama tamamen eriyene kadar çalkala.',
  'Biberonu akan soğuk suyun altında soğut.',
  'Bileğinin içine birkaç damla damlat: ılık olmalı, sıcak değil.',
  'Bebeği dik tutarak besle; 2 saat içinde bitmeyen mamayı dök.',
];

const formulaDonts = <String>[
  'Mamayı mikrodalgada ısıtma; içinde yakıcı sıcak noktalar oluşabilir.',
  'Su ya da toz miktarını değiştirme; sulandırılmış ya da koyu mama bebeğe zarar verir.',
  'Biberona pirinç unu, bal, şeker ya da başka bir şey ekleme.',
  'Biberonu bir yere yaslayıp bebeği yalnız bırakma.',
  'Artan mamayı bir sonraki öğün için saklama.',
];

const formulaStorage = <String>[
  'En güvenlisi her öğünde taze hazırlamaktır.',
  'Önceden hazırlayacaksan hemen soğut ve 5 °C altındaki buzdolabında en fazla 24 saat sakla.',
  'Dışarıda yanında taşıyacaksan kaynamış suyu termosta, tozu ayrı kapta taşı ve gerektiğinde hazırla.',
  'Açılmış mama kutusunu kapağı kapalı, kuru yerde tut; paketteki süre içinde bitir.',
];

const formulaFeedingTips = <String>[
  'Miktar için mama paketindeki tabloyu ve doktorunun önerisini izle.',
  'Bebeğin doygunluk işaretlerine saygı göster: başını çevirmek, emmeyi yavaşlatmak, biberonu itmek.',
  'Biberonu yere paralel tut, ara ara durarak bebeğin kendi hızında içmesine izin ver.',
  'Beslerken göz teması kur ve bebeği kucağında tut.',
];
