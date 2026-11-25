// Öfke nöbeti kaydı, ekran süresi, babalar/destekçiler, kardeşe hazırlık, menopoz takibi.

// ---------------- Öfke nöbetleri ----------------
const tantrumTriggers = <String>['Yorgunluk', 'Açlık', 'Geçiş / ayrılma', '“Hayır” duymak', 'Aşırı uyarılma', 'Diğer'];

/// Süre seçenekleri: etiket ve kayıtta tutulan yaklaşık dakika.
const tantrumDurations = <(String, int)>[('5 dk’dan kısa', 3), ('5–10 dk', 8), ('10–20 dk', 15), ('20 dk’dan uzun', 25)];

const tantrumNowSteps = <String>[
  'Önce güvenliğe bak: çevrede çarpabileceği, düşebileceği bir şey var mı?',
  'Sakin kal; derin nefes al, sesini alçak tut.',
  'Az konuş ve yanında kal; nöbet sırasında açıklamalar işe yaramaz.',
  'Pazarlık yapma, ödül ya da ceza sözü verme.',
  'Geçince kucak sun ve duyguyu adlandır: “Çok kızdın, çünkü parktan çıkmak istemedin.”',
];

const tantrumPrevent = <String>[
  'Uyku ve öğün saatlerini düzenli tut; yorgun ve aç çocuk daha kolay patlar.',
  'Geçişlerden önce haber ver: “5 dakika sonra eve gidiyoruz.”',
  'Küçük seçenekler sun: “Mavi bardak mı, sarı mı?”',
  'İstenen davranışı fark et ve öv.',
];

const tantrumDoctor = <String>[
  'Nöbetler çok sık, çok uzun ya da 5 yaşından sonra da şiddetliyse',
  'Çocuk kendine ya da başkalarına zarar veriyorsa',
  'Nefes tutma nöbetinde bayılma ya da morarma oluyorsa',
  'Konuşma ya da sosyal gelişimle ilgili başka kaygıların da varsa',
];

class TantrumEntry {
  final DateTime at;
  final String trigger;
  final int minutes;
  const TantrumEntry(this.at, this.trigger, this.minutes);
  Map<String, dynamic> toJson() => {'at': at.toIso8601String(), 'trigger': trigger, 'minutes': minutes};
  static TantrumEntry? fromJson(Object? v) {
    if (v is! Map) return null;
    final at = DateTime.tryParse('${v['at']}');
    final tr = v['trigger'], m = v['minutes'];
    if (at == null || tr is! String || m is! int || m < 0 || m > 600) return null;
    return TantrumEntry(at, tr, m);
  }
}

String timeBand(DateTime t) => t.hour < 12 ? 'Sabah' : t.hour < 17 ? 'Öğleden sonra' : 'Akşam';

class TantrumSummary {
  final int count30;
  final String? topTrigger;
  final String? topBand;
  final int avgMinutes;
  const TantrumSummary(this.count30, this.topTrigger, this.topBand, this.avgMinutes);
}

String? _top(Iterable<String> xs) {
  final c = <String, int>{};
  for (final x in xs) { c[x] = (c[x] ?? 0) + 1; }
  if (c.isEmpty) return null;
  return (c.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;
}

TantrumSummary summarizeTantrums(List<TantrumEntry> all, DateTime now) {
  final from = now.subtract(const Duration(days: 30));
  final recent = all.where((e) => e.at.isAfter(from) && !e.at.isAfter(now)).toList();
  final avg = recent.isEmpty ? 0 : (recent.fold(0, (a, e) => a + e.minutes) / recent.length).round();
  return TantrumSummary(recent.length, _top(recent.map((e) => e.trigger)), _top(recent.map((e) => timeBand(e.at))), avg);
}

// ---------------- Ekran süresi ----------------
/// Günlük önerilen üst sınır (dakika); 0 = önerilmez; null = sayı yerine aile kuralı.
int? screenLimitFor(int months) => months < 24 ? 0 : months < 72 ? 60 : null;

String screenAdviceFor(int months) {
  if (months < 18) return '18 aydan küçüklerde görüntülü aile görüşmeleri dışında ekran önerilmez.';
  if (months < 24) return '18–24 ay: yalnızca kısa süre, kaliteli içerik ve mutlaka bir yetişkinle birlikte izlenmeli.';
  if (months < 72) return '2–5 yaş: günde en fazla 1 saat, kaliteli içerik; mümkünse birlikte izleyin. Daha azı daha iyidir.';
  return '6 yaş ve üstü: tutarlı aile kuralları koyun; ekran uykuyu, hareketi ve aile zamanını engellememeli.';
}

const screenTips = <String>[
  'Yemekte ve yatmadan 1 saat önce ekran yok.',
  'Yatak odasında televizyon, tablet ya da telefon bulundurmayın.',
  'Ekranı sakinleştirici olarak kullanmak yerine başka yollar deneyin.',
  'Birlikte izleyin ve izlediklerinizi konuşun.',
  'Ebeveyn olarak kendi ekran alışkanlığınız da örnek olur.',
];

String dayKey(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Son 7 günün (bugün dahil) ortalama dakikası; yalnızca kayıt girilmiş günler sayılır.
int weekAverage(Map<String, int> minutesByDay, DateTime now) {
  final vals = <int>[];
  for (var i = 0; i < 7; i++) {
    final v = minutesByDay[dayKey(now.subtract(Duration(days: i)))];
    if (v != null) vals.add(v);
  }
  return vals.isEmpty ? 0 : (vals.reduce((a, b) => a + b) / vals.length).round();
}

// ---------------- Babalar ve destekçiler ----------------
const partnerStages = <(String, List<String>)>[
  ('Gebelikte', [
    'Kontrollere birlikte git, sorularınızı birlikte hazırlayın.',
    'Doğum planını birlikte oku; tercihlerini bil ve savun.',
    'Ağır kaldırmayı ve yorucu ev işlerini üstlen.',
    'Gebelikte acil belirtileri öğren; ne zaman hastaneye gidileceğini bil.',
    'Hastane çantasını, yolu ve doğum günü için kimin ne yapacağını planlayın.',
  ]),
  ('Doğumda', [
    'Kasılmaları say, su ve atıştırmalık getir, nefesinde eşlik et.',
    'Ekiple konuşurken onun sözcüsü ol; isteklerini hatırlat.',
    'Ten tene teması ve ilk emzirmeyi destekle.',
    'İlk saatlerde ziyaretçileri sınırla.',
  ]),
  ('İlk 6 hafta', [
    'Gece beslenmelerinde bebeği getir, gazını çıkar, bezini değiştir.',
    'Anne uyurken bebekle sen ilgilen.',
    'Yemek, temizlik ve çamaşırı üstlen ya da organize et.',
    'Ziyaretleri kısa tut, kapıdaki “nöbetçi” sen ol.',
    'Kanama, ateş, dikiş ve ruh hâli değişikliklerini izle; “Nasılsın?” diye her gün sor.',
  ]),
  ('Sonrasında', [
    'Banyo, kitap ya da yürüyüş gibi bebekle baş başa rutinler edin.',
    'Uykuda nöbetleşin; ikinizin de dinlenmesi önemli.',
    'İşe dönüşü birlikte planlayın: kreş, bakıcı, süt sağma.',
    'Birbirinize ve kendinize zaman ayırın.',
  ]),
];

const partnerSelfCare = <String>[
  'Babalarda da doğum sonrası depresyon görülebilir (yaklaşık 10’da 1).',
  'Sürekli yorgunluk, öfke, kaçma isteği, alkol kullanımında artış ya da umutsuzluk varsa aile hekimine ya da bir ruh sağlığı uzmanına başvur.',
  'Kendine ya da başkasına zarar verme düşüncesi varsa hemen 112’yi ara.',
];

// ---------------- Kardeşe hazırlık ----------------
const siblingStages = <(String, List<String>)>[
  ('Gebelikte', [
    'Bebeği yaşına uygun anlat; kitaplar ve kendi bebeklik fotoğrafları yardımcı olur.',
    'Yatak değişimi, tuvalet eğitimi, kreş gibi büyük değişiklikleri doğumdan önce ya da birkaç ay sonra yap.',
    'Doğum sırasında ona kimin bakacağını belirle ve önceden tanıştır.',
    'Bebeğe birlikte küçük bir hediye seçin.',
  ]),
  ('Doğumda', [
    'Hastaneden büyük kardeşi arayın ya da görüntülü konuşun.',
    'İlk karşılaşmada bebek yatağında olsun; kollarını önce büyük kardeşe açın.',
    'Bebekten büyük kardeşe küçük bir hediye hazırlayın.',
  ]),
  ('Eve gelince', [
    'Her gün 10–15 dakika yalnız onunla özel zaman geçir.',
    'Yaşına uygun görevler ver: bez getirmek, şarkı söylemek.',
    'Altına kaçırma, bebek gibi konuşma gibi gerilemeler olağandır; ceza verme.',
    'Duygularını adlandır: “Bazen kızgın hissedebilirsin, bu normal.”',
    'Ziyaretçilerden büyük kardeşle de ilgilenmelerini iste.',
    'Küçük çocuğu bebekle yalnız bırakma.',
  ]),
];

List<String> get siblingItems => [for (final s in siblingStages) ...s.$2];

// ---------------- Menopoz ----------------
const menopauseSymptoms = <String>[
  'Sıcak basması', 'Gece terlemesi', 'Uyku sorunu', 'Ruh hâli değişikliği',
  'Eklem ve kas ağrısı', 'Vajinal kuruluk', 'Unutkanlık, odaklanma güçlüğü', 'Düzensiz kanama',
];

const menopauseLevels = <String>['Yok', 'Hafif', 'Orta', 'Şiddetli'];

const menopauseTips = <String>[
  'Katmanlı giyin, odayı serin tutun; yatakta pamuklu çarşaf kullanın.',
  'Kafein, alkol ve acı baharatlar sıcak basmalarını tetikleyebilir; günlükten izleyin.',
  'Düzenli yürüyüş ve kuvvet egzersizi uykuyu, ruh hâlini ve kemikleri destekler.',
  'Kalsiyum ve D vitamini ihtiyacını doktorunla konuş; sigarayı bırak.',
  'Hormon tedavisi ve hormon dışı seçenekleri doktorunla birlikte değerlendir.',
];

const menopauseDoctor = <String>[
  '12 ay adet görmedikten sonra herhangi bir vajinal kanama',
  'Çok yoğun, uzun ya da sık kanama',
  'Günlük yaşamını bozan sıcak basması, uykusuzluk ya da çökkünlük',
  'Göğüs ağrısı, çarpıntı ya da nefes darlığı',
];

/// Son 30 gün: kayıtlı gün sayısı ve belirti başına ortalama şiddet (0–3).
(int, Map<String, double>) summarizeMenopause(Map<String, Map<String, int>> byDay, DateTime now) {
  final keys = {for (var i = 0; i < 30; i++) dayKey(now.subtract(Duration(days: i)))};
  final days = byDay.entries.where((e) => keys.contains(e.key)).toList();
  final avg = <String, double>{};
  if (days.isEmpty) return (0, avg);
  for (final s in menopauseSymptoms) {
    final total = days.fold<int>(0, (a, e) => a + (e.value[s] ?? 0));
    avg[s] = total / days.length;
  }
  return (days.length, avg);
}
