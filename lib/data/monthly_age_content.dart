/// 0–72 ay arası yaşa göre genel ebeveynlik önerileri.
/// Klinik gelişim basamağı, tanı, aşı takvimi veya bireysel tıbbi tavsiye değildir.
class MonthlyGuideTopic {
  final int month;
  final String category;
  final String title;
  final String description;
  const MonthlyGuideTopic(this.month, this.category, this.title, this.description);
  String get id => 'monthly_${month}_$category';
}

const monthlyGuideCategories = <String>['Gelişim', 'Beslenme', 'Uyku', 'Oyun', 'Bakım', 'Güvenlik'];

const _focus = <String>[
  'Yeni ortama alışma ve bakım verenle yakın temas',
  'Seslere ve yüzlere dikkat',
  'Karşılıklı ses ve yüz ifadeleri',
  'Baş ve gövde kontrolünü gözlemleme',
  'Etrafı inceleme ve nesnelere uzanma',
  'Ellerle keşif ve birlikte etkileşim',
  'Destekli oturma ve çevreyi keşfetme',
  'Nesneleri elden ele aktarma oyunları',
  'Hareket girişimleri ve iletişim',
  'Taklit, jestler ve nesne sürekliliği oyunları',
  'İşaret etme ve karşılıklı iletişim',
  'Günlük rutinlerde bağımsızlık denemeleri',
  'İlk yılın ardından iletişim ve hareket',
];

String _stage(int month) {
  if (month < 3) return 'yenidoğan ve erken bebeklik';
  if (month < 6) return 'erken bebeklik';
  if (month < 9) return 'ek gıdaya geçiş dönemi';
  if (month < 12) return 'hareket ve keşif dönemi';
  if (month < 18) return 'ilk adımlar ve iletişim dönemi';
  if (month < 24) return 'erken çocukluk';
  if (month < 36) return 'iki yaş dönemi';
  if (month < 48) return 'üç yaş dönemi';
  if (month < 60) return 'okul öncesi dört yaş dönemi';
  return 'okul öncesi beş-altı yaş dönemi';
}

String _development(int m) {
  if (m < 13) return _focus[m];
  if (m < 24) return 'Günlük sözcükleri, jestleri, hareketi ve öz bakım denemelerini oyun içinde gözlemleyin.';
  if (m < 36) return 'İki aşamalı basit yönergeleri, hayalî oyunu ve sosyal etkileşimi birlikte deneyimleyin.';
  if (m < 48) return 'Hikâye anlatma, sıra bekleme, hareket koordinasyonu ve duyguları adlandırmaya fırsat verin.';
  if (m < 60) return 'Soru sorma, birlikte problem çözme, çizim ve arkadaşlık becerilerini destekleyin.';
  return 'Günlük yaşam sorumlulukları, anlatım, sayı ve ses oyunlarıyla okul öncesi becerileri destekleyin.';
}

String _feeding(int m) {
  if (m < 6) return 'Bu dönemde beslenmenin temeli anne sütü veya uygun bebek mamasıdır. Ek gıda, su ve beslenme değişiklikleri için sağlık uzmanınızın önerilerini izleyin.';
  if (m < 12) return 'Gelişimsel hazır oluşa uygun ek gıdaları güvenli kıvamda sunun; anne sütü veya uygun mama devam eder. Yeni besinlerde alerji belirtilerini gözlemleyin. Bal vermeyin.';
  if (m < 24) return 'Düzenli ana ve ara öğün fırsatları sunun; açlık-tokluk işaretlerine saygı gösterin. Üzüm, sert kuruyemiş ve benzeri boğulma risklerini uygun şekilde hazırlayın.';
  return 'Sebze, meyve, protein ve tahıllarda çeşitlilik sağlayın. Çocuğu yemek hazırlığına yaşına uygun görevlerle katın; zorla yedirmekten kaçının.';
}

String _sleep(int m) {
  if (m < 12) return 'Her uykuda sırtüstü yatırın; düz ve sert uyku yüzeyinde yastık, oyuncak ve gevşek örtü bulundurmayın. Uyku süresi bebekler arasında değişir.';
  if (m < 36) return 'Tutarlı bir akşam rutini oluşturun. Gündüz uykusu ve gece uykusundaki değişimleri gözlemleyin; tek bir saat hedefini zorlamayın.';
  return 'Sakin bir yatma rutini, düzenli uyanma saati ve yaşa uygun ekran sınırları belirleyin. Uzayan uyku sorunlarını uzmanla görüşün.';
}

String _play(int m) {
  if (m < 3) return 'Uyanıkken gözetimli kısa yüzüstü oyunlar, konuşma ve yüz yüze etkileşim deneyin; yorulma belirtilerinde ara verin.';
  if (m < 6) return 'Yumuşak sesler, güvenli nesnelere uzanma ve birlikte şarkı söyleme oyunları oynayın.';
  if (m < 12) return 'Ce-ee, nesne saklama, resimli kitap ve güvenli yerde hareket oyunlarını deneyin.';
  if (m < 24) return 'Blok dizme, taklit, resimli kitap, basit ritim ve serbest hareket oyunları sunun.';
  if (m < 36) return 'Sınıflama, büyük parçalı yapboz, hayalî mutfak ve hareket parkuru oyunlarını gözetimle deneyin.';
  if (m < 48) return 'Rol yapma, renk eşleştirme, hikâye tamamlama ve sıra alma oyunları oynayın.';
  if (m < 60) return 'Kes-yapıştır etkinliklerini güvenli araçlarla, basit kurallı oyunları ve açık hava hareketlerini deneyin.';
  return 'Harf-ses farkındalığı, sayı eşleştirme, hikâye kurma ve iş birliği oyunlarıyla keşfi destekleyin.';
}

String _care(int m) {
  if (m < 6) return 'Bez, cilt ve beslenme kayıtlarını izleyin. Kontrolleri sağlık ekibinizle planlayın; ateş veya beslenme güçlüğünde yaşa uygun acil değerlendirme gereksinimini sorun.';
  if (m < 12) return 'Diş ve ağız bakımını sağlık uzmanıyla planlayın. Büyüme ölçümlerini tarihleriyle kaydedin; gelişim temposunu başka çocuklarla karşılaştırmayın.';
  if (m < 36) return 'El yıkama, diş fırçalama ve günlük öz bakım rutinlerini birlikte uygulayın. Tuvalet alışkanlığında hazır oluşa saygı gösterin.';
  return 'Diş, hijyen, hareket ve rutin sağlık kontrollerini takip edin. Çocuğun kendi bakımına katılmasına yaşına uygun fırsatlar tanıyın.';
}

String _safety(int m) {
  if (m < 12) return 'Yüksek yüzeylerde yalnız bırakmayın. Küçük parçaları, kabloları, ilaçları ve sıcak içecekleri erişimden uzak tutun; uygun oto koltuğu kullanın.';
  if (m < 36) return 'Merdiven, pencere, su ve mutfak risklerini kontrol edin. Yiyecekleri boğulma riskini azaltacak biçimde hazırlayın; su yakınında sürekli gözetim sağlayın.';
  return 'Trafik, oyun alanı, su güvenliği ve yabancılarla sınırlar konusunda yaşa uygun konuşun. Bisiklet ve benzeri etkinliklerde uygun koruyucu ekipman kullanın.';
}

List<MonthlyGuideTopic> guidesForMonth(int month) {
  if (month < 0 || month > 72) return const [];
  final stage = _stage(month);
  return <MonthlyGuideTopic>[
    MonthlyGuideTopic(month, 'Gelişim', '$month. ay: gelişim ve iletişim', '$stage döneminde: ${_development(month)} Gelişim basamakları kişiden kişiye değişir; beceri kaybı veya endişeniz varsa çocuk hekiminize danışın.'),
    MonthlyGuideTopic(month, 'Beslenme', '$month. ay: beslenme', _feeding(month)),
    MonthlyGuideTopic(month, 'Uyku', '$month. ay: uyku', _sleep(month)),
    MonthlyGuideTopic(month, 'Oyun', '$month. ay: oyun ve öğrenme', _play(month)),
    MonthlyGuideTopic(month, 'Bakım', '$month. ay: günlük bakım', _care(month)),
    MonthlyGuideTopic(month, 'Güvenlik', '$month. ay: güvenlik', _safety(month)),
  ];
}
