import 'dart:math';
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

  test('çalma sırası: tekrar, sırayla, karışık', () {
    expect(melodyOrder('twinkle', LullabyRepeat.one), ['twinkle']);
    expect(melodyOrder('twinkle', LullabyRepeat.all), ['twinkle', 'ninni', 'brahms']);
    final shuffled = melodyOrder('ninni', LullabyRepeat.shuffle, random: Random(1));
    expect(shuffled.first, 'ninni');
    expect(shuffled.toSet(), {'brahms', 'twinkle', 'ninni'});
  });

  test('ninni listesi tek döngüde birleşir', () {
    final one = synthesizeWav('ninni');
    final list = synthesizeMelodyPlaylist(['ninni', 'brahms']);
    expect(list.length, greaterThan(one.length * 2));
    expect(() => synthesizeMelodyPlaylist(['rain']), throwsArgumentError);
  });

  testWidgets('gürültü ve ninni aynı anda çalar; tekrar biçimi değişince sıra yenilenir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final players = <FakePlayer>[];
    final synthCalls = <String>[];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SleepSoundsPage(
      playerFactory: () { final p = FakePlayer(); players.add(p); return p; },
      synth: (ids) async { synthCalls.add(ids.join(',')); return synthesizeWav('white', seconds: 1); }))));
    await tester.pumpAndSettle();
    expect(players, hasLength(2));
    await tester.tap(find.byKey(const Key('uyku_sure_15')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('uyku_womb')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.scrollUntilVisible(find.byKey(const Key('uyku_brahms')), 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('uyku_brahms')));
    await tester.pump(const Duration(milliseconds: 100));
    final noise = players[0], music = players[1];
    expect(noise.calls.last, startsWith('play:womb:'));
    expect(music.calls.last, startsWith('play:brahms_twinkle_ninni:'), reason: 'varsayılan: hepsini sırayla');
    expect(noise.calls.where((c) => c == 'stop'), isEmpty, reason: 'ninni başlayınca gürültü durmamalı');

    await tester.ensureVisible(find.byKey(const Key('uyku_tekrar_one')));
    await tester.tap(find.byKey(const Key('uyku_tekrar_one')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(music.calls.last, startsWith('play:brahms:'));
    expect(synthCalls, containsAll(['womb', 'brahms,twinkle,ninni', 'brahms']));

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 3000));
    await tester.pump();
    expect(find.text('Şimdi çalıyor'), findsOneWidget);
    expect(find.textContaining('sonra kapanacak'), findsOneWidget);
    await tester.tap(find.byKey(const Key('uyku_durdur')));
    await tester.pump();
    expect(noise.calls.last, 'stop');
    expect(music.calls.last, 'stop');
    expect(find.text('Uyku sesleri 🌙'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SleepSoundsPage.prefsKey), '0.50|0.60|15|one');
  });
}
