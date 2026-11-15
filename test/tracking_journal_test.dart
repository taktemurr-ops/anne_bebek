import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/tracking_journal.dart';

void main() {
  test('Mama, emzirme ve kilo için sayı doğrulaması', () {
    expect(validJournalAmount('Mama', 120), isTrue);
    expect(validJournalAmount('Mama', -2), isFalse);
    expect(validJournalAmount('Emzirme', 15), isTrue);
    expect(validJournalAmount('Emzirme', 0), isFalse);
    expect(validJournalAmount('Kilo', 65.5), isTrue);
    expect(validJournalAmount('Kilo', double.nan), isFalse);
  });
  test('Son 7 gün özeti, geçersiz ve eski kayıtları dışlar', () {
    final now = DateTime(2026, 11, 1, 15);
    final entries = <Map<String, dynamic>>[
      {'type': 'Mama', 'date': '2026-11-01T12:00:00', 'amount': 120},
      {'type': 'Mama', 'date': '2026-10-26T00:00:00', 'amount': 90},
      {'type': 'Mama', 'date': '2026-10-25T23:59:59', 'amount': 50},
      {'type': 'Emzirme', 'date': '2026-10-30T09:00:00', 'amount': 20},
      {'type': 'Ek gıda', 'date': '2026-10-31T11:00:00'},
      {'type': 'Mama', 'date': '2026-11-02T12:00:00', 'amount': 100},
      {'type': 'Mama', 'date': 'bozuk', 'amount': 50},
      {'type': 'Mama', 'date': '2026-11-01T10:00:00', 'amount': -1},
    ];
    final summary = feedingSummary(entries, now);
    expect(summary.formulaMl, 210);
    expect(summary.formulaCount, 2);
    expect(summary.nursingMinutes, 20);
    expect(summary.nursingCount, 1);
    expect(summary.solidFoodCount, 1);
  });
  test('Bozuk JSON kaydı uygulamayı çökertmez', () {
    expect(decodeJournal('{bozuk'), isEmpty);
    expect(decodeJournal('null'), isEmpty);
    expect(decodeJournal('[{"type":"Mama","date":"2026-10-31T12:00:00"}]'), hasLength(1));
    expect(decodeJournal('[{"type":"Mama","date":"gecersiz"}]'), isEmpty);
  });
}
