class AgeGuide {
  final String id;
  final String title;
  final String category;
  final String description;
  final int fromMonth;
  final int toMonth;
  const AgeGuide(this.id, this.title, this.category, this.description, this.fromMonth, this.toMonth);
  bool matchesAge(int? months) => months == null || (months >= fromMonth && months <= toMonth);
  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    return q.isEmpty || '$title $category $description'.toLowerCase().contains(q);
  }
}

int? ageInCompletedMonths(DateTime? birth, DateTime now) {
  if (birth == null || birth.isAfter(now)) return null;
  var months = (now.year - birth.year) * 12 + now.month - birth.month;
  final lastDay = DateTime(now.year, now.month + 1, 0).day;
  if (now.day < birth.day && !(birth.day > lastDay && now.day == lastDay)) months--;
  return months < 0 ? 0 : months;
}

const ageGuides = <AgeGuide>[
  AgeGuide('feeding_0', 'İlk aylarda beslenme', 'Beslenme', 'Emzirme veya mama kayıtlarını tutun. Beslenme güçlüğü, kilo alımı veya yeterlilik endişesinde sağlık uzmanına başvurun.', 0, 5),
  AgeGuide('feeding_6', 'Ek gıdaya geçiş', 'Beslenme', 'Ek gıdaya hazırlık belirtilerini ve yeni besinleri not edin. Boğulma riskini azaltan uygun kıvam ve güvenli oturma önemlidir.', 6, 11),
  AgeGuide('feeding_12', 'Aile sofrasına geçiş', 'Beslenme', 'Çeşitli besinleri ve olası reaksiyonları takip edin. Yaşa uygun parça boyutları ve gözetim önemlidir.', 12, 36),
  AgeGuide('sleep_0', 'Güvenli uyku ortamı', 'Uyku', 'Bebeği sırtüstü, düz ve sert bir uyku yüzeyine yatırın; uyku alanında gevşek yastık ve örtü bulundurmayın.', 0, 11),
  AgeGuide('sleep_12', 'Uyku rutini', 'Uyku', 'Düzenli uyku ve uyanma saatlerini not edin; çocuğun ihtiyaçlarına göre rutini uyarlayın.', 12, 36),
  AgeGuide('play_0', 'Gözetimli yüzüstü oyun', 'Oyun', 'Bebek uyanıkken ve gözetim altındayken kısa yüzüstü oyun fırsatları sağlayın; zorlanma varsa uzmanla görüşün.', 0, 5),
  AgeGuide('play_6', 'Etkileşimli oyunlar', 'Oyun', 'Nesne saklama, birlikte kitap bakma ve konuşma oyunları deneyin; gelişim temposu çocuklar arasında değişebilir.', 6, 11),
  AgeGuide('play_12', 'Dil ve hareket oyunları', 'Oyun', 'Kitap, taklit, müzik ve güvenli hareket oyunlarıyla birlikte zaman geçirin.', 12, 36),
  AgeGuide('safety_0', 'Evde güvenlik', 'Güvenlik', 'İlaçları, temizlik ürünlerini ve küçük nesneleri erişimden uzak tutun. Yaşa uygun oto koltuğu kullanın.', 0, 36),
  AgeGuide('health_0', 'Kontrol ve aşı kayıtları', 'Sağlık', 'Sağlık kuruluşunun verdiği aşı ve kontrol tarihlerini kaydedin; takvim için güncel resmî sağlık kaynaklarını izleyin.', 0, 36),
  AgeGuide('teeth_6', 'Ağız ve diş bakımı', 'Sağlık', 'Diş çıkışını takip edin; yaşa uygun ağız bakımı ve ilk diş hekimi kontrolünü sağlık uzmanıyla planlayın.', 6, 36),
  AgeGuide('family_0', 'Bakıcılar için günlük not', 'Aile', 'Beslenme, uyku ve önemli bakım bilgilerini bakım verenlerle güvenli biçimde paylaşmak için günlük özet oluşturun.', 0, 36),
];
