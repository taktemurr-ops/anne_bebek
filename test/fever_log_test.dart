import 'package:anne_bebek/screens/fever_log_page.dart';
import 'package:anne_bebek/services/backup_service.dart';
import 'package:anne_bebek/services/fever_log.dart';
import 'package:anne_bebek/services/secure_health_store.dart';
import 'package:anne_bebek/tracking_journal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/secure_storage_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final t0 = DateTime(2026, 11, 21, 20);

  group('ateş eşikleri', () {
    test('3 aydan küçük bebekte 38 °C acil', () {
      expect(feverAdvice(38.1, 'Kulak', 2).level, FeverLevel.emergency);
      expect(feverAdvice(38.1, 'Kulak', 12).level, FeverLevel.fever);
    });
    test('koltuk altı ölçüm 0,5 °C düzeltilir', () {
      expect(feverAdvice(37.6, 'Koltuk altı', 12).level, FeverLevel.fever);
      expect(feverAdvice(37.6, 'Kulak', 12).level, FeverLevel.normal);
    });
    test('3–6 ay 39 °C doktor, her yaşta 40 °C acil, düşük ısı uyarısı', () {
      expect(feverAdvice(39.2, 'Alın', 4).level, FeverLevel.doctor);
      expect(feverAdvice(40.1, 'Kulak', 48).level, FeverLevel.emergency);
      expect(feverAdvice(34.8, 'Koltuk altı', 12).level, FeverLevel.low);
    });
    test('giriş doğrulama', () {
      expect(parseTemperature('38,4'), 38.4);
      expect(parseTemperature('384'), isNull);
      expect(parseTemperature('abc'), isNull);
    });
    test('uzun süren ateş ve son ilaç', () {
      final log = [
        FeverEntry(t0.subtract(const Duration(hours: 30)), temperature: 38.5, method: 'Kulak'),
        FeverEntry(t0.subtract(const Duration(hours: 10)), temperature: 38.9, method: 'Kulak', medicine: 'Ateş düşürücü 5 ml'),
        FeverEntry(t0.subtract(const Duration(hours: 1)), temperature: 38.2, method: 'Kulak'),
      ];
      final d = feverDuration(log, t0)!;
      expect(d.inHours, 30);
      expect(longFeverWarning(d, 10), isNotNull);
      expect(longFeverWarning(d, 36), isNull);
      final m = lastMedicine(log, t0)!;
      expect(m.medicine, 'Ateş düşürücü 5 ml');
      expect(m.since.inHours, 10);
      final withNormal = [...log, FeverEntry(t0.subtract(const Duration(hours: 5)), temperature: 37.0, method: 'Kulak')];
      expect(feverDuration(withNormal, t0)!.inHours, 1);
    });
    test('kodla-çöz döngüsü ve bozuk veri', () {
      final back = decodeFeverLog(encodeFeverLog([FeverEntry(t0, temperature: 38.0, medicine: 'X')]));
      expect(back.single.temperature, 38.0);
      expect(decodeFeverLog('[{"time":"x"}]'), isEmpty);
      expect(decodeFeverLog('{bozuk'), isEmpty);
    });
  });

  group('gebelik ölçümleri', () {
    test('tansiyon ve kan şekeri uyarıları', () {
      expect(pregnancyReadingWarning('Tansiyon', 120, 80), isNull);
      expect(pregnancyReadingWarning('Tansiyon', 142, 85), contains('yüksek'));
      expect(pregnancyReadingWarning('Tansiyon', 165, 100), contains('112'));
      expect(pregnancyReadingWarning('Kan şekeri', 60, null), contains('düşük'));
      expect(journalAmountText({'type': 'Tansiyon', 'amount': 140.0, 'amount2': 90.0}), '140/90 mmHg');
      expect(journalEntryWarning({'type': 'Tansiyon', 'amount': 150, 'amount2': 95}), isNotNull);
      expect(validJournalAmount('Süt sağma', 120), isTrue);
      expect(validJournalAmount('Küçük tansiyon', 200), isFalse);
    });
  });

  test('ateş kaydı güvenli depoda ve yedekte', () {
    expect(SecureHealthStore.isAllowed(FeverLogPage.storageKey), isTrue);
    expect(BackupService.keys, contains(FeverLogPage.storageKey));
  });

  testWidgets('ateş kaydı eklenir ve yaşa göre uyarı gösterilir', (tester) async {
    SharedPreferences.setMockInitialValues({});
    installSecureStorageMock();
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: FeverLogPage(
        birth: DateTime(2026, 10, 1), clock: () => t0))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ates_ekle')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('ates_derece')), '38,3');
    await tester.tap(find.byKey(const Key('ates_kaydet')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ates_uyari')), findsOneWidget);
    expect(find.textContaining('3 aydan küçük bebekte'), findsWidgets);
    final saved = decodeFeverLog(await SecureHealthStore.read(FeverLogPage.storageKey));
    expect(saved.single.temperature, 38.3);
  });
}
