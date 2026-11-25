// Ek rehberler: gebelik/emzirme besin güvenliği, gebelikte kilo alımı,
// ağlayan bebek, yaşa göre uyku ve ev güvenliği.
// Kaynaklar: NHS, ACOG, ABD FDA/EPA balık önerisi, IOM 2009 gebelik kilo
// rehberi, AASM 2016 uyku önerileri, AAP güvenli uyku ve ev güvenliği.

// ---------------- Yiyebilir miyim? ----------------

enum FoodVerdict { safe, caution, avoid }

class FoodSafety {
  final String name;
  final FoodVerdict pregnancy;
  final FoodVerdict breastfeeding;
  final String note;
  const FoodSafety(this.name, this.pregnancy, this.breastfeeding, this.note);
}

const _s = FoodVerdict.safe, _c = FoodVerdict.caution, _a = FoodVerdict.avoid;

const foodSafetyList = <FoodSafety>[
  FoodSafety('Alkol', _a, _a, 'Gebelikte güvenli bir miktarı yoktur. Emzirirken en güvenlisi içmemektir; içildiyse 1 kadeh için en az 2–3 saat beklenmeli.'),
  FoodSafety('Kahve, çay, kola (kafein)', _c, _c, 'Günde en fazla 200 mg kafein: yaklaşık 2 fincan filtre kahve ya da 4 bardak çay.'),
  FoodSafety('Enerji içecekleri', _a, _a, 'Yüksek kafein ve uyarıcı içerir.'),
  FoodSafety('Çiğ ya da az pişmiş et (tartar, çiğ köfte)', _a, _s, 'Toksoplazma ve bakteri riski; et içi pembe kalmayacak şekilde pişirilmeli.'),
  FoodSafety('İyi pişmiş et ve tavuk', _s, _s, 'Demir ve protein için iyi kaynak.'),
  FoodSafety('Sucuk, salam, pastırma', _c, _s, 'Gebelikte iyice pişirilerek (tavada sıcak) yenmeli; soğuk yenmemeli.'),
  FoodSafety('Pate ve ciğer', _a, _c, 'Gebelikte A vitamini fazlalığı ve listeria riski. Emzirirken ara sıra.'),
  FoodSafety('Çiğ ya da az pişmiş yumurta', _a, _s, 'Salmonella riski; sarısı ve beyazı katılaşana kadar pişirilmeli. Ev yapımı mayonez dahil.'),
  FoodSafety('İyi pişmiş yumurta', _s, _s, 'Protein ve kolin kaynağı.'),
  FoodSafety('Pastörize süt, yoğurt, ayran', _s, _s, 'Kalsiyum ve protein için önerilir.'),
  FoodSafety('Pastörize edilmemiş (çiğ) süt ve köy peyniri', _a, _c, 'Listeria ve brusella riski; pastörize ürünler tercih edilmeli.'),
  FoodSafety('Kaşar, beyaz peynir (pastörize)', _s, _s, 'Pastörize sütten yapılanlar güvenlidir.'),
  FoodSafety('Küflü yumuşak peynirler (brie, camembert, rokfor)', _a, _s, 'Gebelikte yalnızca dumanı tütene kadar pişirilerek yenebilir.'),
  FoodSafety('Suşi ve çiğ balık', _a, _s, 'Gebelikte parazit ve bakteri riski; pişmiş suşi çeşitleri seçilebilir.'),
  FoodSafety('Soğuk füme somon', _a, _s, 'Listeria riski; gebelikte pişirilerek yenebilir.'),
  FoodSafety('Somon, hamsi, sardalya, levrek, çupra', _s, _s, 'Haftada 2–3 porsiyon önerilir; omega-3 kaynağı.'),
  FoodSafety('Ton balığı', _c, _c, 'Konserve açık ton haftada 1–2 porsiyon; büyük ton balığı (biftek) daha seyrek.'),
  FoodSafety('Kılıç balığı, köpek balığı, kral uskumru', _a, _a, 'Cıva oranı yüksektir.'),
  FoodSafety('Midye, karides (iyi pişmiş)', _s, _s, 'Çiğ ya da az pişmiş deniz ürünlerinden kaçınılmalı.'),
  FoodSafety('Çiğ filizler (yonca, soya filizi)', _a, _c, 'Bakteri riski; iyice pişirilerek yenebilir.'),
  FoodSafety('Yıkanmamış meyve ve sebze', _a, _a, 'Toksoplazma riski; bol suyla iyice yıkanmalı.'),
  FoodSafety('Meyve ve sebzeler (yıkanmış)', _s, _s, 'Günde en az 5 porsiyon hedeflenmeli.'),
  FoodSafety('Kuruyemiş ve fıstık', _s, _s, 'Alerjin yoksa yiyebilirsin; gebelikte yemek bebekte alerjiyi artırmaz.'),
  FoodSafety('Bal', _s, _s, 'Yetişkin için güvenlidir; yalnızca 1 yaşından küçük bebeklere verilmez.'),
  FoodSafety('Tatlandırıcılar (aspartam, sukraloz)', _c, _c, 'Ölçülü kullanım güvenli kabul edilir; sakarinden kaçın.'),
  FoodSafety('Bitki çayları', _c, _c, 'Günde 1–2 fincan; adaçayı ve nane fazlası süt miktarını azaltabilir. Rezene, meyan kökü ve sinameki gebelikte önerilmez.'),
  FoodSafety('Ciğer yağı (balık yağı değil) ve A vitamini takviyesi', _a, _c, 'Gebelikte yüksek A vitamini bebeğe zarar verebilir.'),
  FoodSafety('Folik asit', _s, _s, 'Gebeliğin ilk 12 haftasında günde 400 mikrogram önerilir.'),
  FoodSafety('Sigara ve nargile', _a, _a, 'Bebeğin gelişimine ve ani bebek ölümü riskine etkisi kanıtlanmıştır; pasif içicilik de zararlıdır.'),
  FoodSafety('Hazır salatalar ve açık büfe', _c, _s, 'Gebelikte buzdolabında bekletilmiş hazır salatalarda listeria riski; taze hazırlananı seç.'),
  FoodSafety('Kırmızı pul biber ve baharatlar', _s, _s, 'Güvenlidir; mide yanması yapıyorsa azalt.'),
  FoodSafety('Şeftali, ananas, papaya', _s, _s, 'Olgun meyveler güvenlidir; “düşük yaptırır” inanışının bilimsel dayanağı yoktur.'),
];

String foodVerdictLabel(FoodVerdict v) => switch (v) {
      FoodVerdict.safe => 'Güvenli',
      FoodVerdict.caution => 'Dikkatli / sınırlı',
      FoodVerdict.avoid => 'Kaçın',
    };

// ---------------- Gebelikte kilo alımı (IOM 2009, tekil gebelik) ----------------

class WeightGainPlan {
  final double bmi;
  final String category;
  final double totalMin, totalMax; // kg
  final double weeklyMin, weeklyMax; // 2. ve 3. trimester kg/hafta
  const WeightGainPlan(this.bmi, this.category, this.totalMin, this.totalMax, this.weeklyMin, this.weeklyMax);

  /// [week] haftasına kadar önerilen toplam artış aralığı (kg).
  (double, double) expectedBy(int week) {
    if (week <= 13) return (0, 2.0 * week.clamp(0, 13) / 13);
    final w = (week.clamp(14, 40) - 13).toDouble();
    return (0.5 + w * weeklyMin, 2.0 + w * weeklyMax);
  }
}

WeightGainPlan? weightGainPlan(double weightKg, double heightCm) {
  if (weightKg < 30 || weightKg > 250 || heightCm < 120 || heightCm > 220) return null;
  final h = heightCm / 100;
  final bmi = weightKg / (h * h);
  if (bmi < 18.5) return WeightGainPlan(bmi, 'Zayıf', 12.5, 18, 0.44, 0.58);
  if (bmi < 25) return WeightGainPlan(bmi, 'Normal kilolu', 11.5, 16, 0.35, 0.50);
  if (bmi < 30) return WeightGainPlan(bmi, 'Fazla kilolu', 7, 11.5, 0.23, 0.33);
  return WeightGainPlan(bmi, 'Obez', 5, 9, 0.17, 0.27);
}

// ---------------- Ağlayan bebek ----------------

const cryingChecklist = <(String, String)>[
  ('Aç mı?', 'Son beslenmeden bu yana geçen süreye bak; yenidoğanlar 2–3 saatte bir acıkır. Açlık işaretleri: ellerini emme, başını çevirip arama.'),
  ('Bezi ıslak ya da kirli mi?', 'Bezi kontrol et; pişik varsa bariyer krem sür.'),
  ('Gazı mı var?', 'Dik tutup sırtını sıvazla, geğirt. Sırtüstü yatırıp bacaklarını bisiklet çevirir gibi oynat.'),
  ('Üşüyor ya da terledi mi?', 'Ensesine dokun: terliyse bir kat azalt, soğuksa bir kat ekle. Oda 20–22 °C olmalı.'),
  ('Yoruldu mu?', 'Esneme, göz ovma, boşluğa bakma uykuya hazır olduğunu gösterir. Işığı azalt, ortamı sakinleştir.'),
  ('Kucak ve yakınlık istiyor mu?', 'Ten tene temas, kundak (kalçaları serbest), yavaş sallanma ve hafif “şşş” sesi rahatlatır.'),
  ('Ortamı değiştir', 'Pusetle kısa bir yürüyüş, beyaz gürültü ya da ılık bir banyo deneyebilirsin.'),
  ('Rahatsızlık işareti var mı?', 'Ateşini ölç; giysi etiketine, saçın parmağa dolanmasına, burun tıkanıklığına bak.'),
];

const colicFacts = <String>[
  'Kolik: sağlıklı bir bebeğin günde 3 saatten fazla, haftada 3 günden fazla, en az 3 hafta boyunca nedensiz ağlamasıdır.',
  'Genellikle 2. haftada başlar, 6. haftada en yoğun hâline ulaşır ve 3–4 ayda kendiliğinden geçer.',
  'Çoğunlukla akşam saatlerinde olur; bebeğin bir şeyi olduğu ya da senin bir hata yaptığın anlamına gelmez.',
  'Emziren anne beslenmesini doktora danışmadan kısıtlamamalı; mama değiştirme kararı da doktorla verilmeli.',
];

const cryingSafetyPlan = <String>[
  'Bebeği güvenli yatağına sırtüstü yatır.',
  'Odadan çık, kapıyı kapat ve 10–15 dakika kendini sakinleştir (nefes egzersizi, su içmek, birini aramak).',
  'Her 5–10 dakikada bir kontrol et.',
  'Eşinden, bir yakınından ya da komşundan yardım iste; yardım istemek zayıflık değildir.',
  'Bebeği asla sarsma. Sarsmak birkaç saniyede kalıcı beyin hasarına ve ölüme yol açabilir.',
];

const cryingRedFlags = <String>[
  '3 aydan küçük bebekte 38 °C ve üstü ateş',
  'Ağlamanın tiz, farklı ya da zayıf olması',
  'Beslenmeyi reddetme, tekrarlayan ya da yeşil/fışkırır tarzda kusma',
  'Nefes almakta zorlanma, morarma',
  'Aşırı uyku hâli, gevşeklik, uyandırmakta zorlanma',
  'Bıngıldakta şişlik ya da çökme',
  'Bastırınca solmayan döküntü',
  'Düşme ya da darbe sonrası başlayan ağlama',
];

// ---------------- Yaşa göre uyku ----------------

class SleepNeed {
  final int fromMonth, toMonth;
  final String label;
  final String total; // 24 saatte
  final String naps;
  final String awake; // uyanık kalma süresi
  const SleepNeed(this.fromMonth, this.toMonth, this.label, this.total, this.naps, this.awake);
}

const sleepNeeds = <SleepNeed>[
  SleepNeed(0, 3, '0–3 ay', '14–17 saat', 'Gün içinde çok sayıda kısa uyku', '45–90 dakika'),
  SleepNeed(4, 6, '4–6 ay', '12–16 saat', '3 gündüz uykusu', '1,5–2,5 saat'),
  SleepNeed(7, 9, '7–9 ay', '12–16 saat', '2–3 gündüz uykusu', '2–3 saat'),
  SleepNeed(10, 12, '10–12 ay', '12–16 saat', '2 gündüz uykusu', '3–4 saat'),
  SleepNeed(13, 18, '13–18 ay', '11–14 saat', '1–2 gündüz uykusu', '3–5 saat'),
  SleepNeed(19, 36, '1,5–3 yaş', '11–14 saat', '1 gündüz uykusu', '5–6 saat'),
  SleepNeed(37, 72, '3–6 yaş', '10–13 saat', '0–1 gündüz uykusu', 'Gün boyu'),
];

SleepNeed sleepNeedFor(int months) =>
    sleepNeeds.firstWhere((s) => months <= s.toMonth, orElse: () => sleepNeeds.last);

const safeSleepRules = <String>[
  'Bebeği her uykuda sırtüstü yatır; yan ya da yüzüstü değil.',
  'Sert, düz bir yatak kullan; yastık, yorgan, oyuncak ve kenar koruyucu koyma.',
  'İlk 6 ay bebeği kendi yatağında ama sizin odanızda uyut.',
  'Kanepede ya da koltukta bebekle birlikte uyuma; alkol, sigara ya da uyku ilacı kullandıysan aynı yatakta uyutma.',
  'Odayı fazla ısıtma (20–22 °C); bebeğin başını örtme.',
  'Uyku sırasında emzik vermek ani bebek ölümü riskini azaltabilir (emzirme oturduktan sonra).',
];

// ---------------- Ev güvenliği ----------------

class SafetyItem {
  final String id;
  final String stage;
  final String text;
  const SafetyItem(this.id, this.stage, this.text);
}

const safetyStages = ['Yenidoğan (0–3 ay)', 'Dönme ve emekleme (4–9 ay)', 'Yürüme (10–24 ay)', 'Çocuk (2–5 yaş)'];

const homeSafetyItems = <SafetyItem>[
  SafetyItem('s_back', 'Yenidoğan (0–3 ay)', 'Bebek sırtüstü, boş ve düz bir yatakta uyuyor'),
  SafetyItem('s_car', 'Yenidoğan (0–3 ay)', 'Araçta arkaya bakan, doğru takılmış oto koltuğu kullanılıyor'),
  SafetyItem('s_bath', 'Yenidoğan (0–3 ay)', 'Banyo suyu 37 °C civarında; bebek suda bir an bile yalnız bırakılmıyor'),
  SafetyItem('s_boiler', 'Yenidoğan (0–3 ay)', 'Sıcak su (şofben/kombi) 50 °C’nin altına ayarlı'),
  SafetyItem('s_smoke', 'Yenidoğan (0–3 ay)', 'Duman ve karbonmonoksit dedektörü takılı'),
  SafetyItem('s_nosmoke', 'Yenidoğan (0–3 ay)', 'Evde ve arabada sigara içilmiyor'),
  SafetyItem('s_table', 'Yenidoğan (0–3 ay)', 'Alt değiştirme masasında bebek yalnız bırakılmıyor'),
  SafetyItem('s_hot', 'Yenidoğan (0–3 ay)', 'Bebek kucaktayken sıcak içecek içilmiyor'),
  SafetyItem('c_sockets', 'Dönme ve emekleme (4–9 ay)', 'Prizlere kapak takıldı'),
  SafetyItem('c_furniture', 'Dönme ve emekleme (4–9 ay)', 'Kitaplık, TV ve dolaplar duvara sabitlendi'),
  SafetyItem('c_stairs', 'Dönme ve emekleme (4–9 ay)', 'Merdivenin üstüne ve altına güvenlik kapısı takıldı'),
  SafetyItem('c_small', 'Dönme ve emekleme (4–9 ay)', 'Tuvalet kâğıdı rulosundan geçebilecek küçük nesneler yerde yok'),
  SafetyItem('c_battery', 'Dönme ve emekleme (4–9 ay)', 'Düğme piller ve mıknatıslı oyuncaklar ulaşılamaz yerde'),
  SafetyItem('c_meds', 'Dönme ve emekleme (4–9 ay)', 'İlaçlar ve temizlik ürünleri kilitli dolapta'),
  SafetyItem('c_cords', 'Dönme ve emekleme (4–9 ay)', 'Elektrik kabloları ve perde ipleri ulaşılamaz durumda'),
  SafetyItem('c_cloth', 'Dönme ve emekleme (4–9 ay)', 'Masa örtüsü yok; sıcak tencere ve çaydanlık kenarda değil'),
  SafetyItem('w_windows', 'Yürüme (10–24 ay)', 'Pencerelere emniyet kilidi takıldı; altlarında tırmanılacak eşya yok'),
  SafetyItem('w_balcony', 'Yürüme (10–24 ay)', 'Balkon kapısı kilitli; balkonda tırmanılacak eşya yok'),
  SafetyItem('w_stove', 'Yürüme (10–24 ay)', 'Ocak düğmeleri korumalı, tencere sapları içe dönük'),
  SafetyItem('w_cabinets', 'Yürüme (10–24 ay)', 'Mutfak ve banyo dolaplarına kilit takıldı'),
  SafetyItem('w_water', 'Yürüme (10–24 ay)', 'Kova, küvet ve leğenlerde su bırakılmıyor; klozet kapağı kilitli'),
  SafetyItem('w_corners', 'Yürüme (10–24 ay)', 'Sivri masa köşelerine koruyucu takıldı'),
  SafetyItem('w_doors', 'Yürüme (10–24 ay)', 'Kapılara parmak sıkışma koruyucusu takıldı'),
  SafetyItem('w_plants', 'Yürüme (10–24 ay)', 'Zehirli olabilecek bitkiler (difenbahya, zakkum vb.) kaldırıldı'),
  SafetyItem('k_seat', 'Çocuk (2–5 yaş)', 'Boyuna ve kilosuna uygun oto koltuğu kullanılıyor'),
  SafetyItem('k_helmet', 'Çocuk (2–5 yaş)', 'Bisiklet ve scooter’da kask takılıyor'),
  SafetyItem('k_pool', 'Çocuk (2–5 yaş)', 'Havuz, deniz ve gölde çocuk kol mesafesinde gözetleniyor'),
  SafetyItem('k_fire', 'Çocuk (2–5 yaş)', 'Çakmak ve kibritler ulaşılamaz yerde'),
  SafetyItem('k_street', 'Çocuk (2–5 yaş)', 'Sokakta el ele yürüme ve karşıdan karşıya geçme kuralları öğretildi'),
  SafetyItem('k_name', 'Çocuk (2–5 yaş)', 'Çocuk adını, soyadını ve bir yakınının telefonunu biliyor'),
];
