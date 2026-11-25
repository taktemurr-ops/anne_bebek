// Annelik ve çalışma hakları, bebekle seyahat, meme kendi muayenesi, günün bilgisi.
import '../data/encyclopedia/encyclopedia.dart';

const rightsSections = <(String, List<String>)>[
  ('Gebelikte', [
    'Gebelik süresince düzenli doktor kontrolleri için ücretli izin hakkın var.',
    'Hamilelik ya da doğum izni nedeniyle işten çıkarılma geçerli bir neden sayılmaz (İş Kanunu m.5 ve m.18).',
    'Gebe ve emziren çalışanlar için gece çalışması ve ağır işlerle ilgili koruyucu kurallar vardır; işyeri hekimine danış.',
  ]),
  ('Doğum izni', [
    'Analık izni toplam 24 haftadır: doğumdan önce 8, doğumdan sonra 16 hafta (1 Mayıs 2026’dan itibaren).',
    'Çoğul gebelikte doğum öncesi izne 2 hafta eklenir; toplam 26 hafta olur.',
    'Sağlığın uygunsa ve doktor onaylarsa doğum öncesi iznin bir kısmını doğum sonrasına aktarabilirsin.',
    'İzin süresince SGK’dan analık (geçici iş göremezlik) ödeneği alınır; prim günü şartı vardır.',
    'Eşin işçiyse 10 gün ücretli babalık izni hakkı vardır.',
  ]),
  ('Doğumdan sonra', [
    'Süt izni: bebeğin 1 yaşına kadar günde toplam 1,5 saat; hangi saatlerde kullanacağını sen belirlersin ve çalışmadan sayılır.',
    'İstersen analık izninden sonra 6 aya kadar ücretsiz izin kullanabilirsin.',
    'Yarım çalışma: ilk doğumda 60, ikincide 120, sonrakilerde 180 gün, haftalık sürenin yarısı kadar çalışırsın. Şartları sağlarsan İŞKUR yarım çalışma ödeneği öder; bu dönemde süt izni kullanılmaz.',
    'Yarım çalışma ödeneği için analık izni bittikten sonra 30 gün içinde İŞKUR’a başvur; geciken günler ödemeden düşülür.',
    'Kısmi süreli çalışma: çocuk ilkokula başlayana kadar ebeveynlerden biri, 1 ay önceden yazılı olarak isteyebilir.',
  ]),
  ('Memurlar', [
    'Devlet memurlarında da analık izni 24 haftadır.',
    'Memurlarda süt izni ilk 6 ay günde 3 saat, sonraki 6 ay günde 1,5 saattir; yarım zamanlı çalışma ve aylıksız izin kuralları ayrıdır. Kurumunun insan kaynaklarına danış.',
  ]),
  ('Başvurular ve destekler', [
    'Doğum yardımı ve SGK emzirme ödeneği gibi destekler için e-Devlet ve SGK’yı kontrol et; tutarlar her yıl güncellenir.',
    'İzin ve başvuru tarihlerini Aile hatırlatıcılarına eklersen süreleri kaçırmazsın.',
  ]),
];

const travelPhases = <(String, List<String>)>[
  ('Yola çıkmadan', [
    'Bebeğin kimliği ya da pasaportu, aşı kartı ve sağlık bilgileri',
    'Doktorun önerdiği ilaçlar, ateş ölçer, serum fizyolojik ve ilk yardım malzemeleri',
    'Yolculuk süresinden fazla bez, ıslak mendil ve yedek kıyafet',
    'Mama ya da süt, biberon ve termosta kaynamış su',
    'Tanıdık battaniye ya da oyuncak',
    'Gidilen yerdeki en yakın hastane ve acil numarası',
  ]),
  ('Araçla', [
    'Araca doğru takılmış, yaşına uygun (bebekte arkaya bakan) oto koltuğu',
    'Her 2 saatte bir mola; bebeği koltuktan çıkarıp hareket ettir',
    'Bebeği araçta bir dakika bile yalnız bırakma',
    'Güneşlik ve havalandırma; aşırı ısınmayı önle',
  ]),
  ('Uçakla', [
    'Havayolunun bebek kurallarını (yaş sınırı, puset, beşik koltuk) önceden öğren',
    'Kalkış ve inişte emzir ya da biberon/emzik ver; yutkunmak kulak basıncını azaltır',
    'Bebek mamasını ve sütü güvenlik kontrolünde görevliye bildir; genellikle izin verilir',
    'Bebeği kucağında taşıyorsan ek bebek kemerini kullan',
  ]),
  ('Varınca', [
    'Uyku alanı düz ve boş olsun; yastık, yorgan ve oyuncak koyma',
    'Prizleri, balkonu, pencereleri ve ilaçları kontrol et',
    'Sıcak havada sık emzir ve bebeği doğrudan güneşten koru',
  ]),
];

List<String> get travelItems => [for (final p in travelPhases) ...p.$2];

const breastExamWhen =
    'Ayda bir, adetin bittikten 3–5 gün sonra yap. Adet görmüyorsan her ayın aynı günü yap.';

const breastExamSteps = <String>[
  'Ayna karşısında kolların yanında dur: iki memenin şekline, boyutuna ve cildine bak.',
  'Kollarını başının üstüne kaldır ve aynı değişiklikleri kontrol et.',
  'Ellerini beline koyup göğüs kaslarını sık; ciltte çekinti ya da kabarıklık var mı bak.',
  'Sırt üstü uzan, muayene edeceğin tarafın omzunun altına küçük bir yastık koy.',
  'Karşı elinin orta üç parmağının iç yüzüyle küçük daireler çizerek hafif, orta ve derin bastır.',
  'Köprücük kemiğinden sütyen hattına, koltuk altından göğüs kemiğine kadar memenin tamamını tara.',
  'Koltuk altını da aynı şekilde yokla.',
  'Meme başını hafifçe sık; akıntı olup olmadığına bak.',
  'Diğer tarafta tekrarla. Duşta sabunlu elle ayakta da yapabilirsin.',
];

const breastExamDoctor = <String>[
  'Yeni bir kitle, sertlik ya da kalınlaşma',
  'Ciltte çekinti, kızarıklık ya da portakal kabuğu görünümü',
  'Meme başında yeni içe dönme, yara ya da kanlı akıntı',
  'Koltuk altında şişlik',
  'Tek memede geçmeyen ağrı ya da boyut değişikliği',
];

const breastScreening = <String>[
  '20 yaşından itibaren ayda bir kendi kendine meme muayenesi',
  '40–69 yaş: yılda bir doktor muayenesi ve 2 yılda bir ücretsiz mamografi (KETEM, aile sağlığı merkezi)',
  '30–65 yaş: 5 yılda bir ücretsiz HPV-DNA testi (rahim ağzı kanseri taraması)',
  'Kendi muayenen mamografinin yerini tutmaz; ailende meme kanseri varsa doktorunla daha erken taramayı konuş.',
];

/// Günün bilgisi: tarih değişince değişen, bağlama uygun bir ansiklopedi başlığı.
EncyclopediaTopic dailyTopic(DateTime day, {bool hasBaby = false, bool pregnant = false}) {
  final cats = <String>{
    if (hasBaby) ...['Bebek (0–12 ay)', 'Çocuk (1–6 yaş)', 'Lohusalık ve Emzirme'],
    if (pregnant) ...['Gebelik', 'Doğum'],
  };
  final pool = cats.isEmpty
      ? encyclopediaTopics
      : encyclopediaTopics.where((e) => cats.contains(e.category)).toList();
  final list = pool.isEmpty ? encyclopediaTopics : pool;
  final dayIndex = DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/ 86400000;
  return list[dayIndex % list.length];
}
