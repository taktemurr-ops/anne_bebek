import 'dart:typed_data';

import 'package:anne_bebek/screens/sleep_sounds_page.dart';
import 'package:anne_bebek/services/loop_player.dart';
import 'package:anne_bebek/services/sound_synth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePlayer implements LoopPlayer {
  final calls = <String>[];
  double volume = 0;
  @override
  Future<void> playLoop(String id, Uint8List wav, double v) async { calls.add('play:$id:${wav.length}'); volume = v; }
  @override
  Future<void> setVolume(double v) async { volume = v; }
  @override
  Future<void> stop() async { calls.add('stop'); }
  @override
  Future<void> dispose() async { calls.add('dispose'); }
}

int _sample(Uint8List wav, int i) => ByteData.sublistView(wav).getInt16(44 + i * 2, Endian.little);

void main() {
  group('ses üretimi', () {
    test('her ses geçerli WAV üretir', () {
      for (final s in sleepSounds) {
        final wav = synthesizeWav(s.id, seconds: 4);
        expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF', reason: s.id);
        expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE', reason: s.id);
        final data = ByteData.sublistView(wav);
        expect(data.getUint32(24, Endian.little), sampleRate);
        expect(data.getUint32(40, Endian.little), wav.length - 44);
        var peak = 0;
        for (var i = 0; i < (wav.length - 44) ~/ 2; i += 97) {
          peak = peak < _sample(wav, i).abs() ? _sample(wav, i).abs() : peak;
        }
        expect(peak, greaterThan(1000), reason: '${s.id} sessiz olmamalı');
        expect(peak, lessThan(32767), reason: '${s.id} kırpılmamalı');
      }
    });

    test('gürültü döngüsü dikişsizdir ve aynı tohumla aynıdır', () {
      final a = synthesizeWav('pink', seconds: 4);
      expect(synthesizeWav('pink', seconds: 4), a);
      final frames = (a.length - 44) ~/ 2;
      var maxStep = 0;
      for (var i = 1; i < frames; i++) {
        final d = (_sample(a, i) - _sample(a, i - 1)).abs();
        if (d > maxStep) maxStep = d;
      }
      final jump = (_sample(a, frames - 1) - _sample(a, 0)).abs();
      expect(jump, lessThanOrEqualTo(maxStep), reason: 'döngü geçişi, sesin kendi içindeki geçişlerinden sert olmamalı');
    });

    test('melodiler sessizlikle biter (döngüde tık yok)', () {
      for (final id in ['brahms', 'twinkle', 'ninni']) {
        final w = synthesizeWav(id);
        final frames = (w.length - 44) ~/ 2;
        expect(_sample(w, frames - 1).abs(), lessThan(50), reason: id);
        expect(frames / sampleRate, greaterThan(20), reason: id);
      }
    });
  });

  testWidgets('ses çalınır, ikinci dokunuşta durur; zamanlayıcı ve ses düzeyi kaydedilir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final player = FakePlayer();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SleepSoundsPage(
      playerFactory: () => player,
      synth: (id) async => synthesizeWav(id, seconds: 1)))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uyku_sure_15')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('uyku_womb')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(player.calls.last, startsWith('play:womb:'));
    expect(find.textContaining('sonra kapanacak'), findsOneWidget);
    expect(find.text('🤰 Anne karnı ve kalp atışı'), findsOneWidget);
    await tester.tap(find.byKey(const Key('uyku_womb')));
    await tester.pump();
    expect(player.calls.last, 'stop');
    expect(find.text('Uyku sesleri 🌙'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SleepSoundsPage.prefsKey), '0.50|15');
  });
}
