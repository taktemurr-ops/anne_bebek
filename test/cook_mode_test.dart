import 'package:anne_bebek/screens/cook_mode_page.dart';
import 'package:anne_bebek/services/cook_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Adımdaki süre bulunur', () {
    expect(stepMinutes('Kısık ateşte 20–25 dakika pişirin.'), 25);
    expect(stepMinutes('Fırında 40 dakika pişirin.'), 40);
    expect(stepMinutes('Önce 3 dakika kavurun, sonra 10 dakika pişirin.'), 10);
    expect(stepMinutes('Buzdolabında en az 2 saat dinlendirin.'), 120);
    expect(stepMinutes('1,5 saat mayalandırın.'), 90);
    expect(stepMinutes('Soğanı ince doğrayın.'), isNull);
    expect(formatCountdown(65), '01:05');
    expect(formatCountdown(3725), '1:02:05');
  });

  testWidgets('Pişirme modu: adımlar, zamanlayıcı ve malzemeler', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CookModePage(
        title: 'Deneme çorbası',
        ingredients: ['1 su bardağı mercimek', '1 soğan'],
        steps: ['Soğanı ince doğrayın.', 'Kısık ateşte 20–25 dakika pişirin.', 'Sıcak servis edin.'],
      ),
    ));
    expect(find.text('Adım 1 / 3'), findsOneWidget);
    expect(find.byKey(const ValueKey('cook_timer_0')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('cook_next')));
    await tester.pumpAndSettle();
    expect(find.text('Adım 2 / 3'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('cook_timer_1')));
    await tester.pump();
    expect(find.text('25:00'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('24:57'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cook_ingredients')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cook_ing_0')));
    await tester.pumpAndSettle();
    final box = tester.widget<CheckboxListTile>(find.byKey(const ValueKey('cook_ing_0')));
    expect(box.value, isTrue);

    // Zamanlayıcıyı kapatıp sayfayı temizle.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
