import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/family_more.dart';
import '../services/json_store.dart';
import '../services/text_share.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

String _dk(int n) => t('{0} dk').replaceAll('{0}', '$n');

Widget _stat(String value, String label) => Expanded(child: Column(children: [
      Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kitMor)),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
    ]));

/// Öfke nöbeti: şu an ne yapmalı + kayıt ve örüntü özeti.
class TantrumHelperPage extends StatefulWidget {
  static const storageKey = 'tantrum_log_v1';
  final DateTime Function()? clock;
  const TantrumHelperPage({super.key, this.clock});
  @override
  State<TantrumHelperPage> createState() => _TantrumHelperPageState();
}

class _TantrumHelperPageState extends State<TantrumHelperPage> {
  List<TantrumEntry> _entries = [];
  bool _loading = true;
  String _trigger = tantrumTriggers.first;
  int _minutes = tantrumDurations.first.$2;

  DateTime get _now => widget.clock?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> m = {};
    try { m = await JsonStore.readMap(TantrumHelperPage.storageKey); } catch (_) {}
    final raw = m['entries'];
    final list = raw is List ? raw.map(TantrumEntry.fromJson).whereType<TantrumEntry>().toList() : <TantrumEntry>[];
    list.sort((a, b) => b.at.compareTo(a.at));
    if (mounted) setState(() { _entries = list; _loading = false; });
  }

  Future<void> _save() async {
    try {
      await JsonStore.writeMap(TantrumHelperPage.storageKey, {'entries': [for (final e in _entries.take(500)) e.toJson()]});
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  Future<void> _add() async {
    setState(() => _entries.insert(0, TantrumEntry(_now, _trigger, _minutes)));
    await _save();
    if (mounted) kitSnack(context, t('Kaydedildi.'));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final s = summarizeTantrums(_entries, _now);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const KitHeader('Şu an nöbet varsa', Icons.self_improvement),
      PastelCard(child: KitBullets(tantrumNowSteps)),
      const KitHeader('Nöbeti kaydet', Icons.edit_note_outlined),
      Text('Ne tetikledi?', style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final tr in tantrumTriggers)
          ChoiceChip(label: Text(tr), selected: _trigger == tr, onSelected: (_) => setState(() => _trigger = tr)),
      ]),
      const SizedBox(height: 8),
      Text('Ne kadar sürdü?', style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final d in tantrumDurations)
          ChoiceChip(label: Text(d.$1), selected: _minutes == d.$2, onSelected: (_) => setState(() => _minutes = d.$2)),
      ]),
      const SizedBox(height: 8),
      FilledButton.icon(key: const Key('ofke_kaydet'), onPressed: _add, icon: const Icon(Icons.add), label: Text('Şimdi kaydet')),
      const KitHeader('Son 30 gün', Icons.insights_outlined),
      PastelCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stat('${s.count30}', t('nöbet')),
        _stat(s.topTrigger == null ? '—' : t(s.topTrigger!), t('En sık tetikleyici')),
        _stat(s.topBand == null ? '—' : t(s.topBand!), t('En sık zaman')),
      ])),
      if (s.count30 > 0 && s.topTrigger != null)
        KitNote(t('Örüntü: nöbetler en çok “{0}” ile başlıyor. Önlemek için aşağıdaki ipuçlarından bu tetikleyiciye uygun olanı dene.').replaceAll('{0}', t(s.topTrigger!))),
      const KitHeader('Önlemek için', Icons.lightbulb_outline),
      const KitBullets(tantrumPrevent),
      const KitHeader('Doktora danış', Icons.medical_services_outlined),
      const KitBullets(tantrumDoctor),
      if (_entries.isNotEmpty) ...[
        const KitHeader('Son kayıtlar', Icons.history),
        for (final e in _entries.take(10))
          PastelCard(padding: const EdgeInsets.fromLTRB(12, 8, 4, 8), child: Row(children: [
            Expanded(child: Text('${e.at.day}.${e.at.month}.${e.at.year} ${e.at.hour.toString().padLeft(2, '0')}:${e.at.minute.toString().padLeft(2, '0')} · ${t(e.trigger)} · ~${_dk(e.minutes)}',
                style: const TextStyle(fontSize: 13))),
            IconButton(tooltip: t('Sil'), icon: const Icon(Icons.delete_outline), onPressed: () async {
              setState(() => _entries.remove(e));
              await _save();
            }),
          ])),
      ],
      const KitFootnote('Kaynak: Amerikan Pediatri Akademisi (HealthyChildren), NHS. Kayıtlar yalnızca bu cihazda tutulur.'),
    ]);
  }
}

/// Ekran süresi: yaşa göre öneri ve günlük kayıt.
class ScreenTimePage extends StatefulWidget {
  static const storageKey = 'screen_time_v1';
  final DateTime? birth;
  final DateTime Function()? clock;
  const ScreenTimePage({super.key, this.birth, this.clock});
  @override
  State<ScreenTimePage> createState() => _ScreenTimePageState();
}

class _ScreenTimePageState extends State<ScreenTimePage> {
  Map<String, int> _days = {};
  bool _loading = true;

  DateTime get _now => widget.clock?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> m = {};
    try { m = await JsonStore.readMap(ScreenTimePage.storageKey); } catch (_) {}
    final d = m['days'];
    final out = <String, int>{};
    if (d is Map) {
      for (final e in d.entries) {
        if (e.key is String && e.value is int && (e.value as int) >= 0 && (e.value as int) <= 1440) out[e.key as String] = e.value as int;
      }
    }
    if (mounted) setState(() { _days = out; _loading = false; });
  }

  Future<void> _change(int delta) async {
    final k = dayKey(_now);
    setState(() => _days[k] = ((_days[k] ?? 0) + delta).clamp(0, 1440));
    try {
      await JsonStore.writeMap(ScreenTimePage.storageKey, {'days': _days});
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  String _limitText(int limit) {
    final label = t('Önerilen üst sınır');
    return '$label: ${_dk(limit)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final months = ageInMonths(widget.birth, _now);
    final limit = months == null ? null : screenLimitFor(months);
    final today = _days[dayKey(_now)] ?? 0;
    final over = limit != null && today > limit;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      KitNote(months == null ? 'Bebek profiline doğum tarihi eklersen yaşa göre öneri gösterilir.' : screenAdviceFor(months)),
      PastelCard(color: over ? const Color(0xFFFFE4E4) : const Color(0xFFFFFFFF), child: Column(children: [
        Text('Bugün', style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(_dk(today), key: const Key('ekran_bugun'), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: kitMor)),
        if (limit != null)
          Text(limit == 0 ? t('Bu yaşta önerilmez') : _limitText(limit),
              style: TextStyle(color: over ? const Color(0xFFD32F2F) : const Color(0xFF6B5B6B), fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
          OutlinedButton(onPressed: today == 0 ? null : () => _change(-15), child: Text('−15 dk')),
          FilledButton(key: const Key('ekran_15'), onPressed: () => _change(15), child: Text('+15 dk')),
          FilledButton(onPressed: () => _change(30), child: Text('+30 dk')),
          FilledButton(onPressed: () => _change(60), child: Text('+60 dk')),
        ]),
      ])),
      PastelCard(child: Row(children: [
        _stat(_dk(weekAverage(_days, _now)), t('Son 7 gün ortalaması')),
        _stat('${_days.length}', t('Kayıtlı gün')),
      ])),
      const KitHeader('Sağlıklı ekran alışkanlıkları', Icons.tv_off_outlined),
      const KitBullets(screenTips),
      const KitFootnote('Kaynak: Dünya Sağlık Örgütü 5 yaş altı fiziksel etkinlik, hareketsizlik ve uyku rehberi (2019), Amerikan Pediatri Akademisi.'),
    ]);
  }
}

/// Babalar ve destekçiler için rehber.
class PartnerGuidePage extends StatefulWidget {
  const PartnerGuidePage({super.key});
  @override
  State<PartnerGuidePage> createState() => _PartnerGuidePageState();
}

class _PartnerGuidePageState extends State<PartnerGuidePage> {
  int _sel = 0;

  Future<void> _share() async {
    final st = partnerStages[_sel];
    final title = t('Babalar ve destekçiler için');
    final items = st.$2.map((e) => '• ${t(e)}').join('\n');
    final text = '$title · ${t(st.$1)}\n$items';
    try { await TextShare.share(text); } catch (_) { if (mounted) kitSnack(context, t('Paylaşım açılamadı.')); }
  }

  @override
  Widget build(BuildContext context) {
    final st = partnerStages[_sel];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const KitNote('Eşin, annen, kardeşin ya da bir arkadaşın: yanında olan herkes için ne zaman neye yardım edebileceklerinin listesi. Paylaşabilirsin.'),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (var i = 0; i < partnerStages.length; i++)
          ChoiceChip(key: Key('destek_$i'), label: Text(partnerStages[i].$1), selected: i == _sel, onSelected: (_) => setState(() => _sel = i)),
      ]),
      const SizedBox(height: 8),
      PastelCard(child: KitBullets(st.$2)),
      FilledButton.icon(onPressed: _share, icon: const Icon(Icons.ios_share), label: Text('Bu listeyi paylaş')),
      const KitHeader('Destekçinin kendi sağlığı', Icons.favorite_border),
      const KitBullets(partnerSelfCare),
      const KitCallButton('112', 'Acil yardım'),
      const KitFootnote('Kaynak: NHS, UNICEF ebeveyn rehberleri; babalarda doğum sonrası depresyon: Paulson ve Bazemore, JAMA 2010.'),
    ]);
  }
}

/// Kardeşe hazırlık kontrol listesi.
class SiblingPrepPage extends StatefulWidget {
  static const storageKey = 'sibling_prep_v1';
  const SiblingPrepPage({super.key});
  @override
  State<SiblingPrepPage> createState() => _SiblingPrepPageState();
}

class _SiblingPrepPageState extends State<SiblingPrepPage> {
  Set<String> _done = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> m = {};
    try { m = await JsonStore.readMap(SiblingPrepPage.storageKey); } catch (_) {}
    final valid = siblingItems.toSet();
    final d = m['done'];
    if (mounted) setState(() { _done = d is List ? d.whereType<String>().where(valid.contains).toSet() : {}; _loading = false; });
  }

  Future<void> _toggle(String item) async {
    setState(() => _done.contains(item) ? _done.remove(item) : _done.add(item));
    try {
      await JsonStore.writeMap(SiblingPrepPage.storageKey, {'done': _done.toList()});
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelCard(child: Text('${_done.length} / ${siblingItems.length}',
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kitMor))),
      for (final st in siblingStages) ...[
        KitHeader(st.$1, Icons.family_restroom),
        for (final item in st.$2)
          PastelCard(padding: const EdgeInsets.symmetric(horizontal: 4), child: CheckboxListTile(
            value: _done.contains(item), activeColor: kitMor, onChanged: (_) => _toggle(item),
            title: Text(item, style: const TextStyle(fontSize: 13.5)),
          )),
      ],
      const KitFootnote('Kaynak: Amerikan Pediatri Akademisi (HealthyChildren), NHS.'),
    ]);
  }
}

/// Menopoz belirti takibi.
class MenopauseTrackerPage extends StatefulWidget {
  static const storageKey = 'menopause_log_v1';
  final DateTime Function()? clock;
  const MenopauseTrackerPage({super.key, this.clock});
  @override
  State<MenopauseTrackerPage> createState() => _MenopauseTrackerPageState();
}

class _MenopauseTrackerPageState extends State<MenopauseTrackerPage> {
  Map<String, Map<String, int>> _days = {};
  bool _loading = true;

  DateTime get _now => widget.clock?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> m = {};
    try { m = await JsonStore.readMap(MenopauseTrackerPage.storageKey); } catch (_) {}
    final out = <String, Map<String, int>>{};
    final d = m['days'];
    if (d is Map) {
      for (final e in d.entries) {
        if (e.key is! String || e.value is! Map) continue;
        final day = <String, int>{};
        for (final s in (e.value as Map).entries) {
          if (s.key is String && menopauseSymptoms.contains(s.key) && s.value is int && (s.value as int) >= 0 && (s.value as int) <= 3) {
            day[s.key as String] = s.value as int;
          }
        }
        out[e.key as String] = day;
      }
    }
    if (mounted) setState(() { _days = out; _loading = false; });
  }

  String _loggedText(int n) {
    final label = t('Kayıtlı gün');
    return '$label: $n';
  }

  Future<void> _set(String symptom, int level) async {
    final k = dayKey(_now);
    setState(() => (_days[k] ??= {})[symptom] = level);
    try {
      await JsonStore.writeMap(MenopauseTrackerPage.storageKey, {'days': _days});
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final today = _days[dayKey(_now)] ?? const {};
    final (logged, avg) = summarizeMenopause(_days, _now);
    final top = avg.entries.where((e) => e.value > 0).toList()..sort((a, b) => b.value.compareTo(a.value));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const KitNote('Her gün belirtilerinin şiddetini işaretle; doktor görüşmesinde son 30 günün özetini gösterebilirsin.'),
      const KitHeader('Bugün', Icons.today_outlined),
      for (final s in menopauseSymptoms)
        PastelCard(padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s, style: const TextStyle(fontWeight: FontWeight.w800, color: kitMor)),
          const SizedBox(height: 4),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (var l = 0; l < menopauseLevels.length; l++)
              ChoiceChip(label: Text(menopauseLevels[l]), selected: (today[s] ?? 0) == l, onSelected: (_) => _set(s, l)),
          ]),
        ])),
      const KitHeader('Son 30 gün', Icons.insights_outlined),
      PastelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_loggedText(logged), style: const TextStyle(fontWeight: FontWeight.w800)),
        if (top.isEmpty) Text('Henüz belirti kaydı yok.')
        else for (final e in top.take(4))
          Text('• ${t(e.key)}: ${t(menopauseLevels[e.value.round().clamp(0, 3)])} (${e.value.toStringAsFixed(1)})'),
      ])),
      const KitHeader('Rahatlatmak için', Icons.spa_outlined),
      const KitBullets(menopauseTips),
      const KitHeader('Doktora git', Icons.medical_services_outlined),
      const KitBullets(menopauseDoctor),
      const KitFootnote('Kaynak: NHS, Kuzey Amerika Menopoz Derneği (The Menopause Society), Dünya Sağlık Örgütü. Kayıtlar yalnızca bu cihazda tutulur.'),
    ]);
  }
}
