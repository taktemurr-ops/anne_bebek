import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/json_store.dart';
import '../services/ttc.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

/// Gebe kalmaya çalışıyorum: doğurgan günler, bazal ateş, ovulasyon ve gebelik testi.
class TtcPage extends StatefulWidget {
  static const storageKey = 'ttc_journal_v1';
  final List<DateTime> periodStarts;
  final VoidCallback? onPregnant;
  final DateTime Function()? clock;
  const TtcPage({super.key, this.periodStarts = const [], this.onPregnant, this.clock});

  @override
  State<TtcPage> createState() => _TtcPageState();
}

class _TtcPageState extends State<TtcPage> {
  List<TtcDay> _days = [];
  bool _loading = true;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> all = {};
    try { all = await JsonStore.readMap(TtcPage.storageKey); } catch (_) {}
    if (!mounted) return;
    setState(() { _days = decodeTtcDays(all['days']); _loading = false; });
  }

  Future<void> _save(List<TtcDay> next) async {
    try {
      await JsonStore.writeMap(TtcPage.storageKey, {'days': next.map((d) => d.toJson()).toList()});
      if (mounted) setState(() => _days = next);
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  Future<void> _edit([DateTime? day]) async {
    var d = day ?? _now();
    d = DateTime(d.year, d.month, d.day);
    TtcDay existing() => _days.firstWhere((e) => e.day == d, orElse: () => TtcDay(d));
    var cur = existing();
    final bbt = TextEditingController(text: cur.bbt?.toStringAsFixed(2).replaceAll('.', ',') ?? '');
    final note = TextEditingController(text: cur.note);
    int? opk = cur.opk, test = cur.pregnancyTest;
    var intimacy = cur.intimacy;
    String? error;
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
      title: Text('Günlük kayıt'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.event), title: Text(dmy(d)), onTap: () async {
          final p = await kitPickDay(ctx, initial: d);
          if (p == null) return;
          d = DateTime(p.year, p.month, p.day);
          cur = existing();
          set(() {
            bbt.text = cur.bbt?.toStringAsFixed(2).replaceAll('.', ',') ?? '';
            note.text = cur.note; opk = cur.opk; test = cur.pregnancyTest; intimacy = cur.intimacy;
          });
        }),
        TextField(key: const Key('ttc_bbt'), controller: bbt, keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: t('Bazal vücut sıcaklığı (°C)'), hintText: t('ör. 36,45'), errorText: error == null ? null : t(error!))),
        const SizedBox(height: 8),
        Text('Ovulasyon testi', style: TextStyle(fontWeight: FontWeight.w700)),
        Wrap(spacing: 6, children: [
          for (var i = 0; i < opkResults.length; i++)
            ChoiceChip(key: Key('ttc_opk_$i'), label: Text(opkResults[i]), selected: opk == i, onSelected: (s) => set(() => opk = s ? i : null)),
        ]),
        Text('Gebelik testi', style: TextStyle(fontWeight: FontWeight.w700)),
        Wrap(spacing: 6, children: [
          for (var i = 0; i < pregnancyTestResults.length; i++)
            ChoiceChip(key: Key('ttc_test_$i'), label: Text(pregnancyTestResults[i]), selected: test == i, onSelected: (s) => set(() => test = s ? i : null)),
        ]),
        SwitchListTile(contentPadding: EdgeInsets.zero, value: intimacy, onChanged: (v) => set(() => intimacy = v),
            title: Text('Cinsel ilişki')),
        TextField(controller: note, decoration: InputDecoration(labelText: t('Not (belirti, akıntı vb.)'))),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Vazgeç')),
        FilledButton(key: const Key('ttc_kaydet'), onPressed: () {
          if (bbt.text.trim().isNotEmpty && parseBbt(bbt.text) == null) {
            set(() => error = '35–38,5 °C arasında bir değer gir.');
            return;
          }
          Navigator.pop(ctx, true);
        }, child: Text('Kaydet')),
      ])));
    final entry = TtcDay(d, bbt: bbt.text.trim().isEmpty ? null : parseBbt(bbt.text), opk: opk,
        pregnancyTest: test, intimacy: intimacy, note: note.text.trim());
    bbt.dispose();
    note.dispose();
    if (ok != true) return;
    final next = [..._days.where((e) => e.day != d), if (!entry.isEmpty) entry]..sort((a, b) => a.day.compareTo(b.day));
    await _save(next);
    if (entry.pregnancyTest == 1 && mounted) _congrats();
  }

  void _congrats() => showDialog<void>(context: context, builder: (ctx) => AlertDialog(
    title: Text('Tebrikler! 💗'),
    content: Text('Pozitif gebelik testini doğrulatmak ve ilk kontrolü planlamak için doktoruna görün. '
        'Folik asidi kullanmaya devam et. Gebelik bölümünden hafta hafta takibe başlayabilirsin.'),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Kapat')),
      if (widget.onPregnant != null) FilledButton(onPressed: () { Navigator.pop(ctx); widget.onPregnant!(); }, child: Text('Gebelik takibini aç')),
    ]));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final now = _now();
    final w = nextFertileWindow(widget.periodStarts, _days, now);
    final cd = cycleDay(widget.periodStarts, now);
    final inWindow = w != null && w.contains(now);
    final temps = _days.where((d) => d.bbt != null).toList();
    final recent = temps.length > 30 ? temps.sublist(temps.length - 30) : temps;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelCard(color: inWindow ? const Color(0xFFFFE3F0) : const Color(0xFFFFF4FA), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.periodStarts.isEmpty)
          Text('Doğurgan günleri tahmin edebilmek için Kadınlar bölümünde en az bir adet başlangıç tarihi gir.', style: TextStyle(fontSize: 13))
        else ...[
          if (cd != null) Text('${t('Döngü günü')}: $cd', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: kitMor)),
          if (inWindow) Text('Bugün doğurgan dönemdesin', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFE94791))),
          if (w != null) ...[
            const SizedBox(height: 4),
            Text('${t('Doğurgan dönem')}: ${dmy(w.start)} – ${dmy(w.end)}'),
            Text('${t('Tahmini yumurtlama')}: ${dmy(w.ovulation)}'),
          ],
        ],
      ])),
      FilledButton.icon(key: const Key('ttc_bugun'), onPressed: () => _edit(), icon: const Icon(Icons.edit_calendar_outlined), label: Text('Bugünü kaydet')),
      if (recent.length >= 2) ...[
        const KitHeader('Bazal vücut sıcaklığı', Icons.show_chart),
        PastelCard(child: SizedBox(height: 120, child: CustomPaint(painter: _BbtPainter(recent.map((e) => e.bbt!).toList()), size: Size.infinite))),
      ],
      if (_days.isNotEmpty) ...[
        const KitHeader('Son kayıtlar', Icons.history),
        for (final d in _days.reversed.take(20))
          PastelCard(padding: EdgeInsets.zero, onTap: () => _edit(d.day), child: ListTile(dense: true,
            title: Text(dmy(d.day)),
            subtitle: Text([
              if (d.bbt != null) '${d.bbt!.toStringAsFixed(2).replaceAll('.', ',')} °C',
              if (d.opk != null) '${t('Ovulasyon testi')}: ${t(opkResults[d.opk!])}',
              if (d.pregnancyTest != null) '${t('Gebelik testi')}: ${t(pregnancyTestResults[d.pregnancyTest!])}',
              if (d.intimacy) '♥',
              if (d.note.isNotEmpty) d.note,
            ].join(' · ')))),
      ],
      const KitHeader('Bebek planlarken', Icons.lightbulb_outline),
      const KitBullets(ttcTips),
      const KitFootnote('Tahminler ortalama döngüye dayanır ve kesin değildir; doğum kontrolü için kullanılmamalıdır.'),
    ]);
  }
}

class _BbtPainter extends CustomPainter {
  final List<double> v;
  _BbtPainter(this.v);
  @override
  void paint(Canvas c, Size s) {
    final lo = v.reduce((a, b) => a < b ? a : b) - 0.1, hi = v.reduce((a, b) => a > b ? a : b) + 0.1;
    final p = Path();
    final dot = Paint()..color = kitMor;
    for (var i = 0; i < v.length; i++) {
      final x = v.length == 1 ? s.width / 2 : s.width * i / (v.length - 1);
      final y = s.height - (v[i] - lo) / (hi - lo) * s.height;
      i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
      c.drawCircle(Offset(x, y), 3, dot);
    }
    c.drawPath(p, Paint()..color = kitMor..style = PaintingStyle.stroke..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(_BbtPainter o) => o.v != v;
}
