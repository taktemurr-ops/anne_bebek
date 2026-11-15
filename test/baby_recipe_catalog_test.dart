import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/data/baby_recipe_catalog.dart';
void main() {
  test('300 farklı tarif varyasyonu ve benzersiz kimlikler', () {
    expect(babyRecipes.length, 300);
    expect(babyRecipes.map((r) => r.id).toSet().length, 300);
    expect(babyRecipes.every((r) => r.ingredients.isNotEmpty && r.steps.length == 3), isTrue);
  });
}
