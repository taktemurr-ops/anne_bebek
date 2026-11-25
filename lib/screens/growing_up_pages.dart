import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/growing_up.dart';
import '../services/json_store.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

/// Uyku eğitimi: yöntemler, seçilen yöntem ve gece uyanma kaydı.
class SleepTrainingPage extends StatefulWidget {
  static const storageKey = 'sleep_training_v1';
  final DateTime? birth;
  final DateTime Function()? clock;
  const SleepTrainingPage({super.key, this.birth, this.clock});
  @override
  State<SleepTrainingPage> createState() => _SleepTrainingPageState();
}

class _SleepTrainingPageState extends State<SleepTrainingPage> {
  String _method = sleepMethods.first.id;
  Map<String, int> _nights = {};
  bool _loading = true;

  DateTime get _now => widget.clock?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> m = {};
    try { m = await JsonStore.readMap(SleepTrainingPage.storageKey); } catch (_) {}
    final method = m['method'];
    final n = m['nights'];
    final nights = <String, int>{};
    if (n is Map) {
      for (final e in n.entries) {
        if (e.key is String && e.value is int && (e.value as int) >= 0 && (e.value as int) <= 20) nights[e.key as String] = e.value as int;
      }
    }
    if (mounted) {
      setState(() {
        if (method is String && sleepMethods.any((s) => s.id == method)) _method = method;
        _nights = nights;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    try {
      await JsonStore.writeMap(SleepTrainingPage.storageKey, {'method': _method, 'nights': _nights});
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  String _avgText(double? v) => v == null ? '—' : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final m = sleepMethods.firstWhere((s) => s.id == _method);
    final months = ageInMonths(widget.birth, _now);
    final lastNight = exerciseDayKey(_now);
    final (avg, prev) = wakingAverages(_nights, _now);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      if (months != null && months < 6)
        const KitNote('Bebeğin 6 aydan küçük: şimdilik düzenli bir yatma rutini ve “uykulu ama uyanık” yatırma yeterli.'),
      const KitHeader('Yöntemler', Icons.bedtime_outlined),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final s in sleepMethods)
          ChoiceChip(key: Key('uyku_yontem_${s.id}'), label: Text(s.name), selected: _method == s.id,
              onSelected: (_) { setState(() => _method = s.id); unawaited(_save()); }),
      ]),
      const SizedBox(height: 8),
      PastelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(m.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: kitMor)),
        Text(m.age, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3B6FB6))),
        const SizedBox(height: 6),
        Text(m.how),
        const SizedBox(height: 6),
        Text(m.note, style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B5B6B))),
      ])),
      const KitHeader('Dün gece kaç kez uyandı?', Icons.nights_stay_outlined),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (var i = 0; i <= 6; i++)
          ChoiceChip(key: Key('uyanma_$i'), label: Text(i == 6 ? '6+' : '$i'), selected: _nights[lastNight] == i,
              onSelected: (_) { setState(() => _nights[lastNight] = i); unawaited(_save()); }),
      ]),
      const SizedBox(height: 8),
      PastelCard(child: Row(children: [
        Expanded(child: Column(children: [
          Text(_avgText(avg), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kitMor)),
          Text('Son 7 gece ortalaması', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ])),
        Expanded(child: Column(children: [
          Text(_avgText(prev), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kitMor)),
          Text('Önceki 7 gece', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ])),
      ])),
      if (avg != null && prev != null && avg < prev)
        const KitNote('Gece uyanmaları azalıyor; aynı şekilde devam et.', color: Color(0xFFE3F3E5)),
      const KitHeader('Başlamadan önce', Icons.info_outline),
      const KitBullets(sleepTrainingNotes),
      const KitFootnote('Kaynak: Amerikan Pediatri Akademisi (HealthyChildren), NHS, Mindell ve ark. Sleep 2006 davranışsal uyku yöntemleri derlemesi.'),
    ]);
  }
}

/// Kreş ve okula hazırlık kontrol listesi.
class SchoolPrepPage extends StatefulWidget {
  static const storageKey = 'school_prep_v1';
  final int initialTab;
  const SchoolPrepPage({super.key, this.initialTab = 0});
  @override
  State<SchoolPrepPage> createState() => _SchoolPrepPageState();
}

class _SchoolPrepPageState extends State<SchoolPrepPage> {
  late int _tab = widget.initialTab;
  Set<String> _done = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    Map<String, dynamic> m = {};
    try { m = await JsonStore.readMap(SchoolPrepPage.storageKey); } catch (_) {}
    final valid = {...nurseryItems, ...schoolItems};
    final d = m['done'];
    if (mounted) setState(() { _done = d is List ? d.whereType<String>().where(valid.contains).toSet() : {}; _loading = false; });
  }

  Future<void> _toggle(String item) async {
    setState(() => _done.contains(item) ? _done.remove(item) : _done.add(item));
    try {
      await JsonStore.writeMap(SchoolPrepPage.storageKey, {'done': _done.toList()});
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final stages = _tab == 0 ? nurseryStages : schoolStages;
    final items = _tab == 0 ? nurseryItems : schoolItems;
    final count = items.where(_done.contains).length;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      PastelSegmentTabs(labels: const ['Kreş', 'Okul'], selected: _tab, onChanged: (i) => setState(() => _tab = i)),
      const SizedBox(height: 10),
      PastelCard(child: Text('$count / ${items.length}', textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kitMor))),
      if (_tab == 1) const KitNote('Bu liste bir sınav değildir; çocuklar farklı hızda gelişir. Eksik görünen alanlarda evde oyunla destek olabilirsin.'),
      for (final st in stages) ...[
        KitHeader(st.$1, _tab == 0 ? Icons.child_friendly_outlined : Icons.school_outlined),
        for (final item in st.$2)
          PastelCard(padding: const EdgeInsets.symmetric(horizontal: 4), child: CheckboxListTile(
            value: _done.contains(item), activeColor: kitMor, onChanged: (_) => _toggle(item),
            title: Text(item, style: const TextStyle(fontSize: 13.5)),
          )),
      ],
      const KitFootnote('Kaynak: Amerikan Pediatri Akademisi (HealthyChildren), UNICEF erken çocukluk rehberleri, MEB okul öncesi öneriler.'),
    ]);
  }
}

/// Gebelik ve emzirme dönemi egzersiz programı ve haftalık hedef.
class PregnancyExercisePage extends StatefulWidget {
  static const storageKey = 'exercise_program_v1';
  final DateTime Function()? clock;
  const PregnancyExercisePage({super.key, this.clock});
  @override
  State<PregnancyExercisePage> createState() => _PregnancyExercisePageState();
}

class _PregnancyExercisePageState extends State<PregnancyExercisePage> {
  int _plan = 0;
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
    try { m = await JsonStore.readMap(PregnancyExercisePage.storageKey); } catch (_) {}
    final d = m['days'];
    final out = <String, int>{};
    if (d is Map) {
      for (final e in d.entries) {
        if (e.key is String && e.value is int && (e.value as int) >= 0 && (e.value as int) <= 600) out[e.key as String] = e.value as int;
      }
    }
    final plan = m['plan'];
    if (mounted) setState(() { _days = out; if (plan is int && plan >= 0 && plan < exercisePlans.length) _plan = plan; _loading = false; });
  }

  Future<void> _save() async {
    try {
      await JsonStore.writeMap(PregnancyExercisePage.storageKey, {'plan': _plan, 'days': _days});
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  Future<void> _add(int minutes) async {
    final k = exerciseDayKey(_now);
    setState(() => _days[k] = ((_days[k] ?? 0) + minutes).clamp(0, 600));
    await _save();
  }

  String _weekText(int total) {
    final label = t('Bu hafta');
    return '$label: $total / $weeklyExerciseGoal';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final total = weekTotal(_days, _now);
    final today = _days[exerciseDayKey(_now)] ?? 0;
    final plan = exercisePlans[_plan];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      const KitNote('Haftada en az 150 dakika orta tempolu hareket önerilir. Başlamadan önce doktorunun onayını al; gebeliğinde risk varsa programı birlikte belirleyin.'),
      PastelCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_weekText(total), key: const Key('egzersiz_hafta'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kitMor)),
        const SizedBox(height: 6),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
            value: (total / weeklyExerciseGoal).clamp(0.0, 1.0), minHeight: 10,
            backgroundColor: const Color(0xFFF1E5EF), color: kitMor)),
        const SizedBox(height: 6),
        Text(t('{0} dk').replaceAll('{0}', '$today'), style: const TextStyle(fontSize: 12.5)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilledButton(key: const Key('egzersiz_10'), onPressed: () => _add(10), child: Text('+10 dk')),
          FilledButton(onPressed: () => _add(20), child: Text('+20 dk')),
          FilledButton(onPressed: () => _add(30), child: Text('+30 dk')),
          OutlinedButton(onPressed: today == 0 ? null : () => _add(-10), child: Text('−10 dk')),
        ]),
      ])),
      const KitHeader('Dönemine uygun program', Icons.fitness_center_outlined),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (var i = 0; i < exercisePlans.length; i++)
          ChoiceChip(key: Key('egzersiz_plan_$i'), label: Text(exercisePlans[i].$1), selected: _plan == i,
              onSelected: (_) { setState(() => _plan = i); unawaited(_save()); }),
      ]),
      const SizedBox(height: 8),
      PastelCard(child: KitBullets(plan.$2)),
      if (_plan == exercisePlans.length - 1) ...[
        const KitHeader('Emzirirken', Icons.child_care_outlined),
        const KitBullets(breastfeedingExerciseTips),
      ],
      const KitHeader('Kaçın', Icons.block),
      const KitBullets(exerciseAvoid),
      const KitHeader('Hemen dur ve doktoruna ulaş', Icons.warning_amber_rounded),
      const KitBullets(exerciseStop),
      const KitFootnote('Kaynak: Dünya Sağlık Örgütü fiziksel etkinlik rehberi (2020), ACOG Görüş 804 (gebelik ve doğum sonrası egzersiz), NHS.'),
    ]);
  }
}
