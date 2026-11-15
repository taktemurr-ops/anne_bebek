import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Paket 39: Mevcut 'alisveris' ve 'tamamlanan' kayıt biçimleri değiştirilmez.
/// Kategori/miktar notları ayrı bir anahtarda saklanır.
class SmartShoppingPage extends StatefulWidget {
  const SmartShoppingPage({super.key});
  @override
  State<SmartShoppingPage> createState() => _SmartShoppingPageState();
}

class _SmartShoppingPageState extends State<SmartShoppingPage> {
  static const _purple = Color(0xFF48235F);
  static const _pink = Color(0xFFFFF7FC);
  static const _categories = <String>[
    'Tümü', 'Sebze & Meyve', 'Et & Balık', 'Süt & Kahvaltılık',
    'Bakliyat & Tahıl', 'Baharat & Sos', 'Temizlik', 'Bebek', 'Diğer',
  ];
  final _items = <String>[];
  final _done = <String>{};
  final _details = <String, Map<String, String>>{};
  String _query = '';
  String _category = 'Tümü';
  bool _hideDone = false;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final items = (jsonDecode(prefs.getString('alisveris') ?? '[]') as List)
          .map((e) => e.toString()).toList();
      final done = (jsonDecode(prefs.getString('tamamlanan') ?? '[]') as List)
          .map((e) => e.toString()).toSet();
      final raw = jsonDecode(prefs.getString('paket39_shopping_details_v1') ?? '{}') as Map;
      if (!mounted) return;
      setState(() {
        _items..clear()..addAll(items);
        _done..clear()..addAll(done);
        _details.clear();
        for (final entry in raw.entries) {
          if (entry.value is Map) {
            _details[entry.key.toString()] = (entry.value as Map)
                .map((key, value) => MapEntry(key.toString(), value.toString()));
          }
        }
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _notice('Liste okunamadı; mevcut veriler değiştirilmedi.');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok1 = await prefs.setString('alisveris', jsonEncode(_items));
      final ok2 = await prefs.setString('tamamlanan', jsonEncode(_done.toList()));
      final ok3 = await prefs.setString('paket39_shopping_details_v1', jsonEncode(_details));
      if (!ok1 || !ok2 || !ok3) throw StateError('Kaydetme başarısız');
    } catch (_) { _notice('Değişiklik kaydedilemedi.'); }
  }

  void _notice(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _guess(String name) {
    final n = name.toLowerCase();
    if (RegExp(r'domates|salatalık|biber|patates|soğan|elma|muz|havuç|kabak|ıspanak|limon|marul|patlıcan').hasMatch(n)) return 'Sebze & Meyve';
    if (RegExp(r'tavuk|kıyma|dana|balık|somon|hindi|köfte').hasMatch(n)) return 'Et & Balık';
    if (RegExp(r'süt|yoğurt|peynir|yumurta|tereyağ|labne').hasMatch(n)) return 'Süt & Kahvaltılık';
    if (RegExp(r'pirinç|bulgur|mercimek|nohut|fasulye|un|makarna|yulaf').hasMatch(n)) return 'Bakliyat & Tahıl';
    if (RegExp(r'tuz|karabiber|kimyon|salça|zeytinyağ|sos|kekik').hasMatch(n)) return 'Baharat & Sos';
    if (RegExp(r'deterjan|sabun|çamaşır|temizlik').hasMatch(n)) return 'Temizlik';
    if (RegExp(r'bebek|bez|mama|ıslak mendil').hasMatch(n)) return 'Bebek';
    return 'Diğer';
  }

  Future<void> _edit({String? original}) async {
    final name = TextEditingController(text: original ?? '');
    final note = TextEditingController(text: original == null ? '' : (_details[original]?['note'] ?? ''));
    var category = original == null ? 'Diğer' : (_details[original]?['category'] ?? _guess(original));
    if (!_categories.contains(category)) category = 'Diğer';
    final result = await showDialog<(String, String, String)?>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
        title: Text(original == null ? 'Ürün ekle' : 'Ürünü düzenle'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Ürün / malzeme')),
          const SizedBox(height: 10),
          TextField(controller: note, decoration: const InputDecoration(labelText: 'Miktar / not (ör. 2 kg)')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(initialValue: category,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: _categories.skip(1).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) { if (v != null) update(() => category = v); }),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(onPressed: () {
            final n = name.text.trim();
            if (n.isNotEmpty) Navigator.pop(ctx, (n, note.text.trim(), category));
          }, child: const Text('Kaydet')),
        ],
      )),
    );
    name.dispose(); note.dispose();
    if (result == null || !mounted) return;
    final (newName, newNote, newCategory) = result;
    setState(() {
      if (original != null && original != newName) {
        _items.remove(original);
        _details.remove(original);
        if (_done.remove(original)) _done.add(newName);
      }
      if (!_items.contains(newName)) _items.add(newName);
      _details[newName] = {'note': newNote, 'category': newCategory};
    });
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _items.where((name) {
      final cat = _details[name]?['category'] ?? _guess(name);
      return (_category == 'Tümü' || cat == _category) &&
          (!_hideDone || !_done.contains(name)) &&
          name.toLowerCase().contains(_query.toLowerCase());
    }).toList()..sort((a, b) {
      final doneOrder = (_done.contains(a) ? 1 : 0).compareTo(_done.contains(b) ? 1 : 0);
      return doneOrder != 0 ? doneOrder : a.toLowerCase().compareTo(b.toLowerCase());
    });
    return Scaffold(
      backgroundColor: _pink,
      appBar: AppBar(title: const Text('Akıllı alışveriş listem'),
        actions: [IconButton(tooltip: 'Yenile', icon: const Icon(Icons.refresh), onPressed: _load)]),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _edit(),
        icon: const Icon(Icons.add), label: const Text('Ürün ekle')),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        ListView(padding: const EdgeInsets.fromLTRB(14, 12, 14, 100), children: [
          Card(color: const Color(0xFFFFE4F1), child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Alışveriş durumum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _purple)),
              const SizedBox(height: 8),
              Text('${_items.where(_done.contains).length} / ${_items.length} ürün tamamlandı'),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _items.isEmpty ? 0 : _items.where(_done.contains).length / _items.length),
            ]))),
          const SizedBox(height: 12),
          TextField(onChanged: (s) => setState(() => _query = s),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Ürün ara')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(initialValue: _category,
            decoration: const InputDecoration(labelText: 'Kategori'),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) { if (v != null) setState(() => _category = v); }),
          SwitchListTile(title: const Text('Tamamlananları gizle'), value: _hideDone,
            onChanged: (v) => setState(() => _hideDone = v)),
          if (visible.isEmpty) const Padding(padding: EdgeInsets.all(20),
            child: Text('Bu filtrede ürün bulunamadı.')),
          ...visible.map((name) => Card(child: CheckboxListTile(
            value: _done.contains(name),
            onChanged: (checked) async {
              setState(() { if (checked == true) { _done.add(name); } else { _done.remove(name); } });
              await _save();
            },
            title: Text(name, style: TextStyle(decoration: _done.contains(name) ? TextDecoration.lineThrough : null)),
            subtitle: Text('${_details[name]?['category'] ?? _guess(name)}${(_details[name]?['note'] ?? '').isEmpty ? '' : '  •  ${_details[name]!['note']}'}'),
            secondary: PopupMenuButton<String>(tooltip: 'Ürün işlemleri',
              onSelected: (action) async {
                if (action == 'edit') { await _edit(original: name); }
                if (action == 'delete') {
                  setState(() { _items.remove(name); _done.remove(name); _details.remove(name); });
                  await _save();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                PopupMenuItem(value: 'delete', child: Text('Sil')),
              ]),
          ))),
          const SizedBox(height: 8),
          const Text('Tariflerden ve haftalık plandan eklenen ürünler aynı listede görünür. Miktar notları mevcut malzeme metinlerini değiştirmez.',
            style: TextStyle(fontSize: 12, color: _purple)),
        ]),
    );
  }
}
