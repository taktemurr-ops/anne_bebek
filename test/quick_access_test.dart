import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/widgets/quick_access.dart';

void main() {
  test('Türkçe harflerle arama normalize edilir', () {
    expect(normalizeQuickSearch('  BÜYÜME  '), 'buyume');
    expect(normalizeQuickSearch('ALIŞVERİŞ'), 'alisveris');
    expect(normalizeQuickSearch('IĞDIR'), 'igdir');
  });
  test('Önceden indekslenmiş arama Türkçe karakter ve açıklamayı destekler', () {
    final items = [
      QuickAccessItem(title: 'Büyüme', description: 'Ölçüm kaydı',
        icon: Icons.straighten, onOpen: () {}),
      QuickAccessItem(title: 'Uyku', description: 'Günlük takip',
        icon: Icons.bedtime, onOpen: () {}),
    ];
    final index = QuickSearchIndex(items);
    expect(index.search('BUYUME').single.title, 'Büyüme');
    expect(index.search('olcum').single.title, 'Büyüme');
    expect(index.search('uyku').single.title, 'Uyku');
    expect(index.search('olmayan'), isEmpty);
    expect(index.search(' '), same(items));
  });
  test('Arama boşlukları temizler', () {
    expect(normalizeQuickSearch('  Uyku '), 'uyku');
  });
}
