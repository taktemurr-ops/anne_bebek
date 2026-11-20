import 'general_recipe_catalog.dart';

/// Tarif detay ekranı için türetilmiş bilgiler (Paket 39 §3).
///
/// Alerjenler malzeme listesinden anahtar kelimeyle bulunur. Bu bir
/// kolaylıktır; paketli ürünlerin etiketleri ayrıca kontrol edilmelidir.
class RecipeMeta {
  const RecipeMeta._();

  static const _allergenKeywords = <String, List<String>>{
    'Gluten': [
      'un', 'ekmek', 'bulgur', 'makarna', 'şehriye', 'erişte', 'irmik', 'yufka',
      'tarhana', 'galeta', 'bisküvi', 'kuskus', 'lavaş', 'pide', 'arpa', 'buğday',
      'milföy', 'kadayıf', 'simit', 'tortilla', 'lazanya', 'kraker', 'yulaf',
    ],
    'Süt ve süt ürünleri': [
      'süt', 'yoğurt', 'peynir', 'tereyağ', 'krema', 'kaşar', 'lor', 'labne',
      'kefir', 'ayran', 'çökelek', 'beşamel', 'parmesan', 'mozzarella', 'kaymak',
    ],
    'Yumurta': ['yumurta', 'mayonez'],
    'Sert kabuklu yemiş': [
      'ceviz', 'fındık', 'badem', 'antep fıstığı', 'kaju', 'çam fıstığı', 'pekan',
    ],
    'Yer fıstığı': ['yer fıstığı', 'fıstık ezmesi'],
    'Balık': [
      'balık', 'somon', 'levrek', 'çipura', 'hamsi', 'ton balığı', 'mezgit',
      'alabalık', 'sardalya', 'palamut', 'uskumru', 'lüfer', 'barbun', 'hamsi',
    ],
    'Kabuklu deniz ürünleri': ['karides', 'midye', 'kalamar', 'ahtapot', 'yengeç', 'istakoz'],
    'Susam': ['susam', 'tahin'],
    'Soya': ['soya'],
    'Kereviz': ['kereviz'],
    'Hardal': ['hardal'],
  };

  static final _wordCache = <String, RegExp>{};

  static bool _containsWord(String text, String word) {
    // "un" gibi kısa kelimelerin "tuna"/"unutmayın" ile eşleşmesini engeller.
    final re = _wordCache.putIfAbsent(word,
        () => RegExp('(^|[^a-zçğıöşü])${RegExp.escape(word)}', caseSensitive: false));
    return re.hasMatch(text);
  }

  /// Malzemelerden bulunan alerjenler (AB/TR gıda etiketi 14 alerjen listesinden).
  static List<String> allergens(GeneralRecipe recipe) {
    final text = recipe.ingredients.join(' • ').toLowerCase();
    final found = <String>[];
    _allergenKeywords.forEach((allergen, words) {
      if (words.any((w) => _containsWord(text, w))) found.add(allergen);
    });
    // "Hindistan cevizi" sert kabuklu yemiş sayılmaz.
    if (found.contains('Sert kabuklu yemiş') &&
        !RegExp(r'(^|[^a-zçğıöşü])(fındık|badem|antep|kaju|çam fıstığı|pekan)')
            .hasMatch(text) &&
        !text.replaceAll('hindistan cevizi', '').contains('ceviz')) {
      found.remove('Sert kabuklu yemiş');
    }
    return found;
  }

  /// Fırın sıcaklığı: tarifte belirtilmişse o değer, yoksa adımlardan okunur.
  static int? ovenCelsius(GeneralRecipe recipe) {
    if (recipe.ovenCelsius != null) return recipe.ovenCelsius;
    for (final step in recipe.steps) {
      final lower = step.toLowerCase();
      if (!lower.contains('fırın')) continue;
      final m = RegExp(r'(\d{3})\s*°?\s*c', caseSensitive: false).firstMatch(step);
      if (m != null) return int.parse(m.group(1)!);
    }
    return null;
  }

  static String serving(GeneralRecipe recipe) =>
      recipe.serving ?? _servingByCategory[recipe.category] ??
      'Pişirdikten sonra sıcak veya ılık servis edin.';

  static String storage(GeneralRecipe recipe) =>
      recipe.storage ?? _storageByCategory[recipe.category] ??
      'Oda sıcaklığında 2 saatten fazla bekletmeyin; kapalı kapta buzdolabında 2 gün saklayın.';

  static List<String> tips(GeneralRecipe recipe) =>
      recipe.tips.isNotEmpty ? recipe.tips : (_tipsByCategory[recipe.category] ?? const []);

  static const _servingByCategory = <String, String>{
    'Çorbalar': 'Sıcak servis edin; yanına limon dilimi ve kızarmış ekmek yakışır.',
    'Et yemekleri': 'Pilav, bulgur pilavı veya yoğurtlu bir salata ile servis edin.',
    'Tavuk yemekleri': 'Pilav, makarna ya da yeşil salata ile sıcak servis edin.',
    'Balık ve deniz ürünleri': 'Roka, kırmızı soğan ve limon ile hemen servis edin.',
    'Sebze yemekleri': 'Zeytinyağlılar ılık veya soğuk; etli sebze yemekleri sıcak servis edilir. Yanına yoğurt yakışır.',
    'Bakliyat yemekleri': 'Pilav, turşu veya taze soğan ile sıcak servis edin.',
    'Makarnalar': 'Pişer pişmez servis edin; üzerine rendelenmiş peynir ekleyebilirsiniz.',
    'Pilavlar': 'Demlendikten sonra ana yemeğin yanında sıcak servis edin.',
    'Kahvaltılıklar': 'Taze çay, domates, salatalık ve yeşilliklerle servis edin.',
    'Hamur işleri': 'Ilıdıktan sonra dilimleyin; çay veya ayran ile servis edin.',
    'Salatalar': 'Sosu servisten hemen önce ekleyin ki yeşillikler diri kalsın.',
    'Mezeler': 'Soğuk servis edin; yanına taze ekmek veya grissini koyun.',
    'Tatlılar': 'Tamamen soğuduktan sonra servis edin; isteğe göre tarçın veya ceviz serpin.',
    'Kek ve kurabiyeler': 'Tamamen soğuduktan sonra dilimleyin; çay veya kahve ile servis edin.',
    'İçecekler': 'Hazırlandıktan hemen sonra soğuk servis edin.',
    'Dünya mutfağı': 'Tarifin geldiği mutfağa uygun garnitürle sıcak servis edin.',
    'Diyet ve sağlıklı tarifler': 'Bol yeşillik ve bir porsiyon protein ile dengeli bir öğün olarak servis edin.',
    'Pratik tarifler': 'Hazırlar hazırlamaz servis edin.',
  };

  static const _storageByCategory = <String, String>{
    'Çorbalar': 'Soğuduktan sonra kapalı kapta buzdolabında 3 gün saklanır; ısıtırken kaynayana kadar ısıtın.',
    'Et yemekleri': 'Buzdolabında kapalı kapta 3 gün, dondurucuda 3 ay saklanır. Yalnızca bir kez ısıtın.',
    'Tavuk yemekleri': 'Buzdolabında kapalı kapta en fazla 2 gün saklayın; tamamen ısıtarak tüketin.',
    'Balık ve deniz ürünleri': 'Aynı gün tüketilmesi önerilir; buzdolabında en fazla 1 gün saklayın.',
    'Sebze yemekleri': 'Buzdolabında kapalı kapta 3 gün saklanır.',
    'Bakliyat yemekleri': 'Buzdolabında 3 gün, dondurucuda 2 ay saklanır.',
    'Makarnalar': 'Buzdolabında 2 gün saklanır; ısıtırken bir kaşık su ekleyin.',
    'Pilavlar': 'Hızla soğutup buzdolabında 1 gün saklayın; bir kez ısıtın.',
    'Kahvaltılıklar': 'Taze tüketin; pişmiş yumurtalı tarifleri buzdolabında en fazla 1 gün saklayın.',
    'Hamur işleri': 'Oda sıcaklığında kapalı kapta 1 gün, buzdolabında 3 gün saklanır; dondurulabilir.',
    'Salatalar': 'Sossuz hâlde buzdolabında 1 gün saklanır.',
    'Mezeler': 'Kapalı kapta buzdolabında 2–3 gün saklanır.',
    'Tatlılar': 'Sütlü tatlıları buzdolabında 3 gün saklayın; diğerleri oda sıcaklığında 2 gün dayanır.',
    'Kek ve kurabiyeler': 'Hava almayan kapta oda sıcaklığında 3–4 gün saklanır.',
    'İçecekler': 'Hemen tüketin; bekleyecekse buzdolabında en fazla 12 saat saklayın.',
    'Dünya mutfağı': 'Buzdolabında kapalı kapta 2 gün saklanır.',
    'Diyet ve sağlıklı tarifler': 'Buzdolabında kapalı kapta 2 gün saklanır.',
    'Pratik tarifler': 'Taze tüketin; buzdolabında en fazla 1 gün saklayın.',
  };

  static const _tipsByCategory = <String, List<String>>{
    'Çorbalar': [
      'Blenderdan geçirmeden önce çorbayı birkaç dakika ılıtın; sıcak buhar kapağı itebilir.',
      'Tuzu pişirmenin sonunda ayarlayın; çorba koyulaştıkça tuz belirginleşir.',
    ],
    'Et yemekleri': [
      'Eti pişirmeden 30 dakika önce buzdolabından çıkarın; daha eşit pişer.',
      'Kıymalı yemeklerde iç kısmın pembe kalmamasına dikkat edin.',
    ],
    'Tavuk yemekleri': [
      'Tavuğun en kalın yeri 74 °C olmalı; kesince pembe kalmamalı.',
      'Çiğ tavuk ile sebzeler için ayrı kesme tahtası kullanın.',
    ],
    'Balık ve deniz ürünleri': [
      'Balık, eti çatalla kolayca ayrılıyorsa pişmiştir; fazla pişirmek kurutur.',
      'Taze balığın gözleri parlak, solungaçları kırmızı olmalı.',
    ],
    'Sebze yemekleri': [
      'Zeytinyağlıları kendi suyunda kısık ateşte pişirip tencerede soğutun.',
      'Sebzeleri eşit boyutta doğrayın ki aynı anda pişsin.',
    ],
    'Bakliyat yemekleri': [
      'Kuru baklagilleri bir gece önceden ıslatın, suyunu dökerek haşlayın.',
      'Tuzu baklagiller yumuşadıktan sonra ekleyin.',
    ],
    'Makarnalar': [
      'Makarnayı bol ve tuzlu suda haşlayın; süzmeden önce bir bardak haşlama suyu ayırın.',
    ],
    'Pilavlar': [
      'Pirinci nişastası gidene kadar yıkayın; pişince 10 dakika demlendirin.',
    ],
    'Hamur işleri': [
      'Fırını önceden ısıtın; hamur işleri soğuk fırında kabarmaz.',
    ],
    'Kek ve kurabiyeler': [
      'Malzemeler oda sıcaklığında olmalı; kek pişerken ilk 25 dakika fırın kapağını açmayın.',
    ],
    'Tatlılar': [
      'Sütlü tatlıları dibi tutmaması için sürekli ve tahta kaşıkla karıştırın.',
    ],
    'Salatalar': [
      'Yeşillikleri yıkadıktan sonra iyice kurutun; sos daha iyi tutunur.',
    ],
  };
}
