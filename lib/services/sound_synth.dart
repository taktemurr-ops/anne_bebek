import 'dart:math' as math;
import 'dart:typed_data';

/// Uygulama içinde matematiksel olarak üretilen uyku sesleri ve ninni
/// melodileri. Hiçbir kayıt ya da dış ses dosyası kullanılmaz; bu nedenle
/// telif sorunu yoktur. Melodiler telif süresi dolmuş (kamu malı) eserlerdir
/// ya da uygulamaya özgü bestedir.

const sampleRate = 22050;

class SleepSound {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final bool melody;
  const SleepSound(this.id, this.title, this.emoji, this.description, {this.melody = false});
}

const sleepSounds = <SleepSound>[
  SleepSound('white', 'Beyaz gürültü', '🌫️', 'Eşit yoğunlukta hışırtı; ani sesleri maskeler.'),
  SleepSound('pink', 'Pembe gürültü', '🌸', 'Beyaz gürültüden daha yumuşak, kulağı yormayan ton.'),
  SleepSound('brown', 'Derin uğultu', '🟤', 'Kalın, alçak tonlu uğultu; uçak kabini gibi.'),
  SleepSound('womb', 'Anne karnı ve kalp atışı', '🤰', 'Rahimdeki boğuk uğultu ve dakikada 70 kalp atışı.'),
  SleepSound('shush', 'Şşş sesi', '🤫', 'Ritmik “şşş”; ağlama krizlerinde sakinleştirmeye yardımcı.'),
  SleepSound('rain', 'Yağmur', '🌧️', 'Hafif yağmur hışırtısı ve damlalar.'),
  SleepSound('waves', 'Deniz dalgası', '🌊', 'Yavaşça gelip giden dalga sesi.'),
  SleepSound('fan', 'Vantilatör', '🌀', 'Sabit, yumuşak vantilatör uğultusu.'),
  SleepSound('brahms', 'Brahms Ninnisi', '🎼', 'J. Brahms, 1868 (kamu malı) – müzik kutusu.', melody: true),
  SleepSound('twinkle', 'Parla Parla Küçük Yıldız', '⭐', 'Geleneksel Fransız ezgisi, 18. yy (kamu malı).', melody: true),
  SleepSound('ninni', 'Uyku melodisi', '🌙', 'Bu uygulama için bestelenmiş sakin melodi.', melody: true),
];

/// [id] için döngüye uygun (başı ve sonu dikişsiz) mono 16 bit WAV üretir.
Uint8List synthesizeWav(String id, {int seconds = 12, int seed = 7}) {
  final samples = switch (id) {
    'brahms' => _melody(_brahms, bpm: 66),
    'twinkle' => _melody(_twinkle, bpm: 76),
    'ninni' => _melody(_ninni, bpm: 60),
    _ => _noiseLoop(id, seconds, seed),
  };
  return encodeWav(samples);
}

/// Melodi kimlikleri; sıralı / karışık çalma için.
List<String> get melodyIds => [for (final s in sleepSounds) if (s.melody) s.id];

/// Birden fazla ninniyi aralarında 2 sn sessizlikle tek döngüde birleştirir.
Uint8List synthesizeMelodyPlaylist(List<String> ids) {
  final parts = <Float64List>[];
  for (final id in ids) {
    final m = switch (id) {
      'brahms' => _melody(_brahms, bpm: 66),
      'twinkle' => _melody(_twinkle, bpm: 76),
      'ninni' => _melody(_ninni, bpm: 60),
      _ => throw ArgumentError.value(id, 'id', 'melodi değil'),
    };
    parts..add(m)..add(Float64List(2 * sampleRate));
  }
  final out = Float64List(parts.fold<int>(0, (n, p) => n + p.length));
  var o = 0;
  for (final p in parts) {
    out.setAll(o, p);
    o += p.length;
  }
  return encodeWav(out);
}

// ---------------- Gürültüler ----------------

Float64List _noiseLoop(String id, int seconds, int seed) {
  final n = seconds * sampleRate;
  final fade = sampleRate; // 1 sn çapraz geçiş
  final raw = _noise(id, n + fade, seed);
  // Sonun son 1 saniyesini başa karıştırarak dikişsiz döngü elde et.
  final out = Float64List(n);
  for (var i = 0; i < n; i++) {
    out[i] = raw[i];
  }
  for (var i = 0; i < fade; i++) {
    final w = i / fade; // 0 → 1
    out[i] = raw[n + i] * (1 - w) + raw[i] * w;
  }
  _normalize(out, id == 'womb' ? 0.55 : 0.45);
  return out;
}

Float64List _noise(String id, int n, int seed) {
  final r = math.Random(seed);
  double white() => r.nextDouble() * 2 - 1;
  final out = Float64List(n);
  // Pembe gürültü filtresi (Paul Kellet).
  var b0 = 0.0, b1 = 0.0, b2 = 0.0, b3 = 0.0, b4 = 0.0, b5 = 0.0, b6 = 0.0;
  double pink() {
    final w = white();
    b0 = 0.99886 * b0 + w * 0.0555179;
    b1 = 0.99332 * b1 + w * 0.0750759;
    b2 = 0.96900 * b2 + w * 0.1538520;
    b3 = 0.86650 * b3 + w * 0.3104856;
    b4 = 0.55000 * b4 + w * 0.5329522;
    b5 = -0.7616 * b5 - w * 0.0168980;
    final p = b0 + b1 + b2 + b3 + b4 + b5 + b6 + w * 0.5362;
    b6 = w * 0.115926;
    return p * 0.11;
  }
  var brownState = 0.0;
  double brown() {
    brownState = (brownState + 0.02 * white()) / 1.02;
    return brownState * 3.5;
  }
  var lp = 0.0, hpPrev = 0.0, hpOut = 0.0;
  for (var i = 0; i < n; i++) {
    final t = i / sampleRate;
    switch (id) {
      case 'white':
        out[i] = white();
      case 'pink':
        out[i] = pink();
      case 'brown':
        out[i] = brown();
      case 'fan':
        lp += 0.08 * (white() - lp);
        out[i] = lp + 0.02 * math.sin(2 * math.pi * 100 * t);
      case 'waves':
        // 6 saniyelik dalga döngüsü (12 sn'ye tam bölünür).
        final s = math.sin(math.pi * t / 6);
        out[i] = brown() * (0.25 + 0.75 * s * s) + pink() * 0.25 * s * s;
      case 'shush':
        // Yüksek geçiren filtre ile "ş" rengi, 1,5 sn'lik ritim.
        final w = white();
        hpOut = 0.92 * (hpOut + w - hpPrev);
        hpPrev = w;
        final phase = (t % 1.5) / 1.5;
        final env = phase < 0.75 ? math.sin(math.pi * phase / 0.75) : 0.0;
        out[i] = hpOut * (0.15 + 0.85 * env);
      case 'rain':
        out[i] = pink() * 0.8;
      case 'womb':
        lp += 0.03 * (brown() - lp);
        out[i] = lp * 2.2 + _heartbeat(t) * 0.9;
      default:
        out[i] = pink();
    }
  }
  if (id == 'rain') {
    // Rastgele damlalar: kısa, sönümlenen tıkırtılar.
    final drops = (n / sampleRate * 18).round();
    for (var d = 0; d < drops; d++) {
      final start = r.nextInt(n);
      final freq = 1800 + r.nextDouble() * 2500;
      final amp = 0.15 + r.nextDouble() * 0.35;
      final len = (sampleRate * 0.03).round();
      for (var k = 0; k < len && start + k < n; k++) {
        out[start + k] += amp * math.exp(-k / (len / 5)) * math.sin(2 * math.pi * freq * k / sampleRate);
      }
    }
  }
  return out;
}

/// Dakikada 70 atım: "güm-güm" çift vuruş.
double _heartbeat(double t) {
  const period = 60 / 70;
  final p = t % period;
  double thump(double start, double amp) {
    final x = p - start;
    if (x < 0 || x > 0.15) return 0;
    return amp * math.exp(-x * 28) * math.sin(2 * math.pi * 48 * x);
  }
  return thump(0, 1.0) + thump(0.28, 0.7);
}

// ---------------- Melodiler ----------------

/// (MIDI nota, vuruş). 0 = sus.
const _brahms = <(int, double)>[
  (64, .5), (64, .5), (67, 2), (64, .5), (64, .5), (67, 2),
  (64, .5), (67, .5), (72, 1), (71, 1.5), (69, .5), (69, 1), (67, 2),
  (62, .5), (64, .5), (65, 1), (62, 1), (62, .5), (64, .5), (65, 2),
  (62, .5), (65, .5), (71, .5), (69, .5), (67, 1), (71, 1), (72, 2),
  (60, .5), (60, .5), (72, 2), (69, .5), (65, .5), (67, 2),
  (64, .5), (60, .5), (65, 1), (67, 1), (69, 1), (67, 2),
  (60, .5), (60, .5), (72, 2), (69, .5), (65, .5), (67, 2),
  (64, .5), (60, .5), (65, 1), (64, 1), (62, 1), (60, 3), (0, 2),
];

const _twinkle = <(int, double)>[
  (60, 1), (60, 1), (67, 1), (67, 1), (69, 1), (69, 1), (67, 2),
  (65, 1), (65, 1), (64, 1), (64, 1), (62, 1), (62, 1), (60, 2),
  (67, 1), (67, 1), (65, 1), (65, 1), (64, 1), (64, 1), (62, 2),
  (67, 1), (67, 1), (65, 1), (65, 1), (64, 1), (64, 1), (62, 2),
  (60, 1), (60, 1), (67, 1), (67, 1), (69, 1), (69, 1), (67, 2),
  (65, 1), (65, 1), (64, 1), (64, 1), (62, 1), (62, 1), (60, 2), (0, 2),
];

/// Uygulamaya özgü, pentatonik sakin ezgi.
const _ninni = <(int, double)>[
  (67, 1), (64, 1), (62, 2), (64, 1), (67, 1), (69, 2),
  (67, 1), (64, 1), (62, 1), (60, 1), (62, 3), (0, 1),
  (64, 1), (67, 1), (69, 2), (72, 1), (69, 1), (67, 2),
  (64, 1), (62, 1), (60, 1), (62, 1), (60, 3), (0, 1),
];

Float64List _melody(List<(int, double)> notes, {required double bpm}) {
  final beat = 60 / bpm;
  final total = notes.fold<double>(0, (s, n) => s + n.$2) * beat;
  final n = (total * sampleRate).round();
  final out = Float64List(n);
  var cursor = 0.0;
  for (final (midi, beats) in notes) {
    final start = (cursor * sampleRate).round();
    cursor += beats * beat;
    if (midi == 0) continue;
    final f = 440 * math.pow(2, (midi - 69) / 12);
    // Müzik kutusu tınısı: temel + oktav, üstel sönüm; nota bitince 1,2 sn kuyruk.
    final len = math.min(n - start, ((beats * beat + 1.2) * sampleRate).round());
    for (var k = 0; k < len; k++) {
      final t = k / sampleRate;
      final attack = math.min(1.0, t / 0.008);
      final env = attack * math.exp(-t * 2.2);
      out[start + k] += env * (math.sin(2 * math.pi * f * t) + 0.3 * math.sin(4 * math.pi * f * t)
          + 0.08 * math.sin(6 * math.pi * f * t));
    }
  }
  // Son 1,5 saniyeyi yumuşakça kıs; döngü başında tık olmasın.
  final fade = math.min(n, (1.5 * sampleRate).round());
  for (var i = 0; i < fade; i++) {
    out[n - 1 - i] *= i / fade;
  }
  _normalize(out, 0.5);
  return out;
}

// ---------------- WAV ----------------

void _normalize(Float64List s, double peak) {
  var max = 0.0;
  for (final v in s) {
    final a = v.abs();
    if (a > max) max = a;
  }
  if (max == 0) return;
  final k = peak / max;
  for (var i = 0; i < s.length; i++) {
    s[i] *= k;
  }
}

Uint8List encodeWav(Float64List samples) {
  final dataLen = samples.length * 2;
  final b = ByteData(44 + dataLen);
  void str(int o, String s) {
    for (var i = 0; i < s.length; i++) {
      b.setUint8(o + i, s.codeUnitAt(i));
    }
  }
  str(0, 'RIFF');
  b.setUint32(4, 36 + dataLen, Endian.little);
  str(8, 'WAVE');
  str(12, 'fmt ');
  b.setUint32(16, 16, Endian.little);
  b.setUint16(20, 1, Endian.little); // PCM
  b.setUint16(22, 1, Endian.little); // mono
  b.setUint32(24, sampleRate, Endian.little);
  b.setUint32(28, sampleRate * 2, Endian.little);
  b.setUint16(32, 2, Endian.little);
  b.setUint16(34, 16, Endian.little);
  str(36, 'data');
  b.setUint32(40, dataLen, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    final v = (samples[i].clamp(-1.0, 1.0) * 32767).round();
    b.setInt16(44 + i * 2, v, Endian.little);
  }
  return b.buffer.asUint8List();
}
