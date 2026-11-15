class GeneralRecipe {
  final String id;
  final String title;
  final String category;
  final List<String> ingredients;
  final List<String> steps;
  final int minutes;

  const GeneralRecipe({
    required this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.minutes,
  });
}

const generalCategoryNames = <String>[
  'Çorbalar',
  'Kahvaltı',
  'Salatalar',
  'Sebze yemekleri',
  'Baklagiller',
  'Makarna ve tahıl',
  'Tavuk',
  'Et',
  'Balık',
  'Fırın',
  'Tatlı',
  'Atıştırmalık',
];

final generalRecipes = List<GeneralRecipe>.generate(120, (index) {
  final categoryIndex = index ~/ 10;
  final itemIndex = index % 10;
  final category = generalCategoryNames[categoryIndex];
  final titles = [
    'Mercimek', 'Domates', 'Kabak', 'Patates', 'Nohut', 'Makarna', 'Tavuk', 'Levrek',
    'Peynir', 'Elma', 'Brokoli', 'Pirinç', 'Ispanak', 'Fasulye', 'Somon', 'Sebzeli',
    'Yoğurt', 'Tavşan', 'Limon', 'Muz'
  ];
  final ingredientsByCategory = [
    ['mercimek', 'soğan', 'sıvı yağ'],
    ['yumurta', 'peynir', 'süt'],
    ['salatalık', 'domates', 'zeytinyağı'],
    ['kabak', 'ıspanak', 'zeytinyağı'],
    ['nohut', 'mercimek', 'soğan'],
    ['makarna', 'domates', 'sarımsak'],
    ['tavuk', 'zeytinyağı', 'limon'],
    ['levrek', 'zeytinyağı', 'limon'],
    ['kıyma', 'patates', 'sos'],
    ['fırın', 'patates', 'peynir'],
    ['elma', 'tarçın', 'yulaf'],
    ['sebze', 'yoğurt', 'baharat'],
  ];

  return GeneralRecipe(
    id: 'G-${(index + 1).toString().padLeft(3, '0')}',
    title: '${titles[itemIndex]} ${categoryIndex + 1}',
    category: category,
    ingredients: [
      ingredientsByCategory[categoryIndex % ingredientsByCategory.length][0],
      ingredientsByCategory[categoryIndex % ingredientsByCategory.length][1],
      ingredientsByCategory[categoryIndex % ingredientsByCategory.length][2],
    ],
    steps: [
      'Malzemeleri hazırlayın.',
      'Pişirme aşamasını uygulayın.',
      'Servis edin.',
    ],
    minutes: 15 + ((itemIndex + categoryIndex) * 5),
  );
});
