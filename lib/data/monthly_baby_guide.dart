/// Yaşa göre genel ebeveyn rehberi. Bireysel tanı veya beslenme reçetesi değildir.
class MonthlyBabyGuide {
  final int month;
  final Map<String, String> sections;
  const MonthlyBabyGuide(this.month, this.sections);
}

const babyGuideCategories = <String>['Beslenme', 'Gelişim', 'Uyku', 'Oyun', 'Sağlık', 'Güvenlik'];

MonthlyBabyGuide babyGuideForMonth(int month) {
  final m = month.clamp(0, 72).toInt();
  final feeding = m < 6
      ? 'Bu dönemde temel besin anne sütü veya uygun bebek formülüdür. İlk 6 ay yalnızca anne sütü önerilir; formül mama gereksinimini sağlık uzmanıyla değerlendirin. Ek gıdaya erken başlamayın.'
      : m < 9
          ? 'Yaklaşık 6. ayda gelişimsel hazır oluşa göre ek gıdaya başlanabilir. Demirden zengin, yumuşak ve güvenli kıvamlı yiyecekleri küçük miktarlarla tanıtın. Anne sütü veya formül mama sürer. Yeni alerjenleri uygun biçimde tanıtırken reaksiyonları izleyin.'
          : m < 12
              ? 'Çeşitli dokular ve besin grupları sunun; bebeğin kendi kendine yemeyi denemesine güvenli biçimde fırsat verin. Anne sütü veya formül mama ilk yaş boyunca önemlidir. Balı 12 aydan önce vermeyin.'
              : m < 24
                  ? 'Aile yemeklerinden yaşa uygun, az tuzlu ve güvenli kıvamlı seçenekler sunun. Düzenli öğün ve ara öğün rutini kurun; çocuğu yemeye zorlamayın. İçecek ve porsiyon ihtiyaçlarını doktoruyla görüşün.'
                  : 'Sebze, meyve, tam tahıl, protein ve uygun süt ürünleriyle çeşitlilik sağlayın. İştah gün gün değişebilir; baskı yerine düzenli öğün ve birlikte yemek yemeyi tercih edin.';
  final development = m < 3
      ? 'Sesinize ve yüzünüze verdiği tepkileri gözlemleyin. Ten teması, konuşma ve kısa etkileşimler bağ kurmayı destekler. Gelişim hızı bebekten bebeğe değişir.'
      : m < 6
          ? 'Baş kontrolü, uzanma, ses çıkarma ve çevreyi inceleme gibi beceriler gelişebilir. Yeni becerileri not edin; belirgin beceri kaybında sağlık uzmanına başvurun.'
          : m < 12
              ? 'Oturma, nesneleri aktarma, sesleri taklit etme ve hareket etme girişimleri görülebilir. Çocuğunuzun kendi hızına saygı gösterin.'
              : m < 24
                  ? 'İlk sözcükler, işaret etme, bağımsız hareket ve basit yönergeleri anlama gelişebilir. Bol bol konuşun ve birlikte kitap inceleyin.'
                  : m < 36
                      ? 'Dil, taklit, problem çözme ve bağımsızlık becerileri hızlanabilir. Günlük işlere küçük görevlerle katılmasını destekleyin.'
                      : 'Hikâye anlatma, akranlarla oyun, öz bakım ve ince motor beceriler gelişir. Beklenen beceriler geniş bir aralıkta ortaya çıkabilir.';
  final sleep = m < 12
      ? 'Bebeğin uyku ihtiyacı yaşına ve bireysel ritmine göre değişir. İlk yıl her uyku için sırtüstü, düz ve sert bir uyku yüzeyi kullanın; yatakta yastık, oyuncak ve gevşek örtü bulundurmayın.'
      : 'Düzenli yatış ve uyanış saatleri oluşturun. Sakin bir akşam rutini ve yaşa uygun gündüz uykusu planı yardımcı olabilir.';
  final play = m < 6
      ? 'Uyanıkken gözetimli yüzüstü oyun, şarkı söyleme, yüz yüze konuşma ve yumuşak sesli oyuncaklarla etkileşim kurun.'
      : m < 12
          ? 'Ce-ee, nesne saklama, kitap resimlerine bakma ve güvenli yerde serbest hareket oyunları deneyin.'
          : m < 36
              ? 'Bloklar, eşleştirme, taklit oyunları, kitap okuma ve açık havada güvenli hareket etkinlikleri yapın.'
              : 'Hayal gücü oyunları, resim, hikâye, basit sayma ve birlikte problem çözme etkinliklerini çeşitlendirin.';
  final health = 'Yaşa uygun aşı ve rutin kontrolleri yerel sağlık takviminden doğrulayın. Büyüme ölçümlerini zaman içinde izleyin. Beslenme, gelişim veya hastalıkla ilgili endişeleri çocuk sağlığı uzmanıyla görüşün.';
  final safety = m < 6
      ? 'Bebeği yüksek yüzeylerde yalnız bırakmayın. Güvenli uyku ve araç koltuğu kurallarını uygulayın. Ateş veya hastalık belirtilerinde özellikle küçük bebekler için gecikmeden tıbbi görüş alın.'
      : m < 12
          ? 'Boğulma riski taşıyan bütün üzüm, sert kuruyemiş, patlamış mısır ve benzeri yiyecekleri uygun olmayan biçimde sunmayın. Küçük nesneleri uzak tutun; hareketlendikçe evi güvenli hâle getirin.'
          : 'Merdiven, pencere, sıcak sıvı, ilaç ve temizlik ürünlerine erişimi önleyin. Yemek sırasında gözetim sağlayın; yaşa uygun araç koltuğu kullanın.';
  return MonthlyBabyGuide(m, {
    'Beslenme': feeding,
    'Gelişim': development,
    'Uyku': sleep,
    'Oyun': play,
    'Sağlık': health,
    'Güvenlik': safety,
  });
}
