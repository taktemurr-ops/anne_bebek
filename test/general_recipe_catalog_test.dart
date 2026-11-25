import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/data/general_recipe_catalog.dart';
import 'package:anne_bebek/data/recipe_meta.dart';

void main() {
  test('Tarif kataloğu yeterli sayıda benzersiz kayıt içerir', () {
    expect(generalRecipes.length, greaterThanOrEqualTo(120));
    expect(generalRecipes.map((r) => r.id).toSet().length, generalRecipes.length);
    expect(generalRecipes.map((r) => r.category).toSet().length, greaterThanOrEqualTo(12));
    for (final recipe in generalRecipes) {
      expect(recipe.title.trim(), isNotEmpty);
      expect(recipe.ingredients, isNotEmpty);
      expect(recipe.steps.length, greaterThanOrEqualTo(3));
    }
  });

  test('Ayrıntılı yeni tarifler eksiksizdir', () {
    final detailed = generalRecipes.where((r) => r.id.startsWith('d13_')).toList();
    expect(detailed.length, greaterThanOrEqualTo(40));
    for (final r in detailed) {
      expect(r.steps.length, greaterThanOrEqualTo(4), reason: r.title);
      expect(r.tips.length, greaterThanOrEqualTo(2), reason: r.title);
      expect(r.declaredServings, isNotNull, reason: r.title);
      expect(r.declaredDifficulty, isNotNull, reason: r.title);
      expect(r.serving, isNotNull, reason: r.title);
      expect(r.storage, isNotNull, reason: r.title);
      expect(r.prepMinutes + r.cookMinutes, r.minutes, reason: r.title);
      expect(RecipeMeta.equipment(r), isNotEmpty, reason: r.title);
    }
  });
}
