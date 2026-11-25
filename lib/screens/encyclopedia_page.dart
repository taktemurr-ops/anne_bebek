import 'package:flutter/material.dart' hide Text;
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../data/encyclopedia/encyclopedia.dart';

const _pink = Color(0xFFE94791);
const _purple = Color(0xFF48235F);

/// A'dan Z'ye ansiklopedi: arama, kategori ve harf dizini.
class EncyclopediaPage extends StatefulWidget {
  const EncyclopediaPage({super.key, this.initialQuery = '', this.initialCategory});
  final String initialQuery;
  final String? initialCategory;
  @override
  State<EncyclopediaPage> createState() => _EncyclopediaPageState();
}

class _EncyclopediaPageState extends State<EncyclopediaPage> {
  late final TextEditingController _search = TextEditingController(text: widget.initialQuery);
  late String? _category = widget.initialCategory;

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  String _letter(String title) {
    final f = title.characters.first;
    return f.replaceAll('i', 'İ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final results = searchEncyclopedia(_search.text, category: _category);
    final alphabetical = _search.text.trim().isEmpty;
    final rows = <Widget>[];
    String? lastLetter;
    for (final t in results) {
      if (alphabetical) {
        final l = _letter(t.title);
        if (l != lastLetter) {
          lastLetter = l;
          rows.add(Padding(padding: const EdgeInsets.fromLTRB(6, 14, 6, 4),
            child: Text(l, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _pink))));
        }
      }
      final emoji = encyclopediaCategories.firstWhere((c) => c.$1 == t.category,
          orElse: () => ('', '📘')).$2;
      rows.add(Card(elevation: 0, color: const Color(0xFFFFFCFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFF6DDEB))),
        child: ListTile(
          leading: Text(emoji, style: const TextStyle(fontSize: 26)),
          title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w800, color: _purple)),
          subtitle: Text(t.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => EncyclopediaTopicPage(topic: t))),
        )));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('A’dan Z’ye Rehber')),
      body: ListView(padding: const EdgeInsets.fromLTRB(14, 6, 14, 24), children: [
        TextField(
          key: const ValueKey('ansiklopedi_ara'),
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            hintText: t('Konu ara (ör. ateş, emzirme, adet sancısı)'),
            suffixIcon: _search.text.isEmpty ? null : IconButton(
              tooltip: t('Temizle'), icon: const Icon(Icons.close_rounded),
              onPressed: () => setState(_search.clear)),
          )),
        const SizedBox(height: 10),
        SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, children: [
          Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(
            label: const Text('Tümü'), selected: _category == null,
            onSelected: (_) => setState(() => _category = null))),
          for (final (name, emoji) in encyclopediaCategories)
            Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(
              label: Text('$emoji $name'), selected: _category == name,
              onSelected: (_) => setState(() => _category = _category == name ? null : name))),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(6, 10, 6, 0), child: Text(
          '${results.length} konu', style: const TextStyle(fontSize: 12, color: Colors.black54))),
        if (results.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text(
          'Aramanla eşleşen konu bulunamadı. Farklı bir kelime dene veya Bilgi Asistanı\'na sor.',
          textAlign: TextAlign.center)),
        ...rows,
        const Padding(padding: EdgeInsets.all(12), child: Text(
          'Bu içerikler genel bilgilendirme amaçlıdır; tanı ve tedavi yerine geçmez. '
          'Acil durumda 112\'yi ara.',
          style: TextStyle(fontSize: 11.5, color: Colors.black54))),
      ]),
    );
  }
}

/// Konu ayrıntısı: özet + üç bölüm.
class EncyclopediaTopicPage extends StatelessWidget {
  const EncyclopediaTopicPage({super.key, required this.topic});
  final EncyclopediaTopic topic;

  Widget _section(String title, String emoji, Color color, List<String> lines) => Card(
    elevation: 0, color: color,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(padding: const EdgeInsets.all(14), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$emoji  $title', style: const TextStyle(fontWeight: FontWeight.w900, color: _purple, fontSize: 15)),
        const SizedBox(height: 8),
        for (final l in lines) Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(padding: EdgeInsets.only(top: 7, right: 8),
              child: CircleAvatar(radius: 3, backgroundColor: _pink)),
            Expanded(child: Text(l, style: const TextStyle(height: 1.4))),
          ])),
      ])));

  @override
  Widget build(BuildContext context) {
    final related = searchEncyclopedia(topic.tags.take(2).join(' '))
        .where((t) => t.id != topic.id).take(3).toList();
    return Scaffold(
      appBar: AppBar(title: Text(topic.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: ListView(padding: const EdgeInsets.fromLTRB(14, 6, 14, 24), children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFE3F0), Color(0xFFF3E6FF)]),
            borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(topic.category, style: const TextStyle(color: _pink, fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 4),
            Text(topic.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _purple)),
            const SizedBox(height: 8),
            Text(topic.summary, style: const TextStyle(height: 1.45)),
          ])),
        const SizedBox(height: 10),
        if (topic.know.isNotEmpty) _section('Bilmen gerekenler', '💡', const Color(0xFFFFF6FB), topic.know),
        if (topic.todo.isNotEmpty) _section('Ne yapabilirsin', '✅', const Color(0xFFF2FBF5), topic.todo),
        if (topic.doctor.isNotEmpty) _section('Ne zaman doktora / acile', '🩺', const Color(0xFFFFF1F1), topic.doctor),
        if (related.isNotEmpty) ...[
          const Padding(padding: EdgeInsets.fromLTRB(6, 10, 6, 6), child: Text('İlgili konular',
            style: TextStyle(fontWeight: FontWeight.w900, color: _purple))),
          for (final r in related) ListTile(
            title: Text(r.title), trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
              builder: (_) => EncyclopediaTopicPage(topic: r)))),
        ],
        const Padding(padding: EdgeInsets.all(10), child: Text(
          'Genel bilgilendirme amaçlıdır; tanı ve tedavi yerine geçmez. Acil durumda 112, zehirlenmede 114.',
          style: TextStyle(fontSize: 11.5, color: Colors.black54))),
      ]),
    );
  }
}
