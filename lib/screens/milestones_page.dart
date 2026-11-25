import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/baby_milestones.dart';
import '../services/json_store.dart';
import '../widgets/reference_widgets.dart';

const _mor = Color(0xFF764A72);

/// Gelişim basamakları: yaşa göre liste, işaretlenen tarih, takip uyarısı.
class MilestonesPage extends StatefulWidget {
  static const storageKey = 'baby_milestones_v1';
  final String childKey;
  final DateTime? birth;
  final DateTime Function()? clock;
  const MilestonesPage({super.key, this.childKey = 'main', this.birth, this.clock});

  @override
  State<MilestonesPage> createState() => _MilestonesPageState();
}

class _MilestonesPageState extends State<MilestonesPage> {
  Map<String, dynamic> _all = {};
  Map<String, String> _done = {};
  int _age = milestoneAges.first;
  bool _loading = true;

  DateTime _now() => (widget.clock ?? DateTime.now)();
  int? get _months => ageInMonths(widget.birth, _now());

  @override
  void initState() {
    super.initState();
    _age = currentMilestoneAge(_months);
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> all = {};
    try { all = await JsonStore.readMap(MilestonesPage.storageKey); } catch (_) {}
    if (!mounted) return;
    setState(() {
      _all = all;
      _done = decodeMilestoneDone(all[widget.childKey]);
      _loading = false;
    });
  }

  Future<void> _toggle(Milestone m) async {
    final next = Map<String, String>.from(_done);
    if (next.containsKey(m.id)) {
      next.remove(m.id);
    } else {
      final picked = await showDatePicker(context: context, initialDate: _now(),
          firstDate: widget.birth ?? DateTime(2000), lastDate: _now(), helpText: t('Ne zaman yaptı?'));
      if (picked == null) return;
      next[m.id] = picked.toIso8601String();
    }
    final all = {..._all, widget.childKey: next};
    try {
      await JsonStore.writeMap(MilestonesPage.storageKey, all);
      if (mounted) setState(() { _all = all; _done = next; });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text('Kayıt cihazda saklanamadı. Lütfen tekrar deneyin.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final group = milestones.where((m) => m.month == _age).toList();
    final doneCount = group.where((m) => _done.containsKey(m.id)).length;
    final overdue = overdueMilestones(_done, _months);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelCard(color: const Color(0xFFFFF4FA), child: Text(
        'Her çocuk kendi hızında gelişir. Listedeki yaşlar, çocukların çoğunun o beceriyi gösterdiği yaştır. '
        'Yaptığında işaretle; tarih otomatik kaydedilir.',
        style: TextStyle(fontSize: 13))),
      SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [
        for (final a in milestoneAges)
          Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(
            key: Key('basamak_yas_$a'),
            label: Text(milestoneAgeLabel(a)), selected: a == _age,
            onSelected: (_) => setState(() => _age = a))),
      ])),
      const SizedBox(height: 8),
      Text('${t(milestoneAgeLabel(_age))}: $doneCount / ${group.length} tamamlandı',
          style: const TextStyle(fontWeight: FontWeight.w800, color: _mor)),
      const SizedBox(height: 6),
      for (final area in milestoneAreas)
        if (group.any((m) => m.area == area)) ...[
          Padding(padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(area, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black54))),
          for (final m in group.where((m) => m.area == area))
            PastelCard(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0), child: CheckboxListTile(
              key: Key('basamak_${m.id}'),
              value: _done.containsKey(m.id),
              onChanged: (_) => _toggle(m),
              activeColor: _mor,
              title: Text(m.title, style: const TextStyle(fontSize: 14)),
              subtitle: _done.containsKey(m.id)
                  ? Text(dmy(DateTime.parse(_done[m.id]!)), style: const TextStyle(fontSize: 12))
                  : null,
            )),
        ],
      if (overdue.isNotEmpty) ...[
        const SizedBox(height: 12),
        PastelCard(color: const Color(0xFFFFF1E6), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Doktorunla konuşabileceğin konular', style: TextStyle(fontWeight: FontWeight.w800, color: _mor)),
          const SizedBox(height: 4),
          Text('Aşağıdakiler henüz işaretlenmedi. Belki yapıyordur ve işaretlemeyi unuttun; '
              'emin değilsen bir sonraki kontrolde çocuk doktoruna sor. Erken destek çok fark yaratır.',
              style: TextStyle(fontSize: 12.5)),
          const SizedBox(height: 6),
          for (final m in overdue.take(8))
            Text('• ${t(m.title)} (${t(milestoneAgeLabel(m.month))})', style: const TextStyle(fontSize: 12.5)),
        ])),
      ],
      const SizedBox(height: 8),
      Text('Kaynak: CDC “Learn the Signs. Act Early.” (2022) ve DSÖ motor gelişim çalışması. Tanı aracı değildir.',
          style: TextStyle(fontSize: 11, color: Colors.black54)),
    ]);
  }
}
