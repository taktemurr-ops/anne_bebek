import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../i18n/i18n.dart' show t;
import '../i18n/text.dart';
import '../services/json_store.dart';
import '../services/mother_exercise.dart';
import '../widgets/module_kit.dart';
import '../widgets/reference_widgets.dart';

/// Pelvik taban programı, nefes egzersizleri ve doğum sonrası hareket rehberi.
class MotherExercisePage extends StatefulWidget {
  static const storageKey = 'mother_exercise_v1';
  final int initialTab;
  const MotherExercisePage({super.key, this.initialTab = 0});

  @override
  State<MotherExercisePage> createState() => _MotherExercisePageState();
}

class _MotherExercisePageState extends State<MotherExercisePage> {
  Set<String> _days = {};
  Map<String, int> _counts = {};
  int _level = 0;
  int _pattern = 0;
  int _minutes = 3;

  // Çalışan oturum
  Timer? _timer;
  bool _isKegel = true;
  int _step = 0; // kegel: tekrar*2 + faz, nefes: adım indeksi
  int _left = 0; // bu fazda kalan saniye
  int _elapsed = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    Map<String, dynamic> all = {};
    try { all = await JsonStore.readMap(MotherExercisePage.storageKey); } catch (_) {}
    final counts = <String, int>{};
    final raw = all['kegel'];
    if (raw is Map) {
      raw.forEach((k, v) { if (v is int && v > 0 && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch('$k')) counts['$k'] = v; });
    }
    final lvl = all['level'];
    if (!mounted) return;
    setState(() {
      _counts = counts;
      _days = counts.keys.toSet();
      _level = lvl is int && lvl >= 0 && lvl < kegelLevels.length ? lvl : 0;
    });
  }

  Future<void> _logKegel() async {
    final k = dayKey(DateTime.now());
    final counts = {..._counts, k: (_counts[k] ?? 0) + 1};
    try {
      await JsonStore.writeMap(MotherExercisePage.storageKey, {'kegel': counts, 'level': _level});
      if (mounted) setState(() { _counts = counts; _days = counts.keys.toSet(); });
    } catch (_) {
      if (mounted) kitSaveFailed(context);
    }
  }

  void _startKegel() {
    _timer?.cancel();
    final l = kegelLevels[_level];
    setState(() { _isKegel = true; _step = 0; _left = l.holdSeconds; _elapsed = 0; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tickKegel());
  }

  void _tickKegel() {
    if (!mounted) return;
    final l = kegelLevels[_level];
    setState(() {
      _left--;
      if (_left > 0) return;
      _step++;
      if (_step >= l.reps * 2) {
        _timer?.cancel();
        _timer = null;
        unawaited(_logKegel());
        kitSnack(context, 'Harika! Bugünkü oturumun kaydedildi.');
        return;
      }
      _left = _step.isEven ? l.holdSeconds : l.relaxSeconds;
    });
  }

  void _startBreath() {
    _timer?.cancel();
    final p = breathPatterns[_pattern];
    setState(() { _isKegel = false; _step = 0; _left = p.steps.first.$2; _elapsed = 0; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed++;
        _left--;
        if (_left > 0) return;
        if (_elapsed >= _minutes * 60) {
          _timer?.cancel();
          _timer = null;
          return;
        }
        _step = (_step + 1) % p.steps.length;
        _left = p.steps[_step].$2;
      });
    });
  }

  void _stop() => setState(() { _timer?.cancel(); _timer = null; });

  bool get _running => _timer != null;

  Widget _circle(String label, int seconds, {required bool big}) => Center(child: AnimatedContainer(
        duration: Duration(milliseconds: big ? 900 : 600),
        width: big ? 210 : 140, height: big ? 210 : 140,
        decoration: BoxDecoration(shape: BoxShape.circle, color: big ? const Color(0xFFF6C9E6) : const Color(0xFFEDE4FF)),
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kitMor)),
          Text('$seconds', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: kitMor)),
        ]),
      ));

  Widget _kegelTab() {
    final l = kegelLevels[_level];
    final today = _counts[dayKey(DateTime.now())] ?? 0;
    final streak = exerciseStreak(_days, DateTime.now());
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      PastelCard(child: Row(children: [
        Expanded(child: Column(children: [
          Text('$today / 3', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kitMor)),
          Text('bugünkü oturum', style: TextStyle(fontSize: 12)),
        ])),
        Expanded(child: Column(children: [
          Text('$streak', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kitMor)),
          Text('gün üst üste', style: TextStyle(fontSize: 12)),
        ])),
      ])),
      if (_running && _isKegel) ...[
        Text('${t('Tekrar')} ${_step ~/ 2 + 1} / ${l.reps}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        _circle(_step.isEven ? 'Sık' : 'Gevşe', _left, big: _step.isEven),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _stop, child: Text('Durdur')),
      ] else ...[
        Wrap(spacing: 6, runSpacing: 4, children: [
          for (var i = 0; i < kegelLevels.length; i++)
            ChoiceChip(label: Text(kegelLevels[i].name), selected: _level == i, onSelected: (_) => setState(() => _level = i)),
        ]),
        const SizedBox(height: 6),
        Text('${l.reps} ${t('tekrar')} · ${l.holdSeconds} ${t('sn sık')}, ${l.relaxSeconds} ${t('sn gevşe')}',
            style: const TextStyle(fontSize: 13)),
        const SizedBox(height: 10),
        FilledButton.icon(key: const Key('kegel_basla'), onPressed: _running ? null : _startKegel,
            icon: const Icon(Icons.play_arrow_rounded), label: Text('Oturumu başlat')),
      ],
      const KitHeader('Nasıl yapılır?', Icons.help_outline),
      const KitBullets(kegelHowTo),
    ]);
  }

  Widget _breathTab() {
    final p = breathPatterns[_pattern];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
      if (_running && !_isKegel) ...[
        _circle(p.steps[_step].$1, _left, big: p.steps[_step].$1 != 'Nefes ver'),
        const SizedBox(height: 8),
        Text('${(_minutes * 60 - _elapsed) ~/ 60}:${((_minutes * 60 - _elapsed) % 60).toString().padLeft(2, '0')}',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: _stop, child: Text('Durdur')),
      ] else ...[
        for (var i = 0; i < breathPatterns.length; i++)
          PastelCard(color: _pattern == i ? const Color(0xFFF6E3F2) : const Color(0xFFFFFFFF), onTap: () => setState(() => _pattern = i),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(breathPatterns[i].name, style: const TextStyle(fontWeight: FontWeight.w800, color: kitMor)),
              Text(breathPatterns[i].description, style: const TextStyle(fontSize: 12.5)),
            ])),
        Wrap(spacing: 6, children: [
          for (final m in const [1, 3, 5, 10])
            ChoiceChip(label: Text('$m ${t('dk')}'), selected: _minutes == m, onSelected: (_) => setState(() => _minutes = m)),
        ]),
        const SizedBox(height: 10),
        FilledButton.icon(key: const Key('nefes_basla'), onPressed: _running ? null : _startBreath,
            icon: const Icon(Icons.air), label: Text('Başla')),
      ],
      const KitFootnote('Nefes egzersizleri rahatlamaya yardımcı olur ama tedavi yerine geçmez. Sürekli kaygı ya da panik yaşıyorsan bir uzmana danış.'),
    ]);
  }

  Widget _recoveryTab() => ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
        const KitNote('Her doğum ve her beden farklıdır. Aşağıdaki süreler normal doğum içindir; sezaryen ya da zor bir doğum sonrası daha yavaş ilerle ve doktorunun önerisine uy.'),
        for (final s in recoveryStages) ...[
          KitHeader(s.title, Icons.directions_walk),
          KitBullets(s.items),
        ],
        const KitHeader('Ne zaman durmalısın?', Icons.warning_amber_rounded),
        const KitBullets(recoveryWarnings),
        const KitFootnote('Kaynak: NHS pelvik taban önerileri, ACOG doğum sonrası fiziksel aktivite görüşü.'),
      ]);

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        initialIndex: widget.initialTab.clamp(0, 2),
        child: Column(children: [
          Material(color: Colors.white, child: TabBar(isScrollable: true, labelColor: kitMor, indicatorColor: kitMor,
            onTap: (_) { if (_running) _stop(); },
            tabs: [Tab(text: t('Pelvik taban')), Tab(text: t('Nefes')), Tab(text: t('Doğum sonrası hareket'))])),
          Expanded(child: TabBarView(physics: const NeverScrollableScrollPhysics(), children: [_kegelTab(), _breathTab(), _recoveryTab()])),
        ]),
      );
}
