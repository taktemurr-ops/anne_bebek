// Genel yemek tarifleri kataloğu (Paket 39 §3).
// Bu dosya araçla üretilir: kategoriler 18 ana kategoriye göre düzenlenmiştir,
// isim değiştirilerek tekrar edilen tarifler çıkarılmıştır.
// Bebek tarifleri bu katalogda yer almaz; bkz. baby_recipe_catalog.dart.
//
// `detailed: false` olan tariflerin hazırlanışı henüz kalıp cümlelerden
// oluşur; uygulama bunu kullanıcıya açıkça belirtir ve tarif yeniden
// yazıldığında bu işaret kaldırılır.

/// Paket 39'da istenen genel tarif kategorileri (sıra ekranda kullanılır).
const generalRecipeCategories = <String>[
  'Çorbalar',
  'Et yemekleri',
  'Tavuk yemekleri',
  'Balık ve deniz ürünleri',
  'Sebze yemekleri',
  'Bakliyat yemekleri',
  'Makarnalar',
  'Pilavlar',
  'Kahvaltılıklar',
  'Hamur işleri',
  'Salatalar',
  'Mezeler',
  'Tatlılar',
  'Kek ve kurabiyeler',
  'İçecekler',
  'Dünya mutfağı',
  'Diyet ve sağlıklı tarifler',
  'Pratik tarifler',
];

class GeneralRecipe {
  final String id, title, category;
  final List<String> ingredients, steps;

  /// Toplam süre (hazırlık + pişirme), dakika.
  final int minutes;
  /// Tarifte açıkça belirtilen değerler; null ise kategoriye göre hesaplanır.
  final int? declaredServings, declaredPrepMinutes, declaredCookMinutes;
  final String? declaredDifficulty;

  /// Fırın gerektiren tariflerde °C; gerekmiyorsa null.
  final int? ovenCelsius;
  final List<String> tips;
  final String? serving, storage;

  /// Hazırlanışı tarife özgü, ayrıntılı adımlardan oluşuyorsa true.
  final bool detailed;

  const GeneralRecipe({
    required this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.minutes,
    int? servings,
    int? prepMinutes,
    int? cookMinutes,
    String? difficulty,
    this.ovenCelsius,
    this.tips = const [],
    this.serving,
    this.storage,
    this.detailed = true,
  })  : declaredServings = servings,
        declaredPrepMinutes = prepMinutes,
        declaredCookMinutes = cookMinutes,
        declaredDifficulty = difficulty;

  /// Kaç kişilik olduğu; belirtilmemişse kategoriye göre tahmin edilir.
  int get servings => declaredServings ?? _defaultServings(category);

  int get prepMinutes => declaredPrepMinutes ?? (minutes * 0.3).round().clamp(5, 30);

  int get cookMinutes => declaredCookMinutes ?? (minutes - prepMinutes).clamp(0, 600);

  /// Kolay / Orta / Zor.
  String get difficulty {
    final declared = declaredDifficulty;
    if (declared != null) return declared;
    if (minutes <= 25 && steps.length <= 4) return 'Kolay';
    if (minutes <= 70) return 'Orta';
    return 'Zor';
  }

  static int _defaultServings(String category) {
    switch (category) {
      case 'Kahvaltılıklar':
      case 'İçecekler':
      case 'Pratik tarifler':
        return 2;
      case 'Tatlılar':
      case 'Hamur işleri':
        return 6;
      case 'Kek ve kurabiyeler':
        return 8;
      default:
        return 4;
    }
  }
}

