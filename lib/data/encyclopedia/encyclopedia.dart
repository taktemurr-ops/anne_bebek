import 'baby.dart';
import 'child.dart';
import 'life.dart';
import 'model.dart';
import 'mother.dart';
import 'pregnancy.dart';

export 'model.dart';

/// Tüm ansiklopedi başlıkları.
const encyclopediaTopics = <EncyclopediaTopic>[
  ...babyTopics,
  ...childTopics,
  ...pregnancyTopics,
  ...motherTopics,
  ...lifeTopics,
];

String _norm(String s) => s
    .replaceAll('İ', 'i').replaceAll('I', 'ı')
    .toLowerCase();

/// Türkçe alfabetik sıralama anahtarı (ç, ğ, ı, ö, ş, ü doğru yerde).
String turkishSortKey(String s) {
  const order = 'abcçdefgğhıijklmnoöprsştuüvyz';
  final buf = StringBuffer();
  for (final ch in _norm(s).split('')) {
    final i = order.indexOf(ch);
    buf.write(i < 0 ? ch : String.fromCharCode(0x100 + i));
  }
  return buf.toString();
}

/// Başlık, özet, etiket ve içerikte arama; başlık eşleşmesi önce gelir.
List<EncyclopediaTopic> searchEncyclopedia(String query, {String? category}) {
  final q = _norm(query.trim());
  final pool = category == null
      ? encyclopediaTopics
      : encyclopediaTopics.where((t) => t.category == category).toList();
  if (q.isEmpty) {
    return [...pool]..sort((a, b) => turkishSortKey(a.title).compareTo(turkishSortKey(b.title)));
  }
  final words = q.split(RegExp(r'\s+')).where((w) => w.length >= 2).toList();
  final scored = <(int, EncyclopediaTopic)>[];
  for (final t in pool) {
    final title = _norm(t.title);
    final tags = _norm(t.tags.join(' '));
    final body = _norm('${t.summary} ${t.know.join(' ')} ${t.todo.join(' ')} ${t.doctor.join(' ')}');
    var score = 0;
    if (title.contains(q)) score += 20;
    for (final w in words) {
      final stem = w.length > 5 ? w.substring(0, 5) : w;
      if (title.contains(stem)) score += 6;
      if (tags.contains(stem)) score += 4;
      if (body.contains(stem)) score += 1;
    }
    if (score > 0) scored.add((score, t));
  }
  scored.sort((a, b) => b.$1 != a.$1
      ? b.$1.compareTo(a.$1)
      : turkishSortKey(a.$2.title).compareTo(turkishSortKey(b.$2.title)));
  return scored.map((e) => e.$2).toList();
}
