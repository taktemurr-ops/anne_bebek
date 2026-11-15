import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/data/general_recipe_catalog.dart';

void main() {
  test('Başlangıç tarif kataloğunda 120 kayıt ve benzersiz kimlik bulunur', () {
    expect(generalRecipes.length, 120);
    expect(generalRecipes.map((r) => r.id).toSet().length, generalRecipes.length);
    expect(generalRecipes.map((r) => r.category).toSet().length, 12);
    for (final recipe in generalRecipes) {
      expect(recipe.title.trim(), isNotEmpty);
      expect(recipe.ingredients, isNotEmpty);
      expect(recipe.steps.length, greaterThanOrEqualTo(3));
    }
  });
}
