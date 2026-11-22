import 'dart:convert';

import 'package:anne_bebek/screens/tracking_report_page.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:anne_bebek/services/tracking_report.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 11, 22, 12);

  test('tüm takip anahtarları güvenli depoda izinli', () {
    for (final d in trackerDefs) {
      expect(SecureHealthStore.isAllowed(d.key), isTrue, reason: d.key);
      expect(trackerSections, contains(d.section));
    }
  });

  test('liste kayıtları ve son tarih', () {
    final raw = jsonEncode([
      {'tur': 'Beslenme', 'zaman': '2026-11-22T08:00:00'},
      {'tur': 'Uyku', 'zaman': '2026-11-20T08:00:00'},
      {'tur': 'Beslenme', 'zaman': '2026-10-01T08:00:00'},
    ]);
    final s = summarizeTracker(trackerDefs.first, raw, now);
    expect(s.records, 3);
    expect(s.last7, 2);
    expect(s.last30, 2);
    expect(s.lastDate, DateTime(2026, 11, 22, 8));
    expect(careEventTotals(raw, now), {'Beslenme': 1, 'Uyku': 1});
  });

  test('çocuk bölümlü sözlük ve gelecekteki tarihler', () {
    final raw = jsonEncode({'main': {'m1': '2026-11-01', 'm2': '2026-11-15', 'm3': null}});
    final s = summarizeTracker(const TrackerDef('baby_milestones_v1', 'x', 'Bebek'), raw, now);
    expect(s.records, 2);
    expect(s.lastDate, DateTime(2026, 11, 15));
    final f = summarizeTracker(const TrackerDef('k', 'x', 'Anne'), jsonEncode([{'tarih': '2027-05-01'}]), now);
    expect(f.records, 1);
    expect(f.lastDate, isNull);
  });

  test('bozuk ya da boş kayıt güvenli', () {
    expect(summarizeTracker(trackerDefs.first, null, now).active, isFalse);
    expect(summarizeTracker(trackerDefs.first, '{bozuk', now).records, 1);
    expect(careEventTotals('{bozuk', now), isEmpty);
  });

  test('metin rapor bölümleri içerir', () {
    final list = [
      TrackerSummary(trackerDefs.first, records: 3, lastDate: now, last7: 2),
      TrackerSummary(trackerDefs.firstWhere((d) => d.section == 'Kadın'), records: 1),
    ];
    final text = buildTrackingReport(list, {'Beslenme': 2}, now, (s) => s);
    expect(text, contains('BEBEK'));
    expect(text, contains('KADIN'));
    expect(text, contains('Beslenme: 2'));
    expect(text, contains('22.11.2026'));
  });

  testWidgets('rapor sayfası kayıtları gösterir ve filtreler', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    await SecureHealthStore.write('olaylar', jsonEncode([{'tur': 'Beslenme', 'zaman': DateTime.now().toIso8601String()}]));
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: TrackingReportPage())));
    await tester.pumpAndSettle();
    expect(find.text('Son 7 günde bebek bakımı'), findsOneWidget);
    await tester.tap(find.byKey(const Key('rapor_filtre_Kadın')));
    await tester.pumpAndSettle();
    expect(find.text('Adet döngüsü'), findsOneWidget);
    expect(find.text('Büyüme ölçümleri'), findsNothing);
  });
}
