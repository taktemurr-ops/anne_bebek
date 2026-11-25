import '../utils/dialog_helpers.dart';
import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import 'dart:convert';
import 'package:flutter/material.dart' hide Text;
import '../services/activity_plan.dart';
import 'baby_activity_catalog_page.dart';
import '../services/secure_health_store.dart';

class ActivityPlannerPage extends StatefulWidget {
  const ActivityPlannerPage({super.key});
  @override
  State<ActivityPlannerPage> createState() => _ActivityPlannerPageState();
}

class _ActivityPlannerPageState extends State<ActivityPlannerPage> {
  static const _key = 'family_activity_planner_v57';
  final List<ActivityPlan> _items = [];
  DateTime _day = DateTime.now();
  bool _loading = true;
  bool _saving = false;
  String? _error;
  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final raw = await SecureHealthStore.read(_key);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _items.addAll(decoded.map((e) => ActivityPlan.fromJson(Map<String, dynamic>.from(e as Map))));
      }
    } catch (_) { _error = 'Etkinlikler yüklenemedi. Kayıtlar korunuyor.'; }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _change(void Function() update) async {
    if (_saving || _error != null) return;
    final before = List<ActivityPlan>.of(_items);
    setState(() { _saving = true; update(); });
    try {
      await SecureHealthStore.write(_key, jsonEncode(_items.map((e) => e.toJson()).toList()));
    } catch (_) {
      _items..clear()..addAll(before);
      _error = 'Değişiklik kaydedilemedi; önceki kayıtlar korundu.';
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _add() async {
    final controller = TextEditingController();
    var category = 'Oyun';
    final result = await showDialogAndDispose<(String, String)>(disposables: [controller], context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, refresh) => AlertDialog(
      title: const Text('Yeni etkinlik'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: controller, maxLength: 120, autofocus: true, decoration: InputDecoration(labelText: t('Etkinlik adı'))),
        DropdownButtonFormField<String>(isExpanded: true, initialValue: category, decoration: InputDecoration(labelText: t('Kategori')), items: ['Oyun', 'Kitap', 'Hareket', 'Aile', 'Diğer'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => refresh(() => category = v ?? 'Oyun')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')), FilledButton(onPressed: () { final value = controller.text.trim(); if (value.isNotEmpty) Navigator.pop(ctx, (value, category)); }, child: const Text('Ekle'))],
    )));
    if (result == null || !mounted) return;
    await _change(() => _items.add(ActivityPlan(id: DateTime.now().microsecondsSinceEpoch.toString(), title: result.$1, category: result.$2, day: _day)));
  }

  @override
  Widget build(BuildContext context) {
    final visible = _items.where((e) => sameActivityDay(e.day, _day)).toList();
    visible.sort((a, b) => a.title.compareTo(b.title));
    return Scaffold(
      appBar: AppBar(title: const Text('Günlük etkinlik planı')),
      floatingActionButton: _loading || _saving || _error != null ? null : FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Etkinlik ekle')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Oyun, kitap ve aile etkinliklerini planlayın. Bu ekran tıbbi gelişim değerlendirmesi yapmaz.'),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BabyActivityCatalogPage())), icon: const Icon(Icons.toys_outlined), label: const Text('Yaşa göre oyun ve aktiviteleri keşfet')),
        const SizedBox(height: 12),
        OutlinedButton.icon(icon: const Icon(Icons.calendar_today), label: Text('${_day.day}.${_day.month}.${_day.year} • Tarih seç'), onPressed: () async { final date = await showDatePicker(context: context, initialDate: _day, firstDate: DateTime(2020), lastDate: DateTime(2100)); if (date != null && mounted) setState(() => _day = date); }),
        if (_error != null) Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)), TextButton(onPressed: () { setState(() { _error = null; _items.clear(); _loading = true; }); _load(); }, child: const Text('Yeniden yükle'))]))),
        const SizedBox(height: 12),
        Text('${visible.where((e) => e.done).length}/${visible.length} etkinlik tamamlandı', style: Theme.of(context).textTheme.titleMedium),
        if (visible.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Bu tarih için henüz etkinlik bulunmuyor.')),
        for (final item in visible) Card(child: CheckboxListTile(
          value: item.done,
          onChanged: _saving || _error != null ? null : (v) => _change(() { final index = _items.indexWhere((e) => e.id == item.id); if (index >= 0) _items[index] = item.copyWith(done: v ?? false); }),
          title: Text(item.title), subtitle: Text(item.category),
          secondary: IconButton(tooltip: t('Sil'), icon: const Icon(Icons.delete_outline), onPressed: _saving || _error != null ? null : () => _change(() => _items.removeWhere((e) => e.id == item.id))),
        )),
        const SizedBox(height: 72),
      ]),
    );
  }
}
