/// General educational pregnancy guide. Dating and care plans require clinical confirmation.
class PregnancyWeekGuide {
  final int week;
  final String development;
  final String maternalChanges;
  final String preparation;
  final String safety;
  const PregnancyWeekGuide(this.week, this.development, this.maternalChanges, this.preparation, this.safety);
}

const _milestones = <String>[
  'Gebelik haftaları son adet tarihinden itibaren sayılır; döllenme genellikle daha sonra gerçekleşir.',
  'Erken dönemde hormon değişiklikleri başlar; gebelik henüz testle doğrulanmamış olabilir.',
  'Döllenme ve erken hücresel gelişim bu döneme denk gelebilir.',
  'Yerleşme ve erken gebelik hormonları hakkında sağlık uzmanından bilgi alabilirsin.',
  'Gebelik kesesi ultrasonla değerlendirilmeye başlanabilir; zamanlama kişiye göre değişir.',
  'Embriyonun erken organ gelişimi sürer; ultrason bulguları tarihlendirmeye bağlıdır.',
  'Beyin ve omurilik gibi temel yapılar hızla gelişmektedir.',
  'Kol ve bacak taslakları belirginleşir; gelişim bireysel farklılık gösterir.',
  'Yüz yapıları ve hareket sisteminin temelleri gelişmeye devam eder.',
  'Organların temel yapıları şekillenmektedir; takip planını doktorunla gözden geçir.',
  'Embriyonik dönemden fetal döneme geçiş yaklaşır.',
  'Fetüsün hareketleri başlayabilir ancak anne tarafından henüz hissedilmeyebilir.',
  'İlk trimester sonuna yaklaşılır; tarama seçenekleri doktorla değerlendirilir.',
  'İkinci trimester başlar; büyüme ve organların olgunlaşması sürer.',
  'İskelet ve kas sistemi gelişmeye devam eder.',
  'Fetüs hareketleri artar; hissedilme zamanı kişiden kişiye değişir.',
  'Gelişen kaslar ve eklemler daha çeşitli hareketleri destekler.',
  'Bazı gebeler ilk hareketleri bu haftalarda fark etmeye başlayabilir.',
  'İşitmeyle ilişkili yapılar gelişmeyi sürdürür.',
  'Ayrıntılı ultrason değerlendirmesi için sağlık ekibinin önerdiği zaman aralığına girilebilir.',
  'Büyüme hızlanırken organların olgunlaşması devam eder.',
  'Hareketler daha belirgin olabilir; hareket örüntüsü henüz düzenli olmayabilir.',
  'Akciğer gelişimi sürer; doğum sonrası yaşama hazırlık devam eder.',
  'Fetüsün uyku ve hareket dönemleri değişkenlik gösterebilir.',
  'Akciğer ve sinir sistemi gelişmeye devam eder.',
  'Büyüme ve kilo alımı hızlanabilir.',
  'Göz ve duyusal sistemlerin olgunlaşması sürer.',
  'Üçüncü trimester yaklaşırken büyüme ve beyin gelişimi devam eder.',
  'Üçüncü trimester başlar; fetüsün hareket örüntüsünü tanımak önem kazanır.',
  'Beyin ve akciğer gelişimi devam eder.',
  'Fetüsün büyümesiyle rahimdeki alan giderek azalır.',
  'Hareketlerin niteliği değişebilir; belirgin azalma değerlendirilmelidir.',
  'Büyüme, yağ dokusu birikimi ve organ olgunlaşması sürer.',
  'Doğum pozisyonu değişebilir; değerlendirmeyi sağlık ekibi yapar.',
  'Akciğerler olgunlaşmaya devam eder.',
  'Doğum hazırlığı ve doğum yeri planlaması önem kazanır.',
  'Doğum belirtileri ve acil başvuru planını gözden geçir.',
  'Gebelik artık doğuma yakın dönemdedir; doğum zamanı kişiye göre değişir.',
  'Doğum bu haftalarda başlayabilir; sağlık ekibinin önerilerini izle.',
  'Tahmini doğum haftasıdır; tarih kesin değildir.',
];

PregnancyWeekGuide pregnancyGuideForWeek(int week) {
  if (week < 1 || week > 40) throw RangeError.range(week, 1, 40, 'week');
  final trimester = week <= 13 ? 1 : week <= 27 ? 2 : 3;
  final maternal = trimester == 1
      ? 'Bulantı, yorgunluk ve meme hassasiyeti görülebilir; her gebelik farklıdır. Şikâyetlerini not ederek kontrolünde paylaş.'
      : trimester == 2
          ? 'Enerji düzeyinde değişiklik, cilt değişimleri ve büyüyen karınla ilişkili yakınmalar olabilir. Rahatlık ve hareket konusunda doktorunun önerisini izle.'
          : 'Uyku güçlüğü, sık idrara çıkma ve hareketle ilgili rahatsızlıklar görülebilir. Yeni veya şiddetli belirtileri sağlık ekibine bildir.';
  final prep = week <= 13
      ? 'Gebelik doğrulaması, ilaçların gözden geçirilmesi, folat desteği ve tarama seçeneklerini doktorunla konuş.'
      : week <= 27
          ? 'Önerilen kontrolleri, ultrason değerlendirmelerini ve gebelik diyabeti taraması zamanlamasını sağlık ekibinle planla.'
          : 'Doğum yeri, ulaşım, destek kişisi, hastane çantası ve doğum sonrası bakım planını netleştir.';
  return PregnancyWeekGuide(week, _milestones[week - 1], maternal, prep,
      'Şiddetli ağrı, yoğun kanama, su gelmesi, şiddetli baş ağrısı, görme değişikliği veya belirgin hareket azalmasında gecikmeden tıbbi değerlendirme al.');
}
