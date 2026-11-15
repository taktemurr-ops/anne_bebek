class BabyRecipe {
  final String id;
  final String title;
  final String age;
  final String category;
  final String ingredient;
  final String vegetable;
  final List<String> ingredients;
  final List<String> steps;

  const BabyRecipe({
    required this.id,
    required this.title,
    required this.age,
    required this.category,
    required this.ingredient,
    required this.vegetable,
    required this.ingredients,
    required this.steps,
  });
}

final babyRecipes = List<BabyRecipe>.generate(300, (index) {
  const vegetables = [
    'kabak', 'havuç', 'balkabağı', 'brokoli', 'karnabahar',
    'ıspanak', 'bezelye', 'tatlı patates', 'pırasa', 'yeşil fasulye',
  ];
  const methods = [
    'sebze püresi', 'sebze çorbası', 'mercimekli sebze', 'yulaflı sebze',
    'pirinçli sebze', 'bulgurlu sebze', 'yoğurtlu sebze', 'yumurtalı sebze',
    'tavuklu sebze', 'kıymalı sebze', 'nohutlu sebze', 'fasulyeli sebze',
    'balıklı sebze', 'fırın sebze ezmesi', 'sebzeli mini köfte', 'sebzeli makarna',
    'sebzeli krep', 'sebzeli mücver', 'sebzeli omlet', 'sebzeli yoğurtlu kase',
    'sebzeli patates ezmesi', 'sebzeli irmik', 'sebzeli patates yemeği',
    'sebzeli pilav', 'sebzeli et yahnisi', 'sebzeli zeytinyağlı tava',
    'sebzeli baklagil yemeği', 'sebzeli çorba', 'sebzeli kısır', 'sebzeli güveç',
  ];
  const categories = [
    'Sebze', 'Çorba', 'Baklagil', 'Tahıl', 'Yoğurt', 'Yumurta', 'Et', 'Balık', 'Fırın', 'Makarna',
  ];
  const ingredients = [
    'patates', 'kırmızı mercimek', 'ince yulaf', 'pirinç', 'ince bulgur',
    'sade pastörize yoğurt', 'yumurta', 'kemiksiz tavuk', 'az yağlı dana kıyma',
    'iyi pişmiş kabuksuz nohut', 'iyi pişmiş kuru fasulye', 'kılçıksız düşük cıvalı balık',
    'zeytinyağı', 'yumurta ve tam buğday unu', 'yumurta ve yulaf unu',
  ];
  const ageGroups = ['6+', '8+', '9+', '10+', '12+'];

  final vegetable = vegetables[index % vegetables.length];
  final method = methods[index % methods.length];
  final category = categories[(index ~/ vegetables.length) % categories.length];
  final ingredient = ingredients[(index ~/ methods.length) % ingredients.length];
  final age = ageGroups[(index ~/ 60) % ageGroups.length];

  return BabyRecipe(
    id: 'b${index.toString().padLeft(3, '0')}',
    title: '$vegetable ile $method',
    age: age,
    category: category,
    ingredient: ingredient,
    vegetable: vegetable,
    ingredients: [
      '1 küçük porsiyon $vegetable',
      ingredient,
      'İhtiyaç kadar içme suyu',
    ],
    steps: [
      'Malzemeleri yıkayıp hazırlayın.',
      'Yumuşayana kadar uygun şekilde pişirin.',
      'Yaşa uygun kıvamda servis edin.',
    ],
  );
});
