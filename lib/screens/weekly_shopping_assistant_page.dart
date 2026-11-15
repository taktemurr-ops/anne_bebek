import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/general_recipe_catalog.dart';
import 'pantry_recipe_page.dart';

/// Paket 39 / Aşama 29. Mevcut kayıtları silmez veya dönüştürmez.
/// Ölçüler farklıysa otomatik toplama yapılmaz; kaynak satırlar gösterilir.
class WeeklyShoppingAssistantPage extends StatefulWidget {
  final DateTime weekStart;
  const WeeklyShoppingAssistantPage({super.key, required this.weekStart});
  @override
  State<WeeklyShoppingAssistantPage> createState() => _WeeklyShoppingAssistantPageState();
}

class _WeeklyShoppingAssistantPageState extends State<WeeklyShoppingAssistantPage> {
  static const _purple = Color(0xFF48235F);
  static const _days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
  static const _meals = ['Kahvaltı', 'Öğle', 'Akşam'];
  final Map<String, List<String>> _groups = {};
  final Set<String> _pantry = {};
  final Set<String> _selected = {};
  final Set<String> _existing = {};
  bool _loading = true;
  String? _error;
  bool _excludePantry = true;
  String _query = '';
  bool _onlySelected = false;
  bool _groupByCategory = true;

  String _categoryFor(String name) {
    final n = _normalize(name);
    if (RegExp(r'(tavuk|hindi|et|kiyma|kofte|balik|somon|ton|karides)').hasMatch(n)) return 'Et, tavuk ve balık';
    if (RegExp(r'(sut|yogurt|peynir|tereyagi|krema|kefir|labne)').hasMatch(n)) return 'Süt ürünleri';
    if (RegExp(r'(domates|biber|sogan|sarimsak|patates|kabak|havuc|patlican|ispanak|marul|maydanoz|dereotu|salatalik|limon|elma|muz|cilek|armut|portakal|mantar|brokoli)').hasMatch(n)) return 'Sebze ve meyve';
    if (RegExp(r'(un|pirinc|bulgur|makarna|ekmek|yulaf|irmik|nisasta|mercimek|nohut|fasulye)').hasMatch(n)) return 'Tahıl ve bakliyat';
    if (RegExp(r'(tuz|karabiber|kimyon|kekik|pul biber|nane|tarçin|zencefil|zeytinyagi|siviyag|salca|sirke|seker|bal)').hasMatch(n)) return 'Baharat ve temel ürünler';
    return 'Diğer malzemeler';
  }

  Future<void> _openPantry() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const PantryRecipePage()));
    if (mounted) await _load();
  }

  void _showSummary() {
    final missing = _groups.keys.where((n) => !_atHome(n)).toList();
    final categories = <String, int>{};
    for (final n in missing) {
      final c = _categoryFor(n);
      categories[c] = (categories[c] ?? 0) + 1;
    }
    showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Haftalık alışveriş özeti'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Toplam farklı malzeme: ${_groups.length}'),
        Text('Evde bulunan: ${_groups.length - missing.length}'),
        Text('Eksik malzeme: ${missing.length}'),
        Text('Alışveriş için seçilen: ${_selected.where((n) => !_atHome(n)).length}'),
        const SizedBox(height: 12),
        const Text('Eksiklerin kategori dağılımı:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...((categories.entries.toList()..sort((a,b) => a.key.compareTo(b.key))).map((e) => Padding(
          padding: const EdgeInsets.only(top: 5), child: Text('${e.key}: ${e.value}'))),
        const SizedBox(height: 10),
        const Text('Miktarlar farklı ölçü birimlerinde otomatik birleştirilmez.', style: TextStyle(fontSize: 12)),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))],
    ));
  }

  String get _weekKey {
    final d = widget.weekStart;
    final id = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return 'paket39_weekly_meal_plan_v2_$id';
  }

  String _normalize(String input) => input.toLowerCase().trim()
      .replaceAll('ı', 'i').replaceAll('ğ', 'g').replaceAll('ü', 'u')
      .replaceAll('ş', 's').replaceAll('ö', 'o').replaceAll('ç', 'c')
      .replaceAll(RegExp(r'\s+'), ' ');

  // Sayısal miktar ve yaygın ölçüleri ayıklar; miktarlar kaynak satırda korunur.
  String _name(String ingredient) {
    var s = _normalize(ingredient).replaceAll(RegExp(r'\([^)]*\)'), ' ');
    s = s.replaceFirst(RegExp(r'^\s*(\d+[.,]?\d*|\d+/\d+|yarim|bir|iki|uc|dort)\s*'), '');
    s = s.replaceFirst(RegExp(r'^(adet|gram|gr|kg|ml|litre|l|paket|dilim|dis|demet|tutam|avuc|kase)\s+'), '');
    s = s.replaceFirst(RegExp(r'^(su|cay|yemek|tatli)\s+(bardagi|kasigi|bardak|kasik)\s+'), '');
    return s.trim();
  }

  bool _atHome(String name) {
    if (name.isEmpty) return false;
    // Yalnızca tam isim eşleşmesi: benzer ama farklı malzemeler yanlış sayılmasın.
    return _pantry.contains(name);
  }

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final planRaw = prefs.getString(_weekKey);
      final plan = planRaw == null ? <String, dynamic>{} : jsonDecode(planRaw);
      if (plan is! Map) throw const FormatException('Haftalık plan biçimi geçersiz');
      final pantryRaw = jsonDecode(prefs.getString('paket39_pantry_ingredients_v1') ?? '[]');
      final shoppingRaw = jsonDecode(prefs.getString('alisveris') ?? '[]');
      if (pantryRaw is! List || shoppingRaw is! List) throw const FormatException('Liste biçimi geçersiz');
      final recipesById = {for (final r in generalRecipes) r.id: r};
      final groups = <String, List<String>>{};
      for (final day in _days) {
        for (final meal in _meals) {
          final id = plan['$day|$meal'];
          final recipe = recipesById[id];
          if (recipe == null) continue;
          for (final raw in recipe.ingredients) {
            final line = raw.trim();
            final name = _name(line);
            if (name.isEmpty) continue;
            final lines = groups.putIfAbsent(name, () => []);
            if (!lines.contains(line)) lines.add(line);
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _groups..clear()..addAll(groups);
        _pantry..clear()..addAll(pantryRaw.whereType<String>().map(_normalize));
        _existing..clear()..addAll(shoppingRaw.whereType<String>().map(_normalize));
        _selected..clear()..addAll(groups.keys.where((n) => !_pantry.contains(n)));
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() { _error = 'Kayıtlar okunamadı. Hiçbir veri değiştirilmedi.'; _loading = false; });
    }
  }

  Future<void> _addToShopping() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final decoded = jsonDecode(prefs.getString('alisveris') ?? '[]');
      if (decoded is! List || decoded.any((e) => e is! String)) {
        throw const FormatException('Alışveriş listesi biçimi geçersiz');
      }
      final items = decoded.cast<String>().toList();
      final normalized = items.map(_normalize).toSet();
      var count = 0;
      for (final name in _selected) {
        if (_excludePantry && _atHome(name)) continue;
        // Tek satır eklenir, farklı miktarlar not olarak korunur.
        final details = _groups[name] ?? [];
        if (details.isEmpty) continue;
        final entry = details.length == 1 ? details.first : '$name (${details.join(' + ')})';
        if (normalized.add(_normalize(entry))) { items.add(entry); count++; }
      }
      if (!await prefs.setString('alisveris', jsonEncode(items))) throw StateError('Kayıt başarısız');
      if (!mounted) return;
      setState(() => _existing..clear()..addAll(normalized));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$count yeni ürün mevcut alışveriş listesine eklendi.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alışveriş listesi kaydedilemedi; eski kayıtlar korundu.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final names = _groups.keys.where((n) =>
      (!_excludePantry || !_atHome(n)) &&
      (!_onlySelected || _selected.contains(n)) &&
      (_query.isEmpty || n.contains(_normalize(_query)) ||
        (_groups[n] ?? []).any((line) => _normalize(line).contains(_normalize(_query)))))
      .toList()..sort();
    if (_groupByCategory) {
      names.sort((a, b) {
        final category = _categoryFor(a).compareTo(_categoryFor(b));
        return category != 0 ? category : a.compareTo(b);
      });
    }
    final date = widget.weekStart;
    final missingCount = _groups.keys.where((n) => !_atHome(n)).length;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FC),
      appBar: AppBar(title: const Text('Haftalık alışveriş analizi'), backgroundColor: const Color(0xFFFFD9ED)),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        _error != null ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!))) :
        Column(children: [
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${date.day}.${date.month}.${date.year} haftası',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _purple)),
            const SizedBox(height: 8),
            Text('${_groups.length} farklı malzeme • ${_groups.keys.where(_atHome).length} evde mevcut • $missingCount eksik'),
            Wrap(spacing: 6, children: [
              TextButton.icon(onPressed: _showSummary, icon: const Icon(Icons.summarize_outlined), label: const Text('Hafta özeti')),
              TextButton.icon(onPressed: _openPantry, icon: const Icon(Icons.kitchen_outlined), label: const Text('Evdeki malzemeler')),
              TextButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Yenile')),
            ]),
            const SizedBox(height: 8),
            TextField(onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), labelText: 'Malzeme ara',
                isDense: true, border: OutlineInputBorder())),
            Wrap(spacing: 8, children: [
              TextButton.icon(onPressed: () => setState(() => _selected.addAll(names)),
                icon: const Icon(Icons.select_all), label: const Text('Görünenleri seç')),
              TextButton.icon(onPressed: () => setState(() => _selected.removeAll(names)),
                icon: const Icon(Icons.deselect), label: const Text('Seçimi kaldır')),
              FilterChip(label: const Text('Yalnızca seçilenler'), selected: _onlySelected,
                onSelected: (v) => setState(() => _onlySelected = v)),
              FilterChip(label: const Text('Kategoriye göre grupla'), selected: _groupByCategory,
                onSelected: (v) => setState(() => _groupByCategory = v)),
              TextButton.icon(onPressed: () => setState(() {
                _selected..clear()..addAll(_groups.keys.where((n) => !_atHome(n)));
              }), icon: const Icon(Icons.auto_awesome), label: const Text('Eksikleri otomatik seç')),
            ]),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Evde olan malzemeleri gizle'),
              value: _excludePantry, onChanged: (v) => setState(() => _excludePantry = v)),
            const Text('Farklı ölçüler otomatik toplanmaz. Her tarifteki miktar ayrı gösterilir.',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
          ])),
          Expanded(child: names.isEmpty ? const Center(child: Text('Bu hafta için eksik malzeme bulunamadı.')) :
            ListView.builder(itemCount: names.length, itemBuilder: (ctx, i) {
              final name = names[i];
              final lines = _groups[name] ?? [];
              final inShopping = lines.any((line) => _existing.contains(_normalize(line)));
              return CheckboxListTile(
                value: _selected.contains(name),
                onChanged: (v) => setState(() { if (v == true) { _selected.add(name); } else { _selected.remove(name); } }),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                secondary: _groupByCategory ? const Icon(Icons.category_outlined, color: _purple) : null,
                subtitle: Text('${_groupByCategory ? '${_categoryFor(name)} • ' : ''}${lines.join(' • ')}${_atHome(name) ? ' • Evde var' : ''}${inShopping ? ' • Listede var' : ''}'),
                activeColor: _purple,
              );
            })),
          Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity,
            child: FilledButton.icon(onPressed: _selected.isEmpty ? null : _addToShopping,
              icon: const Icon(Icons.add_shopping_cart),
              label: Text('Seçili ${_selected.length} malzemeyi alışverişe ekle')))),
        ]),
    );
  }
}
