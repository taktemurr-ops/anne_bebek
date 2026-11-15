import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/baby_activity_catalog.dart';

void main() {
  test('572 age adaptations have unique ids and safe descriptions', () {
    final all = BabyActivityCatalog.all;
    expect(all.length, 572);
    expect(all.map((e) => e.id).toSet().length, 572);
    expect(all.every((e) => e.steps.isNotEmpty && e.safety.isNotEmpty && e.minMonth <= e.maxMonth), isTrue);
    expect(all.where((e) => e.minMonth == 0).length, 52);
  });
}
