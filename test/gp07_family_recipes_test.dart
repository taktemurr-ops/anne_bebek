import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/family_recipes.dart';

void main() {
  test('GP-07 recipe round trip retains ingredients and duration', () {
    final recipe = FamilyRecipe(id: 'r1', title: 'Sebze çorbası',
      ingredients: ['Havuç', 'Su'], preparationMinutes: 25,
      instructions: 'Pişir ve servis et.');
    final restored = decodeFamilyRecipes(encodeFamilyRecipes([recipe]));
    expect(restored.single.ingredients, ['Havuç', 'Su']);
    expect(restored.single.preparationMinutes, 25);
  });
  test('GP-07 missing records return empty list', () {
    expect(decodeFamilyRecipes(null), isEmpty);
  });
  test('GP-07 rejects empty ingredients and duplicate ids', () {
    expect(() => FamilyRecipe.fromJson({
      'id':'r1','title':'Tarif','ingredients':[],
      'preparationMinutes':10,'instructions':'Hazırla'}), throwsFormatException);
    final recipe = FamilyRecipe(id: 'r1', title: 'Tarif',
      ingredients: ['Su'], preparationMinutes: 10, instructions: 'Hazırla');
    expect(() => decodeFamilyRecipes(encodeFamilyRecipes([recipe,recipe])),
      throwsFormatException);
  });
}
