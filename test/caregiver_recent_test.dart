import 'package:anne_bebek/services/last_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bakıcı kartı için son 24 saatin son kayıtları', () {
    final now = DateTime(2026, 11, 25, 14, 0);
    final events = [
      {'tur': 'Beslenme', 'zaman': DateTime(2026, 11, 25, 11, 30).toIso8601String()},
      {'tur': 'Beslenme', 'zaman': DateTime(2026, 11, 25, 12, 45).toIso8601String()},
      {'tur': 'Uyku', 'zaman': DateTime(2026, 11, 24, 9).toIso8601String()},
      {'tur': 'Bez değişimi', 'zaman': DateTime(2026, 11, 25, 13, 50).toIso8601String()},
      {'tur': 'Bez değişimi', 'zaman': DateTime(2026, 11, 25, 15).toIso8601String()},
      {'tur': 'Beslenme', 'zaman': 'bozuk'},
    ];
    final recent = caregiverRecent(events, now);
    expect(recent.map((r) => '${r.type} ${r.time} ${r.ago}'),
        ['Beslenme 12:45 1 sa 15 dk', 'Bez değişimi 13:50 10 dk']);
    expect(caregiverRecent(const [], now), isEmpty);
  });
}
