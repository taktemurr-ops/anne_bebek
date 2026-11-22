import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/json_store.dart';
import '../services/memories.dart';
import '../services/photo_store.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

/// Anı defteri: ilkler, ay ay fotoğraflar ve özel günler.
class MemoriesPage extends StatefulWidget {
  static const storageKey = 'baby_memories_v1';
  final String childKey;
  final DateTime? birth;
  final String childName;
  const MemoriesPage({super.key, this.childKey = 'main', this.birth, this.childName = ''});

  @override
  State<MemoriesPage> createState() => _MemoriesPageState();
}

class _MemoriesPageState extends State<MemoriesPage> {
  Map<String, dynamic> _all = {};
  List<Memory> _items = [];
  String? _dir;
  String _filter = 'Tümü';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> all = {};
    String? dir;
    try { all = await JsonStore.readMap(MemoriesPage.storageKey); } catch (_) {}
    try { dir = await PhotoStore.dirPath(); } catch (_) {}
    if (!mounted) return;
    setState(() { _all = all; _items = decodeMemories(all[widget.childKey]); _dir = dir; _loading = false; });
  }

  Future<bool> _save(List<Memory> next) async {
    next.sort((a, b) => b.date.compareTo(a.date));
    final all = {..._all, widget.childKey: next.map((m) => m.toJson()).toList()};
    try {
      await JsonStore.writeMap(MemoriesPage.storageKey, all);
      if (mounted) setState(() { _all = all; _items = next; });
      return true;
    } catch (_) {
      if (mounted) kitSaveFailed(context);
      return false;
    }
  }

  File? _file(String? name) => name == null || _dir == null ? null : File('$_dir/$name');

  Future<void> _edit([Memory? editing]) async {
    final title = TextEditingController(text: editing?.title ?? '');
    final note = TextEditingController(text: editing?.note ?? '');
    var date = editing?.date ?? DateTime.now();
    var tag = editing?.tag ?? 'Diğer';
    var photo = editing?.photo;
    final added = <String>[];
    final saved = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) {
      Future<void> pick(bool camera) async {
        try {
          final name = await PhotoStore.pick(camera: camera);
          if (name != null) { added.add(name); set(() => photo = name); }
        } catch (_) {
          if (ctx.mounted) kitSnack(ctx, 'Fotoğraf alınamadı. Kamera ya da galeri iznini kontrol et.');
        }
      }
      final f = _file(photo);
      return AlertDialog(
        title: Text(editing == null ? 'Yeni anı' : 'Anıyı düzenle'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 6, runSpacing: 4, children: [
            for (final g in memoryTags)
              ChoiceChip(label: Text(g, style: const TextStyle(fontSize: 12)), selected: tag == g, onSelected: (_) => set(() {
                tag = g;
                if (title.text.trim().isEmpty && g != 'Diğer') title.text = t(g);
              })),
          ]),
          TextField(key: const Key('ani_baslik'), controller: title, decoration: InputDecoration(labelText: t('Başlık'))),
          TextField(controller: note, minLines: 2, maxLines: 5, decoration: InputDecoration(labelText: t('Not'))),
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event), title: Text(dmy(date)),
            subtitle: Text(ageLabelAt(widget.birth, date)),
            onTap: () async {
              final d = await kitPickDay(ctx, initial: date);
              if (d != null) set(() => date = d);
            }),
          if (f != null) ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Image.file(f, height: 160, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink())),
          Wrap(spacing: 8, children: [
            OutlinedButton.icon(onPressed: () => pick(true), icon: const Icon(Icons.photo_camera_outlined), label: Text('Kamera')),
            OutlinedButton.icon(onPressed: () => pick(false), icon: const Icon(Icons.photo_library_outlined), label: Text('Galeri')),
            if (photo != null) TextButton(onPressed: () => set(() => photo = null), child: Text('Fotoğrafı kaldır')),
          ]),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Vazgeç')),
          FilledButton(key: const Key('ani_kaydet'), onPressed: () {
            if (title.text.trim().isEmpty) { kitSnack(ctx, 'Bir başlık yaz.'); return; }
            Navigator.pop(ctx, true);
          }, child: Text('Kaydet')),
        ]);
    }));
    final titleText = title.text.trim();
    final noteText = note.text.trim();
    title.dispose();
    note.dispose();
    // Kaydedilmeyen ya da değiştirilen fotoğraflar diskte kalmasın.
    Future<void> cleanup(Iterable<String> names) async {
      for (final n in names) {
        try { await PhotoStore.deleteFile(n); } catch (_) {}
      }
    }
    if (saved != true) { await cleanup(added); return; }
    final m = editing == null
        ? Memory(id: 'm${DateTime.now().microsecondsSinceEpoch}', date: date, title: titleText, note: noteText, tag: tag, photo: photo)
        : editing.copyWith(date: date, title: titleText, note: noteText, tag: tag, photo: photo, clearPhoto: photo == null);
    final next = [..._items.where((e) => e.id != m.id), m];
    if (await _save(next)) {
      await cleanup([...added.where((n) => n != photo), if (editing?.photo != null && editing!.photo != photo) editing.photo!]);
    }
  }

  Future<void> _delete(Memory m) async {
    if (!await kitConfirm(context, 'Anıyı sil', 'Bu anı ve fotoğrafı silinsin mi?')) return;
    if (await _save(_items.where((e) => e.id != m.id).toList()) && m.photo != null) {
      try { await PhotoStore.deleteFile(m.photo!); } catch (_) {}
    }
  }

  void _view(Memory m) {
    final f = _file(m.photo);
    showDialog<void>(context: context, builder: (ctx) => Dialog(child: SingleChildScrollView(child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (f != null) Image.file(f, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox(height: 40)),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kitMor)),
          Text('${dmy(m.date)}  ${t(ageLabelAt(widget.birth, m.date))}', style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
          if (m.note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(m.note)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton.icon(onPressed: () { Navigator.pop(ctx); _delete(m); }, icon: const Icon(Icons.delete_outline), label: Text('Sil')),
            TextButton.icon(onPressed: () { Navigator.pop(ctx); _edit(m); }, icon: const Icon(Icons.edit_outlined), label: Text('Düzenle')),
          ]),
        ])),
      ]))));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final shown = _filter == 'Tümü' ? _items : _items.where((m) => m.tag == _filter).toList();
    final tags = ['Tümü', ...memoryTags.where((g) => _items.any((m) => m.tag == g))];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelCard(color: const Color(0xFFFFF4FA), child: Row(children: [
        const Icon(Icons.photo_album_outlined, color: kitMor, size: 34),
        const SizedBox(width: 12),
        Expanded(child: Text('İlk gülüşü, ilk adımı, ay ay fotoğrafları burada sakla. Fotoğraflar yalnızca bu telefonda, uygulamanın kendi klasöründe durur.',
            style: TextStyle(fontSize: 12.5))),
      ])),
      FilledButton.icon(key: const Key('ani_ekle'), onPressed: () => _edit(), icon: const Icon(Icons.add_a_photo_outlined), label: Text('Anı ekle')),
      const SizedBox(height: 8),
      if (tags.length > 2) SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [
        for (final g in tags) Padding(padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(label: Text(g), selected: g == _filter, onSelected: (_) => setState(() => _filter = g))),
      ])),
      if (_items.isEmpty) const KitNote('Henüz anı yok. “Anı ekle” ile ilk anını kaydet.'),
      for (final m in shown) PastelCard(padding: EdgeInsets.zero, onTap: () => _view(m), child: Row(children: [
        ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(22)),
          child: SizedBox(width: 92, height: 92, child: _file(m.photo) == null
              ? Container(color: const Color(0xFFF7ECF6), child: const Icon(Icons.favorite_border, color: kitMor))
              : Image.file(_file(m.photo)!, fit: BoxFit.cover, cacheWidth: 300,
                  errorBuilder: (_, _, _) => Container(color: const Color(0xFFF7ECF6), child: const Icon(Icons.broken_image_outlined))))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, color: kitMor)),
          Text('${dmy(m.date)}  ${t(ageLabelAt(widget.birth, m.date))}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          if (m.note.isNotEmpty) Text(m.note, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5)),
        ])),
        const SizedBox(width: 8),
      ])),
      const KitFootnote('Fotoğraflar yedek dosyasına eklenmez; telefon değiştirmeden önce önemli fotoğrafları galerine de kaydet. “Verilerimi sil” fotoğrafları da siler.'),
    ]);
  }
}
