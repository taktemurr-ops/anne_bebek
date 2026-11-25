import 'secure_health_store.dart';
import 'shopping_list.dart';

/// GP-06: Local encrypted shopping checklist, independent of medical journals.
class ShoppingListRepository {
  const ShoppingListRepository._();
  static const storageKey = 'shopping_checklist_v1';

  static Future<List<ShoppingListItem>> load() async =>
      decodeShoppingList(await SecureHealthStore.read(storageKey));

  static Future<void> save(List<ShoppingListItem> items) async {
    final encoded = encodeShoppingList(items);
    decodeShoppingList(encoded);
    await SecureHealthStore.write(storageKey, encoded);
  }

  static Future<void> clear() => SecureHealthStore.delete(storageKey);
}
