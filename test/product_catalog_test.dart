import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/product_catalog.dart';

void main() {
  test('catalog has 36 unique items across 6 categories', () {
    expect(ProductCatalog.products.length, 36);
    expect(ProductCatalog.products.map((p) => p.id).toSet().length, 36);
    expect(ProductCatalog.products.map((p) => p.category).toSet().length, 6);
    for (final p in ProductCatalog.products) {
      expect(p.features.length, 3);
      expect(p.note.isNotEmpty, true);
      expect(ProductCatalog.byId(p.id)?.name, p.name);
    }
  });
}
