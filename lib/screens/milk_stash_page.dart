import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/json_store.dart';
import '../services/milk_stash.dart';
import '../utils/dialog_helpers.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

/// Sağılmış anne sütü stoğu: miktar, yer, son kullanma.
class MilkStashPage extends StatefulWidget {
  static const storageKey = 'milk_stash_v1';
  final DateTime Function()? clock;
  const MilkStashPage({super.key, this.clock});

  @override
  State<MilkStashPage> createState() => _MilkStashPageState();
}

class _MilkStashPageState extends State<MilkStashPage> {
  List<MilkBag> _bags = [];
  bool _loading = true;
  bool _showUsed = false;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> all = {};
    try { all = await JsonStore.readMap(MilkStashPage.storageKey); } catch (_) {}
    if (!mounted) return;
    setState(() { _bags = decodeMilkBags(all['bags']); _loading = false; });
  }

  Future<void> _save(List<MilkBag> next) async {
    // Kullanılan torbaların son 100'ü tutulur.
    final used = next.where((b) => b.used).toList();
    final keep = [...next.where((b) => !b.used), ...used.skip(used.length > 100 ? used.length - 100 : 0)]
      ..sort((a, b) => a.pumped.compareTo(b.pumped));
    try {
      await JsonStore.writeMap(MilkStashPage.storageKey, {'bags': keep.map((b) => b.toJson()).toList()});
      if (mounted) setState(() => _bags = keep);
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  Future<void> _add() async {
    final ml = TextEditingController();
    var when = _now();
    var place = 'Buzdolabı';
    String? error;
    final ok = await showDialogAndDispose<bool>(disposables: [ml], context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
      title: Text('Süt ekle'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(key: const Key('sut_ml'), controller: ml, keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: t('Miktar (ml)'), errorText: error == null ? null : t(error!))),
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.schedule),
          title: Text('${dmy(when)} ${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}'),
          subtitle: Text('Sağım zamanı'),
          onTap: () async {
            final d = await kitPickDay(ctx, initial: when);
            if (d == null || !ctx.mounted) return;
            final tm = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(when));
            set(() => when = DateTime(d.year, d.month, d.day, tm?.hour ?? when.hour, tm?.minute ?? when.minute));
          }),
        Wrap(spacing: 6, runSpacing: 4, children: [
          for (final p in milkPlaces.take(3))
            ChoiceChip(label: Text(p), selected: place == p, onSelected: (_) => set(() => place = p)),
        ]),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Vazgeç')),
        FilledButton(key: const Key('sut_kaydet'), onPressed: () {
          final v = int.tryParse(ml.text.trim());
          if (v == null || v <= 0 || v > 1000) { set(() => error = '1–1000 ml arasında bir miktar gir.'); return; }
          Navigator.pop(ctx, true);
        }, child: Text('Kaydet')),
      ])));
    final v = int.tryParse(ml.text.trim());
    if (ok != true || v == null) return;
    await _save([..._bags, MilkBag(id: 's${DateTime.now().microsecondsSinceEpoch}', pumped: when, ml: v, place: place)]);
  }

  Future<void> _actions(MilkBag b) async {
    final choice = await showModalBottomSheet<String>(context: context, showDragHandle: true, builder: (ctx) => SafeArea(child: Column(
      mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.check_circle_outline), title: Text('Kullanıldı'), onTap: () => Navigator.pop(ctx, 'used')),
        if (b.place == 'Dondurucu') ListTile(leading: const Icon(Icons.water_drop_outlined), title: Text('Çözülmeye al (buzdolabına)'), onTap: () => Navigator.pop(ctx, 'thaw')),
        if (b.place == 'Buzdolabı') ListTile(leading: const Icon(Icons.ac_unit), title: Text('Dondurucuya taşı'), onTap: () => Navigator.pop(ctx, 'freeze')),
        ListTile(leading: const Icon(Icons.delete_outline), title: Text('Sil'), onTap: () => Navigator.pop(ctx, 'delete')),
      ])));
    if (choice == null) return;
    final rest = _bags.where((x) => x.id != b.id).toList();
    switch (choice) {
      case 'used': await _save([...rest, b.copyWith(used: true)]);
      case 'thaw': await _save([...rest, b.copyWith(place: 'Çözülmüş (buzdolabında)', movedAt: _now())]);
      case 'freeze':
        // Buzdolabında geçen süre dondurucu süresinden düşülmez; sağım tarihi esas alınır.
        await _save([...rest, b.copyWith(place: 'Dondurucu')]);
      case 'delete': await _save(rest);
    }
  }

  String _left(MilkBag b, DateTime now) {
    final d = b.expires.difference(now);
    if (d.isNegative) return t('Süresi doldu');
    if (d.inHours < 48) return '${t('Kalan')}: ${d.inHours} ${t('saat')}';
    return '${t('Son kullanma')}: ${dmy(b.expires)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final now = _now();
    final usable = usableFirst(_bags, now);
    final expired = _bags.where((b) => !b.used && b.expired(now)).toList();
    final used = _bags.where((b) => b.used).toList().reversed.toList();
    Widget tile(MilkBag b) => PastelCard(padding: EdgeInsets.zero, onTap: () => _actions(b), child: ListTile(
      leading: Icon(b.place == 'Dondurucu' ? Icons.ac_unit : b.place == 'Oda sıcaklığı' ? Icons.wb_sunny_outlined : Icons.kitchen_outlined,
          color: b.expired(now) && !b.used ? Colors.red : kitMor),
      title: Text('${b.ml} ml · ${t(b.place)}'),
      subtitle: Text('${t('Sağım')}: ${dmy(b.pumped)} · ${b.used ? t('Kullanıldı') : _left(b, now)}',
          style: TextStyle(color: b.expired(now) && !b.used ? Colors.red : null)),
      trailing: const Icon(Icons.more_vert)));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelCard(child: Row(children: [
        Expanded(child: Column(children: [
          Text('${totalMl(usable)} ml', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kitMor)),
          Text('kullanılabilir süt', style: TextStyle(fontSize: 12)),
        ])),
        Expanded(child: Column(children: [
          Text('${usable.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kitMor)),
          Text('torba / şişe', style: TextStyle(fontSize: 12)),
        ])),
      ])),
      FilledButton.icon(key: const Key('sut_ekle'), onPressed: _add, icon: const Icon(Icons.add), label: Text('Süt ekle')),
      if (expired.isNotEmpty) ...[
        const KitHeader('Süresi dolanlar', Icons.warning_amber_rounded),
        const KitNote('Süresi dolan sütü bebeğe verme.', color: Color(0xFFFFE6E6)),
        for (final b in expired) tile(b),
      ],
      if (usable.isNotEmpty) ...[
        const KitHeader('Önce bunları kullan', Icons.sort),
        for (final b in usable) tile(b),
      ],
      if (used.isNotEmpty) TextButton(onPressed: () => setState(() => _showUsed = !_showUsed),
          child: Text(_showUsed ? 'Kullanılanları gizle' : 'Kullanılanları göster')),
      if (_showUsed) for (final b in used.take(30)) tile(b),
      const KitHeader('Saklama kuralları', Icons.info_outline),
      PastelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Oda sıcaklığı (25 °C’ye kadar): 4 saat', style: TextStyle(fontSize: 13)),
        Text('Buzdolabı (4 °C): 4 gün', style: TextStyle(fontSize: 13)),
        Text('Dondurucu (−18 °C): en iyisi 6 ay, en fazla 12 ay', style: TextStyle(fontSize: 13)),
        Text('Çözülmüş süt (buzdolabında): 24 saat', style: TextStyle(fontSize: 13)),
      ])),
      const KitBullets(milkStorageTips),
      const KitFootnote('Kaynak: ABD Hastalık Kontrol Merkezleri (CDC) anne sütü saklama önerileri; sağlıklı, zamanında doğmuş bebekler için.'),
    ]);
  }
}
