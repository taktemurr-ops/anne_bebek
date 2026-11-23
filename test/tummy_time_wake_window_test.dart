import 'package:anne_bebek/screens/tummy_time_page.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/last_event.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:anne_bebek/services/tracking_report.dart';
import 'package:anne_bebek/services/tummy_time.dart';
import 'package:anne_bebek/services/turkey_vaccine_schedule.dart';
import 'package:anne_bebek/services/wake_window.dart';
import 'package:anne_bebek/sleep_journal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final t0 = DateTime(2026, 11, 23, 14, 0);

  group('karın üstü zamanı', () {
    test('başlat/durdur seans kaydeder, kısa seans ve uzun unutma sınırlanır', () {
      var d = const TummyTimeData([]).start(t0);
      expect(d.runningSince, t0);
      final stopped = d.stop(t0.add(const Duration(minutes: 6, seconds: 20)));
      expect(stopped.runningSince, isNull);
      expect(stopped.sessions.single.minutes, 6);
      expect(d.stop(t0.add(const Duration(seconds: 40))).sessions, isEmpty);
      expect(d.stop(t0.add(const Duration(hours: 5))).sessions.single.minutes, 120);
    });

    test('günlük toplam, son 7 gün ve kodla-çöz', () {
      final d = TummyTimeData([
        TummySession(t0, 10),
        TummySession(t0.subtract(const Duration(hours: 3)), 5),
        TummySession(t0.subtract(const Duration(days: 1)), 20),
        TummySession(t0.subtract(const Duration(days: 9)), 30),
      ], t0);
      expect(d.minutesOn(t0), 15);
      final week = d.lastWeek(t0);
      expect(week.length, 7);
      expect(week.last.minutes, 15);
      expect(week[5].minutes, 20);
      final back = TummyTimeData.decode(d.encode());
      expect(back.sessions.length, 4);
      expect(back.runningSince, t0);
      expect(TummyTimeData.decode('{bozuk').sessions, isEmpty);
      expect(TummyTimeData.decode('{"sessions":[{"start":"x","minutes":5},{"start":"2026-11-01T10:00:00.000","minutes":999}]}').sessions, isEmpty);
    });

    test('yaşa göre hedef', () {
      expect(tummyGoalMinutes(0), 15);
      expect(tummyGoalMinutes(3), 30);
      expect(tummyGoalMinutes(null), 30);
      expect(tummyGoalMinutes(12), isNull);
    });

    test('güvenli depo, yedek ve takip raporunda', () {
      expect(SecureHealthStore.isAllowed(TummyTimePage.storageKey), isTrue);
      expect(BackupService.keys, contains(TummyTimePage.storageKey));
      expect(trackerDefs.map((e) => e.key), contains(TummyTimePage.storageKey));
    });
  });

  group('uyanıklık penceresi', () {
    test('aralıklar yaşla birlikte uzar', () {
      var prev = 0;
      for (final m in [0, 2, 4, 6, 9, 12, 18, 30]) {
        final w = wakeWindowForAge(m);
        expect(w.maxMinutes, greaterThan(w.minMinutes));
        expect(w.minMinutes, greaterThanOrEqualTo(prev));
        prev = w.minMinutes;
      }
    });

    test('son uyanışa göre durum', () {
      final birth = DateTime(2026, 5, 1); // 6 aylık: 120–180 dk
      final records = [
        {'start': DateTime(2026, 11, 23, 10).toIso8601String(), 'end': DateTime(2026, 11, 23, 11).toIso8601String()},
        {'start': DateTime(2026, 11, 23, 6).toIso8601String(), 'end': DateTime(2026, 11, 23, 7).toIso8601String()},
      ];
      expect(nextNapSuggestion(records, birth, DateTime(2026, 11, 23, 12))!.status, WakeStatus.early);
      final mid = nextNapSuggestion(records, birth, DateTime(2026, 11, 23, 13, 30))!;
      expect(mid.status, WakeStatus.inWindow);
      expect(mid.lastWake, DateTime(2026, 11, 23, 11));
      expect(mid.from, DateTime(2026, 11, 23, 13));
      expect(mid.to, DateTime(2026, 11, 23, 14));
      expect(nextNapSuggestion(records, birth, DateTime(2026, 11, 23, 15))!.status, WakeStatus.late);
      expect(nextNapSuggestion(records, birth, DateTime(2026, 11, 24, 8)), isNull);
      expect(nextNapSuggestion(const [], birth, t0), isNull);
    });
  });

  testWidgets('karın üstü zamanlayıcısı kaydeder', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    var now = t0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: TummyTimePage(
        birth: DateTime(2026, 9, 1), clock: () => now))));
    await tester.pumpAndSettle();
    expect(find.textContaining('0 / 30 dakika'), findsOneWidget);
    await tester.tap(find.byKey(const Key('karin_dugme')));
    await tester.pump();
    now = t0.add(const Duration(minutes: 8));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('karin_dugme')));
    await tester.pumpAndSettle();
    expect(find.textContaining('8 / 30 dakika'), findsOneWidget);
    final saved = TummyTimeData.decode(await SecureHealthStore.read(TummyTimePage.storageKey));
    expect(saved.sessions.single.minutes, 8);
    expect(saved.runningSince, isNull);
  });

  testWidgets('uyku günlüğünde uyanıklık penceresi kartı', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    final now = DateTime.now();
    final end = now.subtract(const Duration(minutes: 30));
    await SecureHealthStore.write(sleepJournalKey,
        '[{"start":"${end.subtract(const Duration(hours: 1)).toIso8601String()}","end":"${end.toIso8601String()}"}]');
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SleepJournalPage(
        birth: DateTime(now.year - 1, now.month, 1)))));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('uyaniklik_penceresi')), findsOneWidget);
    expect(find.textContaining('Sıradaki uyku için önerilen aralık'), findsOneWidget);
  });

  testWidgets('uyku günlüğünde Uyudu/Uyandı canlı zamanlayıcı kayıt oluşturur', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    var now = DateTime(2026, 11, 20, 13);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SleepJournalPage(clock: () => now))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('uyku_canli_dugme')));
    await tester.pump();
    expect(decodeSleepRunning(await SecureHealthStore.read(sleepRunningKey)), contains(sleepJournalKey));
    now = now.add(const Duration(minutes: 45));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Uyuyor'), findsOneWidget);
    await tester.tap(find.byKey(const Key('uyku_canli_dugme')));
    await tester.pumpAndSettle();
    final saved = parseSleepJournal(await SecureHealthStore.read(sleepJournalKey));
    expect(saved.single['end'], DateTime(2026, 11, 20, 13, 45).toIso8601String());
    expect(decodeSleepRunning(await SecureHealthStore.read(sleepRunningKey)), isEmpty);
    expect(SecureHealthStore.isAllowed(sleepRunningKey), isTrue);
  });

  test('son kayıttan bu yana geçen süre', () {
    final now = DateTime(2026, 11, 23, 12);
    final events = [
      {'tur': 'Beslenme', 'zaman': DateTime(2026, 11, 23, 9, 50).toIso8601String()},
      {'tur': 'Beslenme', 'zaman': DateTime(2026, 11, 23, 11, 15).toIso8601String()},
      {'tur': 'Bez değişimi', 'zaman': 'bozuk'},
      {'tur': 'Uyku', 'zaman': DateTime(2026, 11, 23, 13).toIso8601String()},
    ];
    expect(shortAgo(sinceLastEvent(events, 'Beslenme', now)!), '45 dk');
    expect(sinceLastEvent(events, 'Bez değişimi', now), isNull);
    expect(sinceLastEvent(events, 'Uyku', now), isNull);
    expect(shortAgo(const Duration(hours: 2, minutes: 10)), '2 sa 10 dk');
    expect(shortAgo(const Duration(days: 3)), '3 gün');
  });

  test('ıslak/kakalı bez sayımı ve yenidoğan beklentisi', () {
    final day = DateTime(2026, 11, 23, 18);
    String at(int h) => DateTime(2026, 11, 23, h).toIso8601String();
    final events = [
      {'tur': 'Bez değişimi', 'zaman': at(8), 'bez': 'Islak'},
      {'tur': 'Bez değişimi', 'zaman': at(10), 'bez': 'İkisi'},
      {'tur': 'Bez değişimi', 'zaman': at(12), 'bez': 'Kakalı'},
      {'tur': 'Bez değişimi', 'zaman': at(14)}, // eski kayıt: tür yok
      {'tur': 'Bez değişimi', 'zaman': DateTime(2026, 11, 22, 9).toIso8601String(), 'bez': 'Islak'},
      {'tur': 'Beslenme', 'zaman': at(9), 'bez': 'Islak'},
    ];
    final c = diaperCounts(events, day);
    expect(c.wet, 2);
    expect(c.dirty, 2);
    expect(expectedWetDiapers(DateTime(2026, 11, 21), day), 3);
    expect(expectedWetDiapers(DateTime(2026, 11, 10), day), 6);
    expect(expectedWetDiapers(DateTime(2026, 6, 1), day), isNull);
    expect(expectedWetDiapers(null, day), isNull);
  });

  test('gece/gündüz uyku ayrımı ve şekerleme sayısı', () {
    String iso(int d, int h, [int m = 0]) => DateTime(2026, 11, d, h, m).toIso8601String();
    final records = [
      {'start': iso(22, 20), 'end': iso(23, 6, 30)}, // gece 10 sa 30 dk
      {'start': iso(23, 6, 30), 'end': iso(23, 7, 30)}, // 30 dk gece + 30 dk gündüz
      {'start': iso(23, 13), 'end': iso(23, 14, 15)}, // şekerleme 75 dk
      {'start': iso(23, 16), 'end': iso(23, 16, 5)}, // 5 dk: şekerleme sayılmaz
      {'start': iso(20, 13), 'end': iso(20, 14)}, // başka gün
    ];
    final r = dayNightSleep(records, DateTime(2026, 11, 23, 20));
    expect(r.nightMinutes, 660);
    expect(r.dayMinutes, 110);
    expect(r.naps, 1);
  });

  test('son 24 saatte beslenme sayısı ve ortalama aralık', () {
    final now = DateTime(2026, 11, 23, 12);
    String at(DateTime d) => d.toIso8601String();
    final events = [
      {'tur': 'Beslenme', 'zaman': at(DateTime(2026, 11, 23, 6))},
      {'tur': 'Beslenme', 'zaman': at(DateTime(2026, 11, 23, 9))},
      {'tur': 'Beslenme', 'zaman': at(DateTime(2026, 11, 23, 11, 30))},
      {'tur': 'Beslenme', 'zaman': at(DateTime(2026, 11, 22, 8))}, // 24 saatten eski
      {'tur': 'Uyku', 'zaman': at(DateTime(2026, 11, 23, 10))},
    ];
    final s = last24hStats(events, 'Beslenme', now);
    expect(s.count, 3);
    expect(s.averageGap, const Duration(hours: 2, minutes: 45));
    expect(last24hStats(events, 'Uyku', now).averageGap, isNull);
  });

  test('yaklaşan aşı günü aynı gündeki aşıları gruplar', () {
    final birth = DateTime(2026, 10, 1);
    final next = nextVaccineVisit(birth, DateTime(2026, 11, 23))!;
    expect(next.date, DateTime(2026, 12, 1));
    expect(next.vaccines.map((v) => v.code), containsAll(['bcg_2', 'hex_2', 'pcv_2']));
    expect(nextVaccineVisit(birth, DateTime(2026, 12, 1))!.date, DateTime(2026, 12, 1));
    // 4. ay aşıları 60 günden uzakta: kart gösterilmez.
    expect(nextVaccineVisit(birth, DateTime(2026, 12, 2)), isNull);
    expect(nextVaccineVisit(birth, DateTime(2026, 12, 2), withinDays: 90)!.date, DateTime(2027, 2, 1));
  });
}
