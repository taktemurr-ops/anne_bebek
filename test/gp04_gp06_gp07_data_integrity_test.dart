import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/daily_routines.dart';
import 'package:anne_bebek/services/shopping_list.dart';
import 'package:anne_bebek/services/family_recipes.dart';

void main() {
  test('GP04 multiple children remain isolated after round trip', () {
    final first = DailyRoutineEntry(
      id: 'routine-a', childId: 'child-a', kind: 'feeding',
      startedAt: DateTime.utc(2026, 11, 21), amountMl: 120);
    final second = DailyRoutineEntry(
      id: 'routine-b', childId: 'child-b', kind: 'note',
      startedAt: DateTime.utc(2026, 11, 21), note: 'Test');
    final decoded = decodeDailyRoutines(encodeDailyRoutines([first, second]));
    expect(decoded.where((e) => e.childId == 'child-a').single.id, 'routine-a');
    expect(decoded.where((e) => e.childId == 'child-b').single.id, 'routine-b');
  });

  test('GP04 rejects invalid feeding volume and duplicate record IDs', () {
    final entry = DailyRoutineEntry(
      id: 'duplicate', childId: 'child-a', kind: 'feeding',
      startedAt: DateTime.utc(2026, 11, 21), amountMl: 120);
    expect(() => decodeDailyRoutines(encodeDailyRoutines([entry, entry])),
      throwsFormatException);
    expect(() => DailyRoutineEntry.fromJson({
      'id': 'x', 'childId': 'child-a', 'kind': 'feeding',
      'startedAt': '2026-11-21T10:00:00Z', 'amountMl': -10,
    }), throwsFormatException);
  });

  test('GP06 shopping checklist round trip', () {
    final items = [
      const ShoppingListItem(id: '1', title: 'Bez', quantity: 2),
      const ShoppingListItem(id: '2', title: 'Mendil', completed: true),
    ];
    final decoded = decodeShoppingList(encodeShoppingList(items));
    expect(decoded.length, 2);
    expect(decoded.first.quantity, 2);
    expect(decoded.last.completed, isTrue);
  });

  test('GP06 duplicate products and invalid quantity are rejected', () {
    const item = ShoppingListItem(id: '1', title: 'Bez');
    expect(() => decodeShoppingList(encodeShoppingList([item, item])),
      throwsFormatException);
    expect(() => ShoppingListItem.fromJson({
      'id': '1', 'title': 'Bez', 'quantity': 0, 'completed': false,
    }), throwsFormatException);
  });

  test('GP07 recipe round trip preserves ingredients', () {
    const recipe = FamilyRecipe(
      id: 'recipe-1', title: 'Örnek tarif',
      ingredients: ['Su', 'Yulaf'],
      preparationMinutes: 15, instructions: 'Karıştır.');
    final decoded = decodeFamilyRecipes(encodeFamilyRecipes([recipe]));
    expect(decoded.single.ingredients, ['Su', 'Yulaf']);
    expect(decoded.single.preparationMinutes, 15);
  });

  test('GP07 duplicate IDs and empty ingredients are rejected', () {
    const recipe = FamilyRecipe(
      id: 'recipe-1', title: 'Örnek tarif',
      ingredients: ['Su'], preparationMinutes: 15,
      instructions: 'Karıştır.');
    expect(() => decodeFamilyRecipes(encodeFamilyRecipes([recipe, recipe])),
      throwsFormatException);
    expect(() => FamilyRecipe.fromJson({
      'id': 'recipe-2', 'title': 'Tarif',
      'ingredients': [], 'preparationMinutes': 15,
      'instructions': 'Karıştır.',
    }), throwsFormatException);
  });
}
