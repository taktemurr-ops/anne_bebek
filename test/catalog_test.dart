import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/data/product_catalog.dart';

void main() {
  test('Bütün alışveriş kategorilerinde en az bir ürün bulunur', () {
    for (final category in productCategories) {
      expect(productCatalog.any((item) => item[1] == category), isTrue,
          reason: '$category kategorisi boş kalmamalı');
    }
  });

  test('Katalogda tekrarlanan veya eksik alanlı ürün bulunmaz', () {
    final names = <String>{};
    for (final item in productCatalog) {
      expect(item.length, 3);
      expect(item.every((field) => field.trim().isNotEmpty), isTrue);
      expect(productCategories.contains(item[1]), isTrue);
      expect(names.add(item[0]), isTrue, reason: 'Tekrar eden ürün: ${item[0]}');
    }
  });
}
