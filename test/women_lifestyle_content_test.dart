import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/data/women_lifestyle_content.dart';

void main() {
  test('Kadın yaşamı içerikleri tekil ve dolu', () {
    expect(lifestyleArticles.length, 42);
    expect(lifestyleArticles.map((e) => e.id).toSet().length, 42);
    expect(lifestyleArticles.map((e) => e.category).toSet().length, 7);
    for (final article in lifestyleArticles) {
      expect(article.title.trim().isNotEmpty, isTrue);
      expect(article.body.length, greaterThan(70));
      expect(article.caution.trim().isNotEmpty, isTrue);
    }
  });
}
