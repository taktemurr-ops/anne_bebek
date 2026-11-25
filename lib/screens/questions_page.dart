import 'dart:async';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'dart:convert';

import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';

import '../data/encyclopedia/encyclopedia.dart';
import '../services/secure_health_store.dart';
import '../utils/dialog_helpers.dart';
import 'encyclopedia_page.dart';

const _mor = Color(0xFF764A72);

/// Muayeneye götürmek için açık soruların numaralı düz metin listesi.
String openQuestionsText(List<DoctorQuestion> items, String Function(String) tr) {
  final open = items.where((q) => !q.asked).toList();
  return [
    tr('Doktoruma soracaklarım'),
    for (var i = 0; i < open.length; i++) '${i + 1}. ${open[i].text}${open[i].about == 'Ben' ? ' (${tr('Ben')})' : ''}',
  ].join('\n');
}

class DoctorQuestion {
  final String id;
  final String text;
  final String about; // 'Ben' | 'Bebeğim'
  final DateTime created;
  final String answer;
  final bool asked;
  const DoctorQuestion(this.id, this.text, this.about, this.created, {this.answer = '', this.asked = false});

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'about': about, 'created': created.toIso8601String(),
        'answer': answer, 'asked': asked};
  static DoctorQuestion? fromJson(Object? raw) {
    if (raw is! Map || raw['id'] is! String || raw['text'] is! String) return null;
    final c = DateTime.tryParse('${raw['created']}');
    if (c == null || (raw['text'] as String).trim().isEmpty) return null;
    return DoctorQuestion(raw['id'] as String, raw['text'] as String,
        raw['about'] == 'Bebeğim' ? 'Bebeğim' : 'Ben', c,
        answer: raw['answer'] is String ? raw['answer'] as String : '', asked: raw['asked'] == true);
  }
}

List<DoctorQuestion> decodeQuestions(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    final d = jsonDecode(raw);
    return d is List ? d.map(DoctorQuestion.fromJson).whereType<DoctorQuestion>().toList() : [];
  } catch (_) {
    return [];
  }
}

/// Bağlantısız çalışan soru-cevap: sık sorulan sorular (rehberden) ve
/// "doktoruma soracaklarım" defteri. Çevrim içi forum, sunucu eklenene kadar
/// bunun yerine geçer.
class QuestionsPage extends StatefulWidget {
  static const storageKey = 'doctor_questions_v1';
  /// Sık sorulanlarda öne çıkacak kategoriler (ör. bebek ya da kadın).
  final List<String> categories;
  final String defaultAbout;
  const QuestionsPage({super.key, this.categories = const [], this.defaultAbout = 'Ben'});

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  List<DoctorQuestion> _items = [];
  bool _loading = true;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    List<DoctorQuestion> l = [];
    try {
      l = decodeQuestions(await SecureHealthStore.read(QuestionsPage.storageKey));
    } catch (_) {}
    if (mounted) setState(() { _items = l; _loading = false; });
  }

  Future<void> _save(List<DoctorQuestion> next) async {
    try {
      await SecureHealthStore.write(QuestionsPage.storageKey, jsonEncode(next.map((q) => q.toJson()).toList()));
      if (mounted) setState(() => _items = next);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kaydedilemedi. Tekrar deneyin.')));
      }
    }
  }

  Future<void> _edit([DoctorQuestion? q]) async {
    final text = TextEditingController(text: q?.text ?? '');
    final answer = TextEditingController(text: q?.answer ?? '');
    var about = q?.about ?? widget.defaultAbout;
    var asked = q?.asked ?? false;
    final r = await showDialogAndDispose<Object>(context: context, disposables: [text, answer],
      builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
        title: Text(q == null ? 'Soru ekle' : 'Soruyu düzenle'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          SegmentedButton<String>(segments: const [
            ButtonSegment(value: 'Ben', label: Text('Benim için')),
            ButtonSegment(value: 'Bebeğim', label: Text('Bebeğim için')),
          ], selected: {about}, onSelectionChanged: (s) => update(() => about = s.first)),
          TextField(key: const Key('soru_metin'), controller: text, maxLines: 3, maxLength: 300,
              decoration: InputDecoration(labelText: t('Sorum'))),
          if (q != null) ...[
            SwitchListTile(contentPadding: EdgeInsets.zero, value: asked, title: const Text('Sordum'),
                onChanged: (v) => update(() => asked = v)),
            TextField(controller: answer, maxLines: 4, maxLength: 1000,
                decoration: InputDecoration(labelText: t('Aldığım cevap'))),
          ],
        ])),
        actions: [
          if (q != null) TextButton(onPressed: () => Navigator.pop(ctx, 'delete'),
              child: const Text('Sil', style: TextStyle(color: Colors.redAccent))),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(key: const Key('soru_kaydet'), onPressed: () {
            if (text.text.trim().isEmpty) return;
            Navigator.pop(ctx, DoctorQuestion(q?.id ?? 'q${DateTime.now().microsecondsSinceEpoch}', text.text.trim(),
                about, q?.created ?? DateTime.now(), answer: answer.text.trim(), asked: asked));
          }, child: const Text('Kaydet')),
        ],
      )));
    if (r == null || !mounted) return;
    if (r == 'delete') {
      await _save(_items.where((x) => x.id != q!.id).toList());
    } else {
      final n = r as DoctorQuestion;
      await _save(q == null ? [n, ..._items] : _items.map((x) => x.id == n.id ? n : x).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return DefaultTabController(length: 2, child: Column(children: [
      const Material(color: Colors.white, child: TabBar(labelColor: _mor, indicatorColor: _mor, tabs: [
        Tab(key: Key('soru_tab_defter'), text: 'Doktoruma soracaklarım'),
        Tab(key: Key('soru_tab_sss'), text: 'Sık sorulanlar'),
      ])),
      Expanded(child: TabBarView(children: [_notebook(), _faq()])),
    ]));
  }

  Widget _notebook() {
    final open = _items.where((q) => !q.asked).toList();
    final done = _items.where((q) => q.asked).toList();
    return ListView(padding: const EdgeInsets.all(14), children: [
      Card(color: const Color(0xFFFFE3F0), child: const ListTile(
        leading: Text('📝', style: TextStyle(fontSize: 26)),
        title: Text('Aklına gelen soruyu hemen yaz', style: TextStyle(fontWeight: FontWeight.w700, color: _mor)),
        subtitle: Text('Kontrole gittiğinde listeyi aç, sorduklarını işaretle ve cevapları not al.'))),
      FilledButton.icon(key: const Key('soru_ekle'), style: FilledButton.styleFrom(backgroundColor: _mor),
          onPressed: _edit, icon: const Icon(Icons.add), label: const Text('Soru ekle')),
      const SizedBox(height: 8),
      if (_items.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text(
          'Örnek: “Demir ilacını ne zamana kadar kullanmalıyım?”, “Bebeğimin kakası yeşil, normal mi?”',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.black54))),
      if (open.isNotEmpty) Row(children: [
        const Text('Sorulacaklar', style: TextStyle(fontWeight: FontWeight.w800, color: _mor)),
        const Spacer(),
        TextButton.icon(key: const Key('soru_kopyala'), icon: const Icon(Icons.copy, size: 18), label: const Text('Listeyi kopyala'),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: openQuestionsText(_items, t)));
            if (!mounted) return;
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(
                content: Text('Sorular panoya kopyalandı; not uygulamasına ya da mesaja yapıştırabilirsin.')));
          }),
      ]),
      for (final q in open) _tile(q),
      if (done.isNotEmpty) const Text('Sorduklarım', style: TextStyle(fontWeight: FontWeight.w800, color: _mor)),
      for (final q in done) _tile(q),
    ]);
  }

  Widget _tile(DoctorQuestion q) => Card(child: ListTile(
        leading: Checkbox(value: q.asked, onChanged: (v) => _save(_items.map((x) => x.id == q.id
            ? DoctorQuestion(x.id, x.text, x.about, x.created, answer: x.answer, asked: v == true) : x).toList())),
        title: Text(q.text, style: TextStyle(decoration: q.asked ? TextDecoration.lineThrough : null)),
        subtitle: Text([q.about == 'Bebeğim' ? '👶 Bebeğim' : '🌸 Ben', if (q.answer.isNotEmpty) 'Cevap: ${q.answer}'].join(' • ')),
        trailing: const Icon(Icons.edit_outlined),
        onTap: () => _edit(q)));

  Widget _faq() {
    final query = _search.text.trim();
    List<EncyclopediaTopic> topics = query.isEmpty
        ? encyclopediaTopics.where((t) => widget.categories.isEmpty || widget.categories.contains(t.category)).toList()
        : searchEncyclopedia(query);
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 6), child: TextField(controller: _search,
        key: const Key('sss_ara'),
        decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: t('Sorunu yaz (ör. gaz sancısı, kasık ağrısı)'),
            border: OutlineInputBorder()),
        onChanged: (_) => setState(() {}))),
      Expanded(child: topics.isEmpty
          ? const Center(child: Text('Eşleşen konu yok. Sorunu “Doktoruma soracaklarım”a ekleyebilirsin.'))
          : ListView.builder(itemCount: topics.length, itemBuilder: (_, i) {
              final t = topics[i];
              return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(
                leading: const Icon(Icons.help_outline_rounded, color: _mor),
                title: Text(t.title),
                subtitle: Text(t.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => EncyclopediaTopicPage(topic: t)))));
            })),
    ]);
  }
}
