import 'package:flutter_test/flutter_test.dart';
import 'package:anne_bebek/services/baby_activity_catalog.dart';

void main() {
  test('572 age adaptations have unique ids and safe descriptions', () {
    final all = BabyActivityCatalog.all;
    expect(BabyActivityCatalog.baseCount, 52);
    expect(BabyActivityCatalog.targetedCount, 44);
    expect(all.length, 572 + 44);
    expect(all.map((e) => e.id).toSet().length, all.length);
    for (var b = 0; b < BabyActivityCatalog.ageBands.length; b++) {
      expect(all.where((e) => e.id.startsWith('activity_age_') && e.minMonth == BabyActivityCatalog.ageBands[b].$1).length,
          greaterThanOrEqualTo(4));
    }
    expect(all.every((e) => e.steps.isNotEmpty && e.safety.isNotEmpty && e.minMonth <= e.maxMonth), isTrue);
    expect(all.where((e) => e.minMonth == 0).length, 52 + 4);
  });
}
