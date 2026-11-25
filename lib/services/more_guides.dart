// Bebek bakımı nasıl yapılır, konuşma ve dil gelişimi,
// doğum sonrası korunma yöntemleri.

class HowToTopic {
  final String name;
  final String intro;
  final List<String> steps;
  final List<String> cautions;
  final List<String> doctor;
  const HowToTopic(this.name, this.intro, {this.steps = const [], this.cautions = const [], this.doctor = const []});
}

const babyCareHowTos = <HowToTopic>[
  HowToTopic('Banyo', 'Yenidoğanı haftada 2–3 kez yıkamak yeterlidir. Göbek düşene kadar silerek temizlemek de olur.', steps: [
    'Havlu, temiz bez ve kıyafeti önceden hazırla.',
    'Odayı sıcak tut, cereyan olmasın.',
    'Küvete 5–8 cm su koy; suyu dirseğinle ya da termometreyle kontrol et (yaklaşık 37 °C).',
    'Bebeği başını ve boynunu destekleyerek yavaşça suya indir.',
    'Yüzünü sabunsuz suyla, gözlerini içten dışa doğru sil.',
    'Saçını en son, başını hafifçe arkaya eğerek yıka.',
    'Çıkarır çıkarmaz havluya sar; boyun, koltuk altı ve kasık kıvrımlarını iyice kurula.',
  ], cautions: [
    'Bebeği suda bir an bile yalnız bırakma; kapı ya da telefon için bile.',
    'Parfümsüz, bebekler için yapılmış az miktarda temizleyici kullan.',
    'Suyu musluktan doldururken bebek küvette olmasın.',
  ]),
  HowToTopic('Göbek bakımı', 'Göbek kordonu genellikle 1–2 haftada kendiliğinden kuruyup düşer.', steps: [
    'Göbeği kuru ve temiz tut; havayla temas etsin.',
    'Bezin üst kenarını göbeğin altında kalacak şekilde katla.',
    'Kirlenirse ılık suyla temizle ve iyice kurut.',
  ], cautions: [
    'Alkol, pudra, krem ya da başka bir şey sürme.',
    'Göbeği sarma, bağlama; kordonu kendin koparma.',
    'Düştükten sonra birkaç damla kan olabilir; temiz bir bezle hafifçe bastır.',
  ], doctor: [
    'Göbek çevresinde yayılan kızarıklık ya da şişlik',
    'Kötü kokulu ya da sarı-yeşil akıntı',
    'Ateş ya da bebekte halsizlik',
    'Durmayan kanama',
    'Kordon 3 haftada düşmediyse',
  ]),
  HowToTopic('Tırnak kesme', 'Bebek tırnakları hızlı uzar ve yüzünü çizebilir; haftada 1–2 kez kontrol et.', steps: [
    'Bebek uykuluyken ya da uyurken kes.',
    'Bebek tırnak makası ya da törpüsü kullan.',
    'Parmak ucunu tırnaktan uzaklaşacak şekilde hafifçe aşağı bastır.',
    'El tırnaklarını yuvarlak, ayak tırnaklarını düz kes.',
    'İlk haftalarda törpü kullanmak daha güvenlidir.',
  ], cautions: [
    'Tırnağı ısırarak kısaltma; enfeksiyona yol açabilir.',
    'Kanarsa temiz bir bezle birkaç dakika bastır; yara bandı yutulabilir, kullanma.',
  ], doctor: [
    'Tırnak çevresinde kızarıklık, şişlik ya da iltihap',
  ]),
  HowToTopic('Bez değiştirme', 'Yenidoğanlar günde 8–10 bez kullanabilir; her ıslanmada ya da kirlenmede değiştir.', steps: [
    'Temiz bez, ıslak mendil ya da ılık su ve pamuk, kremi yanına al.',
    'Kirli bezi aç, önü temiz kısmıyla kakayı silerek altına kıvır.',
    'Önden arkaya doğru temizle (kız bebeklerde özellikle).',
    'Kıvrımları kurula, gerekirse bariyer krem sür.',
    'Yeni bezi yerleştir; bel bandı göbeğin altında kalsın, iki parmak sığacak kadar gevşek olsun.',
    'Ellerini yıka.',
  ], cautions: [
    'Bebeği bez değiştirme masasında asla yalnız bırakma; bir elin hep üzerinde olsun.',
    'Erkek bebeklerde sünnet derisini geriye çekmeye çalışma.',
  ]),
  HowToTopic('Gaz çıkarma', 'Beslenirken yutulan hava huzursuzluk yapabilir; beslenme arasında ve sonunda gazını çıkar.', steps: [
    'Omzuna yasla: bebeğin çenesi omzunda olsun, sırtını hafifçe sıvazla.',
    'Kucağında oturt: bir elinle çenesini ve göğsünü destekle, diğeriyle sırtını sıvazla.',
    'Dizlerinde yüzüstü yatır: başı gövdesinden biraz yüksek olsun, sırtını sıvazla.',
    'Omzuna bir bez koy; biraz süt gelmesi normaldir.',
  ], cautions: [
    'Birkaç dakikada gaz çıkmazsa sorun değil; zorlama.',
  ]),
  HowToTopic('Kundaklama', 'Kundak yenidoğanı sakinleştirebilir; doğru yapılmazsa kalça gelişimine zarar verir.', steps: [
    'İnce, hafif bir örtüyü baklava şeklinde ser, üst köşesini içe katla.',
    'Bebeğin omuzlarını katlanan kenarın hizasına yatır.',
    'Bir kolunu yanına alıp örtünün bir ucunu göğsünün üstünden geçirerek sar.',
    'Alt ucu yukarı kaldırırken bacakları serbest bırak; dizler bükülü, kalçalar açık olsun (kurbağa duruşu).',
    'Diğer ucu sararak bitir; göğsünde iki parmak sığacak boşluk kalsın.',
  ], cautions: [
    'Bacakları düz ve sıkı sarma; kalça çıkığı riskini artırır.',
    'Bebek dönmeye çalıştığında kundağı bırak (genellikle 2 ay civarı).',
    'Kundaklı bebeği her zaman sırt üstü yatır ve fazla ısıtma.',
  ]),
  HowToTopic('Burun temizleme', 'Bebekler ağızdan nefes almakta zorlanır; tıkalı burun beslenmeyi ve uykuyu bozar.', steps: [
    'Her burun deliğine birkaç damla serum fizyolojik damlat.',
    '30–60 saniye bekle; sümük yumuşasın.',
    'Burun aspiratörüyle nazikçe çek.',
    'Aspiratörü her kullanımdan sonra yıka ve kurut.',
  ], cautions: [
    'Pamuklu çubuğu burnun içine sokma.',
    'Aspiratörü günde 3–4 kezden fazla kullanmak burnu tahriş edebilir.',
  ], doctor: [
    'Hızlı ya da zorlu nefes alma',
    'Beslenemeyecek kadar tıkanıklık',
    'Ateşle birlikte 10 günden uzun süren akıntı',
  ]),
  HowToTopic('Ağız ve diş bakımı', 'Ağız bakımı ilk dişten önce başlar.', steps: [
    'Dişler çıkmadan önce diş etlerini günde bir kez nemli, temiz bir gazlı bezle sil.',
    'İlk diş çıkınca yumuşak bebek fırçasıyla günde 2 kez fırçala.',
    '3 yaşına kadar pirinç tanesi kadar, 3 yaşından sonra bezelye tanesi kadar florürlü macun kullan.',
    'İlk diş hekimi kontrolünü ilk diş çıktığında ya da en geç 1 yaşında yaptır.',
  ], cautions: [
    'Bebeği biberonla ya da şekerli içecekle uyutma.',
    'Emziği bal ya da şekere batırma.',
  ]),
  HowToTopic('Güneş ve sıcaktan koruma', 'Bebeklerin cildi ince, ısı ayarları gelişmemiştir.', steps: [
    '6 aydan küçük bebekleri doğrudan güneşten uzak tut; gölgede kalın.',
    'Geniş kenarlı şapka ve ince, uzun kollu giysi giydir.',
    '6 aydan sonra açıkta kalan yerlere bebekler için güneş kremi sür.',
    'Sıcak havalarda sık emzir ya da sıvı ver.',
  ], cautions: [
    'Bebeği arabada bir dakika bile yalnız bırakma.',
    'Pusetin üstünü battaniyeyle örtme; içerisi çok ısınır.',
  ], doctor: [
    'Halsizlik, kusma, çok az ıslak bez ya da ateş (sıcak çarpması belirtileri)',
  ]),
];

class SpeechStage {
  final String label;
  final int fromMonths;
  final int toMonths;
  final List<String> expect;
  final List<String> support;
  final List<String> flags;
  const SpeechStage(this.label, this.fromMonths, this.toMonths, {required this.expect, required this.support, required this.flags});
}

const speechStages = <SpeechStage>[
  SpeechStage('0–3 ay', 0, 3, expect: [
    'Yüksek seslere irkilir, senin sesinle sakinleşir',
    'Seni görünce gülümser',
    'Agulama sesleri çıkarır',
    'Farklı ihtiyaçlar için farklı ağlar',
  ], support: [
    'Yüzüne bakarak konuş, şarkı söyle.',
    'Çıkardığı sesleri taklit et; sıra alarak “konuşun”.',
  ], flags: [
    'Yüksek seslere hiç tepki vermiyor',
  ]),
  SpeechStage('4–6 ay', 4, 6, expect: [
    'Gözleriyle sesin geldiği yöne bakar',
    '“ba, pa, ma” gibi sesler çıkarır',
    'Kahkaha atar',
    'Ses tonundaki değişikliği fark eder',
  ], support: [
    'Ses çıkardığında bekle ve cevap ver; karşılıklı sohbet gibi.',
    'Gün içinde ne yaptığını ve ne gördüğünü anlat.',
  ], flags: [
    '6 ayında gülmüyor ya da ses çıkarmıyor',
    'Sesin geldiği yöne dönmüyor',
  ]),
  SpeechStage('7–12 ay', 7, 12, expect: [
    'Adı söylenince döner',
    '“Hayır” sözünü anlar',
    '“baba, dada” gibi heceleri tekrarlar',
    'El sallar, istediğini işaret eder',
    '1 yaşında 1–2 kelime söyleyebilir',
  ], support: [
    'Resimli kitaplara birlikte bak, nesneleri adlandır.',
    'İşaret ettiği şeyi sözcüğe dök: “Kedi mi? Evet, kedi!”',
  ], flags: [
    '9 ayında adına tepki vermiyor',
    '12 ayında işaret etmiyor, el sallamıyor ya da hiç hece söylemiyor',
  ]),
  SpeechStage('12–18 ay', 12, 18, expect: [
    '“anne, baba” dışında birkaç kelime söyler',
    '“Topu ver” gibi basit yönergeleri izler',
    'Sorulunca birkaç vücut bölümünü gösterir',
  ], support: [
    'Söylediği kelimeyi genişlet: “top” → “kırmızı top”.',
    'Ekran süresini sınırla; yüz yüze oyun en iyi dil öğretmenidir.',
  ], flags: [
    '18 ayında en az 3 kelime söylemiyor',
    'İstediğini işaret ederek göstermiyor',
  ]),
  SpeechStage('18–24 ay', 18, 24, expect: [
    'Kelime sayısı hızla artar',
    '2 yaş civarında iki kelimeyi birleştirir: “su ver”',
    'Basit soruları anlar: “Top nerede?”',
  ], support: [
    'Seçenek sun: “Elma mı muz mu?”',
    'Kısa, net cümlelerle konuş; düzeltmek yerine doğrusunu tekrarla.',
  ], flags: [
    '2 yaşında iki kelimeyi birleştirmiyor',
    'Basit yönergeleri anlamıyor',
  ]),
  SpeechStage('2–3 yaş', 24, 36, expect: [
    '2–3 kelimelik cümleler kurar',
    '“Ne? Nerede?” soruları sorar',
    'Yabancılar konuşmasının yarısından fazlasını anlar',
  ], support: [
    'Her gün birlikte kitap oku, sorular sor.',
    'Oyun sırasında yaptıklarını anlat, şarkılar ve tekerlemeler söyle.',
  ], flags: [
    '3 yaşında basit cümle kurmuyor',
    'Yakınları bile konuşmasını çoğunlukla anlamıyor',
  ]),
  SpeechStage('3–5 yaş', 36, 60, expect: [
    '4 ve daha uzun kelimelik cümleler kurar',
    'Olanları ve basit hikâyeleri anlatır',
    '4 yaşında yabancılar konuşmasının çoğunu anlar',
  ], support: [
    'Açık uçlu sorular sor: “Bugün parkta neler yaptın?”',
    'Hikâyenin sonunu ona tamamlat.',
  ], flags: [
    '4 yaşında yabancılar konuşmasını anlamıyor',
    'Kekemelik 6 aydan uzun sürüyor ya da gerginlik, yüz kasılmalarıyla birlikte',
  ]),
];

SpeechStage speechStageFor(int months) =>
    speechStages.firstWhere((s) => months <= s.toMonths, orElse: () => speechStages.last);

const speechGeneralNotes = <String>[
  'Her yaşta önceden yaptığı sesleri, kelimeleri ya da becerileri kaybetmesi hemen doktora danışılmalıdır.',
  'Kaygın varsa çocuk doktoruna söyle; işitme testi ve dil-konuşma terapisti değerlendirmesi istenebilir.',
  'İki dil öğrenmek konuşmayı geciktirmez; her ebeveyn en rahat olduğu dilde konuşabilir.',
  'Çocuklar farklı hızda gelişir; tek bir maddeye değil genel tabloya bak.',
];

class ContraMethod {
  final String name;
  final String effectiveness;
  final String breastfeeding;
  final String notBreastfeeding;
  final String note;
  const ContraMethod(this.name, this.effectiveness, this.breastfeeding, this.notBreastfeeding, this.note);
}

const contraMethods = <ContraMethod>[
  ContraMethod('Emzirme yöntemi (LAM)', 'Yüksek (3 koşul birlikte sağlanırsa)',
      'Ancak şu üç koşul birlikteyse: bebek 6 aydan küçük, adet kanaman başlamamış, bebek gece gündüz yalnızca anne sütüyle besleniyor.',
      'Emzirmiyorsan koruma sağlamaz.',
      'Koşullardan biri bozulduğu anda başka bir yönteme geç.'),
  ContraMethod('Prezervatif', 'Orta-yüksek (her seferinde doğru kullanılırsa)',
      'Hemen kullanılabilir; emzirmeyi etkilemez.',
      'Hemen kullanılabilir.',
      'Cinsel yolla bulaşan enfeksiyonlardan da koruyan tek yöntemdir.'),
  ContraMethod('Bakır spiral (RİA)', 'Çok yüksek',
      'Doğumdan sonraki 48 saat içinde ya da 4 hafta sonra takılabilir; emzirmeyi etkilemez.',
      'Doğumdan sonraki 48 saat içinde ya da 4 hafta sonra takılabilir.',
      'Hormon içermez; çoğu 10 yıl etkilidir ve çıkarılınca doğurganlık hemen döner.'),
  ContraMethod('Hormonlu spiral', 'Çok yüksek',
      'Doğumdan sonraki 48 saat içinde ya da 4 hafta sonra takılabilir; emzirmeyle uyumludur.',
      'Doğumdan sonraki 48 saat içinde ya da 4 hafta sonra takılabilir.',
      'Ürüne göre 3–8 yıl etkilidir; adet kanamasını azaltabilir.'),
  ContraMethod('Deri altı çubuk (implant)', 'Çok yüksek',
      'Doğumdan sonra hemen takılabilir; emzirmeyle uyumludur.',
      'Doğumdan sonra hemen takılabilir.',
      'Kola yerleştirilen küçük bir çubuktur; 3 yıla kadar etkilidir.'),
  ContraMethod('Sadece progestinli hap', 'Yüksek (her gün aynı saatte alınırsa)',
      'Hemen başlanabilir; emzirmeyle uyumludur.',
      'Hemen başlanabilir.',
      'Her gün aynı saatte alınmalıdır; gecikme korumayı azaltır.'),
  ContraMethod('3 aylık iğne', 'Yüksek (iğneler zamanında yapılırsa)',
      'Genellikle doğumdan 6 hafta sonra önerilir.',
      'Hemen başlanabilir.',
      'Bıraktıktan sonra doğurganlığın dönmesi birkaç ay sürebilir.'),
  ContraMethod('Kombine hap, halka ya da bant', 'Yüksek (düzenli kullanılırsa)',
      'Süt miktarını azaltabileceği için emzirirken genellikle 6. aydan sonra önerilir.',
      'En erken doğumdan 3 hafta sonra; pıhtı riskin varsa (sezaryen, sigara, 35 yaş üstü gibi) 6 hafta sonra.',
      'Östrojen içerir; pıhtı öyküsü, migren gibi durumlarda uygun olmayabilir.'),
  ContraMethod('Kalıcı yöntemler (tüp bağlama, vazektomi)', 'Çok yüksek',
      'Tüp bağlama sezaryen sırasında ya da sonrasında yapılabilir.',
      'Tüp bağlama sezaryen sırasında ya da sonrasında yapılabilir.',
      'Kalıcıdır; ileride çocuk istemeyeceğinden emin olmalısın.'),
];

const contraIntro = <String>[
  'Emzirmiyorsan doğumdan 3 hafta sonra bile yumurtlama olabilir; ilk adetten önce gebe kalmak mümkündür.',
  'Dünya Sağlık Örgütü, doğumdan sonra yeniden gebe kalmadan önce en az 24 ay beklemeyi önerir.',
  'Korunmasız ilişki olduysa acil korunma için en kısa sürede doktoruna ya da eczacına başvur; emzirirken de uygun seçenekler vardır.',
];
