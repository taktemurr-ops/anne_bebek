import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/food_intro.dart';
import '../services/json_store.dart';
import '../utils/dialog_helpers.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

/// Ek gıda ve alerjen tanıtma takibi.
class FoodIntroPage extends StatefulWidget {
  static const storageKey = 'baby_food_intro_v1';
  final String childKey;
  final DateTime? birth;
  final DateTime Function()? clock;
  const FoodIntroPage({super.key, this.childKey = 'main', this.birth, this.clock});

  @override
  State<FoodIntroPage> createState() => _FoodIntroPageState();
}

class _FoodIntroPageState extends State<FoodIntroPage> {
  Map<String, dynamic> _all = {};
  Map<String, List<FoodTry>> _tries = {};
  bool _loading = true;
  String _group = foodGroups.first;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> all = {};
    try { all = await JsonStore.readMap(FoodIntroPage.storageKey); } catch (_) {}
    if (!mounted) return;
    setState(() { _all = all; _tries = decodeFoodTries(all[widget.childKey]); _loading = false; });
  }

  Future<void> _save(Map<String, List<FoodTry>> next) async {
    final all = {..._all, widget.childKey: encodeFoodTries(next)};
    try {
      await JsonStore.writeMap(FoodIntroPage.storageKey, all);
      if (mounted) setState(() { _all = all; _tries = next; });
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  Future<void> _addTry(IntroFood food) async {
    var date = _now();
    var reaction = 0;
    final note = TextEditingController();
    final ok = await showDialogAndDispose<bool>(disposables: [note], context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
      title: Text(food.name),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event), title: Text(dmy(date)),
          onTap: () async {
            final d = await kitPickDay(ctx, initial: date, first: widget.birth);
            if (d != null) set(() => date = d);
          }),
        Text('Tepki', style: TextStyle(fontWeight: FontWeight.w700)),
        Wrap(spacing: 6, runSpacing: 4, children: [
          for (var i = 0; i < reactionLevels.length; i++)
            ChoiceChip(key: Key('tepki_$i'), label: Text(reactionLevels[i], style: const TextStyle(fontSize: 12)),
              selected: reaction == i, onSelected: (_) => set(() => reaction = i)),
        ]),
        if (reaction == 2) Text(
          'Nefes darlığı, dudak/dil şişmesi, hırıltı ya da halsizlik varsa hemen 112’yi ara. '
          'Bu besini doktorla konuşmadan tekrar verme.',
          style: TextStyle(color: Colors.red, fontSize: 12.5)),
        TextField(controller: note, decoration: InputDecoration(labelText: t('Not (isteğe bağlı)'))),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Vazgeç')),
        FilledButton(key: const Key('besin_kaydet'), onPressed: () => Navigator.pop(ctx, true), child: Text('Kaydet')),
      ])));
    final text = note.text.trim();
    if (ok != true) return;
    final list = [...?_tries[food.id], FoodTry(date, reaction: reaction, note: text)]..sort((a, b) => a.date.compareTo(b.date));
    await _save({..._tries, food.id: list});
  }

  Future<void> _open(IntroFood food) async {
    final list = _tries[food.id] ?? const <FoodTry>[];
    await showModalBottomSheet<void>(context: context, showDragHandle: true, isScrollControlled: true,
      builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(food.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kitMor)),
          if (food.fromMonth > 6) Text('${t('Önerilen yaş')}: ${t('${food.fromMonth}. aydan sonra')}', style: const TextStyle(fontSize: 12.5)),
          if (food.tip.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(food.tip, style: const TextStyle(fontSize: 12.5))),
          const SizedBox(height: 8),
          if (list.isEmpty) Text('Henüz denenmedi.'),
          for (final e in list.reversed)
            ListTile(dense: true, contentPadding: EdgeInsets.zero,
              leading: Icon(_icon(e.reaction == 0 ? FoodStatus.ok : e.reaction == 1 ? FoodStatus.watch : FoodStatus.reaction),
                  color: _color(e.reaction == 0 ? FoodStatus.ok : e.reaction == 1 ? FoodStatus.watch : FoodStatus.reaction)),
              title: Text('${dmy(e.date)} · ${t(reactionLevels[e.reaction])}'),
              subtitle: e.note.isEmpty ? null : Text(e.note),
              trailing: IconButton(tooltip: t('Kaydı sil'), icon: const Icon(Icons.delete_outline), onPressed: () async {
                Navigator.pop(ctx);
                final rest = [...list]..remove(e);
                final next = Map.of(_tries);
                if (rest.isEmpty) { next.remove(food.id); } else { next[food.id] = rest; }
                await _save(next);
              })),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: () { Navigator.pop(ctx); _addTry(food); },
              icon: const Icon(Icons.add), label: Text('Deneme ekle')),
        ]))));
  }

  IconData _icon(FoodStatus s) => switch (s) {
        FoodStatus.notTried => Icons.radio_button_unchecked,
        FoodStatus.ok => Icons.check_circle,
        FoodStatus.watch => Icons.error_outline,
        FoodStatus.reaction => Icons.warning_amber_rounded,
      };
  Color _color(FoodStatus s) => switch (s) {
        FoodStatus.notTried => Colors.black26,
        FoodStatus.ok => const Color(0xFF2E8B57),
        FoodStatus.watch => const Color(0xFFE08A00),
        FoodStatus.reaction => Colors.red,
      };

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final months = ageInMonths(widget.birth, _now());
    final tried = introFoods.where((f) => _tries.containsKey(f.id)).length;
    final allergens = introFoods.where((f) => f.allergen).toList();
    final allergenTried = allergens.where((f) => _tries.containsKey(f.id)).length;
    final reactions = introFoods.where((f) => foodStatus(_tries[f.id]) == FoodStatus.reaction).toList();
    final keep = allergensToKeepGiving(_tries, _now());
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      if (months != null && months < 6) const KitNote(
        'Ek gıdaya genellikle 6. ayda başlanır. Bebeğin 6 aydan küçük; doktorun önermediyse şimdilik yalnızca anne sütü ya da mama yeterlidir.',
        color: Color(0xFFFFF1E6)),
      PastelCard(child: Row(children: [
        Expanded(child: Column(children: [
          Text('$tried / ${introFoods.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kitMor)),
          Text('besin denendi', style: TextStyle(fontSize: 12)),
        ])),
        Expanded(child: Column(children: [
          Text('$allergenTried / ${allergens.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kitMor)),
          Text('alerjen tanıtıldı', style: TextStyle(fontSize: 12)),
        ])),
      ])),
      if (reactions.isNotEmpty) KitNote(
        '${reactions.map((f) => t(f.name)).join(', ')}: ${t('belirgin tepki kaydedildi. Doktorunla konuşmadan tekrar verme.')}',
        title: 'Dikkat', color: const Color(0xFFFFE6E6)),
      if (keep.isNotEmpty) KitNote(
        '${keep.map((f) => t(f.name)).join(', ')}: ${t('sorunsuz tanıtıldı ama 2 haftadır kayıt yok. Tolere edilen alerjenleri haftada birkaç kez vermeye devam etmek önerilir.')}',
        title: 'Düzenli vermeyi unutma'),
      SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [
        for (final g in foodGroups)
          Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(
            key: Key('besin_grup_$g'), label: Text(g), selected: g == _group, onSelected: (_) => setState(() => _group = g))),
      ])),
      const SizedBox(height: 6),
      for (final f in introFoods.where((f) => f.group == _group))
        PastelCard(padding: EdgeInsets.zero, onTap: () => _open(f), child: ListTile(
          key: Key('besin_${f.id}'),
          leading: Icon(_icon(foodStatus(_tries[f.id])), color: _color(foodStatus(_tries[f.id]))),
          title: Text(f.name, style: const TextStyle(fontSize: 14)),
          subtitle: _tries[f.id] == null
              ? (f.fromMonth > 6 ? Text(t('${f.fromMonth}. aydan sonra'), style: const TextStyle(fontSize: 12)) : null)
              : Text('${t('İlk')}: ${dmy(_tries[f.id]!.first.date)} · ${_tries[f.id]!.length} ${t('kez')}', style: const TextStyle(fontSize: 12)),
          trailing: IconButton(tooltip: t('Deneme ekle'), icon: const Icon(Icons.add_circle_outline, color: kitMor), onPressed: () => _addTry(f)),
        )),
      const KitHeader('Bilmen gerekenler', Icons.lightbulb_outline),
      const KitBullets(foodIntroTips),
      const KitFootnote('Kaynak: DSÖ ek beslenme rehberi, Amerikan Pediatri Akademisi ve EAACI alerjen önleme önerileri. Tıbbi değerlendirme yerine geçmez.'),
    ]);
  }
}
