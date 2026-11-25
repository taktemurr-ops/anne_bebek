// Uyku eğitimi yöntemleri, kreş ve okula hazırlık, gebelik/emzirme egzersiz programı.

// ---------------- Uyku eğitimi ----------------
class SleepMethod {
  final String id, name, age, how, note;
  const SleepMethod(this.id, this.name, this.age, this.how, this.note);
}

const sleepMethods = <SleepMethod>[
  SleepMethod('rutin', 'Yatma rutini', 'Her yaş',
      'Her akşam aynı sırayla 20–30 dakikalık sakin bir rutin: banyo, pijama, beslenme, diş, kitap ya da ninni, ışıklar kapalı.',
      'Tüm yöntemlerin temelidir; tek başına bile uykuya dalmayı kolaylaştırır.'),
  SleepMethod('uyanik', 'Uykulu ama uyanık yatırma', '3–4 aydan sonra',
      'Bebeği gözleri kapanmak üzereyken ama henüz uyumadan yatağına bırak; kendi kendine uykuya geçmeyi öğrenir.',
      'İlk günlerde birkaç kez kucağa alman gerekebilir; sabırla tekrarla.'),
  SleepMethod('al_yatir', 'Al-yatır', '4–6 aydan sonra',
      'Ağlarsa kucağına al, sakinleşince hemen yatağına geri bırak; uyuyana kadar tekrarla.',
      'Yorucu olabilir ama ağlamayı en aza indirir.'),
  SleepMethod('sandalye', 'Kademeli uzaklaşma (sandalye yöntemi)', '6 aydan sonra',
      'Yatağın yanında bir sandalyede otur, uyuyana kadar sakin ol. Her 2–3 gecede bir sandalyeyi kapıya doğru biraz uzaklaştır.',
      'Yavaş ama nazik; 2–3 hafta sürebilir.'),
  SleepMethod('kontrollu', 'Aralıklı kontrol', '6 aydan sonra',
      'Uyanık yatır ve odadan çık. Ağlarsa giderek uzayan aralıklarla (ör. 3, 5, 10 dakika) kısa süre gir; kucağa almadan sesinle sakinleştir.',
      'Genellikle 1 haftada sonuç verir; her aileye uygun olmayabilir.'),
  SleepMethod('kaydirma', 'Yatma saatini kaydırma', '6 aydan sonra',
      'Bebeğin kendiliğinden uyuduğu saatte yatır, birkaç günde bir 15 dakika erkene çek.',
      'Yatakta uzun süre uyanık kalan bebeklerde işe yarar.'),
];

const sleepTrainingNotes = <String>[
  '6 aydan önce uyku eğitimi genellikle önerilmez; önce düzenli bir rutinle başla.',
  'Hastalık, diş çıkarma, seyahat ya da yeni kardeş gibi dönemlerde başlama.',
  'Seçtiğin yöntemi en az 1–2 hafta her gece aynı şekilde uygula; tutarlılık en önemli şeydir.',
  'Gece beslenmesi ihtiyacını bırakmadan önce çocuk doktoruna danış.',
  'Her yöntemde güvenli uyku kuralları geçerli: sırt üstü, düz ve boş yatak.',
];

// ---------------- Kreş ve okul ----------------
const nurseryStages = <(String, List<String>)>[
  ('Seçerken', [
    'Kreşi çocuğunla birlikte ziyaret et; çocukların mutlu ve ilgili görünüp görünmediğine bak',
    'Öğretmen başına düşen çocuk sayısını ve personelin ilk yardım eğitimini sor',
    'Temizlik, el yıkama, mutfak ve tuvalet düzenine bak',
    'Uyku alanının güvenli olduğundan emin ol (sırt üstü, boş yatak)',
    'Kapı güvenliği, çocuğu kimlerin alabileceği ve acil durum planını sor',
    'Hastalık ve aşı kurallarını öğren',
  ]),
  ('Başlamadan önce', [
    'Uyku ve yemek saatlerini kreşin düzenine yavaşça yaklaştır',
    'Kısa sürelerle başlayan bir uyum haftası planla',
    'Kıyafet ve eşyalara adını yaz; yedek kıyafet hazırla',
    'Alerji, ilaç ve acil durum bilgilerini yazılı ver',
    'Evde kreşten söz eden kitaplar oku, oyun oynayın',
  ]),
  ('İlk günler', [
    'Vedalaşmayı kısa ve net tut; gizlice ortadan kaybolma',
    'Ne zaman geleceğini çocuğun anlayacağı şekilde söyle: “Öğle uykusundan sonra”',
    'Evden tanıdık bir oyuncak ya da battaniye ver',
    'Söz verdiğin saatte gel; güven buradan oluşur',
  ]),
  ('Sonrasında', [
    'Öğretmenle düzenli kısa görüşmeler yap',
    'Uyku, iştah ya da davranış değişikliklerini izle; ilk haftalarda olağandır',
    'Kreşte sık hastalanmak ilk yıl yaygındır; aşılarının tam olduğundan emin ol',
  ]),
];

const schoolStages = <(String, List<String>)>[
  ('Bağımsızlık', [
    'Tuvaletini yardımsız yapabiliyor ve ellerini yıkıyor',
    'Ceketini, ayakkabısını kendisi giyip çıkarabiliyor',
    'Beslenme çantasını açıp yemeğini yiyebiliyor',
    'Adını, soyadını ve bir yakınının telefonunu söyleyebiliyor',
  ]),
  ('Sosyal ve duygusal', [
    'Sırasını bekleyebiliyor, paylaşmayı deniyor',
    'İhtiyacını öğretmene söyleyebiliyor',
    'Kısa süreli ayrılıklarla baş edebiliyor',
    'Basit kurallara uyabiliyor',
  ]),
  ('Öğrenmeye hazırlık', [
    'Kalemi tutup çizgi, daire çizebiliyor; makasla kesebiliyor',
    'Kısa bir hikâyeyi dinleyip anlatabiliyor',
    'Renkleri ve basit şekilleri tanıyor',
    '10’a kadar saymayı deniyor',
  ]),
  ('Aile olarak', [
    'Okul öncesi göz ve işitme kontrolü yaptırın',
    'Aşı kartını kontrol edin',
    'Yatma ve kalkma saatlerini okul düzenine 2–3 hafta önceden alıştırın',
    'Okul yolunu birlikte yürüyün, okulu önceden gezin',
  ]),
];

List<String> get nurseryItems => [for (final s in nurseryStages) ...s.$2];
List<String> get schoolItems => [for (final s in schoolStages) ...s.$2];

// ---------------- Egzersiz programı ----------------
const weeklyExerciseGoal = 150; // dakika, Dünya Sağlık Örgütü önerisi

const exercisePlans = <(String, List<String>)>[
  ('1. trimester', [
    'Tempolu yürüyüş: haftada 5 gün, 30 dakika',
    'Yüzme ya da su içinde yürüyüş',
    'Hafif direnç bandı ile kol ve bacak çalışması',
    'Günde 3 set pelvik taban (Kegel) egzersizi',
  ]),
  ('2. trimester', [
    'Yürüyüş, yüzme ya da sabit bisiklet: günde 20–30 dakika',
    'Gebelik yogası ya da pilatesi (uzun süre sırt üstü kalmadan)',
    'Duvar destekli çömelme (squat): 2 set, 10 tekrar',
    'Kedi-inek esnemesi ile sırt rahatlatma',
  ]),
  ('3. trimester', [
    'Kısa ve sık yürüyüşler; yorulunca dinlen',
    'Su içinde egzersiz: eklemlere yük bindirmeden hareket',
    'Pilates topunda kalça çevirme ve pelvik eğme',
    'Doğuma hazırlık nefesi ve gevşeme',
  ]),
  ('Doğum sonrası ve emzirirken', [
    'İlk haftalarda pelvik taban ve derin karın nefesiyle başla',
    'Kendini hazır hissedince 10–15 dakikalık yürüyüşler; her hafta biraz artır',
    '6–8. hafta kontrolünden sonra kademeli kuvvet çalışması',
    'Koşu ve zıplamayı genellikle 12. haftadan sonra, pelvik taban hazırsa dene',
    'Sezaryen sonrası egzersize doktorunun onayıyla başla',
  ]),
];

const exerciseAvoid = <String>[
  'Düşme ya da karına darbe riski olan sporlar (binicilik, kayak, temas sporları)',
  'Çok sıcak ortamda egzersiz (sıcak yoga, sauna)',
  'Dalış ve yüksek irtifada ağır egzersiz',
  '1. trimesterden sonra uzun süre sırt üstü yatarak yapılan hareketler',
];

const exerciseStop = <String>[
  'Vajinal kanama ya da sıvı gelmesi',
  'Düzenli, ağrılı kasılmalar',
  'Göğüs ağrısı, egzersizden önce başlayan nefes darlığı',
  'Baş dönmesi, bayılma hissi ya da şiddetli baş ağrısı',
  'Baldırda ağrı ya da şişlik',
];

const breastfeedingExerciseTips = <String>[
  'Orta düzey egzersiz süt miktarını ve kalitesini etkilemez.',
  'Egzersizden önce emzir ya da süt sağ; göğüslerin daha rahat olur.',
  'İyi destekleyen bir spor sütyeni giy ve bol su iç.',
  'Karın ortasında ayrılma (diastaz) fark edersen bir fizyoterapiste danış.',
];

String exerciseDayKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Pazartesiden başlayan bu haftanın toplam dakikası.
int weekTotal(Map<String, int> byDay, DateTime now) {
  final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
  var total = 0;
  for (var i = 0; i < 7; i++) {
    total += byDay[exerciseDayKey(start.add(Duration(days: i)))] ?? 0;
  }
  return total;
}

/// Son 7 gecenin ortalama uyanma sayısı ve bir önceki 7 gece (karşılaştırma için).
(double?, double?) wakingAverages(Map<String, int> nights, DateTime now) {
  double? avg(int fromDay) {
    final vals = <int>[];
    for (var i = fromDay; i < fromDay + 7; i++) {
      final v = nights[exerciseDayKey(now.subtract(Duration(days: i)))];
      if (v != null) vals.add(v);
    }
    return vals.isEmpty ? null : vals.reduce((a, b) => a + b) / vals.length;
  }
  return (avg(0), avg(7));
}
