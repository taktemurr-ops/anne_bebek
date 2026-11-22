import 'package:anne_bebek/screens/more_guides_pages.dart';
import 'package:anne_bebek/services/more_guides.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bakım konuları dolu', () {
    expect(babyCareHowTos.map((e) => e.name).toSet().length, babyCareHowTos.length);
    for (final h in babyCareHowTos) {
      expect(h.steps, isNotEmpty, reason: h.name);
    }
  });

  test('dil dönemleri yaşa göre seçilir', () {
    expect(speechStageFor(0).label, '0–3 ay');
    expect(speechStageFor(5).label, '4–6 ay');
    expect(speechStageFor(12).label, '7–12 ay');
    expect(speechStageFor(13).label, '12–18 ay');
    expect(speechStageFor(30).label, '2–3 yaş');
    expect(speechStageFor(100).label, '3–5 yaş');
    for (final s in speechStages) {
      expect(s.expect, isNotEmpty);
      expect(s.flags, isNotEmpty);
    }
  });

  test('korunma yöntemleri iki durum için de açıklamalı', () {
    for (final m in contraMethods) {
      expect(m.breastfeeding, isNotEmpty);
      expect(m.notBreastfeeding, isNotEmpty);
    }
  });

  testWidgets('bakım konusu değişir', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BabyCareHowToPage())));
    expect(find.text('Banyo'), findsWidgets);
    await tester.tap(find.byKey(const Key('bakim_1')));
    await tester.pump();
    expect(find.text('Göbek bakımı'), findsWidgets);
    await tester.scrollUntilVisible(find.textContaining('Alkol, pudra'), 200);
    expect(find.textContaining('Alkol, pudra'), findsOneWidget);
  });

  testWidgets('korunma sekmesi değişir', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: PostpartumContraceptionPage())));
    expect(find.textContaining('Ancak şu üç koşul'), findsOneWidget);
    await tester.tap(find.text('Emzirmiyorum'));
    await tester.pump();
    expect(find.textContaining('Emzirmiyorsan koruma sağlamaz'), findsOneWidget);
  });
}
