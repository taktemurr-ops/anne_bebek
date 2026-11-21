import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/data/baby_recipe_catalog.dart';

void main() {
  test('Bebek tarifleri benzersiz ve eksiksizdir', () {
    expect(babyRecipes.length, greaterThanOrEqualTo(60));
    expect(babyRecipes.map((r) => r.id).toSet().length, babyRecipes.length);
    expect(babyRecipes.map((r) => r.title.toLowerCase()).toSet().length, babyRecipes.length,
        reason: 'Aynı isimli tarif tekrar etmemeli');
    for (final r in babyRecipes) {
      expect(r.ingredients, isNotEmpty, reason: r.title);
      expect(r.steps.length, greaterThanOrEqualTo(3), reason: r.title);
    }
  });

  test('Paket 39: tüm yaş grupları (6–72 ay) doludur', () {
    for (final group in babyAgeGroups) {
      expect(babyRecipes.where((r) => r.ageGroup == group).length, greaterThanOrEqualTo(5),
          reason: group);
    }
  });

  test('Yeniden yazılan tariflerde ölçü ve en az 4 adım vardır', () {
    for (final r in babyRecipes.where((r) => r.tips.isNotEmpty)) {
      expect(r.steps.length, greaterThanOrEqualTo(4), reason: r.title);
      expect(r.ingredients.every((i) => RegExp(r'\d|yarım|çeyrek|tutam|birkaç|ihtiyaç', caseSensitive: false).hasMatch(i)),
          isTrue, reason: r.title);
    }
  });

  test('Yaş grubu ve uygunluk hesabı', () {
    const r = BabyRecipe(id: 'x', title: 'x', age: '9+', category: 'c', ingredient: 'i',
        vegetable: 'v', ingredients: ['1 a'], steps: ['a', 'b', 'c']);
    expect(r.minMonths, 9);
    expect(r.ageGroup, '9–11 ay');
    expect(r.suitableFor(8), isFalse);
    expect(r.suitableFor(9), isTrue);
  });

  test('12 aydan küçüklere bal içeren tarif yoktur', () {
    for (final r in babyRecipes.where((r) => r.minMonths < 12)) {
      expect(r.ingredients.any((i) => RegExp(r'(^|\s)bal(\s|$|,)').hasMatch(i.toLowerCase())),
          isFalse, reason: r.title);
    }
  });

  test('Eski varyasyon kimlikleri yeni tarife eşlenir', () {
    expect(babyRecipeIdFor('b03v07'), 'b03v00');
    expect(babyRecipeIdFor('ozgun001'), 'ozgun001');
    expect(babyRecipes.any((r) => r.id == babyRecipeIdFor('b12v04')), isTrue);
  });
}
