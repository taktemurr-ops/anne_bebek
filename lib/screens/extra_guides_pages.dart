import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/extra_guides.dart';
import '../services/json_store.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

Color _verdictColor(FoodVerdict v) => switch (v) {
      FoodVerdict.safe => const Color(0xFF2E8B57),
      FoodVerdict.caution => const Color(0xFFE08A00),
      FoodVerdict.avoid => const Color(0xFFD32F2F),
    };

/// Yiyebilir miyim? Gebelik ve emzirmede besin güvenliği.
class FoodSafetyPage extends StatefulWidget {
  final bool breastfeeding;
  const FoodSafetyPage({super.key, this.breastfeeding = false});
  @override
  State<FoodSafetyPage> createState() => _FoodSafetyPageState();
}

class _FoodSafetyPageState extends State<FoodSafetyPage> {
  late bool _bf = widget.breastfeeding;
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _q.text.trim().toLowerCase();
    final list = foodSafetyList.where((f) => q.isEmpty || t(f.name).toLowerCase().contains(q) || f.name.toLowerCase().contains(q)).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelSegmentTabs(labels: const ['Gebelikte', 'Emzirirken'], selected: _bf ? 1 : 0, onChanged: (i) => setState(() => _bf = i == 1)),
      const SizedBox(height: 10),
      TextField(key: const Key('yiyebilir_ara'), controller: _q, onChanged: (_) => setState(() {}),
          decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: t('Besin ara (ör. peynir, kahve)'), border: const OutlineInputBorder())),
      const SizedBox(height: 10),
      if (list.isEmpty) const KitNote('Bu besin listede yok. Emin değilsen doktoruna ya da eczacına sor.'),
      for (final f in list) Builder(builder: (_) {
        final v = _bf ? f.breastfeeding : f.pregnancy;
        return PastelCard(padding: const EdgeInsets.fromLTRB(12, 10, 12, 10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(v == FoodVerdict.safe ? Icons.check_circle : v == FoodVerdict.caution ? Icons.error_outline : Icons.block, color: _verdictColor(v)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(f.name, style: const TextStyle(fontWeight: FontWeight.w800, color: kitMor)),
            Text(foodVerdictLabel(v), style: TextStyle(fontWeight: FontWeight.w700, color: _verdictColor(v), fontSize: 12.5)),
            Text(f.note, style: const TextStyle(fontSize: 12.5)),
          ])),
        ]));
      }),
      const KitFootnote('Kaynak: NHS, ACOG, ABD FDA/EPA balık önerileri. Kişisel durumun için doktoruna danış.'),
    ]);
  }
}

/// Gebelikte kilo alımı hesaplayıcı (IOM 2009).
class PregnancyWeightPage extends StatefulWidget {
  static const storageKey = 'pregnancy_weight_v1';
  final int? currentWeek;
  const PregnancyWeightPage({super.key, this.currentWeek});
  @override
  State<PregnancyWeightPage> createState() => _PregnancyWeightPageState();
}

class _PregnancyWeightPageState extends State<PregnancyWeightPage> {
  final _pre = TextEditingController(), _height = TextEditingController(), _now = TextEditingController();
  late int _week = (widget.currentWeek ?? 20).clamp(1, 42);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _pre.dispose();
    _height.dispose();
    _now.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    Map<String, dynamic> m = {};
    try { m = await JsonStore.readMap(PregnancyWeightPage.storageKey); } catch (_) {}
    String f(Object? v) => v is num ? v.toString().replaceAll('.', ',') : '';
    _pre.text = f(m['pre']);
    _height.text = f(m['height']);
    _now.text = f(m['now']);
    if (widget.currentWeek == null && m['week'] is int) _week = (m['week'] as int).clamp(1, 42);
    if (mounted) setState(() => _loading = false);
  }

  double? _num(TextEditingController c) => double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    try {
      await JsonStore.writeMap(PregnancyWeightPage.storageKey, {
        if (_num(_pre) != null) 'pre': _num(_pre), if (_num(_height) != null) 'height': _num(_height),
        if (_num(_now) != null) 'now': _num(_now), 'week': _week,
      });
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  String _kg(double v) => v.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final pre = _num(_pre), h = _num(_height), now = _num(_now);
    final plan = pre == null || h == null ? null : weightGainPlan(pre, h);
    Widget field(TextEditingController c, String label, Key key) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(
      key: key, controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) { setState(() {}); unawaited(_save()); },
      decoration: InputDecoration(labelText: t(label), border: const OutlineInputBorder())));
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      field(_pre, 'Gebelik öncesi kilo (kg)', const Key('kilo_once')),
      field(_height, 'Boy (cm)', const Key('kilo_boy')),
      field(_now, 'Şimdiki kilo (kg, isteğe bağlı)', const Key('kilo_simdi')),
      Row(children: [
        Text('${t('Gebelik haftası')}: $_week', style: const TextStyle(fontWeight: FontWeight.w700)),
        Expanded(child: Slider(value: _week.toDouble(), min: 1, max: 42, divisions: 41, activeColor: kitMor,
            onChanged: (v) => setState(() => _week = v.round()), onChangeEnd: (_) => unawaited(_save()))),
      ]),
      if (plan == null)
        const KitNote('Önerilen kilo aralığını görmek için gebelik öncesi kilonu ve boyunu gir.')
      else ...[
        PastelCard(color: const Color(0xFFFFF4FA), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${t('Gebelik öncesi beden kitle indeksi')}: ${plan.bmi.toStringAsFixed(1).replaceAll('.', ',')} (${t(plan.category)})',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('${t('Gebelik boyunca önerilen toplam artış')}: ${_kg(plan.totalMin)}–${_kg(plan.totalMax)} kg',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kitMor)),
          const SizedBox(height: 6),
          Builder(builder: (_) {
            final (lo, hi) = plan.expectedBy(_week);
            return Text('${t('Bu haftaya kadar beklenen artış')}: ${_kg(lo)}–${_kg(hi)} kg');
          }),
          if (_week > 13) Text('${t('2. ve 3. trimesterde haftalık')}: ${_kg(plan.weeklyMin)}–${_kg(plan.weeklyMax)} kg',
              style: const TextStyle(fontSize: 12.5)),
        ])),
        if (now != null && pre != null) Builder(builder: (_) {
          final gain = now - pre;
          final (lo, hi) = plan.expectedBy(_week);
          final status = gain < lo - 1 ? 'Beklenenin altında' : gain > hi + 1 ? 'Beklenenin üstünde' : 'Önerilen aralıkta';
          final ok = status == 'Önerilen aralıkta';
          return KitNote('${t('Şu ana kadar')}: ${gain >= 0 ? '+' : ''}${_kg(gain)} kg — ${t(status)}',
              color: ok ? const Color(0xFFEDF7EE) : const Color(0xFFFFF1E6));
        }),
      ],
      const KitBullets([
        'İlk 3 ayda bulantı nedeniyle kilo almamak ya da biraz vermek olağandır.',
        'Gebelikte diyet yapılmaz; amaç önerilen aralıkta, dengeli beslenerek kilo almaktır.',
        'İkiz gebelikte öneriler farklıdır; doktorunun önerisine uy.',
        'Bir haftada 1 kg’dan fazla ani artış ve el-yüz şişmesi varsa tansiyonunu ölçtür, doktoruna haber ver.',
      ]),
      const KitFootnote('Kaynak: ABD Tıp Enstitüsü (IOM) 2009 gebelikte kilo alımı önerileri, tekil gebelik.'),
    ]);
  }
}

/// Ağlayan bebek rehberi.
class CryingBabyPage extends StatefulWidget {
  final VoidCallback? onOpenSounds;
  const CryingBabyPage({super.key, this.onOpenSounds});
  @override
  State<CryingBabyPage> createState() => _CryingBabyPageState();
}

class _CryingBabyPageState extends State<CryingBabyPage> {
  final _checked = <int>{};

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        const KitNote('Ağlamak bebeğin konuşma yoludur. Sırayla kontrol et; işaretlediklerin burada görünür. Hiçbiri işe yaramazsa sorun sende değil, bazen bebekler sadece ağlar.'),
        for (var i = 0; i < cryingChecklist.length; i++)
          PastelCard(padding: const EdgeInsets.symmetric(horizontal: 4), child: CheckboxListTile(
            key: Key('aglama_$i'), value: _checked.contains(i), activeColor: kitMor,
            onChanged: (_) => setState(() => _checked.contains(i) ? _checked.remove(i) : _checked.add(i)),
            title: Text(cryingChecklist[i].$1, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(cryingChecklist[i].$2, style: const TextStyle(fontSize: 12.5)))),
        if (widget.onOpenSounds != null) OutlinedButton.icon(onPressed: widget.onOpenSounds,
            icon: const Icon(Icons.music_note_outlined), label: Text('Beyaz gürültü ve ninniler')),
        const KitHeader('Çok zorlandıysan', Icons.self_improvement),
        const KitBullets(cryingSafetyPlan),
        const KitHeader('Kolik nedir?', Icons.info_outline),
        const KitBullets(colicFacts),
        const KitHeader('Hemen doktora başvur', Icons.warning_amber_rounded),
        const KitBullets(cryingRedFlags),
        const KitCallButton('112', 'Acil yardım'),
        const KitFootnote('Kaynak: NHS, Amerikan Pediatri Akademisi; sarsılmış bebek sendromunu önleme önerileri.'),
      ]);
}

/// Yaşa göre uyku rehberi.
class SleepGuidePage extends StatefulWidget {
  final DateTime? birth;
  const SleepGuidePage({super.key, this.birth});
  @override
  State<SleepGuidePage> createState() => _SleepGuidePageState();
}

class _SleepGuidePageState extends State<SleepGuidePage> {
  SleepNeed? _cur;
  late SleepNeed _sel;

  @override
  void initState() {
    super.initState();
    final m = ageInMonths(widget.birth, DateTime.now());
    _cur = m == null ? null : sleepNeedFor(m);
    _sel = _cur ?? sleepNeeds.first;
  }

  Widget _row(SleepNeed s) => PastelCard(
    color: identical(s, _cur) ? const Color(0xFFF6E3F2) : const Color(0xFFFFFFFF),
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(s.label, style: const TextStyle(fontWeight: FontWeight.w900, color: kitMor)),
      Text('${t('Toplam uyku (24 saat)')}: ${t(s.total)}', style: const TextStyle(fontSize: 13)),
      Text('${t('Gündüz uykusu')}: ${t(s.naps)}', style: const TextStyle(fontSize: 13)),
      Text('${t('Uyanık kalma süresi')}: ${t(s.awake)}', style: const TextStyle(fontSize: 13)),
    ]));

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      if (_cur != null) ...[
        Text('Bebeğinin yaşına göre', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        _row(_cur!),
      ],
      const KitNote('Süreler ortalamadır; bebeğin ruh hâli ve büyümesi iyiyse kendi ritmi en doğrusudur. Uyanık kalma süresi, iki uyku arasında yorulmadan geçirebileceği yaklaşık süredir.'),
      const KitHeader('Tüm yaşlar', Icons.bedtime_outlined),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final s in sleepNeeds)
          ChoiceChip(
            label: Text(s.label),
            selected: identical(s, _sel),
            onSelected: (_) => setState(() => _sel = s),
          ),
      ]),
      const SizedBox(height: 8),
      _row(_sel),
      const KitHeader('Güvenli uyku', Icons.verified_user_outlined),
      const KitBullets(safeSleepRules),
      const KitFootnote('Kaynak: Amerikan Uyku Tıbbı Akademisi (AASM 2016), ABD Ulusal Uyku Vakfı, AAP güvenli uyku önerileri.'),
    ]);
  }
}

/// Yaşa göre ev güvenliği kontrol listesi.
class HomeSafetyPage extends StatefulWidget {
  static const storageKey = 'home_safety_v1';
  final DateTime? birth;
  const HomeSafetyPage({super.key, this.birth});
  @override
  State<HomeSafetyPage> createState() => _HomeSafetyPageState();
}

class _HomeSafetyPageState extends State<HomeSafetyPage> {
  Set<String> _done = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> m = {};
    try { m = await JsonStore.readMap(HomeSafetyPage.storageKey); } catch (_) {}
    final ids = homeSafetyItems.map((e) => e.id).toSet();
    final d = m['done'];
    if (mounted) {
      setState(() {
        _done = d is List ? d.whereType<String>().where(ids.contains).toSet() : {};
        _loading = false;
      });
    }
  }

  Future<void> _toggle(String id) async {
    setState(() => _done.contains(id) ? _done.remove(id) : _done.add(id));
    try {
      await JsonStore.writeMap(HomeSafetyPage.storageKey, {'done': _done.toList()});
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final m = ageInMonths(widget.birth, DateTime.now());
    final stageNow = m == null ? null : m <= 3 ? 0 : m <= 9 ? 1 : m <= 24 ? 2 : 3;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelCard(child: Column(children: [
        Text('${_done.length} / ${homeSafetyItems.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kitMor)),
        Text('güvenlik önlemi alındı', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: _done.length / homeSafetyItems.length, color: kitMor, backgroundColor: const Color(0xFFF1E6F0)),
      ])),
      if (stageNow != null) KitNote('${t('Bebeğinin yaşı için öncelik')}: ${t(safetyStages[stageNow])}. ${t('Bir sonraki dönemin önlemlerini de şimdiden almaya başla; bebekler beklenenden hızlı gelişir.')}'),
      for (var i = 0; i < safetyStages.length; i++) ...[
        KitHeader(safetyStages[i], i == stageNow ? Icons.star_rounded : Icons.shield_outlined),
        for (final it in homeSafetyItems.where((e) => e.stage == safetyStages[i]))
          CheckboxListTile(key: Key('guvenlik_${it.id}'), dense: true, contentPadding: EdgeInsets.zero, activeColor: kitMor,
            value: _done.contains(it.id), onChanged: (_) => _toggle(it.id),
            title: Text(it.text, style: const TextStyle(fontSize: 13.5))),
      ],
      const KitFootnote('Kaynak: Amerikan Pediatri Akademisi ve Dünya Sağlık Örgütü çocuk yaralanmalarını önleme önerileri.'),
    ]);
  }
}
