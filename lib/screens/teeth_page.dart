import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/baby_teeth.dart';
import '../services/json_store.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

const _mor = Color(0xFF764A72);

/// Diş takibi: 20 süt dişi, çıkış tarihi, sıradaki dişler ve diş bakımı.
class TeethPage extends StatefulWidget {
  static const storageKey = 'baby_teeth_v1';
  final String childKey;
  final DateTime? birth;
  final DateTime Function()? clock;
  const TeethPage({super.key, this.childKey = 'main', this.birth, this.clock});

  @override
  State<TeethPage> createState() => _TeethPageState();
}

class _TeethPageState extends State<TeethPage> {
  Map<String, dynamic> _all = {};
  Map<String, String> _teeth = {};
  bool _loading = true;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  static const _order = ['2', '1', 'k', 'l', 'c'];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> all = {};
    try { all = await JsonStore.readMap(TeethPage.storageKey); } catch (_) {}
    if (!mounted) return;
    setState(() { _all = all; _teeth = decodeTeeth(all[widget.childKey]); _loading = false; });
  }

  Future<void> _save(Map<String, String> next) async {
    final all = {..._all, widget.childKey: next};
    try {
      await JsonStore.writeMap(TeethPage.storageKey, all);
      if (mounted) setState(() { _all = all; _teeth = next; });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text('Kayıt cihazda saklanamadı. Lütfen tekrar deneyin.')));
      }
    }
  }

  Future<void> _tap(String id) async {
    final type = toothTypeOf(id)!;
    final side = id.split('_').last;
    final has = _teeth[id];
    if (has != null) {
      final remove = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
        title: Text('${t(type.name)} (${t(side)})'),
        content: Text('Çıkış tarihi: ${dmy(DateTime.parse(has))}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Kaydı kaldır')),
          FilledButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Tamam')),
        ]));
      if (remove == true) await _save(Map.of(_teeth)..remove(id));
      return;
    }
    final d = await showDatePicker(context: context, initialDate: _now(),
        firstDate: widget.birth ?? DateTime(2000), lastDate: _now(),
        helpText: '${t(type.name)} (${t(side)})');
    if (d == null) return;
    await _save({..._teeth, id: d.toIso8601String()});
  }

  Widget _tooth(String id) {
    final on = _teeth.containsKey(id);
    final type = toothTypeOf(id)!;
    final molar = type.id.endsWith('1') || type.id.endsWith('2');
    return Semantics(
      button: true,
      label: '${t(type.name)} ${t(id.split('_').last)}',
      child: InkWell(
        key: Key('dis_$id'),
        onTap: () => _tap(id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: molar ? 28 : 22, height: 30, margin: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            color: on ? Colors.white : const Color(0xFFF1E6F0),
            border: Border.all(color: on ? _mor : Colors.black26, width: on ? 2 : 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: on ? const Icon(Icons.check, size: 14, color: _mor) : null,
        ),
      ),
    );
  }

  Widget _row(bool upper) {
    final p = upper ? 'u' : 'l';
    final ids = [
      for (final o in _order) '$p${o}_sağ',
      for (final o in _order.reversed) '$p${o}_sol',
    ];
    return FittedBox(child: Row(mainAxisSize: MainAxisSize.min, children: [for (final id in ids) _tooth(id)]));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final months = ageInMonths(widget.birth, _now());
    final soon = expectedSoon(_teeth, months);
    final list = _teeth.entries.toList()..sort((a, b) => a.value.compareTo(b.value));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelCard(child: Column(children: [
        Text('${_teeth.length} / 20 süt dişi çıktı', style: const TextStyle(fontWeight: FontWeight.w800, color: _mor, fontSize: 16)),
        const SizedBox(height: 10),
        Text('Üst çene', style: TextStyle(fontSize: 12, color: Colors.black54)),
        _row(true),
        const SizedBox(height: 10),
        _row(false),
        Text('Alt çene', style: TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 6),
        Text('Çıkan dişe dokun, tarihini seç. Sağ ve sol, bebeğin kendi sağı ve soludur.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
      ])),
      if (soon.isNotEmpty) PastelCard(color: const Color(0xFFFFF4FA), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bu aylarda beklenebilecek dişler', style: TextStyle(fontWeight: FontWeight.w800, color: _mor)),
        const SizedBox(height: 4),
        for (final s in soon) Text('• ${t(s.name)}: ${t('${s.fromMonth}–${s.toMonth}. ay')}', style: const TextStyle(fontSize: 13)),
      ])),
      if (list.isNotEmpty) ...[
        const KitHeader('Çıkış sırası', Icons.history),
        for (final e in list)
          ListTile(dense: true, leading: const Icon(Icons.circle, size: 10, color: _mor),
            title: Text('${t(toothTypeOf(e.key)!.name)} (${t(e.key.split('_').last)})'),
            trailing: Text(dmy(DateTime.parse(e.value)))),
      ],
      const KitHeader('Diş bakımı', Icons.clean_hands_outlined),
      for (final tip in teethCareTips)
        Padding(padding: const EdgeInsets.only(bottom: 6),
            child: Text('• ${t(tip)}', style: const TextStyle(fontSize: 13))),
      const SizedBox(height: 6),
      Text('Aylar ortalamadır; birkaç ay erken ya da geç çıkması olağandır. 18 aya kadar hiç diş çıkmadıysa doktora danış.',
          style: TextStyle(fontSize: 11.5, color: Colors.black54)),
    ]);
  }
}
