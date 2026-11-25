import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

/// Ses çalma soyutlaması; testlerde sahte uygulamayla değiştirilir.
abstract class LoopPlayer {
  Future<void> playLoop(String id, Uint8List wav, double volume);
  Future<void> setVolume(double volume);
  Future<void> stop();
  Future<void> dispose();
}

class AudioLoopPlayer implements LoopPlayer {
  final AudioPlayer _player = AudioPlayer();
  bool _contextSet = false;

  /// Ekran kapanınca da çalsın; gürültü ve ninni aynı anda karışabilsin.
  Future<void> _ensureContext() async {
    if (_contextSet || kIsWeb) return;
    _contextSet = true;
    try {
      await _player.setAudioContext(AudioContext(
        android: const AudioContextAndroid(
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
      ));
    } catch (_) {
      // Bazı platformlarda desteklenmeyebilir; varsayılan ayarla çalmaya devam et.
    }
  }

  @override
  Future<void> playLoop(String id, Uint8List wav, double volume) async {
    await _ensureContext();
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(volume);
    final Source source;
    if (kIsWeb) {
      source = UrlSource('data:audio/wav;base64,${base64Encode(wav)}');
    } else {
      // iOS ve Android'de dosyadan çalmak en güvenilir yoldur.
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/uyku_$id.wav');
      if (!await file.exists() || await file.length() != wav.length) {
        await file.writeAsBytes(wav, flush: true);
      }
      source = DeviceFileSource(file.path);
    }
    await _player.play(source, volume: volume);
  }

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}
