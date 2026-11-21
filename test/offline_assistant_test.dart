import 'package:anne_bebek/services/offline_assistant.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _titles(AssistantAnswer a) => a.sections.map((s) => s.title).toList();

void main() {
  test('acil belirti önce uyarı verir', () {
    final a = OfflineAssistant.answer('Bebeğim nefes alamıyor, dudakları morardı');
    expect(a.urgent, contains('112'));
  });

  test('yaşa göre bebek tarifi: 12 ay altında tuz/şeker/bal uyarısı', () {
    final a = OfflineAssistant.answer('8 aylık bebek için çorba tarifi');
    final s = a.sections.firstWhere((s) => s.title.contains('8 ay'));
    expect(s.lines.any((l) => l.contains('tuz')), isTrue);
    expect(s.source, 'Bebek tarifleri kataloğu');
  });

  test('gebelik haftası ve aşı soruları doğru bölüme gider', () {
    expect(_titles(OfflineAssistant.answer('Gebeliğin 20. haftası')),
        contains('Gebeliğin 20. haftası'));
    final v = OfflineAssistant.answer('Sıradaki aşılar', childMonths: 9,
        childBirth: DateTime(2026, 2, 10));
    expect(v.sections.first.lines.first, contains('12. ay'));
  });

  test('gündelik ifadeler doğru konuyu bulur', () {
    bool has(String q, String part) => _titles(OfflineAssistant.answer(q))
        .any((t) => t.toLowerCase().contains(part));
    expect(_titles(OfflineAssistant.answer('Bebeğim gece sık uyanıyor')).first.toLowerCase(), contains('uyku'));
    expect(has('regl ağrısı', 'adet'), isTrue);
    expect(has('Emzirme ve anne sütü', 'emzirme'), isTrue);
  });

  test('anlamsız soruda boş yanıt; Türkçe büyük harf normalizasyonu', () {
    expect(OfflineAssistant.answer('qwxzv').isEmpty, isTrue);
    expect(OfflineAssistant.normalize('İLK AŞI'), 'ilk aşı');
    expect(OfflineAssistant.monthsFrom('2 yaşındaki çocuk'), 24);
  });
}
