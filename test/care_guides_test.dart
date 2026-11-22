import 'package:anne_bebek/screens/care_guides_pages.dart';
import 'package:anne_bebek/services/care_guides.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('her konu dolu ve adlar tekil', () {
    for (final list in [sickBabyTopics, breastfeedingTopics]) {
      expect(list.map((e) => e.name).toSet().length, list.length);
      for (final c in list) {
        expect(c.intro, isNotEmpty);
        expect(c.home, isNotEmpty, reason: c.name);
        expect(c.doctor, isNotEmpty, reason: c.name);
      }
    }
  });

  test('kaka renkleri ve bez sayıları', () {
    expect(stoolColors.where((s) => s.level == 2).length, greaterThanOrEqualTo(2));
    expect(stoolColors.every((s) => s.level >= 0 && s.level <= 2), isTrue);
    expect(stoolLevelLabel(0), 'Normal');
    expect(stoolLevelLabel(2), 'Aynı gün doktora');
    expect(diaperByDay.length, 6);
  });

  test('acil belirti listeleri dolu', () {
    for (final l in [pregnancyUrgentSigns, pregnancySameDaySigns, postpartumUrgentSigns, postpartumSameDaySigns, formulaSteps, formulaDonts]) {
      expect(l, isNotEmpty);
    }
  });

  testWidgets('hasta bebek rehberinde konu değişir', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SickBabyGuidePage())));
    expect(find.text('Ateş'), findsWidgets);
    await tester.tap(find.byKey(const Key('konu_1')));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('İshal 1 haftadan uzun sürüyorsa'), 200);
    expect(find.text('İshal 1 haftadan uzun sürüyorsa'), findsOneWidget);
  });

  testWidgets('mama adımları işaretlenir ve sıfırlanır', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: FormulaPrepPage())));
    await tester.tap(find.byKey(const Key('mama_adim_0')));
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(find.byKey(const Key('mama_adim_0'))).value, isTrue);
    await tester.scrollUntilVisible(find.text('Yeni biberon için sıfırla'), 200);
    await tester.tap(find.text('Yeni biberon için sıfırla'));
    await tester.pump();
    await tester.scrollUntilVisible(find.byKey(const Key('mama_adim_0')), -200);
    await tester.pump();
    expect(tester.widget<CheckboxListTile>(find.byKey(const Key('mama_adim_0'))).value, isFalse);
  });

  testWidgets('doğum sonrası sekmesi', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PregnancyWarningSignsPage(postpartum: true))));
    expect(find.text('Saatte bir ped dolduran ya da artan kanama, büyük pıhtılar'), findsOneWidget);
  });
}
