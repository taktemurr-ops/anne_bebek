import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/general_recipe_catalog.dart';

/// Paket 39 / Aşama 22. Mevcut tarif ve alışveriş kayıtlarını değiştirmez.
class PantryRecipePage extends StatefulWidget {
  const PantryRecipePage({super.key});
  @override
  State<PantryRecipePage> createState() => _PantryRecipePageState();
}

class _PantryRecipePageState extends State<PantryRecipePage> {
  static const _storageKey = 'paket39_pantry_ingredients_v1';
  static const _purple = Color(0xFF48235F);
  final _input = TextEditingController();
  final _search = TextEditingController();
  final Set<String> _pantry = {};
  String _category = 'Tümü';
  bool _onlyComplete = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = jsonDecode(prefs.getString(_storageKey) ?? '[]');
      if (saved is List) {
        _pantry.addAll(saved.whereType<String>().map(_normalize).where((e) => e.isNotEmpty));
      }
    } catch (_) {
      // Bozuk veri silinmez; kullanıcı yeni malzeme ekleyebilir.
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = await prefs.setString(_storageKey, jsonEncode(_pantry.toList()..sort()));
      if (!ok) throw StateError('Kaydedilemedi');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Malzemeler kaydedilemedi.')));
      }
    }
  }

  String _normalize(String value) => value.toLowerCase().trim()
      .replaceAll('ı', 'i').replaceAll('ğ', 'g').replaceAll('ü', 'u')
      .replaceAll('ş', 's').replaceAll('ö', 'o').replaceAll('ç', 'c')
      .replaceAll(RegExp(r'\s+'), ' ');

  // Miktar/ölçü ifadelerini atarak malzeme adını yaklaşık olarak çıkarır.
  String _ingredientName(String value) {
    var s = _normalize(value);
    s = s.replaceAll(RegExp(r'\([^)]*\)'), ' ');
    s = s.replaceAll(RegExp(r'^\s*[\d.,/]+\s*'), '');
    s = s.replaceAll(RegExp(r'^(yarim|bir|iki|uc|dort|bes)\s+'), '');
    s = s.replaceAll(RegExp(r'^(su|cay|yemek|tatli)\s+(bardagi|kasigi|kasik|bardak)\s*'), '');
    s = s.replaceAll(RegExp(r'^(adet|dis|dilim|tutam|demet|paket|gram|gr|g|kg|ml|litre|l|avuc|kase|kucuk|orta|buyuk|silme|tepeleme)\s+'), '');
    s = s.replaceAll(RegExp(r'^(su|cay|yemek|tatli)\s+(bardagi|kasigi|kasik|bardak)\s*'), '');
    return s.trim();
  }

  bool _have(String ingredient) {
    final name = _ingredientName(ingredient);
    if (name.isEmpty) return false;
    return _pantry.any((p) => p == name ||
        (p.length >= 4 && name.contains(p)) ||
        (name.length >= 4 && p.contains(name)));
  }

  void _add() {
    final text = _normalize(_input.text);
    if (text.isEmpty) return;
    setState(() => _pantry.add(text));
    _input.clear();
    _save();
  }

  Future<void> _addMissing(GeneralRecipe recipe) async {
    final missing = recipe.ingredients.where((i) => !_have(i)).toSet();
    if (missing.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu tarif için eksik malzeme görünmüyor.')));
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final decoded = jsonDecode(prefs.getString('alisveris') ?? '[]');
      if (decoded is! List || decoded.any((e) => e is! String)) {
        throw const FormatException('Liste biçimi geçersiz');
      }
      final existing = decoded.cast<String>();
      final merged = <String>{...existing, ...missing};
      final added = merged.length - existing.toSet().length;
      if (!await prefs.setString('alisveris', jsonEncode(merged.toList()))) {
        throw StateError('Kaydedilemedi');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$added malzeme alışveriş listesine eklendi.')));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Alışveriş listesi güncellenemedi; mevcut kayıtlar korunuyor.')));
      }
    }
  }

  void _detail(GeneralRecipe recipe) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(child: SizedBox(
        height: MediaQuery.sizeOf(ctx).height * .8,
        child: ListView(padding: const EdgeInsets.all(18), children: [
          Text(recipe.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: _purple)),
          Text('${recipe.category} • ${recipe.minutes} dakika'),
          const SizedBox(height: 16),
          const Text('Malzemeler', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          for (final ingredient in recipe.ingredients)
            ListTile(dense: true,
              leading: Icon(_have(ingredient) ? Icons.check_circle : Icons.add_circle_outline,
                color: _have(ingredient) ? Colors.green : Colors.deepOrange),
              title: Text(ingredient)),
          const SizedBox(height: 12),
          const Text('Hazırlanışı', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          for (var i = 0; i < recipe.steps.length; i++)
            Padding(padding: const EdgeInsets.symmetric(vertical: 7),
              child: Text('${i + 1}. ${recipe.steps[i]}')),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: () => _addMissing(recipe),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Eksikleri alışveriş listesine ekle')),
        ]))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Tümü', ...{for (final r in generalRecipes) r.category}];
    final query = _normalize(_search.text);
    final scored = <({GeneralRecipe recipe, int matched, int total})>[];
    for (final r in generalRecipes) {
      if (_category != 'Tümü' && r.category != _category) continue;
      if (query.isNotEmpty && !_normalize(r.title).contains(query) &&
          !r.ingredients.any((i) => _normalize(i).contains(query))) {
        continue;
      }
      final total = r.ingredients.length;
      if (total == 0) continue;
      final matched = r.ingredients.where(_have).length;
      if (_onlyComplete && matched != total) continue;
      scored.add((recipe: r, matched: matched, total: total));
    }
    scored.sort((a, b) {
      final aScore = a.matched / a.total;
      final bScore = b.matched / b.total;
      final cmp = bScore.compareTo(aScore);
      return cmp != 0 ? cmp : b.matched.compareTo(a.matched);
    });
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FC),
      appBar: AppBar(title: const Text('Evdeki malzemeler'), backgroundColor: const Color(0xFFFFD9ED)),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        ListView(padding: const EdgeInsets.all(14), children: [
          const Text('Dolabımda neler var?', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: _purple)),
          const SizedBox(height: 6),
          const Text('Malzemeleri tek tek ekle. Öneriler yaklaşık metin eşleşmesine göre sıralanır; miktar yeterliliğini ayrıca kontrol et.'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: _input,
              onSubmitted: (_) => _add(),
              decoration: const InputDecoration(labelText: 'Örn. domates, yumurta, süt',
                border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _add, tooltip: 'Malzeme ekle', icon: const Icon(Icons.add)),
          ]),
          const SizedBox(height: 10),
          if (_pantry.isEmpty) const Text('Henüz malzeme eklenmedi.'),
          Wrap(spacing: 7, runSpacing: 5, children: [
            for (final item in (_pantry.toList()..sort())) InputChip(
              label: Text(item), onDeleted: () { setState(() => _pantry.remove(item)); _save(); }),
          ]),
          const Divider(height: 28),
          const Text('Tarif önerileri', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: _purple)),
          const SizedBox(height: 8),
          TextField(controller: _search, onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search),
              hintText: 'Tarif veya malzeme ara', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final c in categories) Padding(padding: const EdgeInsets.only(right: 7),
              child: ChoiceChip(label: Text(c), selected: _category == c,
                onSelected: (_) => setState(() => _category = c))),
          ])),
          SwitchListTile(contentPadding: EdgeInsets.zero,
            title: const Text('Yalnızca tüm malzemeleri bulunan tarifler'),
            value: _onlyComplete, onChanged: (v) => setState(() => _onlyComplete = v)),
          Text('${scored.length} tarif • Uygunluk yaklaşık malzeme eşleşmesidir',
            style: const TextStyle(color: _purple)),
          const SizedBox(height: 8),
          for (final result in scored) Card(color: Colors.white, child: ListTile(
            title: Text(result.recipe.title),
            subtitle: Text('${result.recipe.category} • ${result.recipe.minutes} dk • '
              '${result.matched}/${result.total} malzeme var'),
            leading: CircleAvatar(backgroundColor: const Color(0xFFFFD9ED),
              child: Text('${(result.matched * 100 / result.total).round()}%',
                style: const TextStyle(fontSize: 11, color: _purple))),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _detail(result.recipe),
          )),
        ]),
    );
  }
}
