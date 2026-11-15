import 'dart:convert';
import 'package:flutter/material.dart';
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan kaydedilemedi. Lütfen tekrar deneyin.')));
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
    final categories = ['Tümü', ...{for (final r in generalRecipes) r.category}];
    final chosen = await showModalBottomSheet<GeneralRecipe>(
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
              decoration: const InputDecoration(prefixIcon: Icon(Icons.search),
                hintText: 'Tarif veya malzeme ara', border: OutlineInputBorder()))),
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
    search.dispose();
    if (chosen == null || !mounted) return;
    setState(() => _plan['$day|$meal'] = chosen.id);
    await _save();
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
          IconButton(tooltip: 'Önceki hafta', onPressed: () => _changeWeek(-1), icon: const Icon(Icons.chevron_left)),
          Expanded(child: Column(children: [
            Text('${_dateLabel(_weekStart)} – ${_dateLabel(_weekStart.add(const Duration(days: 6)))}', textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: _purple)),
            Text(_hasStoredWeek ? 'Kayıtlı hafta' : 'Henüz planlanmamış hafta', style: const TextStyle(fontSize: 12)),
          ])),
          IconButton(tooltip: 'Sonraki hafta', onPressed: () => _changeWeek(1), icon: const Icon(Icons.chevron_right)),
          TextButton(onPressed: () async { setState(() { _weekStart = _monday(DateTime.now()); _loading = true; }); await _load(); }, child: const Text('Bugün')),
        ]),
        const Text('7 gün • Kahvaltı, öğle ve akşam', style: TextStyle(fontWeight: FontWeight.bold, color: _purple)),
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
                  if (r != null) IconButton(tooltip: 'Tarifi görüntüle',
                    icon: const Icon(Icons.menu_book_outlined), onPressed: () => _showRecipe(r)),
                  if (r != null) IconButton(tooltip: 'Plana eklenen tarifi kaldır',
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
