import 'package:anne_bebek/data/encyclopedia/encyclopedia.dart';
import 'package:anne_bebek/services/offline_assistant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ansiklopedi: en az 90 konu, benzersiz kimlik ve başlık, her kategori dolu', () {
    expect(encyclopediaTopics.length, greaterThanOrEqualTo(115));
    expect(encyclopediaTopics.map((t) => t.id).toSet().length, encyclopediaTopics.length);
    expect(encyclopediaTopics.map((t) => t.title.toLowerCase()).toSet().length, encyclopediaTopics.length);
    for (final (name, _) in encyclopediaCategories) {
      expect(encyclopediaTopics.where((t) => t.category == name).length, greaterThanOrEqualTo(8), reason: name);
    }
    for (final t in encyclopediaTopics) {
      expect(encyclopediaCategories.any((c) => c.$1 == t.category), isTrue, reason: t.id);
      expect(t.summary.trim(), isNotEmpty, reason: t.id);
      expect(t.know.length + t.todo.length, greaterThanOrEqualTo(3), reason: t.id);
    }
  });

  test('arama: başlık eşleşmesi önce, Türkçe harfler doğru', () {
    expect(searchEncyclopedia('ateş').first.id, 'b_ates');
    expect(searchEncyclopedia('MASTİT').first.id, 'l_mastit');
    expect(searchEncyclopedia('regl ağrısı').first.id, 'k_sanci');
    expect(searchEncyclopedia('', category: 'Gebelik'), isNotEmpty);
    expect(searchEncyclopedia('qwxz'), isEmpty);
  });

  test('alfabetik sıralama Türkçe kurallara uyar', () {
    final keys = ['Çocuk', 'Cilt', 'Şeker', 'Su', 'Ömür', 'Oda'].map(turkishSortKey).toList();
    expect(keys[1].compareTo(keys[0]), lessThan(0)); // C < Ç
    expect(keys[3].compareTo(keys[2]), lessThan(0)); // S < Ş
    expect(keys[5].compareTo(keys[4]), lessThan(0)); // O < Ö
  });

  test('asistan ansiklopediden yanıt verir', () {
    final a = OfflineAssistant.answer('mastit belirtileri');
    expect(a.sections.first.title, 'Meme dolgunluğu ve mastit');
    expect(a.sections.first.source, contains('Rehber'));
  });
}
