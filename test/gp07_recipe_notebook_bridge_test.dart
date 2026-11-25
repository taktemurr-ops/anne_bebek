import 'package:anne_bebek/data/baby_recipe_catalog.dart';
import 'package:anne_bebek/data/general_recipe_catalog.dart';
import 'package:anne_bebek/services/family_recipes.dart';
import 'package:anne_bebek/services/recipe_notebook_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tüm katalog tarifleri defter modelinin kurallarına uyar', () {
    for (final r in generalRecipes) {
      final f = RecipeNotebookBridge.fromGeneral(r);
      expect(FamilyRecipe.fromJson(f.toJson()).id, 'katalog_${r.id}');
      expect(f.instructions, contains('1. '));
    }
    for (final r in babyRecipes) {
      final f = RecipeNotebookBridge.fromBaby(r);
      expect(f.title, contains('+ ay'));
      expect(f.ingredients, isNotEmpty);
    }
  });

  test('aynı tarif iki kez eklenmez, mevcut tarifler korunur', () {
    const own = FamilyRecipe(id: 'kendi_1', title: 'Annemin keki',
        ingredients: ['2 yumurta'], preparationMinutes: 40, instructions: 'Karıştır, pişir.');
    final recipe = RecipeNotebookBridge.fromBaby(babyRecipes.first);
    final (once, added1) = RecipeNotebookBridge.add([own], recipe);
    final (twice, added2) = RecipeNotebookBridge.add(once, recipe);
    expect(added1, isTrue);
    expect(added2, isFalse);
    expect(twice.map((e) => e.id), ['kendi_1', recipe.id]);
    // Kodlama/çözme sonrası defter geçerli kalır.
    expect(decodeFamilyRecipes(encodeFamilyRecipes(twice)), hasLength(2));
  });
}
