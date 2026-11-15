import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/growth_analysis.dart';

void main() {
  test('Ölçümler tarihe göre sıralanır, geçersiz kayıtlar dışlanır', () {
    final rows = <Map<String, String>>[
      {'tarih': '2026-10-20T10:00:00', 'kilo': '9,8'},
      {'tarih': '2026-09-20T10:00:00', 'kilo': '9.2'},
      {'tarih': '2026-10-21T10:00:00', 'kilo': '-2'},
      {'tarih': '2026-11-03T10:00:00', 'kilo': '10.0'},
      {'tarih': 'bozuk', 'kilo': '10.0'},
    ];
    final points = growthSeries(rows, 'kilo', now: DateTime(2026, 11, 1));
    expect(points.length, 2);
    expect(points.first.value, 9.2);
    expect(points.last.value, 9.8);
    expect(growthChange(points, 'kg'), contains('+0.6 kg'));
  });

  test('Tek ölçümde fark hesaplanmaz; baş çevresi desteklenir', () {
    final points = growthSeries([
      {'tarih': '2026-10-20', 'basCevresi': '45.5'},
    ], 'basCevresi', now: DateTime(2026, 11, 1));
    expect(points.single.value, 45.5);
    expect(growthChange(points, 'cm'), contains('en az iki'));
  });
}
