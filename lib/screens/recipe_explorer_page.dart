import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/general_recipe_catalog.dart';
import 'weekly_meal_planner_page.dart';

/// Paket 39 / Asama 38-42: Mevcut tarif ve favori kayitlariyla uyumlu kesif ekrani.
class RecipeExplorerPage extends StatefulWidget {
  const RecipeExplorerPage({super.key});
  @override
  State<RecipeExplorerPage> createState() => _RecipeExplorerPageState();
}

class _RecipeExplorerPageState extends State<RecipeExplorerPage> {
  static const _purple = Color(0xFF48235F);
  static const _pink = Color(0xFFFFEAF5);
  final _search = TextEditingController();
  final Set<String> _favorites = {};
  String _category = 'Tümü';
  String _sort = 'Önerilen';
  int _maxMinutes = 0;
  bool _onlyFavorites = false;
  final List<String> _recentIds = [];
  bool _onlyRecent = false;

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final decoded = jsonDecode(p.getString('favoriler') ?? '[]');
      final history = jsonDecode(p.getString('paket39_recipe_recent_v1') ?? '[]');
      if (mounted) {
        setState(() {
          if (decoded is List) { _favorites..clear()..addAll(decoded.whereType<String>()); }
          if (history is List) { _recentIds..clear()..addAll(history.whereType<String>()); }
        });
      }
    } catch (_) { /* Bozuk eski veriyi silme. */ }
  }

  Future<void> _toggleFavorite(GeneralRecipe recipe) async {
    final p = await SharedPreferences.getInstance();
    // Ana ekranla ayni anahtari kullan; en son kaydi yeniden oku.
    Set<String> latest;
    try {
      final raw = jsonDecode(p.getString('favoriler') ?? '[]');
      latest = raw is List ? raw.whereType<String>().toSet() : {..._favorites};
    } catch (_) { latest = {..._favorites}; }
    if (!latest.add(recipe.title)) latest.remove(recipe.title);
    final saved = await p.setString('favoriler', jsonEncode(latest.toList()));
    if (!mounted) return;
    if (saved) {
      setState(() { _favorites..clear()..addAll(latest); });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favori kaydedilemedi.')));
    }
  }

  Future<void> _addIngredients(GeneralRecipe recipe) async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = jsonDecode(p.getString('alisveris') ?? '[]');
      if (raw is! List) throw const FormatException('Alışveriş listesi okunamadı');
      final items = raw.whereType<String>().toList();
      var added = 0;
      for (final ingredient in recipe.ingredients) {
        if (!items.contains(ingredient)) { items.add(ingredient); added++; }
      }
      final ok = await p.setString('alisveris', jsonEncode(items));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok
          ? '$added malzeme alışveriş listesine eklendi.'
          : 'Alışveriş listesi kaydedilemedi.')));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alışveriş listesi okunamadı; mevcut veriler korunuyor.')));
      }
    }
  }

  Future<void> _recordRecent(GeneralRecipe r) async {
    try {
      final p = await SharedPreferences.getInstance();
      final stored = jsonDecode(p.getString('paket39_recipe_recent_v1') ?? '[]');
      final ids = stored is List ? stored.whereType<String>().toList() : <String>[];
      ids.remove(r.id);
      ids.insert(0, r.id);
      if (ids.length > 30) ids.removeRange(30, ids.length);
      if (await p.setString('paket39_recipe_recent_v1', jsonEncode(ids)) && mounted) {
        setState(() { _recentIds..clear()..addAll(ids); });
      }
    } catch (_) { /* Mevcut verileri koru. */ }
  }

  void _details(GeneralRecipe r) {
    _recordRecent(r);
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) =>
      _InteractiveRecipeDetails(recipe: r, addIngredients: () => _addIngredients(r))));
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Tümü', ...{for (final r in generalRecipes) r.category}];
    final q = _search.text.trim().toLowerCase();
    final filtered = generalRecipes.where((r) =>
      (_category == 'Tümü' || r.category == _category) &&
      (_maxMinutes == 0 || r.minutes <= _maxMinutes) &&
      (!_onlyFavorites || _favorites.contains(r.title)) &&
      (!_onlyRecent || _recentIds.contains(r.id)) &&
      (q.isEmpty || r.title.toLowerCase().contains(q) ||
       r.category.toLowerCase().contains(q) ||
       r.ingredients.any((m) => m.toLowerCase().contains(q)))).toList();
    if (_sort == 'Süre: kısa → uzun') {
      filtered.sort((a,b) => a.minutes.compareTo(b.minutes));
    } else if (_sort == 'Süre: uzun → kısa') {
      filtered.sort((a,b) => b.minutes.compareTo(a.minutes));
    } else if (_sort == 'İsim: A → Z') {
      filtered.sort((a,b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Tarif keşfi'), backgroundColor: _pink),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 6), child: TextField(
          controller: _search, onChanged: (_) => setState(() {}),
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search),
            hintText: 'Tarif, kategori veya malzeme ara',
            suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () { _search.clear(); setState(() {}); }),
            border: const OutlineInputBorder()))),
        SizedBox(height: 46, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [for (final c in categories) Padding(padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(label: Text(c), selected: _category == c,
              onSelected: (_) => setState(() => _category = c)))])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          DropdownButton<int>(value: _maxMinutes, items: const [
            DropdownMenuItem(value: 0, child: Text('Tüm süreler')),
            DropdownMenuItem(value: 15, child: Text('≤ 15 dk')),
            DropdownMenuItem(value: 30, child: Text('≤ 30 dk')),
            DropdownMenuItem(value: 60, child: Text('≤ 60 dk')),
          ], onChanged: (v) => setState(() => _maxMinutes = v ?? 0)),
          DropdownButton<String>(value: _sort, items: ['Önerilen','Süre: kısa → uzun','Süre: uzun → kısa','İsim: A → Z']
            .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _sort = v ?? 'Önerilen')),
          FilterChip(label: const Text('Favorilerim'), selected: _onlyFavorites,
            onSelected: (v) => setState(() => _onlyFavorites = v)),
          FilterChip(label: const Text('Son görüntülenenler'), selected: _onlyRecent,
            onSelected: (v) => setState(() => _onlyRecent = v)),
        ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Row(children: [
          Text('${filtered.length} / ${generalRecipes.length} tarif', style: const TextStyle(color: _purple)),
          const Spacer(),
          TextButton(onPressed: () => setState(() {
            _search.clear(); _category = 'Tümü'; _sort = 'Önerilen'; _maxMinutes = 0; _onlyFavorites = false; _onlyRecent = false;
          }), child: const Text('Filtreleri sıfırla')),
        ])),
        Expanded(child: filtered.isEmpty ? const Center(child: Text('Bu filtrelere uygun tarif bulunamadı.')) :
          ListView.builder(itemCount: filtered.length, itemBuilder: (ctx, i) {
            final r = filtered[i];
            return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              color: i.isEven ? _pink : const Color(0xFFF4EFFF),
              child: ListTile(
                title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${r.category} • ${r.minutes} dk • ${r.ingredients.length} malzeme'),
                trailing: IconButton(tooltip: 'Favorilere ekle / çıkar',
                  icon: Icon(_favorites.contains(r.title) ? Icons.favorite : Icons.favorite_border,
                    color: const Color(0xFFE94291)),
                  onPressed: () => _toggleFavorite(r)),
                onTap: () => _details(r)));
          })),
      ]),
    );
  }
}

/// Aşama 43–47: Porsiyon, ölçü uyarlama, adım takibi, not ve geçmiş.
/// Tarif kataloğunun orijinal kayıtlarını değiştirmez.
class _InteractiveRecipeDetails extends StatefulWidget {
  final GeneralRecipe recipe;
  final Future<void> Function() addIngredients;
  const _InteractiveRecipeDetails({required this.recipe, required this.addIngredients});
  @override
  State<_InteractiveRecipeDetails> createState() => _InteractiveRecipeDetailsState();
}

class _InteractiveRecipeDetailsState extends State<_InteractiveRecipeDetails> {
  static const _purple = Color(0xFF48235F);
  static const _pink = Color(0xFFFFEAF5);
  final _notes = TextEditingController();
  final Set<int> _completed = {};
  bool _progressLoaded = false;
  int _portions = 2;
  int _basePortions = 2;
  bool _saving = false;

  String get _noteKey => 'paket39_recipe_note_v1_${widget.recipe.id}';

  String get _progressKey => 'paket39_recipe_steps_v1_${widget.recipe.id}';
  @override
  void initState() { super.initState(); _loadNotes(); _loadProgress(); }
  @override
  void dispose() { _notes.dispose(); super.dispose(); }

  Future<void> _loadNotes() async {
    try {
      final p = await SharedPreferences.getInstance();
      final note = p.getString(_noteKey) ?? '';
      if (mounted) setState(() => _notes.text = note);
    } catch (_) { /* Mevcut kaydı silme. */ }
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonDecode(prefs.getString(_progressKey) ?? '[]');
      if (raw is List && mounted) {
        setState(() {
          _completed..clear()..addAll(raw.whereType<int>().where((i) => i >= 0 && i < widget.recipe.steps.length));
          _progressLoaded = true;
        });
      }
    } catch (_) { if (mounted) setState(() => _progressLoaded = true); /* Bozuk kaydi silme. */ }
  }

  Future<void> _saveProgress() async {
    if (!_progressLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = await prefs.setString(_progressKey, jsonEncode(_completed.toList()..sort()));
      if (!ok && mounted) _message('Adim ilerlemesi kaydedilemedi.');
    } catch (_) { if (mounted) _message('Adim ilerlemesi kaydedilemedi.'); }
  }

  void _message(String message) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static DateTime _monday(DateTime d) => DateTime(d.year, d.month, d.day)
      .subtract(Duration(days: d.weekday - 1));
  static String _dateId(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static const _days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
  static const _meals = ['Kahvaltı', 'Öğle', 'Akşam'];

  Future<void> _planRecipe() async {
    DateTime selected = DateTime.now();
    String meal = 'Akşam';
    final result = await showDialog<(DateTime, String)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
        title: const Text('Tarifi yemek planına ekle'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Gün seç'),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: Text('${selected.day.toString().padLeft(2, '0')}.${selected.month.toString().padLeft(2, '0')}.${selected.year}'),
            onTap: () async {
              final chosen = await showDatePicker(context: ctx, initialDate: selected,
                firstDate: DateTime(2020), lastDate: DateTime(2100));
              if (chosen != null) update(() => selected = chosen);
            },
          ),
          DropdownButtonFormField<String>(
            initialValue: meal, decoration: const InputDecoration(labelText: 'Öğün'),
            items: _meals.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) { if (v != null) update(() => meal = v); },
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, (selected, meal)), child: const Text('Devam')),
        ],
      )),
    );
    if (result == null || !mounted) return;
    final (date, selectedMeal) = result;
    final key = 'paket39_weekly_meal_plan_v2_${_dateId(_monday(date))}';
    final slot = '${_days[date.weekday - 1]}|$selectedMeal';
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      final legacy = prefs.getString('paket39_weekly_meal_plan_v1');
      final migrated = prefs.getBool('paket39_weekly_migration_v2') ?? false;
      final isCurrentWeek = _dateId(_monday(date)) == _dateId(_monday(DateTime.now()));
      // Ilk kullanimda mevcut haftanin eski plani korunarak aktarilir.
      final source = raw ?? (isCurrentWeek && !migrated ? legacy : null);
      final plan = <String, String>{};
      if (source != null) {
        final decoded = jsonDecode(source);
        if (decoded is! Map) throw const FormatException('Plan okunamadi');
        for (final entry in decoded.entries) {
          if (entry.key is String && entry.value is String) plan[entry.key as String] = entry.value as String;
        }
      }
      if (plan.containsKey(slot) && plan[slot] != widget.recipe.id) {
        if (!mounted) return;
        final replace = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Öğün zaten planlanmış'),
          content: const Text('Bu gün ve öğünde başka bir tarif var. Değiştirilsin mi?'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Değiştir'))],
        ));
        if (replace != true) return;
      }
      plan[slot] = widget.recipe.id;
      final ok = await prefs.setString(key, jsonEncode(plan));
      if (!ok) throw StateError('Plan kaydedilemedi');
      if (isCurrentWeek) {
        await prefs.setString('paket39_weekly_meal_plan_v1', jsonEncode(plan));
        await prefs.setBool('paket39_weekly_migration_v2', true);
      }
      _message('Tarif ${_days[date.weekday - 1]} / $selectedMeal öğününe eklendi.');
    } catch (_) { _message('Plan kaydedilemedi. Mevcut kayıtlar korunuyor.'); }
  }

  Future<void> _addScaledIngredients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final decoded = jsonDecode(prefs.getString('alisveris') ?? '[]');
      if (decoded is! List || decoded.any((v) => v is! String)) throw const FormatException('Liste biçimi geçersiz');
      final items = decoded.cast<String>().toList();
      int added = 0;
      for (final original in widget.recipe.ingredients) {
        final item = _scaledIngredient(original);
        if (!items.contains(item)) { items.add(item); added++; }
      }
      if (!await prefs.setString('alisveris', jsonEncode(items))) throw StateError('Kaydedilemedi');
      _message('$added malzeme $_portions porsiyon için alışveriş listesine eklendi.');
    } catch (_) { _message('Alışveriş listesi kaydedilemedi; mevcut kayıtlar korunuyor.'); }
  }

  Future<void> _saveNotes() async {
    setState(() => _saving = true);
    try {
      final p = await SharedPreferences.getInstance();
      final ok = await p.setString(_noteKey, _notes.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Tarif notun kaydedildi.' : 'Not kaydedilemedi.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not kaydedilemedi; mevcut kayıtlar korunuyor.')));
      }
    } finally { if (mounted) setState(() => _saving = false); }
  }

  String _scaledIngredient(String ingredient) {
    if (_portions == _basePortions) return ingredient;
    // Yalnızca açık sayısal başlangıçları uyarlıyoruz; belirsiz ölçüler korunur.
    final match = RegExp(r'^(\d+(?:[.,]\d+)?)(\s+)(.+)$').firstMatch(ingredient.trim());
    if (match == null) return ingredient;
    final value = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (value == null) return ingredient;
    final scaled = value * _portions / _basePortions;
    final formatted = scaled == scaled.roundToDouble()
        ? scaled.toInt().toString()
        : scaled.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '').replaceAll('.', ',');
    return '$formatted${match.group(2)}${match.group(3)}';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recipe;
    return Scaffold(
      appBar: AppBar(title: Text(r.title), backgroundColor: _pink),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('${r.category} • ${r.minutes} dakika', style: const TextStyle(color: _purple)),
        const SizedBox(height: 12),
        Card(color: _pink, child: Padding(padding: const EdgeInsets.all(12), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Porsiyon ayarı', style: TextStyle(fontWeight: FontWeight.bold, color: _purple)),
            const SizedBox(height: 6),
            const Text('Tariflerde standart porsiyon bilgisi bulunmadığından başlangıç değeri 2 kabul edilir. İstersen değiştirebilirsin.', style: TextStyle(fontSize: 12)),
            Row(children: [
              const Text('Temel:'),
              DropdownButton<int>(value: _basePortions, items: List.generate(12, (i) =>
                DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                onChanged: (v) => setState(() { _basePortions = v ?? 2; _portions = _basePortions; })),
              const Spacer(),
              IconButton(onPressed: _portions > 1 ? () => setState(() => _portions--) : null,
                icon: const Icon(Icons.remove_circle_outline)),
              Text('$_portions porsiyon', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: _portions < 24 ? () => setState(() => _portions++) : null,
                icon: const Icon(Icons.add_circle_outline)),
            ]),
          ]))),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: _planRecipe,
          icon: const Icon(Icons.event_note_outlined), label: const Text('Tarifi gün ve öğüne planla')),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: () => Navigator.push(context,
          MaterialPageRoute<void>(builder: (_) => const WeeklyMealPlannerPage())),
          icon: const Icon(Icons.calendar_view_week), label: const Text('Haftalık yemek planımı görüntüle')),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: _addScaledIngredients,
          icon: const Icon(Icons.add_shopping_cart), label: Text('$_portions porsiyonluk malzemeleri alışveriş listesine ekle')),
        const SizedBox(height: 6),
        TextButton(onPressed: widget.addIngredients,
          child: const Text('Orijinal malzemeleri ekle (önceki özellik)')),
        const SizedBox(height: 18),
        const Text('Malzemeler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _purple)),
        if (_portions != _basePortions) const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Text('Yalnızca sayıyla başlayan ölçüler oransal hesaplanır. Kesirli, yaklaşık ve metin içindeki ölçüleri kontrol et.',
            style: TextStyle(fontSize: 12, color: Colors.deepOrange))),
        ...r.ingredients.map((v) => ListTile(dense: true,
          leading: const Icon(Icons.check_circle_outline), title: Text(_scaledIngredient(v)))),
        const SizedBox(height: 14),
        Row(children: [
          const Expanded(child: Text('Hazırlanışı', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _purple))),
          Text('${_completed.length}/${r.steps.length} adım'),
        ]),
        LinearProgressIndicator(value: r.steps.isEmpty ? 0 : _completed.length / r.steps.length),
        const SizedBox(height: 8),
        ...r.steps.asMap().entries.map((e) => CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _completed.contains(e.key),
          title: Text('${e.key + 1}. ${e.value}',
            style: TextStyle(decoration: _completed.contains(e.key) ? TextDecoration.lineThrough : null)),
          onChanged: !_progressLoaded ? null : (checked) {
            setState(() {
              if (checked == true) { _completed.add(e.key); } else { _completed.remove(e.key); }
            });
            _saveProgress();
          })),
        TextButton.icon(onPressed: !_progressLoaded ? null : () { setState(_completed.clear); _saveProgress(); },
          icon: const Icon(Icons.refresh), label: const Text('Adımları sıfırla')),
        const Divider(height: 28),
        const Text('Kişisel tarif notum', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _purple)),
        const SizedBox(height: 8),
        TextField(controller: _notes, maxLines: 4,
          decoration: const InputDecoration(hintText: 'Tarifle ilgili notlarını yaz...', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        FilledButton.icon(onPressed: _saving ? null : _saveNotes,
          icon: const Icon(Icons.save_outlined), label: const Text('Notumu kaydet')),
        const SizedBox(height: 24),
      ]),
    );
  }
}
