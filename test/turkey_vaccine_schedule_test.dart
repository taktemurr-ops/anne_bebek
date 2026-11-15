import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/turkey_vaccine_schedule.dart';
void main() {
  test('Ay sonu doğumlarda tarih taşması engellenir', () {
    const dose = PlannedVaccine('a','A',1);
    expect(dose.dueDate(DateTime(2026,1,31)), DateTime(2026,2,28));
  });
  test('Altılı karma dozları listelenir', () {
    expect(standardVaccines.where((v) => v.code.startsWith('hex_')).length, 4);
  });
  test('2026 suçiçeği ikinci doz eşiği', () {
    final before = routineVaccinesForBirth(DateTime(2022, 8, 1));
    final after = routineVaccinesForBirth(DateTime(2022, 10, 1));
    expect(before.any((v) => v.code == 'var_48'), false);
    expect(after.any((v) => v.code == 'var_48'), true);
  });
  test('2026 yakalama grubu 49-72 ay', () {
    expect(mayNeedVaricellaCatchup(DateTime(2021, 11, 1), DateTime(2026, 11, 1)), true);
    expect(mayNeedVaricellaCatchup(DateTime(2024, 11, 1), DateTime(2026, 11, 1)), false);
  });
  test('Doğum Hepatit B aynı gün planlanır', () {
    expect(standardVaccines.first.dueDate(DateTime(2026,5,4)), DateTime(2026,5,4));
  });
}
