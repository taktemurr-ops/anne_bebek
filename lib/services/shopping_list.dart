import 'dart:convert';

/// GP-06: Local shopping checklist. Prices are deliberately not required.
class ShoppingListItem {
  final String id;
  final String title;
  final int quantity;
  final bool completed;

  const ShoppingListItem({required this.id, required this.title,
    this.quantity = 1, this.completed = false});

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'quantity': quantity, 'completed': completed,
  };

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final title = json['title'];
    final quantity = json['quantity'];
    final completed = json['completed'];
    if (id is! String || id.trim().isEmpty || title is! String ||
        title.trim().isEmpty || title.runes.length > 120 ||
        quantity is! int || quantity < 1 || quantity > 999 ||
        completed is! bool) {
      throw const FormatException('Geçersiz alışveriş listesi ürünü');
    }
    return ShoppingListItem(id: id, title: title.trim(),
      quantity: quantity, completed: completed);
  }
}

String encodeShoppingList(List<ShoppingListItem> items) =>
    jsonEncode(items.map((item) => item.toJson()).toList());

List<ShoppingListItem> decodeShoppingList(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  final decoded = jsonDecode(raw);
  if (decoded is! List) throw const FormatException('Alışveriş listesi bozuk');
  final ids = <String>{};
  final result = <ShoppingListItem>[];
  for (final rawItem in decoded) {
    if (rawItem is! Map) throw const FormatException('Geçersiz ürün');
    final item = ShoppingListItem.fromJson(Map<String, dynamic>.from(rawItem));
    if (!ids.add(item.id)) throw const FormatException('Yinelenen ürün kimliği');
    result.add(item);
  }
  return result;
}
