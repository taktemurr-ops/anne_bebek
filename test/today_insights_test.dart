import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/today_insights.dart';
void main() {
  test('bugün ve yedi günlük kayıtlar doğru sayılır', () {
    final now = DateTime(2026, 11, 1, 12);
    final events = [
      {'tur':'Beslenme','zaman':'2026-11-01T09:00:00'},
      {'tur':'Beslenme','zaman':'2026-10-30T09:00:00'},
      {'tur':'Beslenme','zaman':'2026-10-20T09:00:00'},
      {'tur':'Uyku','zaman':'2026-11-01T08:00:00'},
      {'tur':'Beslenme','zaman':'bozuk'},
    ];
    expect(TodayInsights.countToday(events, 'Beslenme', now), 1);
    expect(TodayInsights.countLastDays(events, 'Beslenme', now, 7), 2);
    expect(TodayInsights.countToday(events, 'Uyku', now), 1);
  });
  test('son ölçüm tarihe göre bulunur', () {
    final items = [{'tarih':'2026-01-01','kilo':'5'}, {'tarih':'2026-10-01','kilo':'9'}];
    expect(TodayInsights.latestMeasurement(items)?['kilo'], '9');
    expect(TodayInsights.latestMeasurement([]), isNull);
  });
  test('doktor özeti kaynak kayıtları ve uyarı içerir', () {
    final text = TodayInsights.report(babyName:'Ada', birth:DateTime(2025, 10, 1), events:[], measurements:[], now:DateTime(2026, 11, 1));
    expect(text, contains('Ada'));
    expect(text, contains('tanı veya klinik değerlendirme değildir'));
  });
}
