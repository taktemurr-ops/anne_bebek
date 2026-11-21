import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/data/general_recipe_catalog.dart';
import 'package:anne_bebek/data/recipe_meta.dart';

void main() {
  test('Paket 39: her genel tarif 18 ana kategoriden birindedir', () {
    for (final r in generalRecipes) {
      expect(generalRecipeCategories, contains(r.category), reason: r.title);
    }
    // Her kategoride en az bir tarif bulunur.
    for (final c in generalRecipeCategories) {
      expect(generalRecipes.any((r) => r.category == c), isTrue, reason: c);
    }
  });

  test('Paket 39: genel tariflerde isim değiştirilmiş tekrar yoktur', () {
    final base = <String>{};
    for (final r in generalRecipes) {
      final t = r.title.toLowerCase()
          .replaceAll(RegExp(r'\s*\((alternatif tarif \d+|ev usulü)\)\s*$'), '')
          .trim();
      expect(base.add(t), isTrue, reason: 'Tekrar eden tarif: ${r.title}');
    }
  });

  test('Paket 39: genel tariflerde bebek tarifi yoktur', () {
    final babyWords = RegExp(r'bebek|\b\d+\s*ay\+|\(\d+\+?\s*ay\)', caseSensitive: false);
    for (final r in generalRecipes) {
      expect(babyWords.hasMatch(r.title), isFalse, reason: r.title);
    }
  });

  test('Paket 39: tarif bilgileri tutarlıdır', () {
    for (final r in generalRecipes) {
      expect(r.servings, greaterThan(0), reason: r.title);
      expect(r.prepMinutes, greaterThanOrEqualTo(0), reason: r.title);
      expect(r.cookMinutes, greaterThanOrEqualTo(0), reason: r.title);
      expect(const ['Kolay', 'Orta', 'Zor'], contains(r.difficulty), reason: r.title);
      expect(RecipeMeta.serving(r), isNotEmpty);
      expect(RecipeMeta.storage(r), isNotEmpty);
    }
  });

  test('Paket 39: ayrıntılı tariflerde ölçüler ve en az 4 adım bulunur', () {
    for (final r in generalRecipes.where((r) => r.tips.isNotEmpty)) {
      expect(r.steps.length, greaterThanOrEqualTo(4), reason: r.title);
      expect(r.ingredients.every((i) => RegExp(r'\d|yarım|çeyrek|tutam|isteğe|az', caseSensitive: false).hasMatch(i)),
          isTrue, reason: r.title);
    }
  });

  test('Alerjenler malzemelerden doğru bulunur', () {
    const recipe = GeneralRecipe(
      id: 't1', title: 'Test', category: 'Tatlılar',
      ingredients: ['2 su bardağı un', '1 su bardağı süt', '2 yumurta', '1 avuç ceviz', '2 yemek kaşığı tahin'],
      steps: ['a', 'b', 'c'], minutes: 30);
    expect(RecipeMeta.allergens(recipe),
        containsAll(['Gluten', 'Süt ve süt ürünleri', 'Yumurta', 'Sert kabuklu yemiş', 'Susam']));

    const tuna = GeneralRecipe(
      id: 't2', title: 'Test', category: 'Salatalar',
      ingredients: ['1 kutu ton balığı', '1 limon', 'Yarım demet maydanoz'],
      steps: ['a', 'b', 'c'], minutes: 10);
    expect(RecipeMeta.allergens(tuna), ['Balık']);

    const coconut = GeneralRecipe(
      id: 't3', title: 'Test', category: 'Tatlılar',
      ingredients: ['2 yemek kaşığı hindistan cevizi', '1 muz'],
      steps: ['a', 'b', 'c'], minutes: 10);
    expect(RecipeMeta.allergens(coconut), isNot(contains('Sert kabuklu yemiş')));
  });

  test('Fırın sıcaklığı adımlardan okunur', () {
    const r = GeneralRecipe(
      id: 't4', title: 'Test', category: 'Hamur işleri',
      ingredients: ['1 yufka'], steps: ['Fırını 180 °C ısıtın.', 'b', 'c'], minutes: 40);
    expect(RecipeMeta.ovenCelsius(r), 180);
  });

  test('Paket 39: 1000+ özgün genel tarif, hepsi ayrıntılı', () {
    expect(generalRecipes.length, greaterThanOrEqualTo(1000));
    expect(generalRecipes.where((r) => !r.detailed), isEmpty);
  });
}
