import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/loop_player.dart';
import '../services/sound_synth.dart';

const _mor = Color(0xFF764A72);

Uint8List _synth(String id) => synthesizeWav(id);

/// Uyku sesleri ve ninniler: cihazda üretilen beyaz gürültü, doğa sesleri ve
/// kamu malı ninni melodileri; zamanlayıcı ve ses düzeyi ile.
class SleepSoundsPage extends StatefulWidget {
  static const prefsKey = 'sleep_sounds_prefs_v1';
  final LoopPlayer Function()? playerFactory;
  final Future<Uint8List> Function(String id)? synth;
  const SleepSoundsPage({super.key, this.playerFactory, this.synth});

  @override
  State<SleepSoundsPage> createState() => _SleepSoundsPageState();
}

class _SleepSoundsPageState extends State<SleepSoundsPage> {
  late final LoopPlayer _player = (widget.playerFactory ?? AudioLoopPlayer.new)();
  final Map<String, Uint8List> _cache = {};
  String? _playing;
  String? _preparing;
  double _volume = 0.5;
  int _timerMinutes = 30; // 0 = sınırsız
  DateTime? _endsAt;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPrefs());
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(SleepSoundsPage.prefsKey);
    if (raw == null || !mounted) return;
    final parts = raw.split('|');
    final v = double.tryParse(parts.first);
    final m = parts.length > 1 ? int.tryParse(parts[1]) : null;
    setState(() {
      if (v != null && v >= 0.05 && v <= 1) _volume = v;
      if (m != null && const [0, 15, 30, 45, 60, 90].contains(m)) _timerMinutes = m;
    });
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(SleepSoundsPage.prefsKey, '${_volume.toStringAsFixed(2)}|$_timerMinutes');
  }

  @override
  void dispose() {
    _ticker?.cancel();
    unawaited(_player.stop().then((_) => _player.dispose()).catchError((_) {}));
    super.dispose();
  }

  Future<void> _toggle(SleepSound s) async {
    if (_playing == s.id) return _stop();
    setState(() => _preparing = s.id);
    try {
      final wav = _cache[s.id] ??= widget.synth != null
          ? await widget.synth!(s.id)
          : kIsWeb ? _synth(s.id) : await compute(_synth, s.id);
      if (!mounted) return;
      await _player.playLoop(s.id, wav, _volume);
      if (!mounted) return;
      setState(() {
        _playing = s.id;
        _preparing = null;
        _endsAt = _timerMinutes == 0 ? null : DateTime.now().add(Duration(minutes: _timerMinutes));
      });
      _startTicker();
    } catch (_) {
      if (!mounted) return;
      setState(() => _preparing = null);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Ses çalınamadı. Telefonun sessiz modda olmadığını kontrol edip tekrar deneyin.')));
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    if (!mounted || _playing == null) return;
    final end = _endsAt;
    if (end != null) {
      final left = end.difference(DateTime.now());
      if (left <= Duration.zero) {
        await _stop();
        return;
      }
      // Son 20 saniyede sesi yavaşça kıs.
      if (left < const Duration(seconds: 20)) {
        await _player.setVolume(_volume * left.inMilliseconds / 20000);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    _ticker = null;
    try {
      await _player.stop();
    } catch (_) {}
    if (mounted) setState(() { _playing = null; _endsAt = null; });
  }

  String _left() {
    final end = _endsAt;
    if (end == null) return 'Zamanlayıcı kapalı';
    final d = end.difference(DateTime.now());
    final m = d.inMinutes, s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} sonra kapanacak';
  }

  @override
  Widget build(BuildContext context) {
    final noises = sleepSounds.where((s) => !s.melody).toList();
    final melodies = sleepSounds.where((s) => s.melody).toList();
    final current = sleepSounds.where((s) => s.id == _playing).firstOrNull;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: [Color(0xFF3E3A6B), Color(0xFF764A72)])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(current == null ? 'Uyku sesleri 🌙' : '${current.emoji} ${current.title}',
              key: const Key('uyku_baslik'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(current == null
              ? 'Bir sese dokun; tekrar dokununca durur. Tüm sesler telefonda üretilir, internet gerekmez.'
              : _left(),
              key: const Key('uyku_kalan'),
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          if (current != null) Align(alignment: Alignment.centerRight, child: TextButton.icon(
            key: const Key('uyku_durdur'), onPressed: _stop,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.stop_circle_outlined), label: const Text('Durdur'))),
        ])),
      const SizedBox(height: 12),
      Row(children: [
        const Icon(Icons.volume_down_rounded, color: _mor),
        Expanded(child: Slider(key: const Key('uyku_ses'), value: _volume, min: 0.05, max: 1, divisions: 19,
          label: '%${(_volume * 100).round()}',
          onChanged: (v) {
            setState(() => _volume = v);
            if (_playing != null) unawaited(_player.setVolume(v));
          },
          onChangeEnd: (_) => unawaited(_savePrefs()))),
        const Icon(Icons.volume_up_rounded, color: _mor),
      ]),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final m in const [15, 30, 45, 60, 90, 0])
          ChoiceChip(key: Key('uyku_sure_$m'), label: Text(m == 0 ? 'Sınırsız' : '$m dk'),
            selected: _timerMinutes == m,
            onSelected: (_) {
              setState(() {
                _timerMinutes = m;
                if (_playing != null) _endsAt = m == 0 ? null : DateTime.now().add(Duration(minutes: m));
              });
              if (_playing != null) unawaited(_player.setVolume(_volume));
              unawaited(_savePrefs());
            }),
      ]),
      const SizedBox(height: 14),
      const Text('Gürültü ve doğa sesleri', style: TextStyle(fontWeight: FontWeight.w800, color: _mor, fontSize: 15.5)),
      const SizedBox(height: 6),
      ...noises.map(_tile),
      const SizedBox(height: 10),
      const Text('Ninniler (müzik kutusu)', style: TextStyle(fontWeight: FontWeight.w800, color: _mor, fontSize: 15.5)),
      const SizedBox(height: 6),
      ...melodies.map(_tile),
      const SizedBox(height: 12),
      Card(color: const Color(0xFFFFF4FA), child: const Padding(padding: EdgeInsets.all(12), child: Text(
        'Güvenli kullanım: Telefonu bebeğin yatağının içine koyma, en az 2 metre uzakta tut. Sesi kısık tut; '
        'bebeğin yanında konuşma sesinden yüksek olmamalı (yaklaşık 50 dB). Mümkünse zamanlayıcı kullan, '
        'bütün gece yüksek sesle çalma.',
        style: TextStyle(fontSize: 12.5)))),
      const Padding(padding: EdgeInsets.all(8), child: Text(
        'Sesler uygulama içinde matematiksel olarak üretilir. Brahms Ninnisi (1868) ve “Parla Parla Küçük Yıldız” '
        'ezgisi kamu malıdır; “Uyku melodisi” bu uygulama için bestelenmiştir.',
        style: TextStyle(fontSize: 11.5, color: Colors.black54))),
    ]);
  }

  Widget _tile(SleepSound s) {
    final playing = _playing == s.id;
    final preparing = _preparing == s.id;
    return Card(color: playing ? const Color(0xFFEDE4FF) : null, child: ListTile(
      key: Key('uyku_${s.id}'),
      leading: CircleAvatar(backgroundColor: const Color(0xFFFFE3F0),
          child: Text(s.emoji, style: const TextStyle(fontSize: 20))),
      title: Text(s.title),
      subtitle: Text(s.description),
      trailing: preparing
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, color: _mor, size: 34),
      onTap: preparing ? null : () => _toggle(s),
    ));
  }
}
