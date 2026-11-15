import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/cycle_tracker.dart';

void main() {
  test('Boş veya hatalı kayıtlar ekranı bozmaz', () {
    expect(decodeCycleDates(null), isEmpty);
    expect(decodeCycleDates('bozuk json'), isEmpty);
    expect(decodeCycleDates('{}'), isEmpty);
  });

  test('Geçerli tarihler tekilleştirilir ve yeniden eskiye sıralanır', () {
    final dates = decodeCycleDates('["2024-01-01", "2024-03-01", "2024-01-01", 5, "gecersiz"]');
    expect(dates.length, 2);
    expect(dates.first.month, 3);
    expect(dates.last.month, 1);
  });
}
