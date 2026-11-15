import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/data/baby_recipe_catalog.dart';
void main() {
  test('Bebek tarifleri benzersiz kimlikler içerir', () {
    expect(babyRecipes.length, greaterThanOrEqualTo(300));
    expect(babyRecipes.map((r) => r.id).toSet().length, babyRecipes.length);
    expect(babyRecipes.every((r) => r.ingredients.isNotEmpty && r.steps.length == 3), isTrue);
  });
}
