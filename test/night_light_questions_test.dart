import 'package:anne_bebek/screens/night_light_page.dart';
import 'package:anne_bebek/screens/questions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('açık sorular numaralı listeye dönüşür, sorulanlar çıkar', () {
    final c = DateTime(2026, 11, 25);
    final items = [
      DoctorQuestion('1', 'Kakası yeşil, normal mi?', 'Bebeğim', c),
      DoctorQuestion('2', 'Demir ilacı ne zamana kadar?', 'Ben', c),
      DoctorQuestion('3', 'Aşıdan sonra ateş?', 'Bebeğim', c, asked: true),
    ];
    expect(openQuestionsText(items, (s) => s),
        'Doktoruma soracaklarım\n1. Kakası yeşil, normal mi?\n2. Demir ilacı ne zamana kadar? (Ben)');
  });

  testWidgets('gece ışığı dokunuşla parlaklık değiştirir ve renk seçilir', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) => Scaffold(body: TextButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const NightLightPage())),
        child: const Text('aç'))))));
    await tester.tap(find.text('aç'));
    await tester.pumpAndSettle();
    Color current() => (tester.widget<AnimatedContainer>(find.byType(AnimatedContainer)).decoration as BoxDecoration?)?.color
        ?? tester.widget<Container>(find.descendant(of: find.byType(AnimatedContainer), matching: find.byType(Container)).first).color!;
    expect(find.textContaining('uzun bas'), findsOneWidget);
    final before = current();
    await tester.tap(find.byKey(const Key('gece_isigi')));
    await tester.pumpAndSettle();
    expect(current(), isNot(before));
    expect(find.textContaining('uzun bas'), findsNothing);
    await tester.tap(find.byKey(const Key('gece_renk_2')));
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const Key('gece_isigi')));
    await tester.pumpAndSettle();
    expect(find.byType(NightLightPage), findsNothing);
    expect(nightLightColors.length, 3);
  });
}
