/// Özgün örnek tarifler; sağlık uzmanının kişisel önerisinin yerine geçmez.
class BabyMeal {
  final String name;
  final int minMonth;
  final String category;
  final int minutes;
  final List<String> ingredients;
  final List<String> steps;
  final String allergens;
  final String safety;
  const BabyMeal(this.name, this.minMonth, this.category, this.minutes,
      this.ingredients, this.steps, this.allergens, this.safety);
}

const babyMeals = <BabyMeal>[
  BabyMeal('Yumuşak kabak püresi', 6, 'Sebze', 15, ['1 küçük kabak', 'İçme suyu'], ['Kabağı yıkayıp soyun.', 'Buharda tamamen yumuşayana kadar pişirin.', 'Bebeğin becerisine uygun kıvama getirin.'], 'Belirgin yaygın alerjen içermez; bireysel alerjileri kontrol edin.', 'Tuz eklemeyin; dik oturarak ve gözetim altında sunun.'),
  BabyMeal('Tatlı patates ezmesi', 6, 'Sebze', 25, ['1 küçük tatlı patates', 'İçme suyu'], ['Yıkayıp soyun.', 'Tamamen yumuşayana kadar pişirin.', 'Ezerek uygun kıvamda sunun.'], 'Belirgin yaygın alerjen içermez.', 'Sıcaklığını kontrol edin; büyük sert parçalar bırakmayın.'),
  BabyMeal('Armut püresi', 6, 'Meyve', 12, ['1 olgun armut'], ['Armutu yıkayıp soyun.', 'Gerekirse yumuşayana kadar pişirin.', 'Çekirdeğini çıkarıp ezin.'], 'Belirgin yaygın alerjen içermez.', 'Sert çiğ parçalar vermeyin.'),
  BabyMeal('Avokado ezmesi', 6, 'Meyve', 5, ['Yarım olgun avokado'], ['Avokadoyu yıkayıp ikiye bölün.', 'Çekirdeğini çıkarın.', 'İyice ezip taze sunun.'], 'Bireysel alerjileri kontrol edin.', 'Pütürleri bebeğin yeme becerisine uyarlayın.'),
  BabyMeal('Yoğurtlu yulaf', 6, 'Kahvaltı', 15, ['2 yemek kaşığı yulaf', '3 yemek kaşığı sade pastörize yoğurt', 'Su'], ['Yulafı suyla iyice pişirin.', 'Ilımasını bekleyin.', 'Yoğurtla karıştırın.'], 'Süt içerir; yulaf çapraz bulaşma açısından kontrol edilmelidir.', 'Şeker ve bal eklemeyin; yoğurt pastörize olmalıdır.'),
  BabyMeal('Mercimekli sebze ezmesi', 7, 'Ana öğün', 25, ['2 yemek kaşığı kırmızı mercimek', 'Yarım havuç', 'Yarım kabak', 'Su'], ['Mercimeği iyice yıkayın.', 'Sebzelerle birlikte tamamen yumuşayana kadar pişirin.', 'Bebeğin becerisine uygun şekilde ezin.'], 'Malzemelerin bireysel alerji geçmişini kontrol edin.', 'Tuz eklemeyin ve uygun doku sağlayın.'),
  BabyMeal('Brokoli ve patates ezmesi', 7, 'Sebze', 20, ['Birkaç brokoli çiçeği', '1 küçük patates', 'Su'], ['Sebzeleri yıkayın.', 'Buharda iyice yumuşatın.', 'Birlikte ezerek servis edin.'], 'Bireysel alerjileri kontrol edin.', 'Sert sap ve iri parçaları ayırın.'),
  BabyMeal('İyi pişmiş yumurtalı sebze', 7, 'Kahvaltı', 15, ['1 yumurta', '2 yemek kaşığı rendelenmiş kabak'], ['Kabağı yumuşatın.', 'Yumurtayı ekleyin.', 'Yumurta tamamen pişene kadar karıştırın.'], 'Yumurta içerir.', 'Yumurta tamamen pişmiş olmalı; yeni alerjenleri dikkatle tanıtın.'),
  BabyMeal('Tavuklu sebze ezmesi', 8, 'Ana öğün', 30, ['Küçük parça kemiksiz tavuk', 'Yarım havuç', 'Yarım patates', 'Su'], ['Tavuğu tamamen pişirin.', 'Sebzeleri yumuşayana kadar pişirin.', 'Kemik ve sert parça kalmadığını kontrol edip uygun dokuya getirin.'], 'Bireysel alerjileri kontrol edin.', 'Tavuk tamamen pişmiş olmalı; kemik bulunmamalı.'),
  BabyMeal('Muzlu yulaf lapası', 8, 'Kahvaltı', 12, ['2 yemek kaşığı yulaf', 'Yarım olgun muz', 'Su'], ['Yulafı suyla iyice pişirin.', 'Muzu çatalla ezin.', 'Ilıyan yulafla karıştırın.'], 'Yulafın olası çapraz bulaşmasını kontrol edin.', 'Bal ve ilave şeker eklemeyin.'),
  BabyMeal('Balıksız sebzeli bulgur', 9, 'Ana öğün', 25, ['2 yemek kaşığı ince bulgur', 'Yarım kabak', 'Yarım havuç', 'Su'], ['Bulguru ve sebzeleri yıkayın.', 'Hepsini tamamen yumuşayana kadar pişirin.', 'Uygun kıvamda sunun.'], 'Buğday/gluten içerir.', 'İri ve sert parçalar bırakmayın.'),
  BabyMeal('Fırında yumuşak sebze çubukları', 9, 'Parmak gıda', 30, ['1 havuç', '1 tatlı patates', 'Az zeytinyağı'], ['Sebzeleri soyup uygun uzunlukta kesin.', 'Tamamen yumuşayana kadar fırınlayın.', 'Sıcaklığını kontrol edin.'], 'Bireysel alerjileri kontrol edin.', 'Parmakla kolayca ezilebilecek yumuşaklıkta olmalı; sürekli gözetim gerekir.'),
  BabyMeal('Sebzeli iyi pişmiş omlet', 10, 'Kahvaltı', 15, ['1 yumurta', '1 yemek kaşığı ince rendelenmiş kabak', 'Az zeytinyağı'], ['Kabağı yumuşatın.', 'Yumurtayla karıştırın.', 'İçi tamamen pişene kadar pişirin.'], 'Yumurta içerir.', 'Uygun küçük/yumuşak parçalara ayırın.'),
  BabyMeal('Sebzeli pirinç', 10, 'Ana öğün', 25, ['2 yemek kaşığı pirinç', 'Yarım kabak', 'Yarım havuç', 'Su'], ['Pirinci yıkayın.', 'Sebzelerle tamamen yumuşayana kadar pişirin.', 'Yaşa uygun kıvamda sunun.'], 'Bireysel alerjileri kontrol edin.', 'Tuz eklemeyin; çeşitlilik için farklı tahıllarla dönüşümlü sunun.'),
  BabyMeal('Yoğurtlu meyve kasesi', 12, 'Ara öğün', 8, ['4 yemek kaşığı sade pastörize yoğurt', 'Yarım olgun muz', 'Yumuşak armut'], ['Meyveleri yıkayın ve çekirdeklerini ayırın.', 'Yaşa uygun şekilde doğrayın veya ezin.', 'Yoğurtla karıştırın.'], 'Süt içerir.', 'Sert meyve parçaları bırakmayın; boğulma riskine dikkat edin.'),
  BabyMeal('Sebzeli köfte', 12, 'Ana öğün', 30, ['100 g kıyma', 'Yarım rendelenmiş kabak', '1 yemek kaşığı yulaf'], ['Malzemeleri karıştırın.', 'Küçük yassı köfteler hazırlayın.', 'İçi tamamen pişene kadar pişirin.'], 'Yulafın çapraz bulaşmasını kontrol edin.', 'İyi pişirin, uygun yumuşak parçalara bölün.'),
];

List<BabyMeal> mealsForMonth(int month) =>
    babyMeals.where((meal) => month >= meal.minMonth).toList(growable: false);

String nutritionNoteForMonth(int month) {
  if (month < 6) return 'İlk yaklaşık 6 ay temel besin anne sütü veya uygun bebek formülüdür. Ek gıdaya başlama zamanını sağlık uzmanıyla değerlendirin.';
  if (month < 9) return 'Ek gıdaya küçük miktarlarla başlayın. Demir içeren besinlere, farklı tatlara ve uygun dokulara yer verin. Anne sütü veya formül sürer.';
  if (month < 12) return 'Giderek çeşitlenen besinler ve bebeğin becerisine uygun dokular sunun. Öğün sayısı ve miktarı bireyseldir.';
  return 'Dengeli aile yemeklerine yaşa uygun biçimde katılımı destekleyin. Çeşitlilik, güvenli doku ve düzenli öğünler önemlidir.';
}
