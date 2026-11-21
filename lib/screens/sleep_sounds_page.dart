import 'dart:async';
import '../i18n/text.dart';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/loop_player.dart';
import '../services/sound_synth.dart';

const _mor = Color(0xFF764A72);

Uint8List _synth(String id) => synthesizeWav(id);
Uint8List _synthList(List<String> ids) => synthesizeMelodyPlaylist(ids);

/// Ninnilerin tekrar biçimi.
enum LullabyRepeat { one, all, shuffle }

extension LullabyRepeatText on LullabyRepeat {
  String get label => switch (this) {
        LullabyRepeat.one => 'Aynısını tekrarla',
        LullabyRepeat.all => 'Hepsini sırayla',
        LullabyRepeat.shuffle => 'Karışık',
      };
  IconData get icon => switch (this) {
        LullabyRepeat.one => Icons.repeat_one_rounded,
        LullabyRepeat.all => Icons.repeat_rounded,
        LullabyRepeat.shuffle => Icons.shuffle_rounded,
      };
}

/// [first] ile başlayan çalma sırası. Karışıkta ilk ninni korunur, kalanı karıştırılır.
List<String> melodyOrder(String first, LullabyRepeat mode, {math.Random? random}) {
  final ids = melodyIds;
  if (mode == LullabyRepeat.one) return [first];
  final start = ids.indexOf(first);
  final rest = [...ids.skip(start + 1), ...ids.take(start)];
  if (mode == LullabyRepeat.shuffle) rest.shuffle(random ?? math.Random());
  return [first, ...rest];
}

/// Uyku sesleri ve ninniler: cihazda üretilen gürültü/doğa sesleri ile kamu
/// malı ninniler. Bir gürültü ve bir ninni aynı anda çalabilir; ikisi de
/// kesintisiz tekrar eder ve zamanlayıcıyla kapanır.
class SleepSoundsPage extends StatefulWidget {
  static const prefsKey = 'sleep_sounds_prefs_v2';
  final LoopPlayer Function()? playerFactory;
  final Future<Uint8List> Function(List<String> ids)? synth;
  const SleepSoundsPage({super.key, this.playerFactory, this.synth});

  @override
  State<SleepSoundsPage> createState() => _SleepSoundsPageState();
}

class _Layer {
  final LoopPlayer player;
  String? id; // çalan ses ya da ilk ninni
  List<String> order = const [];
  String? preparing;
  double volume;
  _Layer(this.player, this.volume);
}

class _SleepSoundsPageState extends State<SleepSoundsPage> {
  late final _Layer _noise = _Layer((widget.playerFactory ?? AudioLoopPlayer.new)(), 0.5);
  late final _Layer _music = _Layer((widget.playerFactory ?? AudioLoopPlayer.new)(), 0.6);
  final Map<String, Uint8List> _cache = {};
  LullabyRepeat _mode = LullabyRepeat.all;
  int _timerMinutes = 30; // 0 = sınırsız
  DateTime? _endsAt;
  Timer? _ticker;

  bool get _anyPlaying => _noise.id != null || _music.id != null;

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
    double? v(int i) {
      final x = i < parts.length ? double.tryParse(parts[i]) : null;
      return x != null && x >= 0.05 && x <= 1 ? x : null;
    }
    final m = parts.length > 2 ? int.tryParse(parts[2]) : null;
    final mode = parts.length > 3 ? LullabyRepeat.values.where((e) => e.name == parts[3]).firstOrNull : null;
    setState(() {
      _noise.volume = v(0) ?? _noise.volume;
      _music.volume = v(1) ?? _music.volume;
      if (m != null && const [0, 15, 30, 45, 60, 90].contains(m)) _timerMinutes = m;
      if (mode != null) _mode = mode;
    });
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(SleepSoundsPage.prefsKey,
        '${_noise.volume.toStringAsFixed(2)}|${_music.volume.toStringAsFixed(2)}|$_timerMinutes|${_mode.name}');
  }

  @override
  void dispose() {
    _ticker?.cancel();
    for (final l in [_noise, _music]) {
      unawaited(l.player.stop().then((_) => l.player.dispose()).catchError((_) {}));
    }
    super.dispose();
  }

  Future<Uint8List> _wavFor(List<String> ids) async {
    final key = ids.join(',');
    final cached = _cache[key];
    if (cached != null) return cached;
    final Uint8List wav;
    if (widget.synth != null) {
      wav = await widget.synth!(ids);
    } else if (ids.length == 1) {
      wav = kIsWeb ? await Future<Uint8List>.delayed(const Duration(milliseconds: 16), () => _synth(ids.single))
          : await compute(_synth, ids.single);
    } else {
      wav = kIsWeb ? await Future<Uint8List>.delayed(const Duration(milliseconds: 16), () => _synthList(ids))
          : await compute(_synthList, ids);
    }
    // Karışık sıralar her seferinde farklıdır; önbelleği şişirmesin.
    if (_mode != LullabyRepeat.shuffle || ids.length == 1) _cache[key] = wav;
    return wav;
  }

  Future<void> _toggle(SleepSound s) async {
    final layer = s.melody ? _music : _noise;
    if (layer.id == s.id) return _stopLayer(layer);
    final order = s.melody ? melodyOrder(s.id, _mode) : [s.id];
    setState(() => layer.preparing = s.id);
    try {
      final wav = await _wavFor(order);
      if (!mounted) return;
      await layer.player.playLoop(order.join('_'), wav, layer.volume).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      setState(() {
        layer
          ..id = s.id
          ..order = order
          ..preparing = null;
        // Zamanlayıcı ilk ses başlarken kurulur; ikinci katman mevcut süreyi korur.
        if (_endsAt == null && _timerMinutes != 0) {
          _endsAt = DateTime.now().add(Duration(minutes: _timerMinutes));
        }
      });
      _startTicker();
    } catch (_) {
      if (!mounted) return;
      setState(() => layer.preparing = null);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(content: Text('Ses çalınamadı. Telefonun sessiz modda olmadığını kontrol edip tekrar deneyin.')));
    }
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _tick() async {
    if (!mounted || !_anyPlaying) return;
    final end = _endsAt;
    if (end != null) {
      final left = end.difference(DateTime.now());
      if (left <= Duration.zero) {
        await _stopAll();
        return;
      }
      if (left < const Duration(seconds: 20)) {
        final k = left.inMilliseconds / 20000;
        for (final l in [_noise, _music]) {
          if (l.id != null) await l.player.setVolume(l.volume * k);
        }
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _stopLayer(_Layer l) async {
    try {
      await l.player.stop();
    } catch (_) {}
    if (!mounted) return;
    setState(() { l.id = null; l.order = const []; });
    if (!_anyPlaying) {
      _ticker?.cancel();
      _ticker = null;
      setState(() => _endsAt = null);
    }
  }

  Future<void> _stopAll() async {
    await _stopLayer(_noise);
    await _stopLayer(_music);
  }

  /// Tekrar biçimi değişince çalan ninniyi yeni sırayla baştan başlat.
  Future<void> _setMode(LullabyRepeat m) async {
    setState(() => _mode = m);
    unawaited(_savePrefs());
    final current = _music.id;
    if (current == null) return;
    final s = sleepSounds.firstWhere((x) => x.id == current);
    _music.id = null;
    await _toggle(s);
  }

  String _left() {
    final end = _endsAt;
    if (end == null) return 'Zamanlayıcı kapalı – sürekli tekrar eder';
    final d = end.difference(DateTime.now());
    final m = d.inMinutes, s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')} sonra kapanacak';
  }

  String _title(String id) => sleepSounds.firstWhere((s) => s.id == id).title;

  Widget _volumeRow(String label, _Layer l, Key key) => Row(children: [
        SizedBox(width: 64, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))),
        Expanded(child: SliderTheme(
          data: SliderTheme.of(context).copyWith(activeTrackColor: Colors.white, thumbColor: Colors.white,
              inactiveTrackColor: Colors.white24),
          child: Slider(key: key, value: l.volume, min: 0.05, max: 1, divisions: 19,
            onChanged: (v) {
              setState(() => l.volume = v);
              if (l.id != null) unawaited(l.player.setVolume(v));
            },
            onChangeEnd: (_) => unawaited(_savePrefs())))),
      ]);

  @override
  Widget build(BuildContext context) {
    final noises = sleepSounds.where((s) => !s.melody).toList();
    final melodies = sleepSounds.where((s) => s.melody).toList();
    final lines = <String>[
      if (_noise.id != null) '${sleepSounds.firstWhere((s) => s.id == _noise.id).emoji} ${_title(_noise.id!)}',
      if (_music.id != null) '🎵 ${_music.order.length > 1 ? '${_music.order.map(_title).join(' → ')} (${_mode.label.toLowerCase()})' : '${_title(_music.id!)} (tekrar)'}',
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: [Color(0xFF3E3A6B), Color(0xFF764A72)])),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_anyPlaying ? 'Şimdi çalıyor' : 'Uyku sesleri 🌙', key: const Key('uyku_baslik'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          if (!_anyPlaying) const Text(
              'Bir sese dokun; tekrar dokununca durur. Bir gürültü ile bir ninniyi aynı anda çalabilirsin. '
              'Sesler telefonda üretilir, internet gerekmez.',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          for (final l in lines) Text(l, style: const TextStyle(color: Colors.white, fontSize: 13.5)),
          if (_anyPlaying) Text(_left(), key: const Key('uyku_kalan'),
              style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
          const SizedBox(height: 4),
          _volumeRow('Gürültü', _noise, const Key('uyku_ses_gurultu')),
          _volumeRow('Ninni', _music, const Key('uyku_ses_ninni')),
          if (_anyPlaying) Align(alignment: Alignment.centerRight, child: TextButton.icon(
            key: const Key('uyku_durdur'), onPressed: _stopAll,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.stop_circle_outlined), label: const Text('Hepsini durdur'))),
        ])),
      const SizedBox(height: 12),
      const Text('Kapanma zamanlayıcısı', style: TextStyle(fontWeight: FontWeight.w700, color: _mor)),
      const SizedBox(height: 4),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final m in const [15, 30, 45, 60, 90, 0])
          ChoiceChip(key: Key('uyku_sure_$m'), label: Text(m == 0 ? 'Sınırsız' : '$m dk'),
            selected: _timerMinutes == m,
            onSelected: (_) {
              setState(() {
                _timerMinutes = m;
                if (_anyPlaying) _endsAt = m == 0 ? null : DateTime.now().add(Duration(minutes: m));
              });
              for (final l in [_noise, _music]) {
                if (l.id != null) unawaited(l.player.setVolume(l.volume));
              }
              unawaited(_savePrefs());
            }),
      ]),
      const SizedBox(height: 14),
      const Text('Gürültü ve doğa sesleri', style: TextStyle(fontWeight: FontWeight.w800, color: _mor, fontSize: 15.5)),
      const Text('Kesintisiz tekrar eder.', style: TextStyle(fontSize: 12, color: Colors.black54)),
      const SizedBox(height: 6),
      ...noises.map((s) => _tile(s, _noise)),
      const SizedBox(height: 10),
      const Text('Ninniler (müzik kutusu)', style: TextStyle(fontWeight: FontWeight.w800, color: _mor, fontSize: 15.5)),
      const SizedBox(height: 6),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final m in LullabyRepeat.values)
          ChoiceChip(key: Key('uyku_tekrar_${m.name}'), avatar: Icon(m.icon, size: 18),
              label: Text(m.label), selected: _mode == m, onSelected: (_) => _setMode(m)),
      ]),
      const SizedBox(height: 6),
      ...melodies.map((s) => _tile(s, _music)),
      const SizedBox(height: 12),
      Card(color: const Color(0xFFFFF4FA), child: const Padding(padding: EdgeInsets.all(12), child: Text(
        'Güvenli kullanım: Telefonu bebeğin yatağının içine koyma, en az 2 metre uzakta tut. Sesi kısık tut; '
        'bebeğin yanında konuşma sesinden yüksek olmamalı (yaklaşık 50 dB). Mümkünse zamanlayıcı kullan, '
        'bütün gece yüksek sesle çalma. Ekran kapansa da ses çalmaya devam eder.',
        style: TextStyle(fontSize: 12.5)))),
      const Padding(padding: EdgeInsets.all(8), child: Text(
        'Sesler uygulama içinde matematiksel olarak üretilir. Brahms Ninnisi (1868) ve “Parla Parla Küçük Yıldız” '
        'ezgisi kamu malıdır; “Uyku melodisi” bu uygulama için bestelenmiştir.',
        style: TextStyle(fontSize: 11.5, color: Colors.black54))),
    ]);
  }

  Widget _tile(SleepSound s, _Layer layer) {
    final current = layer.id == s.id;
    final inQueue = layer.id != null && layer.order.contains(s.id);
    final preparing = layer.preparing == s.id;
    return Card(color: inQueue ? const Color(0xFFEDE4FF) : null, child: ListTile(
      key: Key('uyku_${s.id}'),
      leading: CircleAvatar(backgroundColor: const Color(0xFFFFE3F0),
          child: Text(s.emoji, style: const TextStyle(fontSize: 20))),
      title: Text(s.title),
      subtitle: Text(s.description),
      trailing: preparing
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(current ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded, color: _mor, size: 34),
      onTap: preparing ? null : () => _toggle(s),
    ));
  }
}
