import '../utils/dialog_helpers.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'dart:convert';
import 'package:flutter/material.dart' hide Text;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/general_recipe_catalog.dart';
import 'weekly_shopping_assistant_page.dart';

/// Paket 39: Haftalık yemek planı. Mevcut alışveriş anahtarını korur.
class WeeklyMealPlannerPage extends StatefulWidget {
  const WeeklyMealPlannerPage({super.key});
  @override
  State<WeeklyMealPlannerPage> createState() => _WeeklyMealPlannerPageState();
}

class _WeeklyMealPlannerPageState extends State<WeeklyMealPlannerPage> {
  static const _key = 'paket39_weekly_meal_plan_v1';
  static const _days = ['Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi','Pazar'];
  static const _meals = ['Kahvaltı','Öğle','Akşam'];
  static const _purple = Color(0xFF48235F);
  final Map<String,String> _plan = {};
  DateTime _weekStart = _monday(DateTime.now());
  static DateTime _monday(DateTime d) { final date = DateTime(d.year,d.month,d.day); return date.subtract(Duration(days: date.weekday - 1)); }
  static String _weekId(DateTime d) => '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  String get _weekKey => 'paket39_weekly_meal_plan_v2_${_weekId(_weekStart)}';
  String _dateLabel(DateTime d) => '${d.day.toString().padLeft(2,'0')}.${d.month.toString().padLeft(2,'0')}.${d.year}';
  bool _hasStoredWeek = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_weekKey);
      // Eski tek haftalık planı sadece ilk açılışta mevcut haftaya aktar.
      final migrated = prefs.getBool('paket39_weekly_migration_v2') ?? false;
      final legacy = !migrated ? prefs.getString(_key) : null;
      final source = raw ?? legacy;
      final next = <String,String>{};
      if (source != null) {
        final decoded = jsonDecode(source);
        if (decoded is! Map) throw const FormatException('Plan biçimi geçersiz');
        for (final entry in decoded.entries) {
          if (entry.key is String && entry.value is String) {
            next[entry.key as String] = entry.value as String;
          }
        }
      }
      if (legacy != null && raw == null) {
        final ok = await prefs.setString(_weekKey, jsonEncode(next));
        if (!ok) throw StateError('Taşıma kaydedilemedi');
      }
      if (!migrated) await prefs.setBool('paket39_weekly_migration_v2', true);
      if (mounted) setState(() { _plan..clear()..addAll(next); _hasStoredWeek = source != null; _error = null; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Plan okunamadı. Kayıtlar değiştirilmedi.'; _loading = false; });
    }
  }

  Future<void> _changeWeek(int offset) async {
    setState(() { _weekStart = _weekStart.add(Duration(days: 7 * offset)); _loading = true; });
    await _load();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ok = await prefs.setString(_weekKey, jsonEncode(_plan));
      if (!ok) throw StateError('Kaydedilemedi');
      // Geriye dönük uyumluluk: yalnızca içinde bulunulan hafta için eski anahtarı güncelle.
      if (_weekId(_weekStart) == _weekId(_monday(DateTime.now()))) {
        await prefs.setString(_key, jsonEncode(_plan));
      }
      _hasStoredWeek = true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan kaydedilemedi. Lütfen tekrar deneyin.')));
      }
    }
  }

  GeneralRecipe? _recipe(String? id) {
    if (id == null) return null;
    for (final r in generalRecipes) { if (r.id == id) return r; }
    return null;
  }

  Future<void> _choose(String day, String meal) async {
    final search = TextEditingController();
    String category = 'Tümü';
    final categories = ['Tümü', ...generalRecipeCategories];
    final chosen = await showModalBottomSheetAndDispose<GeneralRecipe>(disposables: [search],
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, update) {
        final q = search.text.trim().toLowerCase();
        final options = generalRecipes.where((r) =>
          (category == 'Tümü' || r.category == category) &&
          (q.isEmpty || r.title.toLowerCase().contains(q) ||
           r.ingredients.any((i) => i.toLowerCase().contains(q)))).toList();
        return SafeArea(child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * .78,
          child: Column(children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('$day • $meal', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: _purple))),
            Padding(padding: const EdgeInsets.all(12), child: TextField(
              controller: search, onChanged: (_) => update(() {}),
              decoration: InputDecoration(prefixIcon: Icon(Icons.search),
                hintText: t('Tarif veya malzeme ara'), border: OutlineInputBorder()))),
            SizedBox(height: 42, child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final c in categories) Padding(padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(label: Text(c), selected: c == category,
                  onSelected: (_) => update(() => category = c)))
            ])),
            Expanded(child: ListView.builder(itemCount: options.length, itemBuilder: (_, i) {
              final r = options[i];
              return ListTile(title: Text(r.title), subtitle: Text('${r.category} • ${r.minutes} dk'),
                trailing: const Icon(Icons.add_circle_outline), onTap: () => Navigator.pop(ctx, r));
            })),
          ])));
      }));
    if (chosen == null || !mounted) return;
    setState(() => _plan['$day|$meal'] = chosen.id);
    await _save();
  }

  // Önceki haftadan yalnızca boş hücreleri doldurur; mevcut seçimleri korur.
  Future<void> _copyPreviousWeek() async {
    final previous = _weekStart.subtract(const Duration(days: 7));
    final previousKey = 'paket39_weekly_meal_plan_v2_${_weekId(previous)}';
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(previousKey);
      if (raw == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Önceki hafta için kayıtlı plan bulunamadı.')));
        }
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) throw const FormatException('Plan biçimi geçersiz');
      final additions = <String, String>{};
      for (final entry in decoded.entries) {
        if (entry.key is String && entry.value is String &&
            !_plan.containsKey(entry.key) && _recipe(entry.value as String) != null) {
          additions[entry.key as String] = entry.value as String;
        }
      }
      if (additions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aktarılabilecek boş öğün bulunamadı.')));
        }
        return;
      }
      if (!mounted) return;
      final approved = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Önceki haftayı kopyala'),
        content: Text('${additions.length} öğün boş alanlara eklenecek. Bu haftanın mevcut seçimleri değişmeyecek.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Aktar')),
        ],
      ));
      if (approved != true || !mounted) return;
      setState(() => _plan.addAll(additions));
      await _save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${additions.length} öğün önceki haftadan aktarıldı.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önceki hafta okunamadı. Eski kayıtlar korundu.')));
      }
    }
  }

  // Aşama 53–57: Mevcut hafta kayıtlarına dokunmadan plan önerileri.
  bool _isBreakfast(GeneralRecipe r) => r.category.toLowerCase().contains('kahvalt') ||
      r.title.toLowerCase().contains('omlet') || r.title.toLowerCase().contains('menemen');

  List<GeneralRecipe> _candidates(String meal, String style) {
    final recipes = generalRecipes.where((r) {
      if (meal == 'Kahvaltı') return _isBreakfast(r);
      if (_isBreakfast(r)) return false;
      if (style == 'Pratik' && r.minutes > 30) return false;
      if (style == 'Sebze ağırlıklı') {
        final category = r.category.toLowerCase();
        return category.contains('sebze') || category.contains('salata') ||
            category.contains('çorba') || category.contains('bakliyat');
      }
      return true;
    }).toList();
    if (recipes.isEmpty) return generalRecipes.toList();
    recipes.sort((a, b) => style == 'Pratik'
        ? a.minutes.compareTo(b.minutes)
        : a.title.compareTo(b.title));
    return recipes;
  }

  Map<String, String> _generateSuggestions(String style, {bool onlyEmpty = true}) {
    final generated = <String, String>{};
    final used = <String>{..._plan.values};
    for (var day = 0; day < _days.length; day++) {
      for (final meal in _meals) {
        final key = '${_days[day]}|$meal';
        if (onlyEmpty && _plan.containsKey(key)) continue;
        final options = _candidates(meal, style);
        if (options.isEmpty) continue;
        final start = (day * 7 + _meals.indexOf(meal) * 13) % options.length;
        GeneralRecipe selected = options[start];
        for (var offset = 0; offset < options.length; offset++) {
          final option = options[(start + offset) % options.length];
          if (!used.contains(option.id)) { selected = option; break; }
        }
        generated[key] = selected.id;
        used.add(selected.id);
      }
    }
    return generated;
  }

  Future<void> _autoPlan() async {
    var style = 'Dengeli';
    var replace = false;
    final result = await showDialog<Map<String, dynamic>>(
      context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, update) => AlertDialog(
        title: const Text('7 günlük hazır menü oluştur'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Kahvaltı, öğle ve akşam için tarif önerileri oluşturulur. Beslenme veya sağlık önerisi değildir.'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(initialValue: style,
            decoration: InputDecoration(labelText: t('Menü türü')),
            items: ['Dengeli', 'Pratik', 'Sebze ağırlıklı']
              .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => update(() => style = v ?? 'Dengeli')),
          CheckboxListTile(contentPadding: EdgeInsets.zero,
            title: const Text('Dolu öğünleri de değiştir'),
            subtitle: const Text('Kapalıysa yalnızca boş öğünler doldurulur.'),
            value: replace, onChanged: (v) => update(() => replace = v ?? false)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, {'style': style, 'replace': replace}),
            child: const Text('Önerileri oluştur')),
        ],
      )));
    if (result == null || !mounted) return;
    final generated = _generateSuggestions(result['style'] as String,
      onlyEmpty: !(result['replace'] as bool));
    if (generated.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doldurulacak boş öğün bulunamadı.')));
      return;
    }
    final accepted = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Menü önizlemesi'),
      content: SizedBox(width: double.maxFinite, height: 320,
        child: ListView(children: [
          Text('${generated.length} öğün için öneri hazırlandı.'),
          const SizedBox(height: 8),
          for (final entry in generated.entries) ListTile(dense: true,
            title: Text(entry.key.replaceAll('|', ' • ')),
            subtitle: Text(_recipe(entry.value)?.title ?? 'Tarif bulunamadı')),
        ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Plana kaydet')),
      ],
    ));
    if (accepted != true || !mounted) return;
    setState(() => _plan.addAll(generated));
    await _save();
  }

  Future<void> _suggestReplacement(String day, String meal) async {
    final key = '$day|$meal';
    final options = _candidates(meal, 'Dengeli').where((r) => r.id != _plan[key]).toList();
    if (options.isEmpty) return;
    options.sort((a, b) => a.minutes.compareTo(b.minutes));
    final selected = await showModalBottomSheet<GeneralRecipe>(context: context,
      isScrollControlled: true, showDragHandle: true,
      builder: (ctx) => SafeArea(child: SizedBox(height: MediaQuery.sizeOf(ctx).height * .65,
        child: Column(children: [
          Padding(padding: const EdgeInsets.all(12), child: Text('$day • $meal için alternatifler',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _purple))),
          Expanded(child: ListView.builder(itemCount: options.length.clamp(0, 30),
            itemBuilder: (_, i) { final r = options[i]; return ListTile(
              title: Text(r.title), subtitle: Text('${r.category} • ${r.minutes} dk'),
              onTap: () => Navigator.pop(ctx, r)); })),
        ]))));
    if (selected == null || !mounted) return;
    final approved = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Öğünü değiştir'),
      content: Text('$day • $meal öğününe ${selected.title} eklensin mi?'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Değiştir'))],
    ));
    if (approved != true || !mounted) return;
    setState(() => _plan[key] = selected.id);
    await _save();
  }

  Future<void> _showSummary() async {
    final planned = _plan.entries.where((e) => _recipe(e.value) != null).toList();
    final minutes = planned.fold<int>(0, (sum, e) => sum + (_recipe(e.value)?.minutes ?? 0));
    final unique = planned.map((e) => e.value).toSet().length;
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Haftalık yemek özeti'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hafta: ${_dateLabel(_weekStart)} – ${_dateLabel(_weekStart.add(const Duration(days: 6)))}'),
          const SizedBox(height: 8),
          Text('Planlanan öğün: ${planned.length}/21'),
          Text('Boş öğün: ${21 - planned.length}'),
          Text('Farklı tarif: $unique'),
          Text('Tarif süreleri toplamı: $minutes dk'),
          const SizedBox(height: 8),
          const Text('Süreler tariflerin tahmini sürelerinin toplamıdır; alışveriş ve hazırlık planı değildir.'),
        ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Kapat'))],
    ));
  }

  Future<void> _addShopping() async {
    final ingredients = <String>{};
    for (final id in _plan.values) {
      final r = _recipe(id);
      if (r != null) ingredients.addAll(r.ingredients.map((e) => e.trim()).where((e) => e.isNotEmpty));
    }
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Önce plana tarif ekleyin.')));
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final old = (jsonDecode(prefs.getString('alisveris') ?? '[]') as List).cast<String>();
      final merged = <String>{...old, ...ingredients};
      final added = merged.length - old.toSet().length;
      final ok = await prefs.setString('alisveris', jsonEncode(merged.toList()));
      if (!ok) throw StateError('Kaydedilemedi');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$added yeni malzeme alışveriş listesine eklendi. Listeyi görmek için Alışveriş sekmesine geçin.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alışveriş listesi güncellenemedi.')));
    }
  }

  void _showRecipe(GeneralRecipe r) => showModalBottomSheet<void>(context: context,
    isScrollControlled: true, showDragHandle: true, builder: (ctx) => SafeArea(
      child: SizedBox(height: MediaQuery.sizeOf(ctx).height * .75,
        child: ListView(padding: const EdgeInsets.all(18), children: [
          Text(r.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: _purple)),
          Text('${r.category} • ${r.minutes} dk'),
          const SizedBox(height: 16),
          const Text('Malzemeler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ...r.ingredients.map((i) => ListTile(dense: true, title: Text(i), leading: const Icon(Icons.check_circle_outline))),
          const Text('Hazırlanışı', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          ...r.steps.asMap().entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text('${e.key + 1}. ${e.value}'))),
        ]))));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFFFF7FC),
    appBar: AppBar(title: const Text('Haftalık yemek planım'), backgroundColor: const Color(0xFFFFD9ED)),
    body: _loading ? const Center(child: CircularProgressIndicator()) :
      ListView(padding: const EdgeInsets.all(14), children: [
        if (_error != null) Padding(padding: const EdgeInsets.all(8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        Row(children: [
          IconButton(tooltip: t('Önceki hafta'), onPressed: () => _changeWeek(-1), icon: const Icon(Icons.chevron_left)),
          Expanded(child: Column(children: [
            Text('${_dateLabel(_weekStart)} – ${_dateLabel(_weekStart.add(const Duration(days: 6)))}', textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: _purple)),
            Text(_hasStoredWeek ? 'Kayıtlı hafta' : 'Henüz planlanmamış hafta', style: const TextStyle(fontSize: 12)),
          ])),
          IconButton(tooltip: t('Sonraki hafta'), onPressed: () => _changeWeek(1), icon: const Icon(Icons.chevron_right)),
          TextButton(onPressed: () async { setState(() { _weekStart = _monday(DateTime.now()); _loading = true; }); await _load(); }, child: const Text('Bugün')),
        ]),
        Text('7 gün • Kahvaltı, öğle ve akşam • ${_plan.length}/21 öğün planlandı',
          style: const TextStyle(fontWeight: FontWeight.bold, color: _purple)),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: (_plan.length / 21).clamp(0.0, 1.0),
          color: _purple, backgroundColor: const Color(0xFFFFD9ED)),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(
          onPressed: _copyPreviousWeek, icon: const Icon(Icons.copy_all_outlined),
          label: const Text('Önceki haftanın boş öğünlerini aktar'))),
        Wrap(spacing: 8, runSpacing: 6, children: [
          FilledButton.icon(onPressed: _autoPlan, icon: const Icon(Icons.auto_awesome),
            label: const Text('Hazır 7 günlük menü')),
          OutlinedButton.icon(onPressed: _showSummary, icon: const Icon(Icons.summarize_outlined),
            label: const Text('Hafta özeti')),
        ]),
        const SizedBox(height: 8),
        const Text('Tarifleri seçin; planınız cihazda saklanır. Önceki tarifler ve diğer uygulama kayıtları değişmez.'),
        const SizedBox(height: 12),
        for (final day in _days) Card(color: Colors.white, child: Padding(
          padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.all(8), child: Text('$day • ${_dateLabel(_weekStart.add(Duration(days: _days.indexOf(day))))}',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _purple))),
            for (final meal in _meals) Builder(builder: (ctx) {
              final key = '$day|$meal';
              final r = _recipe(_plan[key]);
              return ListTile(
                dense: true,
                title: Text(meal, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(r?.title ?? 'Tarif seçilmedi'),
                onTap: () => _choose(day, meal),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (r != null) IconButton(tooltip: t('Alternatif tarif öner'),
                    icon: const Icon(Icons.swap_horiz), onPressed: () => _suggestReplacement(day, meal)),
                  if (r != null) IconButton(tooltip: t('Tarifi görüntüle'),
                    icon: const Icon(Icons.menu_book_outlined), onPressed: () => _showRecipe(r)),
                  if (r != null) IconButton(tooltip: t('Plana eklenen tarifi kaldır'),
                    icon: const Icon(Icons.close), onPressed: () {setState(() => _plan.remove(key)); _save();}),
                  const Icon(Icons.edit_outlined, color: _purple),
                ]),
              );
            }),
          ]))),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => WeeklyShoppingAssistantPage(weekStart: _weekStart))),
          icon: const Icon(Icons.auto_awesome_outlined),
          label: const Text('Akıllı haftalık alışveriş analizi'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(onPressed: _addShopping, icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Haftalık malzemeleri alışveriş listeme ekle')),
        const SizedBox(height: 12),
      ]),
  );
}
