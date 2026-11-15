import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/guide_content.dart';

void main() {
  const rehberKonular = <String>[
    'Adet Dönemi', 'Alerji', 'Anne Sütü', 'Aşı Takvimi', 'Bebek Bakımı',
    'Bebek Gelişimi', 'Bebek Masajı', 'Bebek Ürünleri', 'Beslenme', 'Doğum',
    'Doğum Sonrası', 'Eğitim & Oyun', 'Ev Düzeni', 'Gebelik',
    'Güzellik & Bakım', 'Hastalıklar ve Belirtiler', 'Kişisel Gelişim',
    'Moda & Stil', 'Rahatlama', 'Uyku Düzeni',
  ];

  test('Rehberdeki tüm konuların dolu içeriği bulunur', () {
    for (final konu in rehberKonular) {
      expect(guideContent.containsKey(konu), isTrue, reason: konu);
      expect(guideContent[konu]!.length, greaterThanOrEqualTo(3), reason: konu);
      expect(guideContent[konu]!.every((s) => s.trim().isNotEmpty), isTrue);
    }
  });

  test('Sağlık ekranındaki alt konuların içeriği bulunur', () {
    for (final konu in <String>[
      'En Sık Sorulan Sorular', 'Hastalıklar ve Belirtiler', 'Aşı Takvimi',
      'Beslenme Önerileri', 'Adet Dönemi', 'Gebelik', 'Doğum Sonrası',
      'Ruh Sağlığı', 'Sağlık',
    ]) {
      expect(guideContent[konu], isNotEmpty, reason: konu);
    }
  });
}
