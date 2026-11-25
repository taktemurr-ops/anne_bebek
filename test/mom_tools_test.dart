import 'dart:convert';
import 'package:anne_bebek/data/baby_names.dart';
import 'package:anne_bebek/screens/mom_tools_page.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/mom_tools.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final t0 = DateTime(2026, 11, 21, 10);

  group('kasılma özeti', () {
    List<Contraction> series(int count, Duration every, Duration lasting) => [
      for (var i = 0; i < count; i++) Contraction(t0.add(every * i), t0.add(every * i + lasting)),
    ];

    test('5 dk arayla 1 dk süren kasılmalar 1 saat sürünce 5-1-1 uyarısı verir', () {
      final items = series(13, const Duration(minutes: 5), const Duration(seconds: 65));
      final now = items.last.end!.add(const Duration(minutes: 1));
      final s = summarizeContractions(items, now);
      expect(s.fiveOneOne, isTrue);
      expect(s.averageInterval, const Duration(minutes: 5));
      expect(s.averageDuration, const Duration(seconds: 65));
    });

    test('kısa süreli ya da seyrek kasılmalar uyarı vermez', () {
      final short = series(13, const Duration(minutes: 5), const Duration(seconds: 40));
      expect(summarizeContractions(short, short.last.end!).fiveOneOne, isFalse);
      final sparse = series(8, const Duration(minutes: 9), const Duration(seconds: 70));
      expect(summarizeContractions(sparse, sparse.last.end!).fiveOneOne, isFalse);
      final tooRecent = series(5, const Duration(minutes: 4), const Duration(seconds: 70));
      expect(summarizeContractions(tooRecent, tooRecent.last.end!).fiveOneOne, isFalse,
          reason: 'bir saat dolmadan uyarı verilmez');
    });

    test('kayıt bozuksa ya da bitiş başlangıçtan önceyse yok sayılır', () {
      expect(Contraction.fromJson({'start': 'x'}), isNull);
      expect(Contraction.fromJson({'start': t0.toIso8601String(),
          'end': t0.subtract(const Duration(seconds: 1)).toIso8601String()}), isNull);
    });
  });

  group('tekme sayacı', () {
    test('10 harekete ulaşınca tamam, 2 saati geçince uyarı', () {
      var s = KickSession(t0);
      for (var i = 0; i < 9; i++) { s = s.kick(); }
      expect(kickStatus(s, t0.add(const Duration(minutes: 30))), KickStatus.counting);
      expect(kickStatus(s, t0.add(const Duration(hours: 2))), KickStatus.overdue);
      expect(kickStatus(s.kick(), t0.add(const Duration(hours: 3))), KickStatus.reached);
    });
  });

  group('emzirme zamanlayıcısı', () {
    test('taraf değiştirince süreler ayrı birikir ve günlük kaydı oluşur', () {
      var n = const NursingTimer().toggle('Sol', t0);
      n = n.toggle('Sağ', t0.add(const Duration(minutes: 8)));
      final end = t0.add(const Duration(minutes: 13, seconds: 30));
      expect(n.secondsFor('Sol', end), 480);
      expect(n.secondsFor('Sağ', end), 330);
      final e = n.toJournalEntry(end)!;
      expect(e['type'], 'Emzirme');
      expect(e['amount'], 14);
      expect(e['side'], 'Her ikisi');
      expect(e['date'], t0.toIso8601String());
      expect(suggestNextSide([e]), 'Sağ');
    });

    test('aynı tarafa dokunmak duraklatır; 30 sn altı kaydedilmez', () {
      var n = const NursingTimer().toggle('Sağ', t0);
      n = n.toggle('Sağ', t0.add(const Duration(seconds: 20)));
      expect(n.running, isFalse);
      expect(n.secondsFor('Sağ', t0.add(const Duration(hours: 1))), 20);
      expect(n.toJournalEntry(t0.add(const Duration(hours: 1))), isNull);
    });

    test('elle girilen kayıtta karşı taraf önerilir', () {
      expect(suggestNextSide([
        {'type': 'Emzirme', 'date': t0.toIso8601String(), 'side': 'Sol'},
        {'type': 'Emzirme', 'date': t0.subtract(const Duration(hours: 3)).toIso8601String(), 'side': 'Sağ'},
      ]), 'Sağ');
      expect(suggestNextSide([{'type': 'Mama', 'date': t0.toIso8601String()}]), isNull);
    });

    test('veri kodla-çöz döngüsünde korunur, bozuk veri boş döner', () {
      final d = MomToolsData([Contraction(t0)], [KickSession(t0, count: 3)],
          const NursingTimer().toggle('Sol', t0));
      final back = MomToolsData.decode(d.encode());
      expect(back.contractions.single.end, isNull);
      expect(back.kicks.single.count, 3);
      expect(back.nursing.activeSide, 'Sol');
      expect(MomToolsData.decode('{bozuk').contractions, isEmpty);
    });
  });

  group('isimler', () {
    test('cinsiyet filtresi her ikisi isimlerini de içerir; Türkçe arama', () {
      final girls = searchBabyNames('', gender: 'K');
      expect(girls.any((n) => n.gender == 'E'), isFalse);
      expect(girls.map((n) => n.name), contains('Deniz'));
      expect(searchBabyNames('zumra').map((n) => n.name), contains('Zümra'));
      expect(searchBabyNames('yağmur').length, greaterThanOrEqualTo(2), reason: 'isim + anlam');
      final names = babyNames.map((n) => n.name).toList();
      expect(names.toSet().length, names.length, reason: 'tekrar eden isim yok');
      expect(babyNames.length, greaterThanOrEqualTo(600));
      expect(babyNames.where((n) => n.gender == 'K').length, greaterThanOrEqualTo(250));
      expect(babyNames.where((n) => n.gender == 'E').length, greaterThanOrEqualTo(250));
      for (final n in babyNames) {
        expect(n.meaning.trim(), isNotEmpty, reason: n.name);
        expect(n.origin.trim(), isNotEmpty, reason: n.name);
      }
      final c = searchBabyNames('', initial: 'Ç');
      expect(c, isNotEmpty);
      expect(c.every((n) => n.name.startsWith('Ç')), isTrue);
      expect(searchBabyNames('', initial: 'C').any((n) => n.name.startsWith('Ç')), isFalse);
    });
  });

  test('yeni anahtarlar güvenli depoda ve yedekte', () {
    expect(SecureHealthStore.isAllowed(MomToolsPage.storageKey), isTrue);
    expect(BackupService.keys, containsAll([MomToolsPage.storageKey, MomToolsPage.nameFavoritesKey]));
  });

  group('ekran', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      installSecureStorageMock();
    });

    Future<void> pump(WidgetTester tester, int tab, DateTime Function() clock) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: MomToolsPage(initialTab: tab, clock: clock))));
      await tester.pumpAndSettle();
    }

    testWidgets('kasılma başlat/bitir kaydı güvenli depoya yazar', (tester) async {
      var now = t0;
      await pump(tester, 0, () => now);
      await tester.tap(find.byKey(const Key('kasilma_dugme')));
      await tester.pump();
      now = now.add(const Duration(seconds: 70));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('01:10'), findsOneWidget);
      await tester.tap(find.byKey(const Key('kasilma_dugme')));
      await tester.pumpAndSettle();
      final data = MomToolsData.decode(await SecureHealthStore.read(MomToolsPage.storageKey));
      expect(data.contractions.single.duration, const Duration(seconds: 70));
    });

    testWidgets('tekme sayacı 10 harekette oturumu kapatır', (tester) async {
      var now = t0;
      await pump(tester, 1, () => now);
      await tester.tap(find.byKey(const Key('tekme_basla')));
      await tester.pump();
      for (var i = 0; i < 10; i++) {
        now = now.add(const Duration(minutes: 2));
        await tester.tap(find.byKey(const Key('tekme_dokun')));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(find.textContaining('10 harekete 20:00 içinde ulaştın'), findsOneWidget);
      final data = MomToolsData.decode(await SecureHealthStore.read(MomToolsPage.storageKey));
      expect(data.kicks.single.count, 10);
      expect(data.kicks.single.end, isNotNull);
    });

    testWidgets('emzirme kaydı beslenme günlüğüne eklenir', (tester) async {
      var now = t0;
      await SecureHealthStore.write(MomToolsPage.feedingKey,
          jsonEncode([{'type': 'Emzirme', 'date': t0.subtract(const Duration(hours: 3)).toIso8601String(), 'side': 'Sol', 'amount': 10}]));
      await pump(tester, 2, () => now);
      expect(find.text('Sıradaki önerilen taraf: Sağ'), findsOneWidget);
      await tester.tap(find.byKey(const Key('emzirme_sag')));
      await tester.pump();
      now = now.add(const Duration(minutes: 6));
      await tester.tap(find.byKey(const Key('emzirme_sol')));
      await tester.pump();
      now = now.add(const Duration(minutes: 4));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Toplam 10:00'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('emzirme_kaydet')));
      await tester.tap(find.byKey(const Key('emzirme_kaydet')));
      await tester.pumpAndSettle();
      final journal = jsonDecode((await SecureHealthStore.read(MomToolsPage.feedingKey))!) as List;
      expect(journal, hasLength(2));
      expect(journal.first['amount'], 10);
      expect(journal.first['side'], 'Her ikisi');
      expect(find.textContaining('Beslenme günlüğüne eklendi'), findsOneWidget);
    });

    testWidgets('isim favorisi kalıcıdır', (tester) async {
      await pump(tester, 3, DateTime.now);
      await tester.enterText(find.byKey(const Key('isim_ara')), 'zeynep');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('isim_fav_Zeynep')));
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      expect(jsonDecode(prefs.getString(MomToolsPage.nameFavoritesKey)!), ['Zeynep']);
      expect(find.text('Favoriler (1)'), findsOneWidget);
    });
  });
}
