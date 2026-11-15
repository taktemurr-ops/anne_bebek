import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/child_care_plans.dart';

void main() {
  ChildCareItem item(String id, String child, DateTime date, {bool completed = false}) =>
      ChildCareItem(id: id, childId: child, category: 'Aşı', title: 'Kontrol',
        note: '', date: date, completed: completed);
  final today = DateTime(2026, 11, 1, 15, 30);
  test('Tarih karşılaştırması saati yok sayar', () {
    expect(careDueStatus(item('1','a',DateTime(2026,11,1,8)), today), CareDueStatus.today);
    expect(careDueStatus(item('2','a',DateTime(2026,10,31)), today), CareDueStatus.overdue);
    expect(careDueStatus(item('3','a',DateTime(2026,11,2)), today), CareDueStatus.upcoming);
    expect(careDueStatus(item('4','a',DateTime(2026,10,31), completed:true), today), CareDueStatus.completed);
  });
  test('Filtre farklı çocukların verilerini göstermez', () {
    final all = [item('1','a',DateTime(2026,10,31)), item('2','b',DateTime(2026,10,31)), item('3','a',DateTime(2026,11,2))];
    expect(filterCareItems(all, 'a', today, 'Geciken').map((e)=>e.id).toList(), ['1']);
    expect(filterCareItems(all, 'b', today, 'Geciken').map((e)=>e.id).toList(), ['2']);
  });
}
