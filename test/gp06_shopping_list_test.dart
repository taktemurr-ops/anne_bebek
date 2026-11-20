import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/shopping_list.dart';

void main() {
  test('GP-06 checklist round trip preserves quantity and completion', () {
    final items = [ShoppingListItem(id: '1', title: 'Bebek bezi',
      quantity: 3, completed: true)];
    final restored = decodeShoppingList(encodeShoppingList(items));
    expect(restored.single.title, 'Bebek bezi');
    expect(restored.single.quantity, 3);
    expect(restored.single.completed, isTrue);
  });
  test('GP-06 missing storage yields empty checklist', () {
    expect(decodeShoppingList(null), isEmpty);
  });
  test('GP-06 rejects invalid quantities and duplicate ids', () {
    expect(() => ShoppingListItem.fromJson({
      'id':'a','title':'Bez','quantity':0,'completed':false}), throwsFormatException);
    final item = ShoppingListItem(id: 'a', title: 'Bez');
    expect(() => decodeShoppingList(encodeShoppingList([item,item])), throwsFormatException);
  });
}
